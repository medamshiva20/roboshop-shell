#! /bin/bash 

USERID=$(id -u)
DATE=$(date +%F:%H:%M:%S)
LOG_DIR=/tmp
SCRIPT_NAME=$0
LOG_FILE=$LOG_DIR/$SCRIPT_NAME-$DATE.log

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


curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG_FILE
VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create
useradd roboshop &>>$LOG_FILE

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloading catalogue artifact"

cd /app &>>$LOG_FILE
VALIDATE $? "Moving into app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MongoDB repo into yum.repos.d"

yum install mongodb-org-shell -y
VALIDATE $? "Installing mongo client"

mongo --host 172.31.21.80 </app/schema/catalogue.js
VALIDATE $? "loading catalogue data into mongodb"