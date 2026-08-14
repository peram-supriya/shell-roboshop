#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_dire=/home/ec2-user/app-logs
log_file="$logs_dire/$0.log"    

if [ ! -d $Logs_dire ]; then
    echo "$logs_dire doesn't exists"
    exit 1
fi

File_To_Delete=$(find $Logs_dire -name "*.log" -mtime +14)
# echo "$File_To_Delete"

# Example reading a comma-separated file
while IFS= read -r filepath; do
    echo "Deleting the file: $filepath"
done <<< $Logs_dire
