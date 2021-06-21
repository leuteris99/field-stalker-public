#include <XBee.h>
#include <MessageList.h>
#include <Messenger.h>


//The class to send and recieve messages
Messenger msger = Messenger();
uint8_t payload[] = {'H','i'}; 
bool isCoordinatorEnabled = false;
unsigned long getting_time;


void setup(){
  Serial.begin(9600);  
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  isCoordinatorEnabled = msger.sendATCommand("CE");
  delay(2000);
  if(isCoordinatorEnabled){
    msger.sendMessage(payload, sizeof(payload), msger.bcst_address);
    getting_time = millis();
    }
  else{
    while(msger.father == msger.bcst_address){
      msger.checkForPacketDelivery();
      if(msger.changed){
        msger.father = XBeeAddress64(msger.msg->getSenderAddressHigh(), msger.msg->getSenderAddressLow());
        msger.sendMessage(payload, sizeof(payload), msger.bcst_address);
        payload[0] = 67;
        msger.sendMessage(payload, sizeof(payload), msger.father);
       }
      }
    }
}


void loop(){
  if(isCoordinatorEnabled && millis() - getting_time > 10000){
    payload[0] = 71;
    msger.sendMessage(payload, sizeof(payload), msger.bcst_address);
    getting_time = millis();
    }
  msger.changed = false;
  msger.checkForPacketDelivery();
  if(msger.changed && msger.msg->getMessageValue() == 67){
    msger.setChild();
    Serial.println("No of children:");
    Serial.println(msger.getChildCount());
    msger.clearMsg();
    }
  else if(msger.changed && msger.msg->getMessageValue() == 71 && msger.father.getLsb() == msger.msg->getSenderAddressLow()){
    if(msger.getChildCount()){
      payload[0] = 71;
      sendPreamble();
      sendMeasurments();
      msger.sendMessage(payload, sizeof(payload), msger.bcst_address);
      msger.clearMsg();
      }
    else{
      sendPreamble();
      sendMeasurments();
      msger.clearMsg();
      }  
    }
  else if(msger.changed && msger.msg->getMessageValue() == 80){
    msger.setClockOnRecieve();
    msger.clearMsg();
    }
  else if(msger.changed && msger.msg->getMessageValue() == 82){
    msger.setChildDeviation();
    if(!isCoordinatorEnabled){
      msger.forwardDataToFather();
    }
    else{
      printTheData();
    }
    msger.clearMsg();
  }
}

void sendPreamble(){
  payload[0] = 80; 
  msger.sendMessage(payload, sizeof(payload), msger.father);
  }

void sendMeasurments(){
  unsigned long this_clock;
  int temperature = getTemperatureSensorValue(A0);
  int humidity = getLightSensorValue(A1);
  int light = getMoistySensorValue(A2);
  uint8_t data_size = sizeof(temperature) + sizeof(humidity) + sizeof(light) + sizeof(this_clock);
  uint8_t measurments[7 + data_size];
  measurments[0] = 82;
  measurments[1] = 1;
  measurments[6] = data_size;
  this_clock = millis();
  for(byte i = 0; i < 4; i++){
    measurments[i+2] = this_clock >> i*8;
    measurments[i+7] = measurments[i+2];  
    }
  measurments[11] = temperature;
  measurments[12] = temperature >> 8;
  measurments[13] = humidity;
  measurments[14] = humidity >> 8;
  measurments[15] = light;
  measurments[16] = light >> 8;
  
  msger.sendMessage(measurments, sizeof(measurments), msger.father);
  }
  
int getTemperatureSensorValue(int tempPin){
  return analogRead(tempPin);
  }
int getLightSensorValue(int lightPin){
  return analogRead(lightPin);
  }
int getMoistySensorValue(int moistyPin){
  return analogRead(moistyPin);
  }


void printTheData(){
  Serial.print("da,");
  Serial.print(msger.getTemperatureValue());
  Serial.print(",");
  Serial.print(msger.getLightValue());
  Serial.print(",");
  Serial.print(msger.getMoistyValue());
  Serial.println();

  Serial.println("dv," + String(millis()) + ",0,0");
  Serial.print("da,");
  Serial.print(getTemperatureSensorValue(A0));
  Serial.print(",");
  Serial.print(getLightSensorValue(A1));
  Serial.print(",");
  Serial.print(getMoistySensorValue(A2));
  Serial.println();
  }  
