#!/bin/bash

chown -R ckan:ckan /srv/app/src/ckan/ckan/public/base/i18n

/root/watch_sync.sh &
