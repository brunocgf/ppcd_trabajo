#!/bin/bash

< todos.psv cut -d '|' -f7 | tr -s '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | tr -d '[:punct:]+' | sort | uniq -c | sort -n -r -k 1 | head -n 10

< todos.psv cut -d '|' -f2 | cut -d " " -f1 | cut -d '/' -f1,3 | awk -F"/" 'BEGIN{y = 1900}{if ($2<50) {print 200000+$2*100+$1} else {print 190000+$2*100+$1}}' | sort | uniq -c | gnuplot -p -e "plot '<cat' using 2:1 with lines"

