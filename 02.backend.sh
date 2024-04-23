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
read  mysql_root_password

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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
 then
     useradd expense
     VALIDATE $? "user creation"
 else
    echo -e "already expense user exit... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "unzipping backend code"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

cp /home/ec2-user/expense-shellscript/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copy the backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting backed service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enablind backed service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h db.lrnm.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "loading schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restart backend service"


