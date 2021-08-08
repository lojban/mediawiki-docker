#!/bin/bash

# This is often called from cron, so:
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:$PATH

exec 2>&1
set -e
set -x

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker)}

cd /home/spmediawiki/mediawiki
erb my.cnf.erb >data/my.cnf
chmod --reference=my.cnf.erb data/my.cnf
$CONTAINER_BIN cp data/my.cnf lojban_mediawiki_db:/tmp/
$CONTAINER_BIN cp mysql_backup.sh lojban_mediawiki_db:/tmp/
$CONTAINER_BIN exec lojban_mediawiki_db /tmp/mysql_backup.sh
$CONTAINER_BIN exec -u root lojban_mediawiki_db rm /tmp/my.cnf
