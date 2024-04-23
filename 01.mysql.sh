#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGFILE=$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then  
        echo "$2 ... FAILURE"
        exit 1
    else
        echo "$2 .... SUCCESS"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with super user"
    exit 1
else
   echo "you are super user"
fi

dnf install mysql-server -y
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld
VALIDATE $? "enabling mysqld"

systemctl start mysqld
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "password setup for root user"
