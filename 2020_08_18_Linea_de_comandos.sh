 https://itam.zoom.us/my/unanue

 ##
 > UFO-Dic-2014.tsv cut -f1,3 | tr '\t' ' ' | cut -d ' ' -f1,3 | sort -k 2 -k 1 | uniq -c | sort -n -r -k 1 | head -10

 ##
 python -m http.server 8888
 python -m http.server 8888 &


## utf
iconv -f ISO-8859-15 -t utf-8 UFO-Nov-2014.tsv > ~/clean.txt

## curl
curl -I http://www.gutenberg.org

## g rep
grep -v "18:" UFO-Dic-2014.tsv | wc -l
grep -E "18:|19:|20:" UFO-Dic-2014.tsv
grep -o -E "[Bb]lue|[Oo]range" UFO-Dic-2014.tsv | tr -s '[:upper:]' '[:lower:]' | sort | uniq -c
grep -E "[0-9]{2}" UFO-Dic-2014.tsv | grep "12/13" | tee ocurrio.txt | wc -l
grep -vE "[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}" UFO-Dic-2014.tsv 

## awk
awk -F"[\t]" '/blue/ {print $3 $1}' ufo/UFO-Nov-2014.tsv 
awk '{sum += $1} END {print "SUMA: "sum }' numbers.dat
awk -F',' '{sum1 += $1, sum2 += $2} END {print sum1, sum2}' numbers.dat  #tiene error
awk -F"[\t]" '/minutes/ {print $5}' UFO-Nov-2014.tsv | awk '{sum += $1/60} END {print sum " horas"}'
awk 'BEGIN{ FS="\t"};{if(NF !=7) {print >> "UFO_fixme.tsv"} else {print >> "UFO_OK.tsv"} }' UFO-Nov-2014.tsv
awk 'END { print NR }' UFO-Nov-2014.tsv
awk -F"[\t]" -f minutes_to_hours.awk UFO_OK.tsv

## sed
sed [banderas] comando/patron/[reemplazo]/[modificador] [archivo]
sed 's/foo/bar/' data3.txt
sed '3!s/foo/bar/' data3.xt
sed '/123/s/foo/bar/' data3.txt

# Columnar, sperarda por '|', muchas columnas, muy peado (~400Mb) y ademas tiene informacion confidencial, 
# tiene un id unico Sustituir id unico, agregarle un nuevo id de preferencia numerico,
# seleccionar solo unas columnas y guardarlo en un nuevo archivo que podamos subir en R
< UFO-Nov-2014.tsv awk -F"\t" 'BEGIN{OFS="|"} !/Date/ {print $3, $4, $5}' | sort -R | awk -F"|" '{print NR "|" $0}' > limpios.psv
