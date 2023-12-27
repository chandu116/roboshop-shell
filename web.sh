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


dnf install nginx -y &>> $LOGFILE 

VALIDATE $? "Installing nginx"  

systemctl enable nginx &>> $LOGFILE 

VALIDATE $? "Enabling nginx" 

systemctl start nginx &>> $LOGFILE 

VALIDATE $? "Start nginx" 

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 

VALIDATE $? "Removed default website" 

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE 

VALIDATE $? "Downloaded Web Application" 

cd /usr/share/nginx/html &>> $LOGFILE 

VALIDATE $? "Moving to ngnix html directory" 

unzip -o /tmp/web.zip &>> $LOGFILE 

VALIDATE $? "Unzipping Web" 

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE 

VALIDATE $? "Copied Roboshop reverse proxy config" 

systemctl restart nginx &>> $LOGFILE 

VALIDATE $? "Restart nginx"  