#include <Timer.h>
#include "Sense.h"

configuration SenseAppC 
{ 
} 
implementation { 
  
  components SenseC,MainC, LedsC, new TimerMilliC();
  components new SensirionSht11C();
  components new HamamatsuS1087ParC();

  components new AMSenderC(AM_MSG);
  components ActiveMessageC;

  //components new AMReceiverC(AM_MSG);

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  SenseC.ReadTemp -> SensirionSht11C.Temperature;
  SenseC.ReadHumid -> SensirionSht11C.Humidity;
  SenseC.ReadLight -> HamamatsuS1087ParC;

  SenseC.Packet -> AMSenderC;
  SenseC.AMPacket -> AMSenderC;
  SenseC.AMSend -> AMSenderC;
  SenseC.Control -> ActiveMessageC;

  //SenseC.Receive -> AMReceiverC;
}
