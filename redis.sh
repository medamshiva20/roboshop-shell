#!/bin/bash 

USERID=$(id -u)
LOG_DIR=/tmp
DATE=$(date +%F:%H:%M:%S)
SCRIPT_NAME=$0
LOG_FILE=$LOG_DIR/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
 then
    echo "ERROR:: Please run this script with root access"
    exit 1
 else
    echo "INFO: You are root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
     then 
        echo -e "$2 ... $R FAILURE $N"
        exit 1
     else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG_FILE

yum module enable redis:remi-6.2 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis 6.2"

yum install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis 6.2"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf & /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Allowing Remote connections to redis"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>>$LOGFILE
VALIDATE $? "Starting Redis"