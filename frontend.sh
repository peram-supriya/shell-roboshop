#!/bin/bash

user_id=$(id -u)
Log_folder="/var/log/shell-roboshop"
log_file="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
Script_Directory=$PWD
Mongodb_Host=mongodb.thoshi.online

if [ $user_id -ne 0 ]; then
    echo -e "$R Running as root user $N" | tee -a $log_file
    exit 1
fi

mkdir -p $Log_folder


validate(){
    
    if [ $1 -ne 0 ]; then
     echo "$2 installation failed" | tee -a $log_file
    exit 1
    else
    echo "$2 installation successful" | tee -a $log_file
    fi
}

dnf module disable nginx -y &>>$log_file
dnf module enable nginx:1.24 -y &>>$log_file
dnf install nginx -y &>>$log_file
validate $? "installing Nginx"

systemctl enable nginx &>>$log_file
systemctl start nginx  &>>$log_file
validate $? "enable and started nginx"

rm -rf /usr/share/nginx/html/* 
validate $? "Remove default code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
vlidate $? "unzip the code"

rm -rf /etc/nginx/nginx.conf

cp $Script_Directory/nginx.conf /etc/nginx/nginx.conf
validate $? "Copied our nginx conf file"

systemctl restart nginx
validate $? "restarted nginx"