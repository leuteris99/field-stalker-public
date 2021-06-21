#include "Arduino.h"
#include <XBee.h>
#include<MessageList.h>
#include <SD.h>

#ifndef Messenger_h
#define Messenger_h

class Messenger
{
    public:
        Messenger();
        ~Messenger();
        void sendMessage(uint8_t * msg, uint8_t msg_size, XBeeAddress64 dest_address);
        byte sendATCommand(String command);
        void checkForPacketDelivery();
        void clearMsg();
        void setClockOnRecieve();
        void setChildDeviation();
        void forwardDataToFather();
        int16_t getLightValue();
        int16_t getMoistyValue();
        int16_t getTemperatureValue();
        byte setChild();
        byte getChildCount();
        XBeeAddress64 father;
        XBeeAddress64 bcst_address; 
        MessageList *msg;
        bool changed;
        File data_file;
    private:
        uint8_t *the_data;
        unsigned long clockOnRecieve;
        uint32_t children[15];
        int32_t childrenDeviation[15];
        byte childCount;
        XBee xbee;
        ZBTxRequest *zbTx;
        uint8_t payload[2] = {'H', 'i'}; 
        ZBExplicitRxResponse explicitResponse = ZBExplicitRxResponse();
};


#endif