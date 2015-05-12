#! /bin/bash

if [ -z "$1" ]; then
  URL=http://lambda.gsfc.nasa.gov/data/map/dr2/dcp/
  FILE=wmap_likelihoodcode_sw_only_v2p2p2.tar.gz
  
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

patch -d wmap_likelihoodcode_v2p2p2 -p0 < WMAP_3yr_options.diff

patch -d wmap_likelihoodcode_v2p2p2 -p0 < WMAP_3yr_teeebb_pixlike.diff

patch -d wmap_likelihoodcode_v2p2p2 -p0 < WMAP_3yr_tt_pixlike.diff

patch -d wmap_likelihoodcode_v2p2p2 -p0 < Makefile.diff