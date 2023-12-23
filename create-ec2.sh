#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID="ami-081609eef2e3cc958"
SECURITY_GROUP_ID="sg-001887f7841106c09"
DOMAIN_NAME="sivadevops.website"

# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro
for i in "${NAMES[@]}"
do
  if [[ $i == "mongodb" || $i == "mysql" ]];
   then
      INSTANCE_TYPE="t3.medium"
   else
      INSTANCE_TYPE="t2.micro"
  fi
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type t2.micro --key-name kubernetes --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances.PrivateIpAddress')
    echo "Created $i instances: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z098285010FMU6PDV8O9P --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done
