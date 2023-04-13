#!/bin/sh
export PATH=.:/proc/boot:/bin:/usr/bin:/usr/sbin:/sbin:/mnt/app/media/gracenote/bin:/mnt/app/armle/bin:/mnt/app/armle/sbin:/mnt/app/armle/usr/bin:/mnt/app/armle/usr/sbin
export LD_LIBRARY_PATH=/lib:/mnt/app/root/lib-target:/eso/lib:/mnt/app/usr/lib:/mnt/app/armle/lib:/mnt/app/armle/lib/dll:/mnt/app/armle/usr/lib
export IPL_CONFIG_DIR=/etc/eso/production 
export LOGFILES_DIR=/mnt/ota/system/logs
export COREFILES_DIR=/mnt/ota/system/core

# We do not want VW-HMI specific libecpp
unset LD_PRELOAD

# Info
TOPIC=EEPROM
echo "This script will dump the EEPROM."

# Include SD card mount script
. /eso/hmi/engdefs/scripts/mqb/util_mountsd.sh

# Include info script
. /eso/hmi/engdefs/scripts/mqb/util_info.sh

# Make dump folder
DUMPFOLDER=$VOLUME/Dump/$VERSION/$FAZIT/$TOPIC

echo "Dump-folder: $DUMPFOLDER"
mkdir -p $DUMPFOLDER
echo "Dumping, please wait. This can take a while..."
echo "Be patient, it will look like nothing is happening."
on -f rcc /net/rcc/usr/apps/modifyE2P r 0 10000 > $DUMPFOLDER/eepromdump.txt
echo 
echo "EEPROM dump is saved to $DUMPFOLDER."
sleep 1

# Show contents
echo "Text dump done, converting to binary..."

INFILE=$DUMPFOLDER/eepromdump.txt
BINFILE=$DUMPFOLDER/eepromdump.bin

# Ensure single-byte output from awk
export LC_ALL=C
HEX=$(sed -rn 's/^0x\S+\W+(.*?)$/\1/p' "${INFILE}" | sed -rn 's:\W*(\S\S)\W*:0x\1\n:pg' | sed -rn '/^0x/p')
echo "${HEX}" | awk '{printf("%c",strtonum($0))}' > "${BINFILE}"

echo "Written: ${BINFILE}"
echo "-------------------------------------"

echo ""
echo "Done. You can now read the entire eeprom from the dump on the SD"

exit 0
