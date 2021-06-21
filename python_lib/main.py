from package import Package
import db as db
import datetime
import serial
import re
import time

 #def __init__(self, id, ard_id, temp, light, humidity, timestamp):

if __name__ == "__main__":
    client = db.establishConnection()
    arduino = serial.Serial(port='COM3', baudrate=9600, timeout=.1)
    prepacket = {}
    id = 0
    p_id = 100
    while True:
        data = arduino.readline()
        if data != b'':
            data = re.sub(r"(b')|'", '', str(data))
            data = re.sub(r"(\\r)|(\\n)", '', data)
            if data[:2] == 'dv':
                data = data.split(",")
                id = data[3]
                prepacket[id] = time.time() + (int(data[1]) + int(data[2]))/1000
            if data[:2] == 'da':
                data = data.split(",")
                res = db.createData(Package(int(p_id), int(id), int(data[1]), int(data[2]), int(data[3]), int(prepacket[id])), client)
                print('db response:')
                print(res)
                p_id += 1
            print(data)
            

