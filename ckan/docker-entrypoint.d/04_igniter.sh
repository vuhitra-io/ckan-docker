#!/bin/bash

SRC_DIR="/srv/app/src_extensions"

cd $SRC_DIR/ckanext-fjelltopp-theme

npm --prefix "$FJELLTOPP_THEME" run compile
npm --prefix "$FJELLTOPP_THEME" run watch &
