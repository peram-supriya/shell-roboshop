#!/bin/bash

user_id=$(id -u)
Log_folder="/var/log/shell-roboshop"
log_file="$Log_folder/$0.log"
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

dnf install mysql-server -y
validate $? "Install mysql server"

systemctl enable mysqld
systemctl start mysqld  
validate $? "enable and start my sql"


mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setup root password"