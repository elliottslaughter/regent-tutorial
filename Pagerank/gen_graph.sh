#!/bin/bash

[ $# -gt 0 ] || exit -1

NUM_PAGES=`head -1 "$1"`
NUM_LINKS=`head -2 "$1" | tail -1`
OUTPUT=`echo "$1" | sed s/".dat"/".pdf"/g`
TMP=$(mktemp)
echo 'digraph G { rankdir="LR";' > "$TMP"
tail -"$NUM_LINKS" "$1" | sed s/"[ \t]"/"->"/ | sed s/"$"/";"/ >> "$TMP"
echo '}' >> "$TMP"
dot -Tpdf -o"$OUTPUT" "$TMP"
rm "$TMP"
