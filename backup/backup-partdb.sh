#!/bin/bash

source remotely.sh
remotely_backup partdb

# While sending passwords through environment variables is more or less secure in 2021, MySQL has
# still deprecated it. If this line breaks in the future, you know why!
echo "MYSQLDUMP into $NEW_BACKUP_DIR/my.sql.gz"
remotely_no_escape "MYSQL_PWD=$PARTDB_PASSWORD" mysqldump partdb -u partdb '|' gzip > "$NEW_BACKUP_DIR/my.sql.gz"
backup /var/www/html/partdb/data
