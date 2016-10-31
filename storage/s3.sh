#!/usr/bin/env bash
# Resolve current script dir
cd `dirname $0` && DIR=$(pwd) && cd - > /dev/null

if [[ -z ${S3_ACCESS_KEY} ]] || [[ -z ${S3_SECRET_KEY} ]] || [[ -z ${S3_REGION} ]] || [[ -z ${S3_BUCKET} ]] ; then
  echo "One of s3 config variable not configured!"
  exit 1
fi

S3_ACCESS_KEY_ESCAPED=`echo "$S3_ACCESS_KEY" | sed -e 's/[\.\:\/&]/\\\\&/g'`
S3_SECRET_KEY_ESCAPED=`echo "$S3_SECRET_KEY" | sed -e 's/[\.\:\/&]/\\\\&/g'`

S3CFG=$(cat ${DIR}.s3cfg);
S3CFG=$(echo "$S3CFG" | sed -e "s/access_key =.*/access_key = ${S3_ACCESS_KEY_ESCAPED}/g")
S3CFG=$(echo "$S3CFG" | sed -e "s/secret_key =.*/secret_key = ${S3_SECRET_KEY_ESCAPED}/g")
S3CFG=$(echo "$S3CFG" | sed -e "s/bucket_location =.*/bucket_location = ${S3_REGION}/g")

case $1 in
  "ls")
    PREFIX="s3://${S3_BUCKET}/";
    s3cmd -c <(echo ${S3CFG}) ls -l ${PREFIX}$2 | awk '{ if ($6) { path = substr($6, '${#PREFIX}'); print $1 " " $2 " " $3 " " path " " $4 } else { path = substr($2, '${#PREFIX}'); print "- - " $1 " " path " " $4 }}'
    exit 0
  ;;
  "cp")
    if [[ -z $2 ]] || [[ -z $3 ]]; then
      echo "Missing argument "
    fi
    s3cmd -c <(echo ${S3CFG}) put $2 s3://${S3_BUCKET}/$3
    exit 0
  ;;
  "del")
    if [[ -z $2 ]] || [[ -z $3 ]]; then
      echo "Missing argument "
    fi
    s3cmd -c <(echo ${S3CFG}) del s3://${S3_BUCKET}/$2
    exit 0
  ;;
esac

echo "Unknown command '$1'"
exit 1
