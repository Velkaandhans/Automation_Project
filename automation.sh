sudo apt update -y

#installing apache2 server if not installed
if ! dpkg -s apache2 &> /dev/null; then
        sudo apt -y install apache2
fi

#checking apache2 is runnig
if ! systemctl is-active apache2 &> /dev/null; then
        sudo systemctl start apache2
fi

#to enable service while booting up
sudo systemctl enable apache2

#timestamp,name,S3 bucket declaration
timestamp=$(date +"%m%d%Y-%H%M%S")
s3_bucket="s3://upgrad-velan"
name="vel"

#genrating tar file
sudo tar -cvf /tmp/$name-httpd-logs-$timestamp.tar /var/log/apache2/*.log

#uploading to S3 bucket
sudo aws s3 cp /tmp/$name-httpd-logs-$timestamp.tar $s3_bucket
