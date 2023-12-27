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

dnf install maven -y &>> $LOGFILE

VALIDATE $? "Installed Maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping" 

cd /app &>> $LOGFILE

VALIDATE $? "Moving to App Directory" 

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping shipping" 

mvn clean package &>> $LOGFILE

VALIDATE $? "Installing Dependencies" 

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? "Renaming Jar File" 

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying Shipping Service" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Demon Reload" 

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enabling Shipping" 

systemctl start shipping

VALIDATE $? "Start Shipping" 

dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Install MySQL Client"

mysql -h mysql.daws6s.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading Shipping Data" 

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restart Shipping" 

