#!/usr/local/bin/zsh
# replace multibyte period(。) to (．) and comma(、) to (，)

if [ $# -eq 1 ]; then
  target=$1
  sed -i '' -e 's/、/，/g' $target
  sed -i '' -e 's/。/．/g' $target
else
  find . -name './*.tex' -print0 | xargs -0 sed -i '' -e 's/、/，/g'
  find . -name './*.tex' -print0 | xargs -0 sed -i '' -e 's/。/．/g'
fi
exit 0
