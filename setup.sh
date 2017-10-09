#!/bin/bash

rm -rf ~/.config/systemd/
mkdir -p ~/.config/systemd/
ln -s $(pwd)/systemd ~/.config/systemd/user

systemctl --user enable lojban_mediawiki_db
systemctl --user start lojban_mediawiki_db
systemctl --user enable lojban_mediawiki_web
systemctl --user start lojban_mediawiki_web
