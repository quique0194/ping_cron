#!/bin/bash -e

# NAME: gui-launcher

# Check whether the user is logged-in
if [ -z "$(pgrep gnome-session -n -U $UID)" ]
then
    exit 0;
fi

# Export the current desktop session environment variables
export $(xargs -0 -a "/proc/$(pgrep gnome-session -n -U $UID)/environ")


###########################################################
# SCRIPT REALLY STARTS HERE
###########################################################

# Battery Capacity
BC="cat /sys/class/power_supply/BAT1/capacity"
SOCKETICON="/home/kike/Programs/socket.png"

if [ `$BC` -gt "95" ]; then
    if acpi | grep -q "Charging"; then
        /usr/bin/notify-send -i $SOCKETICON -u normal "Desconecta-el-cargador";
    fi
fi

if [ `$BC` -lt "30" ]; then
    if acpi | grep -q "Discharging"; then
        /usr/bin/notify-send -i $SOCKETICON -u normal "Conecta-el-cargador";
    fi
fi
