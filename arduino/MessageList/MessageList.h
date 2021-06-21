#include "Arduino.h"
#ifndef MessageList_h
#define MessageList_h

class MessageList
{
  public:
    MessageList();
    ~MessageList();
    uint8_t* getList();
    void newMessage(uint32_t addL, uint32_t addH, uint8_t *frameData,
                    int offset, int dataSize);
    void appendMessage(int64_t c);
    uint8_t getMessageValue();
    uint32_t getSenderAddressLow();
    uint32_t getSenderAddressHigh();
    uint8_t* getData();
    int getListSize();
    int getDataSize();
    void deleteBigData();
    void deletePacketData();
    unsigned long getLastClockValue();
    int getMessageCount();
    void makeArray(uint8_t* arr, uint32_t address);

  private:
    int messageCount;
    void makeLong(unsigned long* l, uint8_t* arr);
    void setLastClockValue();
    int dataSize;
    uint32_t addressLow;
    uint32_t addressHigh;
    uint8_t *packetData;
    uint8_t *bigData;
    int bigDataSize;
    unsigned long clockValue;

};

#endif