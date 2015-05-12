#! /bin/bash

if [ -z "$1" ]; then
  URL=http://lambda.gsfc.nasa.gov/data/map/dr4/dcp/
  FILE=wmap_likelihood_sw_v4p1.tar.gz
  
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

patch -d likelihood_v4p1 -p0 < WMAP_7yr_options.diff