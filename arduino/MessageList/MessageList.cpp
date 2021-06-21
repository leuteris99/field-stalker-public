#include "MessageList.h"
#include "Arduino.h"

MessageList::MessageList(){
  this->addressLow = 0;
  this->addressHigh = 0;
  this->bigDataSize = 0;
  this->dataSize = 0;
  this->messageCount = 0;
  this->clockValue = 0;
}


MessageList::~MessageList(){
  this->deleteBigData();
  this->deletePacketData();
}


uint8_t* MessageList::getList(){
  return this->bigData;
}


void MessageList::newMessage(uint32_t addL, uint32_t addH, uint8_t *frameData, int offset, int dataSize){
  this->messageCount++;
  this->deletePacketData();
  int j = 0;
  this->packetData = new uint8_t[dataSize];
  for (int i = offset; i < offset + dataSize; i++){
    this->packetData[j] = frameData[i];
    j++;
    }
  this->addressLow = addL;
  this->addressHigh = addH;
  this->dataSize = dataSize;
  if(packetData[0] == 82){
    this->setLastClockValue();
  }
}


void MessageList::appendMessage(int64_t c ){
  /*
  Remove the recieved packet to the bigData array, without the first 6 bytes
  and add the sender address at the end.
  */
  byte address_size = 4;
  unsigned long newTimestamp;
  uint8_t *add = new uint8_t[address_size];
  this->makeArray(add, this->addressLow);
  uint8_t *temp = new uint8_t[this->bigDataSize];
  for(int i = 0; i < this->bigDataSize; i++){
    temp[i] = this->bigData[i];
  }
  if (this->bigDataSize){
    delete[] this->bigData;
  }
  this->bigData = new uint8_t[this->bigDataSize + this->dataSize - 6 + address_size];
  for(int i = 0; i < this->bigDataSize; i++){
    this->bigData[i] = temp[i];
  }
  int j = 6;
  for(int i = 0; i < this->packetData[1]; i++){
    // c is difference
    makeLong(&newTimestamp, &this->packetData[j + 1]);
    //Serial.println();
    //Serial.print("Old timestamp: ");
    //Serial.println(newTimestamp);
    newTimestamp += c;
    //Serial.print("The difference is: ");
    //Serial.println(String(c));
    makeArray(&this->packetData[j+1], (uint32_t)newTimestamp);
    //Serial.print("New timestamp: ");
    //Serial.println(String(newTimestamp));
    j += this->packetData[j];
  }
  j=0;
  for(int i = 6; i < this->dataSize; i++){
    this->bigData[this->bigDataSize + j] = this->packetData[i];
    j++;
  }
  Serial.println("data size is:");
  Serial.println(this->getDataSize());
  if(this->getDataSize() <= 13){
    for(int i = 0; i < address_size; i++){
      this->bigData[this->bigDataSize + this->dataSize - 6 + i] = add[i];
    }
    this->bigDataSize = this->bigDataSize+ this->dataSize - 6 + address_size;
  }
  else{
    this->bigDataSize = this->bigDataSize + this->dataSize - 6;
  }
  if(this->bigDataSize){
    delete[] temp;
  }
  delete[] add;
}


void MessageList::deletePacketData(){
  if (this->dataSize>0){
    delete[] this->packetData;
    this->dataSize = 0;
  }
}


void MessageList::deleteBigData(){
  if(this->bigDataSize){
    delete[] this->bigData;
    this->bigDataSize = 0;
  }
}


void MessageList::makeArray(uint8_t* arr, uint32_t address){
  for(byte i = 0; i < 4; i++){
    arr[i] = address >> i*8;
    }
}

void MessageList::makeLong(unsigned long* l, uint8_t* arr){
  *l = 0;
  for(int i = 3; i >= 0; i--){
    *l = (*l) | arr[i];
    if (i != 0){
      *l = (*l) << 8;
    }
  }
}
void MessageList::setLastClockValue(){
  this->makeLong(&this->clockValue, &this->packetData[2]);
  /*
  this->clockValue = 0;
  for(int i = 5; i > 1; i--){
    this->clockValue = this->clockValue | this->packetData[i];
    this->clockValue = this->clockValue << (i-2)*8;
  }
  */
  //Serial.print(F("The clock that i recieved is: "));
  //Serial.println(this->clockValue);
}


unsigned long MessageList::getLastClockValue(){
  return this->clockValue;
}


uint8_t MessageList::getMessageValue(){
  return this->packetData[0];
}


uint32_t MessageList::getSenderAddressLow(){
  return this->addressLow;
}


uint32_t MessageList::getSenderAddressHigh(){
  return this->addressHigh;
}


uint8_t *MessageList::getData(){
  return this->packetData;
}


int MessageList::getListSize(){
  return this->bigDataSize;
}

int MessageList::getMessageCount(){
  return this->messageCount;
}

int MessageList::getDataSize(){
  return this->dataSize;
}