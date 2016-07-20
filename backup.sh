#!/bin/bash

## CRONJOB LINE
# 30 23 * * * /path/to/backup.sh

## DEFINE VARIABLES

dt=`date +%F`
bkppath="/path/to/backup/dir" ## change it to where you want backups to reside
sitepath="/var/www/mysite" ## change it to where your site root directory resides
dbuser="db_user" ## change it to your db username
dbpwd="db_password" ## change it to your db password
dbname="db_name" ## change it to your db name
remoteserverbkppath="/path/to/remote-server/backup/dir" ## change it to remote server backup dir
remoteserverip="1.2.3.4" ## change it to remote server ip address
remoteserveruname="remote-server_username" ## change it to remote server username, for e.g. "root"
dbbkpprefix="mydb" ## optional to change
sitebkpprefix="mysite" ## optional to change

## BACK UP THE DATABASE

mysqldump -u$dbuser -p$dbpwd $dbname | gzip > $bkppath/$dbbkpprefix-$dt.sql.gz

## BACK UP THE SITE CODE

tar cfz $bkppath/$sitebkpprefix-$dt.tar.gz $sitepath

## COPY THE LATEST BACKUPS TO ANOTHER SERVER (FOR DOUBLE BACKUPS)
## temporarily copying backup files to move them to remote server with same name. This way
## we only store one latest backup of site and db each, on the remote server.

if [ ! -d $bkppath/tmp ]; then
    mkdir -m 777 $bkppath/tmp
fi

cp $bkppath/$dbbkpprefix-$dt.sql.gz $bkppath/tmp/$dbbkpprefix.sql.gz
cp $bkppath/$sitebkpprefix-$dt.tar.gz $bkppath/tmp/$sitebkpprefix.tar.gz

rsync -a $bkppath/tmp/$dbbkpprefix.sql.gz $remoteserveruname@$remoteserverip:$remoteserverbkppath
rsync -a $bkppath/tmp/$sitebkpprefix.tar.gz $remoteserveruname@$remoteserverip:$remoteserverbkppath

rm -f $bkppath/tmp/$dbbkpprefix.sql.gz
rm -f $bkppath/tmp/$sitebkpprefix.tar.gz

## REMOVE ALL OLDER THAN 3 BACKUPS

find $bkppath/* -mtime +3 -exec rm {} \;