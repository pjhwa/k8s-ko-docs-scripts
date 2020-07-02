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
FILELIST=$(find . -type f -print | sed -e 's/^.\///g' | egrep -v "^OWNERS|.html|.yaml|.png|^_common|^include" | grep ".md" | sed -e 's/.md$/\//g' -e 's/_index\///g')

for kofile in $FILELIST
do
  echo " " >> $OUTPUT/brokenlinks.txt
  echo " " >> $OUTPUT/brokenlinks.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks.txt
  echo "=== /ko/$kofile " >> $OUTPUT/brokenlinks.txt
  echo "===============================================================================================" >> $OUTPUT/brokenlinks.txt
  grep -nir "(/$kofile[)#]" docs >> $OUTPUT/brokenlinks.txt
done

# For redirects

FILELIST_RD=$(find . -type f -print | sed -e 's/^.\///g' | egrep -v "^OWNERS|.html|.yaml|.png|^_common|^include|_index" | grep ".md" | sed -e 's/.md$/\//g')

for kofile in $FILELIST_RD
do
  grep " /$kofile 301" $CURDIR/static/_redirects >> $OUTPUT/redirects.txt
done

# For exceptional cases
echo "/docs/user-guide/kubectl-overview/" >> $OUTPUT/redirects.txt
echo "/docs/user-guide/kubectl-cheatsheet/" >> $OUTPUT/redirects.txt

FILELIST_RD2=$(cat $OUTPUT/redirects.txt | awk '{print $1}')

for kofile in $FILELIST_RD2
do
  echo " " >> $OUTPUT/brokenlinks-rd.txt
  echo " " >> $OUTPUT/brokenlinks-rd.txt
  echo "======================================================" >> $OUTPUT/brokenlinks-rd.txt
  echo "=== $kofile " >> $OUTPUT/brokenlinks-rd.txt
  echo "======================================================" >> $OUTPUT/brokenlinks-rd.txt
  grep -nir "($kofile[)#]" docs >> $OUTPUT/brokenlinks-rd.txt
done

echo "Check the brokenlinks.txt and brokenlinks-rd.txt files in $OUTPUT directory."
exit
