#!/bin/bash

rsync -PSHAXa --delete --delete-excluded --exclude 'backups/*' containers/$1/data/ containers/$1-test/data/
