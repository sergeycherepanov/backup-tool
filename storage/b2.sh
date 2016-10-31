#!/usr/bin/env bash

if [[ -z ${BACKBLAZE_ACCOUNT_ID} ]] || [[ -z ${BACKBLAZE_APP_KEY} ]] || [[ -z ${BACKBLAZE_BUCKET} ]] ; then
  echo "One of backblaze config variable not configured!"
  exit 1
fi

[[ -f ~/.b2_account_info ]] || b2 authorize_account ${BACKBLAZE_ACCOUNT_ID} ${BACKBLAZE_APP_KEY}

case $1 in
  "ls")
    b2 ls --long ${BACKBLAZE_BUCKET} $2 | awk '{if ( "-" == $1) { size = "DIR" } else { size =$5 } print $3 " " $4 " " size " " $6 " " $1}'
    exit 0
  ;;
  "cp")
    if [[ -z $2 ]] || [[ -z $3 ]]; then
      echo "Missing argument "
    fi
    b2 upload_file ${BACKBLAZE_BUCKET} $2 $3
    exit 0
  ;;
  "del")
    if [[ -z $2 ]] || [[ -z $3 ]]; then
      echo "Missing argument "
    fi
    b2 delete_file_version $2 $3
    exit 0
  ;;
esac

echo "Unknown command '$1'"
exit 1
