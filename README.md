# handmade shell commands 

## s3_image


### usage

```sh
export AWS_PROFILE=<your aws profile>
export BUCKET_NAME=<your bucket to upload>
export S3DIRECTORY=<your directory to upload>

s3_image [upload|url] <image path>
```

### show image url

use `s3_image url <path>`.

```sh
$ BUCKET_NAME=MYBUCKET S3DIRECTORY=path/to/image s3_image url local/image/file.png
https:/MYBUCKET.s3.amazonaws.com/path/to/image/file.png
```

### upload image and get url

use `s3_image upload <path>`.

```sh
$ BUCKET_NAME=petitviolet S3DIRECTORY=path/to/image AWS_PROFILE=s3 s3_image upload ~/tmp/scala.png
upload: ../../tmp/scala.png to s3://petitviolet/path/to/image/scala.png
https://petitviolet.s3.amazonaws.com/path/to/image/scala.png%
```

