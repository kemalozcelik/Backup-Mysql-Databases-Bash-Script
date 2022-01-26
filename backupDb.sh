#!/bin/bash
# Set Helper Timestamp Variables
TIMESTAMP=$(date +"%F")

#FTP Login Information
HOST="hostip port"
USER="ftp-username"
PASSWD="ftp-password"


#Temporary Backup Path
FOLDER="/root/backup/DB-Backups/$TIMESTAMP"

#Remote Backup Path
REMOTEDIR="/backup/subfolder"

#MySQL Connection & Binary Information
MYSQL_USER="mysql-username"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD="mysql-password"
MYSQLDUMP=/usr/bin/mysqldump

#DO NOT EDIT BELOW
##############################################
# Make Folder Name Using Current Timestamp 
mkdir -p ${FOLDER}
# Change folder to Source Folder
cd $FOLDER
# Get Databases list into array variable.
databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`
# Loop Start
for db in $databases;
do
FINAMEIND="$db-$TIMESTAMP.gz"
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$FOLDER/$FINAMEIND"
ftp -n -v $HOST << EOT
PASV
user $USER $PASSWD
prompt
lcd $FOLDER
cd $REMOTEDIR
pwd
put $FINAMEIND
bye
EOT
# Remove Uploaded Backup File Individually
rm "$FOLDER/$FINAMEIND" 
done
# Loop End

# Remove Temporary Backup Folder
rm -rf $FOLDER
############################################## 
#DO NOT EDIT ABOVE
