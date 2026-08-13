#!/bin/bash

user_id=$(id -u)
Log_folder="/var/log/shell-roboshop"
log_file="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo -e "$R Running as root user $N" | tee -a $log_file
    exit 1
fi
mkdir -p $Log_folder

echo "installing mongodb"
dnf install mongodb-org -y

validate(){
    
    if [ $? -ne 0 ]; then
     echo "mongodb installation failed" | tee -a $log_file
    exit 1
    else
    echo "mongodb installation successful" | tee -a $log_file
    fi
}

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs default version"

dnf module enable nodejs:20 -y
validate $? "enbaling node js" &>>$log_file

dnf install nodejs -y &>>$log_file
validate $? "installing node js"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "creating system user"

mkdir /app 
validate $? "creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
validate $? "downdloading catalogue code"