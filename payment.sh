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

dnf install python3 gcc python3-devel -y &>>$log_file
validate $? "install python"

id roboshop &>>$log_file

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
 echo -e "Rboshop user already exist ... $Y skipping $N"
fi

mkdir -p /app 
validate $? "creating directory" &>>$log_file

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip
validate $? "downdloading payment code"

cd /app
validate $? "moving to app directory"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/payment.zip &>>$log_file
validate $? "unzip payment code"

cd /app 
pip3 install -r requirements.txt
validate $? "installing Dependencies"

cp $Script_Directory/payment.service /etc/systemd/system/payment.service
validate $? "created systemctl service"

systemctl daemon-reload
validate $? "Reload"

systemctl daemon-reload
systemctl enable payment 
systemctl start payment
validate $? "enable and start payment