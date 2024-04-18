#!/bin/bash

# Check for the WiFi password parameter.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <WiFi-Password>"
    exit 1
fi

# Assign the WiFi password from the script's parameter.
WIFI_PASSWORD=$1

# Function to load firmware.
load_firmware() {
    local FIRMWARE=$1
    tce-load -wi $FIRMWARE
    if [ $? -eq 0 ]; then
        echo "$FIRMWARE loaded successfully."
        return 0
    else
        echo "Failed to load $FIRMWARE or it is already installed."
        return 1
    fi
}

# Step 1: Identify the network hardware and extract the identifier.
echo "Finding network hardware..."
HW_IDENTIFIER=$(lspci | grep -i network | awk '{print $1}')

# Attempt to load the firmware based on the hardware identifier.
load_firmware firmware-broadcom_bcm43xx || load_firmware firmware-broadcom_bnx2 || load_firmware firmware-broadcom_bnx2x

# Dynamically find the wireless interface name.
WIRELESS_INTERFACE=$(iw dev | grep Interface | awk '{print $2}')
if [ -z "$WIRELESS_INTERFACE" ]; then
    echo "No wireless interface found. Exiting."
    exit 1
fi
echo "Wireless interface found: $WIRELESS_INTERFACE"

# Rest of the script for setting up the network...
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

# Start WPA Supplicant using the found interface.
sudo wpa_supplicant -B -D wext -i $WIRELESS_INTERFACE -c /etc/wpa_supplicant.conf

# Obtain an IP address.
sudo udhcpc -i $WIRELESS_INTERFACE

# Set up DNS.
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Test internet connectivity.
ping -c 4 google.com

if [ $? -eq 0 ]; then
    echo "Internet connectivity looks good!"
else
    echo "Failed to establish internet connectivity."
    exit 1
fi
