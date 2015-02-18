#!/bin/zsh
# batch resize by convert with '-geometry' option

USAGE="Usage: "`basename $0`"
 options:
  -t: target directory
  -s: target size (e.g. 500x300), default 300x300
  -v: verbose output
  -p: prefix for resized file name, default 'mini_'
  -f: force resize
  -i: test output (not resize)
  -h: show this message"

# defaults
target='.'
size='300x300'
prefix="mini_"
verbose=false
force=false
is_test=false

while getopts :t:s:p:vfih option
do
  case $option in
    t)
      target=$OPTARG;;
    s)
      size=$OPTARG;;
    p)
      prefix=$OPTARG;;
    v)
      verbose=true;;
    f)
      force=true;;
    i)
      is_test=true;;
    h)
      echo $USAGE
      exit 0;;
    \?)
      echo "$0: invalid option -$OPTARG" >&2
      echo $USAGE
      exit 1;;
  esac
done

if $force; then
  size=$size!
fi

fnames=(`find $target -iregex '.*jpg' -or -iregex '.*png'`)

for fname in $fnames; do
  arr=(`echo $fname | tr -s '/' ' '`)
  input=$fname
  output=`echo $arr[1,$#arr-1] | tr -s ' ' '/'`'/'$prefix$arr[-1]
  if $verbose || $is_test; then
    echo $input '=>' $output
  fi
  if ! $is_test; then
    convert -geometry $size $input $output
  fi
done
