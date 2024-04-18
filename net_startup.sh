#!/bin/bash

# Check for the WiFi password parameter
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <WiFi-Password>"
    exit 1
fi

# Assign the WiFi password from the script's parameter
WIFI_PASSWORD=$1

# Step 1: Identify the network hardware
echo "Finding network hardware..."
NETWORK_HARDWARE=$(lspci | grep -i network)
echo "Network hardware found: $NETWORK_HARDWARE"

# Step 2: Attempt to load the Atheros firmware
echo "Loading Atheros firmware..."
tce-load -wi firmware-atheros

# Check if the firmware load was successful
if [ $? -eq 0 ]; then
    echo "Firmware loaded successfully."
else
    echo "Failed to load firmware. Checking if it's already installed..."

    # Check if firmware exists on HDD
    if [ -e /usr/local/lib/firmware/ath9k_htc ]; then
        echo "Firmware found on HDD."
    else
        echo "Firmware not found. Exiting."
        exit 1
    fi
fi

# Bring up the wlan0 interface
sudo ifconfig wlan0 up

# Use the password to create a wpa_supplicant configuration file
echo "Configuring WPA supplicant..."
echo -e "network={\n\tssid=\"SCREMIN\"\n\tpsk=\"$WIFI_PASSWORD\"\n}" | sudo tee /etc/wpa_supplicant.conf

# Start wpa_supplicant
sudo wpa_supplicant -B -D wext -i wlan0 -c /etc/wpa_supplicant.conf

# Acquire an IP address
echo "Acquiring IP address..."
sudo udhcpc -i wlan0

# Set DNS to Google's public DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Test the connection
echo "Testing connection..."
ping -c 4 google.com

if [ $? -eq 0 ]; then
    echo "Internet connectivity looks good!"
else
    echo "Failed to connect to the Internet."
fi

# End of the script
