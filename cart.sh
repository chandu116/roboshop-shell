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


dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current Nodejs"  

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling current Nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing  Nodejs:18" 

id roboshop
if [ $?-ne 0 ]
then
useradd roboshop
VALIDATE $? "Roboshop user creation"
else
echo -e "roboshop user already exist  $Y Skipping $N"
fi

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating roboshop user" 

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating App directory"  

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart Application"  

cd /app 

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping  cart Application" 

npm install &>> $LOGFILE

VALIDATE $? "Installing  dependencies" 

# use Absoulute path, Because cart.service exists there 
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "cart daemon-reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting cart"








