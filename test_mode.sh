#!/bin/bash

sed -i 's;mw.lojban.org;test-mw.lojban.org;' data/LocalSettings.php 
sed -i 's;https://test-mw.lojban.org;http://test-mw.lojban.org;' data/LocalSettings.php 
