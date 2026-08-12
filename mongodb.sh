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

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y 
validate $? "Installing mongodb server"

systemctl enable mongod 
validate $? "enable mongodb"

systemctl start mongod
validate $? "start mogodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections"

systemctl restart mongod
validate $? "Restarted MongoDB"