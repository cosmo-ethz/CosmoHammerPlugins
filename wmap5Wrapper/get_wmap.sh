#! /bin/bash

if [ -z "$1" ]; then
  URL=http://lambda.gsfc.nasa.gov/data/map/dr3/dcp/
  FILE=wmap_likelihood_full_v3p2.tar.gz
  
  echo trying do get $FILE from $URL
  wget $URL$FILE
  
else
  FILE=$1
fi

if [ ! -f $FILE ]; then
echo $FILE is not a file.
  exit 1
fi

tar -xzvf $FILE

patch -d likelihood_v3 -p0 < WMAP_5yr_options.diff

patch -d likelihood_v3 -p0 < WMAP_5yr_teeebb_pixlike.diff


