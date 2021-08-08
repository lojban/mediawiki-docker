#!/bin/bash

#********************
# MySQL cleanup
#********************

export MYSQL_PWD='<%= File.read('DO_NOT_CHECK_IN/mysql_password.txt').chomp %>'

exec 2>&1
set -e
set -x

# Only do the big jobs once a month
if [ "$(date +%-d)" -eq 1 ]
then
  # Repairs brokenness
  /usr/bin/mysqlcheck --defaults-file=/tmp/my.cnf --all-databases --auto-repair | egrep -v '(Table is already up to date| OK)$'

  # defragments after large deletes or whatever
  /usr/bin/mysqlcheck --defaults-file=/tmp/my.cnf --all-databases --optimize | egrep -v '(Table is already up to date| OK|mysql.general_log|mysql.slow_log|note *: The storage engine for the table doesn.t support optimize)$'
fi

# updates keys/indexes for speed
/usr/bin/mysqlcheck --defaults-file=/tmp/my.cnf --all-databases --analyze | egrep -v '(Table is already up to date| OK|mysql.general_log|mysql.slow_log|note *: The storage engine for the table doesn.t support analyze)$' || true

#********************
# MySQL backup
#********************

mkdir -p /srv/backups/mysqldumps
chmod 700 /srv/backups/mysqldumps
cd /srv/backups/mysqldumps
ls -lrt

# Delete old backups
find . -type f | head -n -10 | xargs rm -f -v

for database in $(mysql --defaults-file=/tmp/my.cnf -N -B -e 'show databases;' | grep -v information_schema | grep -v performance_schema)
do
  DATESTR=$(date +%Y%b%d)

  echo "Backing up MySQL database $database"
  /bin/rm -f $database.$DATESTR.gz
  /usr/bin/mysqldump --defaults-file=/tmp/my.cnf --opt --single-transaction --skip-triggers --add-drop-database \
    --ignore-table=mediawiki.objectcache --ignore-table=mediawiki.copy_l10n_cache --ignore-table=mediawiki.l10n_cache \
    --databases $database | /bin/gzip --rsyncable -9 >$database.$DATESTR.gz
  echo "Done backing up MySQL database $database"
done

chown -R 1086:1086 /srv/backups/mysqldumps
