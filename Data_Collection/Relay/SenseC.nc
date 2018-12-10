#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 100
#define NODE0 633
#define NODE1 622
#define NODE2 589

module SenseC {
  uses {
  	interface SplitControl as Control;
    interface Timer<TMilli>;
  	interface Packet;
  	interface AMSend;
  	interface AMPacket;
    interface Receive;
    interface Boot;
    interface Leds;
    interface Read<uint16_t> as ReadTemp;
    interface Read<uint16_t> as ReadHumid;
    interface Read<uint16_t> as ReadLight;
  }
}
implementation {
	message_t packet;
	sense_msg_t* recv_pkt;

	bool busy = FALSE;
	bool locked = FALSE;

	uint16_t cur_temp = 0;
	uint16_t cur_humid = 0;
	uint16_t cur_light = 0;
	
	uint16_t counter = 0;
	uint16_t version = 0;
    uint16_t interval = 2000;
  
  event void Boot.booted() {
  	call Control.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)(call Packet.getPayload(&packet, NULL));
            counter ++;
			this_pkt->nodeID = 1;
			this_pkt->temp = cur_temp;
			this_pkt->humid = cur_humid;
			this_pkt->light = cur_light;
			this_pkt->seq = counter;
			this_pkt->time = call Timer.getNow();
			this_pkt->token = 0xAFADB0D9;
			this_pkt->version = version;
			this_pkt->interval = interval;
			if(call AMSend.send(NODE0, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led0Toggle();
			}
		} else {
			post sendData();		
		}
  }
    
  event void Timer.fired() {
    call ReadTemp.read();
    call ReadHumid.read();
    call ReadLight.read();
    post sendData();
  }

  event void ReadTemp.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			cur_temp = data;
  	}
  }

  event void ReadHumid.readDone(error_t result, uint16_t data) {
    if (result == SUCCESS) {
	   cur_humid = data;
  	}
  }

  event void ReadLight.readDone(error_t result, uint16_t data) {
  	if (result == SUCCESS) {
			cur_light = data;
  	}
  }

  event void Control.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(interval);
		} else {
			call Control.start();
		}
  }

  event void Control.stopDone(error_t err) {}

event void AMSend.sendDone(message_t* msg, error_t error) {
	busy = FALSE;
}

	task void sendJumpData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = 2;
			this_pkt->temp = recv_pkt->temp;
			this_pkt->humid = recv_pkt->humid;
			this_pkt->light = recv_pkt->light;
			this_pkt->seq = recv_pkt->seq;
			this_pkt->time = recv_pkt->time;
			this_pkt->token = recv_pkt->token;
			this_pkt->version = recv_pkt->version;
			this_pkt->interval = recv_pkt->interval;

			//call Control.stop();
			call Leds.led1Toggle();
			
			if(call AMSend.send(NODE0, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led2Toggle();
			}
		} else {
			post sendJumpData();
		}
	}

	task void setFrequency() {
		if (busy) {
			call Timer.stop();
			call Timer.startPeriodic(interval);
		} else {
			post setFrequency();
		}
	}

  /* Receive jumpdata & new interval */
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
  	if( len == sizeof(sense_msg_t) ) {
  		//sense_msg_t* tmp_pkt = (sense_msg_t*)payload;
  
  		//if (tmp_pkt->token != 0xAFADB0D9) {
  		//	return msg;
  		//}
  
         if (call AMPacket.source(msg) == NODE2) {
  			recv_pkt = (sense_msg_t*)payload;
  			post sendJumpData();
  		}
  
       //   else if(tmp_pkt->nodeID == 3) {
  	//		recv_pkt = (sense_msg_t*)payload;
  	//		version = recv_pkt->version;
  	//		interval = recv_pkt->interval;

  	//	}
  	}
  	return msg;
  }
}

