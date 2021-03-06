#!/bin/bash -eux

AWS_PROFILE=${AWS_PROFILE:-"s3"}

BUCKET_NAME=${BUCKET_NAME:-"petitviolet"}
S3DIRECTORY=${S3DIRECTORY:-"public/image"}
DOMAIN=${DOMAIN:-"static.petitviolet.net"}

remove_exif() {
  /usr/local/bin/exiftool -all= $1
  if [ -e $1_original ]; then
    rm $1_original
  fi
}

build_s3_file_path() {
  echo "s3://$(echo "${BUCKET_NAME}/${S3DIRECTORY%/}/$(basename $1)" | sed -e 's/\/\//\//g')"
}

s3_upload() {
  local target=$1
  local s3file_path=$(build_s3_file_path $target)
  aws --profile=$AWS_PROFILE s3 cp $target $s3file_path --acl public-read
}

s3_file_url() {
  local target=$1
  local domain=".s3.amazonaws.com"
  # local s3url="https://$(echo "${BUCKET_NAME}${domain%/}/${S3DIRECTORY%/}/$(basename $target)" | sed -e 's/\/\//\//g')"
  local s3url="https://${DOMAIN}/image/$(echo "$(basename $target)" | sed -e 's/\/\//\//g')"
  echo $s3url
}

s3_upload_image() {
  local target=$1
  if [ -e $target ]; then
    remove_exif $target 1>&2 &&\
      image_optimize $target 1>&2 &&\
      s3_upload $target 1>&2 &&\
      s3_file_url $target | tr -d '\n'
    exit 0
  else
    echo "${target} does not exists."
    exit 1
  fi
}

s3_delete_image() {
  local s3file_path=$(build_s3_file_path $1)
  aws --profile=$AWS_PROFILE s3 rm $s3file_path
}

image_optimize() {
  # echo $1
  # # npm install -g imageoptim-cli
  # if type imageOptim &>/dev/null
  # then
  #   echo $1 | imageOptim
  # fi
  :
}

if [ $# -eq 0 ]; then
  echo 'you should specify a command[upload|url] and a image file path'
  exit 1
fi

subcommand=$1

if [ $# -eq 0 ]; then
  echo 'you should specify a image file path'
  exit 1
fi

target=$2

case $subcommand in
  upload)
    s3_upload_image $target
    ;;
  url)
    s3_file_url $target
    ;;
  delete)
    s3_delete_image $target
    ;;
  *)
    echo "command $subcommand not found. usage: $(basename $0) (upload|url) <target>" >2
    echo "optionnal env values: AWS_PROFILE, BUCKET_NAME, S3DIRECTORY"
    exit 1
    ;;
esac

