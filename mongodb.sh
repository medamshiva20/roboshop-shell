#!/bin/bash 

USERID=$(id -u)
LOGS_DIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
DATE=$(date +%F:%H:%M:%S)
SCRIPT_NAME=$0
LOG_FILE=$LOGS_DIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
 then
    echo "$R ERROR:: Please run this script with root access $N"
    exit 1
 else
    echo "INFO: You are root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
       then 
          echo -e "$2 ...$R FAILURE $N"
          exit 1
       else
          echo -e "$2 ...$G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repo.d/mongo.repo &>>$LOG_FILE

yum install mogodb-org -y &>>$LOG_FILE
VALIDATE $? "Installation of MongoDB" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i "s/127.0.0.1/0.0.0.0" /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Edited mongod conf"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MonogoDB"
