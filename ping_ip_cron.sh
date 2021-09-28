#!/bin/bash

# Based on: https://askubuntu.com/questions/522505/script-to-monitor-internet-connection-stability
#***************************************
# FOR CRONTAB
# * * * * * /location/of/ping_ip_cron.sh {IP}
#***************************************

# CHECK ARGS
if [[ -z $1 ]]
  then
    echo "Need to provide IP as first argument"
    exit 1
fi


# DEFINE NET VARS
CURR_INTERFACE=$(ip route list | grep '^default' | awk  '{print $5}' | head -n 1)
WIFI_SSID=$(iwgetid $CURR_INTERFACE -r)
CURR_IS_METERED=$(nmcli -t -f GENERAL.METERED dev show $CURR_INTERFACE | grep -o "yes")


# DO NOT RUN IF NO NETWORK
[[ -z "$CURR_INTERFACE" ]] && echo "No network connected, aborting" && exit 0

# DO NOT RUN ON METERED CONNECTIONS
[[ ! -z "$CURR_IS_METERED" ]] && echo "Metered connection, aborting" && exit 0


# GET CSV VARS
SPEED_TEST_RES=$(ping -c 2 -q $1 2>/dev/null | tail -n 1)

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')
MIN=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $1}')
AVG=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $2}')
MAX=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $3}')
MDEV=$(echo $SPEED_TEST_RES | awk  '{print $4}' | awk -F/ '{print $4}')

[[ -z "$MIN" ]] && { MIN=0; AVG=0; MAX=0; MDEV=0; }


# GENERATE CSV
NEW_ROW="$DATE,$TIME,$MIN,$AVG,$MAX,$MDEV"
# echo $NEW_ROW | tr "," "\t"

LOG_FILE="$HOME/logs/${CURR_INTERFACE}_${WIFI_SSID}_ping_$1.csv"
mkdir -p $(dirname $LOG_FILE)
touch $LOG_FILE
echo $NEW_ROW >> $LOG_FILE

# Add header if needed
HEADER="DATE,TIME,MIN,AVG,MAX,MDEV"
if [ ! $(head -n 1 $LOG_FILE) == $HEADER ]; then
  sed -i "1i$HEADER" $LOG_FILE
fi

# To see all logs in bash:
# tail ~/logs/* | tr "," "\t"
