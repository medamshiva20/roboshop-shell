#!/bin/bash 

USERID=$(id -u)
# /home/centos/shellscript-logs/script-name-date.log
LOGSDIR=/tmp
DATE=$(date +%F:%H:%M:%S)
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
 then 
    echo "ERROR:: Please run this script with root access"
    exit 1
fi

VALIDATE(){
    if [ $? -ne 0 ]
      then 
         echo -e "$2 ... $R FAILURE $N"
         exit 1
      else
         echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum module disable mysql -y &>>$LOGFILE
VALIDATE $? "Disabling the default version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copying MySQL repo" 

yum install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Staring MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "setting up root password"