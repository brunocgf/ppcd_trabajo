awk -F"|" '/minutes/ {split($6,a," "); print a[1]}' todos.psv |
grep -oE '^[[:digit:]]+$' |
awk 'BEGIN{a = 100}{if ($1<a) a=$1 fi} END{print "min: " a " minutos"}'

awk -F"|" '/minutes/ {split($6,a," "); print a[1]}' todos.psv |
grep -oE '^[[:digit:]]+$' |
awk 'BEGIN{a = 0}{if ($1>a) a=$1 fi} END{print "max: " a " minutos"}'

awk -F"|" '/minutes/ {split($6,a," "); print a[1]}' todos.psv |
grep -oE '^[[:digit:]]+$' |
awk '{sum += $1; n ++} END {print sum/n " minutos"}'