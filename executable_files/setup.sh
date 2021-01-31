#!/bin/bash

# exit when any command fails
set -e

#Setting date and time
date=$(curl -I 'https://google.com/' 2>/dev/null | grep -i '^date:' | sed 's/^[Dd]ate: //g')
echo "Setting the date and time as"
sudo date -s "${date}"

echo "Running the setup_awscli bash script"
./setup_awscli.sh

echo "Running the python script to connect with the greengrasscore"
cd ..
python3 connect.py
