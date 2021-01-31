''' Libraries'''
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
import requests
import json
import csv
import random

''' Global Variables'''
#Device name
deviceName='device01'
#certificate Path
certPath = 'certificates/certificate.pem.crt'
#key path
keyPath = 'certificates/private.pem.key'
#caPath
caPath = 'certificates/ggc-CA.ca'
#root caPath
rootcaPath = "certificates/root.ca.pem"
#Used to loop through all Connectivity options from GG Core
ggCoreConnectivityCount = 0
#publish topic
topic = 'greengrass/telemetry'
#Build the Greengrass Discover URL
greengrassDiscoverURL = 'https://greengrass-ats.iot.us-east-2.amazonaws.com' + ':8443/greengrass/discover/thing/' + deviceName
#MQTT Client
myAWSIoTMQTTClient = None
#QoS
QoS = 0
#Connection Status
connectionStatus = False
#endpoint address
endpoint = "abno170pso3ez-ats.iot.us-east-2.amazonaws.com"
#payload columns
columns = ["ID","Cement","Blast_Furnace_Slag","Fly_Ash","Water","Superplasticizer","Coarse_Aggregate","Fine_Aggregate","Age","Compressive_Strength"]

''' Methods'''
# Function to publish payload to MQTT topic
def publishToIoTTopic(myAWSIoTMQTTClient):
    print("Client connected to greengrass core device")
    cementData = (row for row in open('files/cement.csv','r'))
    counter = 1
    for payload in cementData:
        input("Enter to send message to: ")
        readings = next(cementData).split(",")
        readings[-1] = readings[-1].strip('\n')
        readings.insert(0,counter)
        payload = dict(zip(columns,readings))
        myAWSIoTMQTTClient.publish(topic, json.dumps(payload), QoS)
        counter+=1

# Function to initialise MQTT client
def MQTT_Connect(host,port):
    print(host,port)
    myAWSIoTMQTTClient = AWSIoTMQTTClient(deviceName)
    myAWSIoTMQTTClient.configureEndpoint(host, port)
    myAWSIoTMQTTClient.configureCredentials(caPath, keyPath, certPath)
    myAWSIoTMQTTClient.configureMQTTOperationTimeout(5)
    connectionStatus =  myAWSIoTMQTTClient.connect()
    if connectionStatus:
        publishToIoTTopic(myAWSIoTMQTTClient)
    else:
        print("Failed to connect")

'''greengrass discovery API '''
#Getting the details of the greengrass core and group through a greengrass discovery API
response = requests.get(greengrassDiscoverURL,cert=(certPath,keyPath))

if response.status_code != 200:
    print("http error")
    print(f"response error: {response.status_code}")
    print(f"response message: {response.text}")
    exit(-1)

#content of the response as json
response = response.json()
#contains the CA certificate of the greengrass group
ggCoreCA = response['GGGroups'][0]['CAs'][0]
#open file to wrie ggCoreCA
with open(caPath,'w') as file:
    file.write(ggCoreCA)
#contains ip address and port number of the greengrass core for communication
ggCoreConnectivity = response['GGGroups'][0]['Cores'][0]['Connectivity'][1]
#initialise mqtt client
MQTT_Connect(ggCoreConnectivity['HostAddress'],ggCoreConnectivity['PortNumber'])



