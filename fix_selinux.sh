#!/bin/bash

chcon -t home_bin_t fix_selinux.sh insert_password.sh kill_database.sh kill_web.sh run_database.sh run_web.sh setup.sh build_web.sh
