#!/bin/bash

SG_ID="sg-0f7364ef02abff9ad"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@

do
    Instance_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $Instance_ID == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
    --instance-ids $Instance_ID \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text
    )

    else
        IP=$(aws ec2 describe-instances \
    --instance-ids $Instance_ID \
    --query 'Reservations[*].Instances[*].PrivateIpAddress' \
    --output text
    )

    echo "IP address is: $IP"

    fi
done