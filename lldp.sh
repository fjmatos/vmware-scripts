#!/bin/sh
# Enable/Disable LLDP on vSwitch ports on VMWare ESXi
# Tested with ESXi 6.0.0 3620759
# Doesn't need vCenter, only SSH access to the ESXi machine
# (c) Pekka "raspi" Jarvinen 2016 http://raspi.fi/

SWITCH=$1
OPERATION=$2

if [ "$SWITCH" = "" ] || [ "$OPERATION" = "" ]; then
  echo "Enable/disable LLDP on vSwitch"
  echo ""
  echo "USAGE:"
  echo "$0 <vSwitch> <operation>"
  echo "Examples: "
  echo "Enable LLDP: $0 vSwitch0 1"
  echo "Disable LLDP: $0 vSwitch0 0"

  exit 1
fi

case "$OPERATION" in
    0) ;;
    1) ;;
    *) echo "Invalid operation: $OPERATION"; exit 1 ;;
esac


for PORT in `vsish -e ls /net/portsets/$SWITCH/ports | sed 's/\/$//'`
do
  echo "Port: $PORT"
  DATA=`vsish -e get /net/portsets/$SWITCH/ports/$PORT/status`
  echo "$DATA" | grep -i "port index:"
  echo "$DATA" | grep -i "clientName:"
  echo "$DATA" | grep -i "clientType:"
  echo "$DATA" | grep -i "portCfg:"

  echo "  Trying to change LLDP state to $OPERATION.."
  vsish -e set /net/portsets/$SWITCH/ports/$PORT/lldp/enable $OPERATION &> /dev/null

  LLDPSTATE=`vsish -e get /net/portsets/$SWITCH/ports/$PORT/lldp/enable`
  if [ "$LLDPSTATE" = "$OPERATION" ]; then 
    echo "  LLDP state successfully changed"
  else
    echo "  ERROR: changing LLDP state failed"
  fi

  echo "------------------------------"
  echo ""
  
done
