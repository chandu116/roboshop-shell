#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE(){
if [ $1 -ne 0 ]
    then
    echo -e "$2... $R FAILED $N"
    else
        echo -e "$2... $G SUCCESS $N"
        
fi 
}

if [ $ID -ne 0 ]
then
echo -e "$R ERROR:: Please run this script with root access $N"
exit 1
else
echo "You are root user"
fi 

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current Nodejs"  

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling current Nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing  Nodejs:18" 

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop user" 

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating App directory"  

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading Catalogue Application"  

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping  Catalogue Application" 

npm install &>> $LOGFILE

VALIDATE $? "Installing  dependencies" 

# use Absoulute, Because catalogue.service exists there 
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying Catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Catalogue daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying Mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb Client"

mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue Data into MongoDB"

