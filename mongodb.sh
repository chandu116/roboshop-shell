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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied Mongo DB Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "INSTALLING MONGO DB" 

systemctl enable mongod

VALIDATE $? "Enabling MONGO DB" 

systemctl start mongod

VALIDATE $? "Starting MONGO DB" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MONGO DB" 

