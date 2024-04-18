#!/bin/bash

# Number of hugepages you want to allocate
NUM_HUGEPAGES=4

# Size of the huge pages, default to 1G if supported, otherwise 2M
HUGEPAGESIZE="1G"

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi

# Check if 1G huge pages are supported
if grep -q "Hugepagesize: 1048576 kB" /proc/meminfo; then
    echo "1G huge pages supported."
    HUGEPAGE_PATH="/sys/kernel/mm/hugepages/hugepages-1048576kB"
elif grep -q "Hugepagesize: 2048 kB" /proc/meminfo; then
    echo "1G huge pages not supported, using 2M huge pages instead."
    HUGEPAGESIZE="2M"
    HUGEPAGE_PATH="/sys/kernel/mm/hugepages/hugepages-2048kB"
else
    echo "No huge pages support found!"
    exit 1
fi

# Configure hugepages
echo "Configuring $HUGEPAGESIZE hugepages..."
echo $NUM_HUGEPAGES > $HUGEPAGE_PATH/nr_hugepages

# Verify the configuration
echo "Verifying $HUGEPAGESIZE hugepages allocation..."
grep -e HugePages_Total -e Hugepagesize /proc/meminfo

echo "If allocation is not successful, check available memory and try again."
