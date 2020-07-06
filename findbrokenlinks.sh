#!/bin/bash
#set -x

if [ ! -d "content" ]; then
	echo "You should execute this script from website/ directory."
	exit 1
fi

OUTPUT=$(dirname `pwd`)
CURDIR=$PWD

# Remove the previous output files
rm $OUTPUT/redirects.txt
rm $OUTPUT/brokenlinks*.txt

cd content/ko
FILELIST=$(find docs -name '*.md' -type f -print | sed -e 's/^.\///g' -e 's/.md$/\//g' -e 's/_index\///g')

for kofile in $FILELIST
do
  echo " " >> $OUTPUT/brokenlinks.txt
  echo " " >> $OUTPUT/brokenlinks.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks.txt
  echo "=== /ko/$kofile " >> $OUTPUT/brokenlinks.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks.txt
  grep -nir "(/$kofile[)#]" docs >> $OUTPUT/brokenlinks.txt
  echo "-----------------------------------------------------------------------------------------------" >> $OUTPUT/brokenlinks.txt

  TFILE=$(grep -nr "(/$kofile#" docs | awk -F: '{print $1":"$2}' | tr '\n' ' ')
  for tfile in $TFILE
  do
    LNO=$(echo $tfile | awk -F: '{print $2}')
    TFF=$(echo $tfile | awk -F: '{print $1}')

    echo "" >> $OUTPUT/brokenlinks.txt
    echo "------ /ko/$TFF @$LNO ::" >> $OUTPUT/brokenlinks.txt
    awk -v a=$LNO 'NR==a' $TFF | grep "(/$kofile#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/^/\//g' -e 's/)$//g' >> $OUTPUT/brokenlinks.txt
    echo "" >> $OUTPUT/brokenlinks.txt

    echo "------ Anchor of /ko/$kofile ::" >> $OUTPUT/brokenlinks.txt
    URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep "(/$kofile#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/)$//g' | awk -F'#' '{print $1}')
    if [ "$URLFILE" == "docs/concept/" ] || [ "$URLFILE" == "docs/contribute/" ] || [ "$URLFILE" == "docs/tasks/" ] || [ "$URLFILE" == "docs/setup/" ] || [ "$URLFILE" == "docs/reference/" ] || [ "$URLFILE" == "docs/tutorials/" ]; then
        URLFILE2=$(echo $URLFILE | sed -e 's/$/_index.md/')
    else
        URLFILE2=$(echo $URLFILE | sed -e 's/\/$/.md/')
    fi
    grep "^#" $URLFILE2 | egrep -v "{{%|^#include" | awk '{print tolower($0)}' | sed -e 's/[[:blank:]]$//g' | sed -e 's/^.#* /#/' -e 's/ {#/::{#/' -e 's/ /-/g' -e 's/(/-/g' -e 's/)$//g' -e 's/)/-/g' -e 's/?$//' >> $OUTPUT/brokenlinks.txt
    echo "-------------------------------------------------------------------------------------------" >> $OUTPUT/brokenlinks.txt
  done
done

# For redirects

FILELIST_RD=$(find docs -name '*.md' -type f -print | sed -e 's/^.\///g' | egrep -v "_index" | sed -e 's/.md$/\//g')

for kofile in $FILELIST_RD
do
  grep " /$kofile 301" $CURDIR/static/_redirects >> $OUTPUT/redirects.txt
done

# For exceptional cases
echo "/docs/user-guide/kubectl-overview/" >> $OUTPUT/redirects.txt
echo "/docs/user-guide/kubectl-cheatsheet/" >> $OUTPUT/redirects.txt

FILELIST_RD2=$(cat $OUTPUT/redirects.txt | awk '{print $1":"$2}')

for kofile in $FILELIST_RD2
do
  RDDIR=$(echo $kofile | awk -F: '{print $1}')
  KODIR=$(echo $kofile | awk -F: '{print $2}')

  echo " " >> $OUTPUT/brokenlinks-rd.txt
  echo " " >> $OUTPUT/brokenlinks-rd.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks-rd.txt
  echo "=== $RDDIR " >> $OUTPUT/brokenlinks-rd.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks-rd.txt
  grep -nir "($RDDIR[)#]" docs >> $OUTPUT/brokenlinks-rd.txt
  echo "-----------------------------------------------------------------------------------------------" >> $OUTPUT/brokenlinks-rd.txt

  TFILE=$(grep -nr "($RDDIR#" docs | awk -F: '{print $1":"$2}' | tr '\n' ' ')
  for tfile in $TFILE
  do
    LNO=$(echo $tfile | awk -F: '{print $2}')
    TFF=$(echo $tfile | awk -F: '{print $1}')

    echo "" >> $OUTPUT/brokenlinks-rd.txt
    echo "------ /ko/$TFF @$LNO ::" >> $OUTPUT/brokenlinks-rd.txt
    awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/^/\//g' -e 's/)$//g' >> $OUTPUT/brokenlinks-rd.txt
    echo "" >> $OUTPUT/brokenlinks-rd.txt

    echo "------ Anchor of /ko$KODIR ::" >> $OUTPUT/brokenlinks-rd.txt
    URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/^\///' -e 's/)$//g' | awk -F'#' '{print $1}')
    if [ "$URLFILE" == "docs/concept/" ] || [ "$URLFILE" == "docs/contribute/" ] || [ "$URLFILE" == "docs/tasks/" ] || [ "$URLFILE" == "docs/setup/" ] || [ "$URLFILE" == "docs/reference/" ] || [ "$URLFILE" == "docs/tutorials/" ]; then
    	KODIR2=$(echo $KODIR | sed -e 's/^\///' -e 's/$/_index.md/')
    else
    	KODIR2=$(echo $KODIR | sed -e 's/^\///' -e 's/\/$/.md/')
    fi
    grep "^#" $KODIR2 | egrep -v "{{%|^#include" | awk '{print tolower($0)}' | sed -e 's/[[:blank:]]$//g' | sed -e 's/^.#* /#/' -e 's/ {#/::{#/' -e 's/ /-/g' -e 's/(/-/g' -e 's/)$//g' -e 's/)/-/g' -e 's/?$//' >> $OUTPUT/brokenlinks-rd.txt
    echo "-------------------------------------------------------------------------------------------" >> $OUTPUT/brokenlinks-rd.txt
  done
done

echo "Check the brokenlinks.txt and brokenlinks-rd.txt files in $OUTPUT directory."
exit
