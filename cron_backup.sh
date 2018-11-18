#!/bin/bash

exec 2>&1
set -e
set -x

cd /home/sampre_mw/mediawiki
rm data/mysql_backup.sh
./insert_password.sh mysql mysql_backup.sh
sudo docker cp data/mysql_backup.sh lojban_mediawiki_db:/tmp/
sudo docker exec -t lojban_mediawiki_db /tmp/mysql_backup.sh
