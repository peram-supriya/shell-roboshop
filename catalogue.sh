#!/bin/bash

user_id=$(id -u)
Log_folder="/var/log/shell-roboshop"
log_file="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo -e "$R Running as root user $N" | tee -a $log_file
    exit 1
fi

mkdir -p $Log_folder


validate(){
    
    if [ $? -ne 0 ]; then
     echo "$2 installation failed" | tee -a $log_file
    exit 1
    else
    echo "$2 installation successful" | tee -a $log_file
    fi
}

dnf module disable nodejs -y &>>$log_file
validate $? "disabling nodejs default version"

dnf module enable nodejs:20 -y
validate $? "enbaling node js" &>>$log_file

dnf install nodejs -y &>>$log_file
validate $? "installing node js"

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
 echo -e "Rboshop user already exist ... $Y skipping $N"
fi

mkdir /app 
validate $? "creating directory" &>>$log_file

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
validate $? "downdloading catalogue code"