#!/bin/sh -e

sysctl -w vm.nr_hugepages=$(nproc)

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Configure 1GB hugepages
echo "Configuring 1GB hugepages..."
echo $NUM_HUGEPAGES > /proc/sys/vm/nr_hugepages

# Verify the configuration
echo "Verifying 1GB hugepages allocation..."
grep -e HugePages_Total -e Hugepagesize /proc/meminfo

echo "If allocation is not successful, check available memory and try again."
