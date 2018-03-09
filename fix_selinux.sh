#!/bin/bash

chcon -R -t config_home_t systemd/
chcon -t home_bin_t fix_selinux.sh insert_password.sh kill_database.sh kill_web.sh run_database.sh run_web.sh setup.sh build_web.sh cron_backup.sh grab_extdist.sh
loginctl show-user sampre_mw | grep Linger=yes || (
	echo -e "\n\n\nUSER LINGER DISABLED FOR THIS USER.  VERY BAD; MUST FIX.\n\n\n" ;
	loginctl enable-linger sampre_mw
)
