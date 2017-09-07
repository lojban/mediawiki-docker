#!/bin/bash

chcon -t home_bin_t insert_password.sh run_docker.sh fix_selinux.sh test_mode.sh
# chcon -R -t httpd_user_rw_content_t data/
