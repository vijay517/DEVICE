#!/bin/bash

# exit when any command fails
set -e

ROOTDIR=~/Desktop/DEVICE

#-----------------------------------------------------------------------------------------------------
#			STEP 1: CHECKING IF deviceinfo.txt FILES ARE PRESENT
#-----------------------------------------------------------------------------------------------------

#Checking if the device info text in present
if [ ! -f $ROOTDIR/deviceinfo.txt ]
then
	echo "authentication file keys.csv does not exist in the directory:" $(pwd)
	exit -1
fi

#--------------------------------------------------------------------------------------------------------
#	STEP 2: CREATING THING, CERT AND PRIVATE KEY FOR THE THING. THE POLICY AND CERT IS ATTACHED TO THE THING  
#--------------------------------------------------------------------------------------------------------

#Creating a IoT thing in IoT core in aws
DEVICENAME=$(cat ${ROOTDIR}/deviceinfo.txt | grep -m1 -B1 "DEVICENAME" | grep -Po 'DEVICENAME:\K.*')
aws iot create-thing --thing-name $DEVICENAME

#Create certificate and keys. After creating the keys, the certificate arn is stored for further use
certificateArn=$(aws iot create-keys-and-certificate --set-as-active --certificate-pem-outfile certificate.pem.crt --private-key-outfile private.pem.key | grep -B1 certificateArn | grep -Po '"'"certificateArn"'"\s*:\s*"\K([^"]*)')

#Move the private key and certificate to the certificate directory
mv private.pem.key certificate.pem.crt $ROOTDIR/certificates/

#Attach the policy and certificate to the thing
aws iot attach-policy --policy-name labPolicy --target $certificateArn
aws iot attach-thing-principal --thing-name $DEVICENAME --principal $certificateArn

