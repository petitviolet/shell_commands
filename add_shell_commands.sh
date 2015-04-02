#!/bin/bash

for source in *.sh
do
  target=`echo $source | cut -d '.' -f 1`
  ln -s $(pwd)/$source /usr/local/bin/$target
done
