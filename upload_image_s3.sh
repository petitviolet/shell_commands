#!/bin/bash
# set -e

AWS_PROFILE=${AWS_PROFILE:-"s3"}

BUCKET_NAME=${BUCKET_NAME:-"petitviolet"}
S3DIRECTORY=${S3DIRECTORY:-"public/image"}

S3FILE_PATH="s3://${BUCKET_NAME}/${S3DIRECTORY}"

s3_upload() {
  local target=$1
  aws --profile=$AWS_PROFILE s3 cp ${target} "${S3FILE_PATH}/$(basename $target)" --acl public-read
}

s3_file_url() {
  local target=$1
  local s3url="https://${BUCKET_NAME}.s3.amazonaws.com/${S3DIRECTORY}/$(basename $target)"
  echo $s3url
}

s3-upload-image() {
  if [ $# -eq 0 ]; then
    echo 'you should specify a file path to upload to S3'
    exit 1
  fi

  local target=$1
  if [ -e $target ]; then
    image_optimize $target 1>&2
    s3_upload $target 1>&2
    s3_file_url $target | tr -d '\n'
    exit 0
  else
    echo "${target} does not exists."
    exit 1
  fi
}

image_optimize() {
  # npm install -g imageoptim-cli
  hash imageOptim &>/dev/null
  if [ $? -eq 0 ]; then
    echo $1 | imageOptim
  fi
}

s3-upload-image $1
