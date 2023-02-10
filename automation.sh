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

#creating inventory if not exist
if [ ! -f "/var/www/html/inventory.html" ]; then
        sudo touch /var/www/html/inventory.html
        echo -e "Log Type\tDate Created\tType\tSize" >> /var/www/html/inventory.html
fi
#finding size of tar files
size=$(du -h /tmp/$name-httpd-logs-$timestamp.tar |awk '{print $1}')

#appending inventory file
echo -e "Httpd-logs\t$timestamp\ttar\t$size" >> /var/www/html/inventory.html

#creating anacron under cron.d
cronpath="/etc/cron.d/anacron"
if [ ! -f $cronpath ]; then
        sudo touch $cronpath
fi

#declaring the cronjob if it is not present
if grep -Fxq "30 3 * * * root /root/Automation_Project/automation.sh" $cronpath; then
        echo "Cron Job already exists."
else
        sudo echo -e "30 3 * * * root /root/Automation_Project/automation.sh" >> $cronpath
fi