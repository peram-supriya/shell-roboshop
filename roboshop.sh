#!/bin/bash

SG_ID="sg-0f7364ef02abff9ad"
AMI_ID="ami-0220d79f3f480ecf5"
Zone_ID="Z0015741NRYMEGWZEYS6"
Domain_Name="thoshi.online"

for instance in $@

do
    Instance_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $instance == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
    --instance-ids $Instance_ID \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text
    )

        Record_Name="$Domain_Name"
    else
        IP=$(aws ec2 describe-instances \
    --instance-ids $Instance_ID \
    --query 'Reservations[*].Instances[*].PrivateIpAddress' \
    --output text
    )

    Record_Name="$instance.$Domain_Name"

    fi

    echo "IP address is: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $Zone_ID \
    --change-batch '
    
            {
        "Comment": "Updating record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$Record_Name'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        }
    '
echo "record updated for $instance"

done