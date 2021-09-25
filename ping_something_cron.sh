#!/bin/bash
# Based on: https://askubuntu.com/questions/522505/script-to-monitor-internet-connection-stability
#***************************************
# FOR CRONTAB
# * * * * * /location/of/ping_something_cron.sh {IP}
#***************************************
LOG_FILE="$HOME/logs/ping_test_$1.csv"
mkdir -p $(dirname $LOG_FILE)
touch $LOG_FILE         # Fail early if permission error
DT=$(date '+%Y-%m-%dT%H:%M:%S')
SPEED_TEST_RES=$(ping -c 5 -q $1 2>/dev/null | tail -n 1)

echo $SPEED_TEST_RES
#set -o xtrace
MIN=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $1}')
AVG=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $2}')
MAX=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $3}')
MDEV=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $4}')

[[ -z "$MIN" ]] && { MIN=0; AVG=0; MAX=0; MDEV=0; }
echo "$DT,$MIN,$AVG,$MAX,$MDEV" >> $LOG_FILE
