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

dnf module disable mysql -y &>> $LOGFILE 

VALIDATE $? "Disable Current Mysql Verion"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE 

VALIDATE $? "Copied mySQL REPO"

dnf install mysql-community-server -y &>> $LOGFILE 

VALIDATE $? "Installing mySQL Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enable Mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Start Mysql"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Setting My SQl Root Password"
