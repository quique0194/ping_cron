#!/bin/bash
# https://askubuntu.com/questions/522505/script-to-monitor-internet-connection-stability
#***************************************
# FOR CRONTAB
# */10 * * * * /location/of/my-internet-test.sh
#***************************************

# DEFINE NET VARS
CURR_INTERFACE=$(ip route list | grep '^default' | awk  '{print $5}' | head -n 1)
WIFI_SSID=$(iwgetid $CURR_INTERFACE -r)
CURR_IS_METERED=$(nmcli -t -f GENERAL.METERED dev show $CURR_INTERFACE | grep -o "yes")


# DO NOT RUN ON METERED CONNECTIONS
[[ ! -z "$CURR_IS_METERED" ]] && echo "Metered connection, aborting" && exit 0


# GET CSV VARS
SPEED_TEST_RES=$(speedtest-cli --simple 2>/dev/null)

DT=$(date '+%Y-%m-%dT%H:%M:%S')
DL=$(echo $SPEED_TEST_RES | awk '{print $5}')
UL=$(echo $SPEED_TEST_RES | awk '{print $8}')
PING=$(echo $SPEED_TEST_RES | awk '{print $2}')

[[ -z "$DL" ]] && { DL=0; UL=0; PING=0; }


# GENERATE CSV
NEW_ROW="$DT,$PING,$DL,$UL"

LOG_FILE="$HOME/logs/internet_test_${CURR_INTERFACE}_${WIFI_SSID}.csv"
mkdir -p $(dirname $LOG_FILE)
touch $LOG_FILE
echo $NEW_ROW  >> $LOG_FILE

# Add header if needed
HEADER="TIME,PING,DOWNLOAD,UPLOAD"
if [ ! $(head -n 1 $LOG_FILE) == $HEADER ]; then
  sed -i "1i$HEADER" $LOG_FILE
fi
