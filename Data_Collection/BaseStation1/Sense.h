#ifndef SENSE_H
#define SENSE_H

enum {
  AM_MSG = 6,
  AM_SENSE_MSG_T = 0x89,
  
  NREADINGS = 1,
  DEFAULT_INTERVAL = 100,
};

typedef nx_struct sense_msg_t {
  nx_uint16_t version;      // periodic version 
  nx_uint16_t interval;     // periodic interval
  nx_uint16_t nodeID;       // node id (this node's id is 2)
  nx_uint16_t seq;          // sequence number
  nx_uint32_t token;        // token
  nx_uint16_t temp;         // temperature data
  nx_uint16_t humid;        // humidity data
  nx_uint16_t light;        // illumination data
  nx_uint32_t time;         // current time
}sense_msg_t;

#endif
