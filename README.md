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

## loading

show loading indicator.

reference in Japanese.
[Zshで長い処理をしている間に読込中を表示する - Qiita](http://qiita.com/petitviolet/items/5cc1916eb3fdb8d54823)

```sh
loading 5
# loading <seconds>
```

![loading](https://petitviolet.s3.amazonaws.com/public/image/loading_indicator.gif)

### using loading indicator in other function

```sh
other_function() {
    # show loading indicator
    ## disable job control to suppress print process id
    set +m
    loading 100 &
    set -m
    local loading_pid=$!

    # execute heavy command
    do_something_heavy

    # remove indicator 
    kill -INT $loading_pid &>/dev/null
}
```
