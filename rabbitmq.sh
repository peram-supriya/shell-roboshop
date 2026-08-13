#!/bin/bash

user_id=$(id -u)
Log_folder="/var/log/shell-roboshop"
log_file="/var/log/shell-roboshop/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
Script_Directory=$PWD
Mysql_host=mysql.thoshi.online

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

cp $Script_Directory/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Added rabbitmq repo"

dnf install rabbitmq-server -y &>>$log_file
validate $? "Install rabbitmq server"

systemctl enable rabbitmq-server &>>$log_file
systemctl start rabbitmq-server
validate $? "Enable and started rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "create users"