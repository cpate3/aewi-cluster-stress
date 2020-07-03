#!/bin/bash
# usage : ./check_serviceports.sh <host IP address>

SERVER=$1

>/tmp/failed
>/tmp/success

for PORT in `cat scan_ports`
do
  l_TELNET=`echo "quit" | telnet $SERVER $PORT | grep "Escape character is"`
  if [ "$?" -ne 0 ]; then
    echo "Connection to $SERVER on port $PORT failed"
    echo $i >> /tmp/failed
  else
    echo "Connection to $SERVER on port $PORT succeeded"
    echo $i >> /tmp/success
  fi
  sleep 1
done
