#!/bin/bash

diff -u -r --exclude data containers/$1/ containers/$1-test/
