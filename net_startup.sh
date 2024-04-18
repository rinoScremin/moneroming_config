#!/bin/bash

# This script sets up a wireless connection on Tiny Core Linux

# Raise the wireless interface
sudo ifconfig wlan0 up

# The command below uses wpa_passphrase to create a configuration file for wpa_supplicant
# It outputs the necessary network block for wpa_supplicant to establish a connection with the wireless network
# The SSID and PSK (Pre-shared Key) are specified within
echo -e 'network={\n\tssid="SCREMIN"\n\tpsk=""\n}' | sudo tee /etc/wpa_supplicant.conf

# Run wpa_supplicant in the background (-B) with the wireless extensions driver (-D wext)
# wlan0 is the wireless network interface
# The configuration file is specified with -c
sudo wpa_supplicant -B -D wext -i wlan0 -c /etc/wpa_supplicant.conf

# udhcpc is a scriptable DHCP client program that obtains an IP address and configures the network
# The -i option is used to specify the network interface wlan0
sudo udhcpc -i wlan0 -n

# Configure the DNS resolver to use Google's public DNS server
# This step is necessary because Tiny Core Linux does not automatically set up DNS after DHCP
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# The final command pings google.com to test internet connectivity
ping -c 4 google.com

# End of the script
