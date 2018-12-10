#include "Timer.h"
#include "Sense.h"

#define SAMPLING_FREQUENCY 1000
#define NODE0 633
#define NODE1 622
#define NODE2 589

module SenseC {
  uses {
  	interface SplitControl as Control1;
  	interface SplitControl as Control2;
  	interface AMPacket;
    interface Receive;
  	interface AMSend as AMSend1;  // 1: to PC serial
  	interface AMSend as AMSend2;  // 2: to Nodes
  	interface Packet as Packet1;
  	interface Packet as Packet2;
    interface Boot;
    interface Leds;
  }
}
implementation {
	message_t packet;
	sense_msg_t* recv_pkt;

	bool busy = FALSE;
	uint16_t cur_nodeID, cur_temp, cur_humid, cur_light, cur_seq, cur_version, cur_interval;
	uint32_t cur_time = 0, cur_token;
	uint16_t version = 0, interval = 100;
  
  event void Boot.booted() {
  	call Control1.start();
  	call Control2.start();
  }

  task void sendData() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet1.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = cur_nodeID;
			this_pkt->temp = cur_temp;
			this_pkt->humid = cur_humid;
			this_pkt->light = cur_light;
			this_pkt->seq = cur_seq;
			this_pkt->time = cur_time;
			this_pkt->token = cur_token;
			this_pkt->version = cur_version;
			this_pkt->interval = cur_interval;
			
			if (call AMSend1.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;

				call Leds.led2Toggle();
			}
		} else {
			post sendData();
		}
  }

  task void sendChangeFreq() {
		if (!busy) {
			sense_msg_t* this_pkt = (sense_msg_t*)call Packet2.getPayload(&packet, sizeof(sense_msg_t));
			this_pkt->nodeID = 3;
			this_pkt->time = 0;
			this_pkt->temp = 0;
			this_pkt->humid = 0;
			this_pkt->light = 0;
			this_pkt->token = 0xAFADB0D9;
			this_pkt->seq = 0;
			this_pkt->version = version;
			this_pkt->interval = interval;

			if (call AMSend2.send(AM_BROADCAST_ADDR, &packet, sizeof(sense_msg_t)) == SUCCESS) {
				busy = TRUE;
				call Leds.led1Toggle();
			}
		} else {
			post sendChangeFreq();
		}
  }
  
	event void AMSend1.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			busy = FALSE;
		}
	}

	event void AMSend2.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			busy = FALSE;
		}
	}

  event void Control1.startDone(error_t err) {
		if (err == SUCCESS) {
			
		} else {
			call Control1.start();
		}
  }

  event void Control1.stopDone(error_t err) {}

  event void Control2.startDone(error_t err) {
		if (err == SUCCESS) {
			
		} else {
			call Control2.start();
		}
  }

  event void Control2.stopDone(error_t err) {}

  /* receive packets */
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
//call Leds.led0Toggle();
		if (len == sizeof(sense_msg_t)) {
			sense_msg_t* tmp_pkt = (sense_msg_t*)payload;

			if (tmp_pkt->token != 0xAFADB0D9) {
				return msg;
			} 

            else if (tmp_pkt->nodeID == 3) {
				recv_pkt = (sense_msg_t*)payload;
				version = recv_pkt->version;
				interval = recv_pkt->interval;
				post sendChangeFreq();
			} 

            else{
call Leds.led2Toggle();
					
				//if ((tmp_pkt->nodeID == 1 || tmp_pkt->nodeID == 0x2) && call AMPacket.source(msg) == NODE1 ) {
//call Leds.led0Toggle();
                    //if ( recv_pkt->interval != interval) return msg;
call Leds.led0Toggle();
					recv_pkt = (sense_msg_t*)payload;
					cur_nodeID = recv_pkt->nodeID;
					cur_temp = recv_pkt->temp;
					cur_humid = recv_pkt->humid;
					cur_light = recv_pkt->light;
					cur_seq = recv_pkt->seq;
					cur_time = recv_pkt->time;
					cur_version = recv_pkt->version;
					cur_interval = recv_pkt->interval;
					cur_token = recv_pkt->token;
					post sendData();
				//}
			} 
		}
		return msg;
  }
}
