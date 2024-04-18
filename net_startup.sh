#!/bin/bash

# Check for the WiFi password parameter.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <WiFi-Password>"
    exit 1
fi

# Assign the WiFi password from the script's parameter.
WIFI_PASSWORD=$1

# Function to check and load firmware.
load_firmware() {
    local FIRMWARE=$1
    tce-load -wi $FIRMWARE
    if [ $? -eq 0 ]; then
        echo "$FIRMWARE loaded successfully."
        return 0
    else
        echo "Failed to load $FIRMWARE."
        return 1
    fi
}

# Step 1: Identify the network hardware.
echo "Finding network hardware..."
HW_DESCRIPTION=$(lspci | grep -i network)

# Check if it's Atheros hardware.
if echo "$HW_DESCRIPTION" | grep -iq "atheros"; then
    echo "Atheros network hardware detected."
    load_firmware firmware-atheros && exit 0
fi

# Check if it's Broadcom hardware and attempt to load each firmware.
if echo "$HW_DESCRIPTION" | grep -iq "broadcom"; then
    echo "Broadcom network hardware detected."
    BROADCOM_FIRMWARES=("firmware-broadcom_bcm43xx" "firmware-broadcom_bnx2" "firmware-broadcom_bnx2x")
    
    for FW in "${BROADCOM_FIRMWARES[@]}"; do
        echo "Attempting to load $FW..."
        if load_firmware $FW; then
            echo "$FW successfully loaded, continuing with network setup..."
            break
        fi
    done
fi

# Assuming wlan0 is the wireless interface, if not, change as needed.
INTERFACE="wlan0"

# Generate WPA Supplicant configuration.
WPA_CONF="/etc/wpa_supplicant.conf"
echo -e "network={\n\tssid=\"SCREMIN\"\n\tpsk=\"$WIFI_PASSWORD\"\n}" | sudo tee $WPA_CONF

# Start WPA Supplicant.
sudo wpa_supplicant -B -D wext -i $INTERFACE -c $WPA_CONF

# Request an IP address.
sudo udhcpc -i $INTERFACE

# Set Google DNS.
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Test internet connectivity.
if ping -c 4 google.com; then
    echo "Internet connectivity established."
else
    echo "Failed to establish internet connectivity."
    exit 1
fi
