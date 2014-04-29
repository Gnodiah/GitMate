#! /bin/bash

# Stastistic changed code lines per author per day
git remote update -p > /dev/null
git log --format='%aN' | sort -u > git_authors
today=`date --date='4 days ago' +%m/%d/%Y`

while read line
do
  echo -n $line":    "
  git log --numstat --pretty=format:"%H" --date=short --all --after="$today 00:00" --before="$today 23:59" --author="$line" | awk 'NF==3 {plus+=$1; minus+=$2;} END {printf("=%d, +%d, -%d\n", (plus+minus), plus, minus)}'
done < git_authors
