#!/bin/bash
# Sets permissions of the nextcloud instance for updating

ocpath='/var/www/nextcloud'
htuser='www-data'
htgroup='www-data'

chown -R ${htuser}:${htgroup} ${ocpath}