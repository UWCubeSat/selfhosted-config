#!/bin/bash

# Set REMOTELY_HOST to access the wiki machine (need not be root)

source remotely.sh
remotely_backup wiki

# While sending passwords through environment variables is more or less secure in 2021, MySQL has
# still deprecated it. If this line breaks in the future, you know why!
echo "MYSQLDUMP into $NEW_BACKUP_DIR/my.sql.gz"
remotely_no_escape "MYSQL_PWD=$WIKI_DB_PASSWORD" mysqldump "$WIKI_DB_NAME" -u "$WIKI_DB_USER" '|' gzip > "$NEW_BACKUP_DIR/my.sql.gz"

echo "DUMPBACKUP.PHP into $NEW_BACKUP_DIR/dump.xml.gz"
remotely_no_escape php /var/www/html/wiki/maintenance/dumpBackup.php --full --quiet '|' gzip > "$NEW_BACKUP_DIR/dump.xml.gz"

backup /var/www/html/wiki/
