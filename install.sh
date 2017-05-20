#!/bin/bash

for source in *.sh
do
  target=`echo $source | cut -d '.' -f 1`
  ln -s $(pwd)/$source /usr/local/bin/$target 2>/dev/null
  if [ $? -eq 0 ];then
    echo "installed $target"
  else
    echo "skipped $target"
  fi
done
