#!/bin/bash

# exit when any command fails
set -e

#Setting date and time
date=$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')
echo "Setting the date and time as"
sudo date -s "${date}"

echo "Running the setup_awscli bash script"
./setup_awscli.sh

echo "Checking if the device is registerd. Else the device is registered in aws iot core"
DEVICENAME=$(cat ~/Desktop/DEVICE/deviceinfo.txt | grep -m1 -B1 "DEVICENAME" | grep -Po 'DEVICENAME:\K.*')
var=$(aws iot list-things | grep ${DEVICENAME}  )
if [ -z "$var" ]
then
      echo "${DEVICENAME} is not registered"
      ./setup_device.sh
else
      echo "${DEVICENAME} is registered"
fi


echo "Running the python script to connect with the greengrasscore"
cd ..
pip3 install AWSIoTPythonSDK
python3 connect_prescriptive.py
