
#!/bin/bash
#Usage ./basic_net_trace.sh

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
EC2_URL="https://ec2.$EC2_REGION.amazonaws.com"
EC2_domain="ec2.$EC2_REGION.amazonaws.com"
MY_INSTANCE_ID=`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/instance-id`
INTERFACE=`/usr/bin/curl --silent  http://169.254.169.254/latest/meta-data/network/interfaces/macs/`
SUBNET_ID=`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/$INTERFACE/subnet-id`
VPC_ID=`/usr/bin/curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/$INTERFACE/vpc-id`
HOSTED_ZONE=`dig $EC2_domain && nslookup $EC2_domain`
# Prerequisites
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install traceroute -y

echo `date` "---- tracing EC2_URL ----"

wget $EC2_URL
traceroute $EC2_domain

echo `date` "---- your VPCID is $VPC_ID ----"
echo `date` "---- your AZs are $EC2_AVAIL_ZONE ----"
echo `date` "---- your subnets is $SUBNET_ID ----"
echo `date` "---- your domain is $EC2_domain ----"
echo `date` "---- your domain resolution is $HOSTED_ZONE ----"

sleep 1

EOF
