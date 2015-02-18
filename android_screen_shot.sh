#!/bin/sh
# android screenshot shortcut command


DATE_TIME=`date +"%Y%m%d-%H%M%S"`
FILE_NAME=${DATE_TIME}.png

TARGET_PATH="./"
SIZE="x480"

USAGE="
Usage: "`basename $0`" -t [target_path] -s [size]\n
options\n
  -t: local file path for screen shot\n
  -s: compress rate, using convert"

while getopts ht:s: option
do
  case $option in
    h)
      echo $USAGE
      exit 0;;
    t)
      TARGET_PATH=$OPTARG;;
    s)
      SIZE=$OPTARG;;
    \?)
      echo $USAGE
      exit 1;;
  esac
done

mkdir -p $TARGET_PATH
adb shell screencap -p /sdcard/$FILE_NAME
adb pull /sdcard/$FILE_NAME
adb shell rm /sdcard/$FILE_NAME
convert -resize $SIZE $FILE_NAME $FILE_NAME
mv ./$FILE_NAME $TARGET_PATH
echo screenshot saved to $TARGET_PATH/$FILE_NAME
