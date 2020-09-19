#!/bin/bash
#set -x

if [ ! -d "content" ]; then
        echo "ERROR::"
	echo "You should execute this script from website/ directory."
	exit 1
fi

if [ -z "$1" ]; then
        echo "ERROR::"
	echo "You should specify the localization code like 'ko'."
	echo "Usage: $(basename $0) <l10n code>"
	exit 1
fi

OUTPUT=$(dirname `pwd`)
CURDIR=$PWD

# Remove the previous output files
rm $OUTPUT/redirects.txt 2> /dev/null
rm $OUTPUT/foundlinks*.txt 2> /dev/null
rm /tmp/fbl* 2> /dev/null

cd content/$1

find docs -name '*.md' -type f -print > /tmp/fbl$$
FILELIST=$(cat /tmp/fbl$$ | grep -v "_index.md" | sed -e 's/^.\///g' -e 's/.md$//g')
INDEXFILELIST=$(cat /tmp/fbl$$ | grep "_index.md" | sed -e 's/^.\///g' -e 's/.md$//g' -e 's/\/_index//g')

echo "Finding l10n document links... (index.md file)"

for koindexfile in $INDEXFILELIST
do

  FOUND=$(grep -nir "(/$koindexfile/)" docs | wc -l)

  if [ $FOUND -gt 0 ]; then
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-$1.txt
    echo "=== /$1/$koindexfile/ " >> $OUTPUT/foundlinks-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-$1.txt
    grep -nir "(/$koindexfile/)" docs >> $OUTPUT/foundlinks-$1.txt
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo "-----------------------------------------------------------------------------------------------" >> $OUTPUT/foundlinks-$1.txt
  fi
done

echo "Finding l10n document links..."

for kofile in $FILELIST
do

  FOUND=$(grep -nir "(/$kofile[/)#]" docs | wc -l)

  if [ $FOUND -gt 0 ]; then
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-$1.txt
    echo "=== /$1/$kofile/ " >> $OUTPUT/foundlinks-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-$1.txt
    grep -nir "(/$kofile[/)#]" docs >> $OUTPUT/foundlinks-$1.txt
    echo " " >> $OUTPUT/foundlinks-$1.txt
    echo "-----------------------------------------------------------------------------------------------" >> $OUTPUT/foundlinks-$1.txt

    TFILE=$(grep -nrE "\(/$kofile(/#|#)" docs | awk -F: '{print $1":"$2}' | tr '\n' ' ')
    for tfile in $TFILE
    do
	  # Line Number of the link
      LNO=$(echo $tfile | awk -F: '{print $2}')
	  # The full path of file contains the link
      TFF=$(echo $tfile | awk -F: '{print $1}')

      echo "" >> $OUTPUT/foundlinks-$1.txt
      echo "------ /$1/$TFF @ line $LNO ::" >> $OUTPUT/foundlinks-$1.txt
      awk -v a=$LNO 'NR==a' $TFF | grep -E "\(/$kofile(/#|#)" | sed 's/.*](//;s/).*//' | sed -e 's/)$//g' >> $OUTPUT/foundlinks-$1.txt
      echo "" >> $OUTPUT/foundlinks-$1.txt
  
      echo "------ Select one of the following anchors of /$1/$kofile/ ::" >> $OUTPUT/foundlinks-$1.txt
      URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep -E "\(/$kofile(/#|#)" | sed -e 's/.*](//;s/).*//' -e 's/^\///' | awk -F'#' '{print $1}' | sed -e 's/\/$//' -e 's/$/.md/')

      grep "^#" $URLFILE | egrep -v "{{%|^#include" | awk '{print tolower($0)}' | sed -e 's/[[:blank:]]$//g' | sed -e 's/^.#* /#/' -e 's/ {#/::{#/' -e 's/ /-/g' -e 's/(/-/g' -e 's/)$//g' -e 's/)/-/g' -e 's/?$//' >> $OUTPUT/foundlinks-$1.txt
      echo "-------------------------------------------------------------------------------------------" >> $OUTPUT/foundlinks-$1.txt
    done
  fi
