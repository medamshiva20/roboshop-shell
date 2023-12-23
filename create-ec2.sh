#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID="ami-081609eef2e3cc958"
SECURITY_GROUP_ID="sg-001887f7841106c09"

for i in "${NAMES[@]}"
do
if [[ $i == "mongodb" || $i == "mysql"]]
 then
    echo "$INSTANCE_TYPE="t3.medium"
 else
    echo "$INSTANCE_TYPE="t2.medium"
fi
    echo "creating $i instance"
    aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type t2.micro --key-name kubernetes --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
done
