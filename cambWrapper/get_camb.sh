#! /bin/bash

if [ -z "$1" ]; then
  URL=http://camb.info/
  FILE=CAMB.tar.gz
  
  echo trying do get $FILE from $URL

  cat CAMB_LICENSE
  
  while true; do
    read -e -p "Do you agree?: " -i "yes" yn
    case $yn in
        [Yy]* ) wget $URL$FILE; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done

else
  FILE=$1
fi

if [ ! -f $FILE ]; then
echo $FILE is not a file.
  exit 1
fi

tar -xzvf $FILE