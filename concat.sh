mkdir -p data
files=$(find CMS.631-s15-Favorite-Restaurants -name "*.csv" -exec echo -n "{} " \;)
for f in $files; do sed -e 's/\", /\",/g' -e 's/”/\"/g' -e '/^$/d' $f | csvformat -U 1 > data/${f:33}; done
csvstack $(find data -type f -exec echo -n "{} " \;) > restaurants.csv