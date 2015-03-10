mkdir -p clean
files=$(find CMS.631-s15-Favorite-Restaurants -name "*.csv" -exec echo -n "{} " \;)
for f in $files; do sed 's/\", /\",/g' $f | csvformat -U 1 > data/${f:33}; done
csvstack -u 1 $(find data -type f -exec echo -n "{} " \;) > restaurants.csv