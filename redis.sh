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


validate(){
    
    if [ $? -ne 0 ]; then
     echo "$2 installation failed" | tee -a $log_file
    exit 1
    else
    echo "$2 installation successful" | tee -a $log_file
    fi
}

dnf module disable redis -y &>>$log-file
dnf module enable redis:7 -y &>>$log-file
validate $? "Enable redis:7"

dnf install redis -y &>>$log-file
validate $? "Install redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Allowing remote connections"

systemctl enable redis &>>$log-file
systemctl start redis 
validate $? "enabled and start redis"