done

echo "done."
echo ""


# For redirects

FILELIST_RD=$(cat /tmp/fbl$$ | sed -e 's/^.\///g' | egrep -v "_index" | sed -e 's/.md$/\//g')
NOFILES_RD=$(cat /tmp/fbl$$ | wc -l)

echo "Finding l10n document links with _redirects..."

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

  FOUND=$(grep -nir "($RDDIR[)#]" docs | wc -l)

  if [ $FOUND -gt 0 ]; then
    echo " " >> $OUTPUT/foundlinks-rd-$1.txt
    echo " " >> $OUTPUT/foundlinks-rd-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-rd-$1.txt
    echo "=== $RDDIR " >> $OUTPUT/foundlinks-rd-$1.txt
    echo "===============================================================================================" >> $OUTPUT/foundlinks-rd-$1.txt
    grep -nir "($RDDIR[)#]" docs >> $OUTPUT/foundlinks-rd-$1.txt
    echo "-----------------------------------------------------------------------------------------------" >> $OUTPUT/foundlinks-rd-$1.txt

    TFILE=$(grep -nr "($RDDIR#" docs | awk -F: '{print $1":"$2}' | tr '\n' ' ')
    for tfile in $TFILE
    do
      LNO=$(echo $tfile | awk -F: '{print $2}')
      TFF=$(echo $tfile | awk -F: '{print $1}')

      echo "" >> $OUTPUT/foundlinks-rd-$1.txt
      echo "------ /$1/$TFF @$LNO ::" >> $OUTPUT/foundlinks-rd-$1.txt
      #awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/^/\//g' -e 's/)$//g' >> $OUTPUT/foundlinks-rd-$1.txt
      awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed 's/.*](//;s/).*//' | sed -e 's/^\///' >> $OUTPUT/foundlinks-rd-$1.txt
      URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep "(/$kofile#" | sed 's/.*](//;s/).*//' | sed -e 's/^\///' | awk -F'#' '{print $1}')
      echo "" >> $OUTPUT/foundlinks-rd-$1.txt

      echo "------ Anchor of /${1}$KODIR ::" >> $OUTPUT/foundlinks-rd-$1.txt
      #URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed -n "s/^.*(\/\s*\(\S*)\).*$/\1/p" | sed -e 's/^\///' -e 's/)$//g' | awk -F'#' '{print $1}')
      URLFILE=$(awk -v a=$LNO 'NR==a' $TFF | grep "($RDDIR#" | sed 's/.*](//;s/).*//' | sed -e 's/^\///' | awk -F'#' '{print $1}')
      if [ "$URLFILE" == "docs/concept/" ] || [ "$URLFILE" == "docs/contribute/" ] || [ "$URLFILE" == "docs/tasks/" ] || [ "$URLFILE" == "docs/setup/" ] || [ "$URLFILE" == "docs/reference/" ] || [ "$URLFILE" == "docs/tutorials/" ]; then
      	  KODIR2=$(echo $KODIR | sed -e 's/^\///' -e 's/$/_index.md/')
      else
    	  KODIR2=$(echo $KODIR | sed -e 's/^\///' -e 's/\/$/.md/')
      fi
      grep "^#" $KODIR2 | egrep -v "{{%|^#include" | awk '{print tolower($0)}' | sed -e 's/[[:blank:]]$//g' | sed -e 's/^.#* /#/' -e 's/ {#/::{#/' -e 's/ /-/g' -e 's/(/-/g' -e 's/)$//g' -e 's/)/-/g' -e 's/?$//' >> $OUTPUT/foundlinks-rd-$1.txt
      echo "-------------------------------------------------------------------------------------------" >> $OUTPUT/foundlinks-rd-$1.txt
    done
  fi
done

echo "done."
echo ""

rm /tmp/fbl$$ 2> /dev/null

echo "Check the foundlinks-$1.txt and foundlinks-rd-$1.txt files in $OUTPUT directory."
exit
