#!/bin/bash

main() {
  local force=0
  if [[ -n $1 && $1 = '--force' ]]; then
    force=1
  fi

  for source in $(ls | grep -v '^install' | grep -v 'doc' | grep -v 'README')
  do
    # remove .sh ext
    target=`echo $source | cut -d '.' -f 1`
    if [ 1 -eq $force ]; then
      ln -sf $(pwd)/$source /usr/local/bin/$target 2>/dev/null
    else
      ln -s $(pwd)/$source /usr/local/bin/$target 2>/dev/null
    fi

    if [ $? -eq 0 ];then
      echo "installed $target"
    else
      echo "skipped $target"
    fi
  done
}

main $*
