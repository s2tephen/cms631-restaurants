mkdir -p data
files=$(find CMS.631-s15-Favorite-Restaurants -name '*.csv' -exec echo -n '{} ' \;)
for f in $files; do sed -e 's/\", /\",/g' -e 's/”/\"/g' -e '/^$/d' $f | csvformat -U 1 | sed 's/" /"/g' > data/${f:33}; done
csvstack $(find data -type f -exec echo -n '{} ' \;) > restaurants.csv
csvcut -c 3 restaurants.csv | csvformat -M , | sed -e 's/address,//g' -e 's/.$//' -e 's/^/[/' -e 's/$/]/' | curl -X POST -d @- 'http://www.datasciencetoolkit.org/street2coordinates' | jq -c '.[] | {latitude, longitude}' | json2csv -k latitude,longitude -p > addresses.csv
csvjoin restaurants.csv addresses.csv | csvjson --lat latitude --lon longitude --k restaurant --crs EPSG:4269 -i 2