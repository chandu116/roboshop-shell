#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.daws6s.online

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

dnf install python36 gcc python3-devel -y

id roboshop
if [ $?-ne 0 ]
then
useradd roboshop
VALIDATE $? "Roboshop user creation"
else
echo -e "roboshop user already exist  $Y Skipping $N"
fi

#useradd roboshop &>> $LOGFILE
#VALIDATE $? "Creating roboshop user" 

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating App directory"  

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading Payment"  

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unzip Payment"  

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing dependencies"  

cp home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"  

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"  

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enable payment"  

systemctl start payment &>> $LOGFILE

VALIDATE $? "start payment"  
