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

#useradd roboshop &>> $LOGFILE
#VALIDATE $? "Creating roboshop user" 

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating App directory"  

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading User Application"  

cd /app 

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping  user Application" 

npm install &>> $LOGFILE

VALIDATE $? "Installing  dependencies" 

# use Absoulute path, Because user.service exists there 
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon-reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying Mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb Client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user Data into MongoDB" 
