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

dnf install maven -y &>>$log_file
validate $? "install maven"

id roboshop &>>$log_file

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
 echo -e "Rboshop user already exist ... $Y skipping $N"
fi

mkdir -p /app 
validate $? "creating directory" &>>$log_file

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip
validate $? "downdloading shipping code"

cd /app
validate $? "moving to app directory"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/shipping.zip &>>$log_file
validate $? "unzip shipping code"

cd /app 
mvn clean package &>>$log_file
validate $? "Installing and building shipping"

mv target/shipping-1.0.jar shipping.jar 
validate $? "Moving and renaming shipping"

cp $Script_Directory/shipping.service /etc/systemd/system/shipping.service
validate $? "created systemctl service"

dnf install mysql -y 
validate $? "Install mysql"

mysql -e $Mysql_host -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y Skipping $N"
fi

systemctl enable shipping 
systemctl start shipping
validate $? "enbale ans stared shipping"