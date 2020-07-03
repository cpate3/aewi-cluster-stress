#!/bin/bash
# usage from local MAC to target host : ./enable_serviceports.sh scan_ports <target host IP>
echo
echo "enabling ports:"
for i in `cat $1`
do
  ssh ec2-user@$2 -i ~<pem_key> "sudo nc -l $i" &
  
  echo "enabled port $i\n"
  
  sleep 1
done
