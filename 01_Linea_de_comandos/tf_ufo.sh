 < todos.psv cut -d '|' -f7 | tr -s '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | tr -d '[:punct:]+' | sort | uniq -c | sort -n -r -k 1 | head -n 10