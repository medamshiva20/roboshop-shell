#!/bin/bash 

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
LOG_DIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOG_DIR/$SCRIPT_NAME-$DATE.log
username=roboshop

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ]
  then 
      echo "ERROR:: Please run this script with root access"
  else
      echo "INFO: You are root user"
fi

VALIDATE(){
    
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
VALIDATE $? "Setting up NPM Source"

yum install nodejs -y
VALIDATE $? "Installing NodeJS" &>>$LOGFILE

# IMPROVEMENT: first check the user already exist or not, if not exist then create
if id "$username" &> /dev/null 
 then
    echo "User $username already exist."
 else
    echo "User $username does not exist. Creating user..." 
    useradd $username &>>$LOGFILE
fi

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip
VALIDATE $? "downloading catalogue artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving into app directory"

unzip -o /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "unzipping catalogue"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

# give full path of catalogue.service because we are inside /app
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling Catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting Catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE
VALIDATE $? "Installing mongo client"

mongo --host 172.31.21.80 </app/schema/user.js &>>$LOGFILE
VALIDATE $? "loading user data into mongodb"


