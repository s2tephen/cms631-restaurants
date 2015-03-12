# create directory for cleaned data, temporary marker file
mkdir -p data
echo -e 'marker-symbol\nrestaurant' > marker.csv

# get source files
files=$(find CMS.631-s15-Favorite-Restaurants -name '*.csv' -exec echo -n '{} ' \;)
for f in $files
do
  # make formatting consistent
  sed -e 's/\", /\",/g' -e 's/”/\"/g' -e '/^$/d' $f | csvformat -U 1 | sed 's/" /"/g' > data/${f:33}
  
  # get lat/long/marker, join into csv
  curl 'http://maps.googleapis.com/maps/api/geocode/json?address='+$(csvcut -c 3 data/${f:33} | tail -n +2 | sed -e 's/"//g' -e 's/ /+/g') | jq -c '.results | .[] | .geometry.location' | json2csv -k lat,lng -p | csvjoin data/${f:33} - marker.csv > temp.csv
  mv temp.csv data/${f:33}
done

# remove marker file
rm marker.csv

# combine csvs, convert to geojson
csvstack $(find data -type f -exec echo -n '{} ' \;) > restaurants.csv
csvjson restaurants.csv --lat lat --lon lng -i 2 > restaurants.geojson
