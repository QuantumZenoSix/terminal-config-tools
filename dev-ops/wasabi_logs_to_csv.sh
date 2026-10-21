#!/usr/bin/env bash

# Description: If you have a bunch of bucket logs downloaded from the wasabi console, give then the '.log' extension and this script will pick them up and

# Headers
echo "BucketOwner,Bucket,Time    RemoteIP,Requester,RequestId,Operation" > result.csv

# Rows
for file in ./*.log
do
    echo "Processing ${file} ..."
    sed -E 's/\s(\+0000)/\1/g' ${file} | sed -E 's/\s/,/g' | sed -E 's/,-,".*$//g' | grep -Ev '=====' | grep -Ev '^Record,format:,\[' >> result.csv
done

