#include "Messenger.h"
#include "Arduino.h"




Messenger::Messenger(){
    this->xbee = XBee();
    this->father = XBeeAddress64(0x00000000, 0x0000ffff); 
    this->bcst_address = XBeeAddress64(0x00000000, 0x0000ffff); 
    this->zbTx = new ZBTxRequest(this->bcst_address, this->payload, sizeof(this->payload));
    this->msg = new MessageList();
    this->changed = false;
    this->childCount = 0;
    for(byte i = 0; i < 15; i++){
        this->childrenDeviation[i] = 0;
        this->children[i] = 0;
    }
    Serial.print("Initializing SD card...");
    if (!SD.begin(4)) {
        Serial.println("initialization failed!");
        while (1);
    }

}


Messenger::~Messenger(){
    delete this->msg;
    delete this->zbTx;
}


void Messenger::sendMessage(uint8_t * msg, uint8_t msg_size, XBeeAddress64 dest_address) {
    delete zbTx;
    this->zbTx = new ZBTxRequest(dest_address, msg, msg_size);
    this->zbTx->setBroadcastRadius(0x1);
    this->xbee.send(*this->zbTx);
    //Serial.println(F("The Message Was Sent With Address:"));
    //Serial.println(zbTx->getAddress64().getLsb(), HEX)
}


void Messenger::checkForPacketDelivery(){
    this->xbee.readPacket();
    ZBTxStatusResponse txStatus = ZBTxStatusResponse();
    if (this->xbee.getResponse().isAvailable()) {
        this->changed = true;
        // got something
        //my_clock = millis();
        //Serial.println(F("Got The Message"));
        if (this->xbee.getResponse().getApiId() == ZB_EXPLICIT_RX_RESPONSE) {
            this->xbee.getResponse().getZBExplicitRxResponse(this->explicitResponse);
            this->msg->newMessage(this->explicitResponse.getRemoteAddress64().getLsb(),
                                  this->explicitResponse.getRemoteAddress64().getMsb(),
                                  this->explicitResponse.getFrameData(),
                                  this->explicitResponse.getDataOffset(),
                                  this->explicitResponse.getDataLength());
            //Serial.println(F("Data: "));
            uint8_t *messageData = this->msg->getData();
            for(int i = 0; i < this->explicitResponse.getDataLength(); i++){
                //Serial.print(messageData[i]);
                //Serial.print(F(","));
                }
            //Serial.println();
            //Serial.print(F("    Size: "));
            //Serial.println(this->explicitResponse.getDataLength());
        }
    } else if (this->xbee.getResponse().getApiId() == ZB_TX_STATUS_RESPONSE) {
        this->xbee.getResponse().getZBTxStatusResponse(txStatus);
        //Serial.println(txStatus.getDeliveryStatus(), HEX);
        //get the delivery status, the fifth byte
        if (txStatus.getDeliveryStatus() == SUCCESS) {
            //Serial.print(F("Successful transmition\n"));
        } 
        else {
            // the remote XBee did not receive our packet. is it powered on?
            //Serial.print(F("Unsuccessful transmition\n"));
        }   
    }
    else if (this->xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
        //Serial.println(F("It Is A ZB_RX_RESPONSE"));
    } else if (this->xbee.getResponse().isError()) {
        //Serial.print(F("Error reading packet.  Error code: "));
    //nss.println(xbee.getResponse().getErrorCode());
    }
}

void Messenger::setChildDeviation(){
    for (byte i = 0; i < this->childCount; i++){
        if (this->children[i] == this->msg->getSenderAddressLow()){
            this->data_file = SD.open("trudata.csv", FILE_WRITE);
            this->childrenDeviation[i] = int64_t(this->clockOnRecieve) - this->msg->getLastClockValue();
            data_file.print(this->childrenDeviation[i]);
            Serial.print("dv," + String(this->msg->getLastClockValue()) + "," + String(this->childrenDeviation[i]) + ",");
            Serial.println(this->msg->getSenderAddressLow());
            data_file.close();
            break;
        }
    }
}

void Messenger::forwardDataToFather(){
    for (byte i = 0; i < this->childCount; i++){
        if (this->children[i] == this->msg->getSenderAddressLow()){
            this->msg->appendMessage(this->childrenDeviation[i]);
            this->the_data = new uint8_t[this->msg->getListSize() + 1];
            this->the_data[0] = 82;
            for(byte j = 1; j< this->msg->getListSize() + 1; j++){
                this->the_data[j] = this->msg->getList()[j-1];
            }
            this->sendMessage(this->the_data, this->msg->getListSize() + 1, this->father);
            delete this->msg;
            this->msg = new MessageList();
            break;
        }
    }
}

void Messenger::setClockOnRecieve(){
    this->clockOnRecieve = millis();
}

void Messenger::clearMsg(){
    this->msg->deletePacketData();
}

byte Messenger::setChild(){
    for(byte i = 0; i < this->childCount; i++)
        if(this->children[i] == this->msg->getSenderAddressLow()) return 0;
    this->children[this->childCount] = this->msg->getSenderAddressLow();
    this->childCount++;
    return 1;
}

byte Messenger::getChildCount(){
    return this->childCount;
}

int Messenger::getTemperatureValue(){
    return (int16_t(this->msg->getData()[12]) << 8) | this->msg->getData()[11];
}

int Messenger::getMoistyValue(){
    return (int16_t(this->msg->getData()[14]) << 8) | this->msg->getData()[13];
}

int Messenger::getLightValue(){
    return (int16_t(this->msg->getData()[16]) << 8) | this->msg->getData()[15];
}

byte Messenger::sendATCommand(String command) {
  //This is the Coordinator Command that we need  to read upon the initialization of the
  //network so that we can tell the coordinator only to start looking for neighbours.
  uint8_t CoEnCmd[] = {'C', 'E'};
  //This Command is nessessary for writing the command we previously gave to the XBee module.
  uint8_t writeCmd[] = { 'W', 'R' };
  //Below we have the request for the AT Command
  AtCommandRequest atRequest = AtCommandRequest(CoEnCmd);
  //And here we have the response of the AT Command Requset.
  AtCommandResponse atResponse = AtCommandResponse();
  if (command == "CE") {
    //Here we tell the request which command to send to the XBee module.
    atRequest.setCommand(CoEnCmd);
  } else if (command == "WR") {
    atRequest.setCommand(writeCmd);
  }
  // send the command
  this->xbee.send(atRequest);
  // wait up to 5 seconds for the status response
  if (this->xbee.readPacket(250)) {
    // got a response!
    // should be an AT command response
    if (this->xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
        this->xbee.getResponse().getAtCommandResponse(atResponse);
        if (atResponse.isOk()) {
            if (atResponse.getValueLength() > 0) {
                for (int i = 0; i < atResponse.getValueLength(); i++) {
                    if (atResponse.getValue()[i] == 0x1) {
                        Serial.println(" Coordinator Is Enabled");
                        return 1;
                    }
                }
            }
        }
        else {
            Serial.print("Command return error code: ");
            Serial.println(atResponse.getStatus(), HEX);
        }
    } else {
        Serial.print("Expected AT response but got ");
        Serial.print(this->xbee.getResponse().getApiId(), HEX);
    }
  } else {
    // at command failed
        if (this->xbee.getResponse().isError()) {
            Serial.print("Error reading packet.  Error code: ");
            Serial.println(this->xbee.getResponse().getErrorCode());
        }
        else {
            Serial.print("No response from radio");
        }
  }
    return 0;
}