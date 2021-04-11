#!/bin/bash

#-----------------------------------------------------------------------------------------------------
#			STEP 1: SET DATE AND TIME FROM GOOGLE SERVER
#-----------------------------------------------------------------------------------------------------
date=$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')
echo "Setting the date and time as"
sudo date -s "${date}"

#-----------------------------------------------------------------------------------------------------
#			STEP 2: RUNNING AWS_CLI BATCH SCRIPT TO CHECK IF AWS CLI IS INSTALLED
#-----------------------------------------------------------------------------------------------------
echo "Running the setup_awscli bash script"
./setup_awscli.sh

#-----------------------------------------------------------------------------------------------------
#			STEP 3: CHECK IF THE DEVICE IS REGISTERD IN AWS IOT CORE
#-----------------------------------------------------------------------------------------------------
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

#-----------------------------------------------------------------------------------------------------
#			STEP 4: RUN THE RESPECTIVE SCRIPT | DEVICE01 - PRESCRIPTIVE | DEVICE01 - ANOMALY 
#-----------------------------------------------------------------------------------------------------
cd ..
pip3 install AWSIoTPythonSDK

if [ $DEVICENAME == "device01" ]; then
      ~/Desktop/DEVICE/executable_files/display_msg.sh "SENDING CONCRETE DATA TO EDGE (PRESCRIPTIVE)"
      python3 connect_prescriptive.py
else
      ~/Desktop/DEVICE/executable_files/display_msg.sh "SENDING ANOMALY DATA TO EDGE (ANOMALY)"
      python3 connect_anomaly.py
fi