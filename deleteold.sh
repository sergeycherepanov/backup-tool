#!/bin/bash

# Usage: ./deleteold.sh "bucketname" "30 days"

s3cmd ls s3://$1 | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`
    olderThan=`date -d"-$2" +%s`
    if [[ $createDate -lt $olderThan ]]
      then 
        fileName=`echo $line|awk {'print $4'}`
        echo $fileName
        if [[ $fileName != "" ]]
          then
            s3cmd del "$fileName"
        fi
    fi
done;
