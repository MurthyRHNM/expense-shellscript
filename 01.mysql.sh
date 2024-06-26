#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# below command is safe instead of hard coding sensitive(password) info we should give while running the script
#and should give correct password which we already setup for root
echo "Please enter root password"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then  
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with super user"
    exit 1
else
   echo "you are super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysqld"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysqld"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "setting up root password"

#we should check below command manually then we need to include in this script

mysql -h db.lrnm.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $1 "setting up root password"
else
    echo -e "mysql root password already setup  $Y SKIPPING $N"
fi
