/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;

/* The "Oscilloscope" demo app. Displays graphs showing data received from
   the Oscilloscope mote application, and allows the user to:
   - zoom in or out on the X axis
   - set the scale on the Y axis
   - change the sampling period
   - change the color of each mote's graph
   - clear all data

   This application is in three parts:
   - the Node and Data objects store data received from the motes and support
     simple queries
   - the Window and Graph and miscellaneous support objects implement the
     GUI and graph drawing
   - the Oscilloscope object talks to the motes and coordinates the other
     objects

   Synchronization is handled through the Oscilloscope object. Any operation
   that reads or writes the mote data must be synchronized on Oscilloscope.
   Note that the messageReceived method below is synchronized, so no further
   synchronization is needed when updating state based on received messages.
*/
public class Oscilloscope implements MessageListener
{
    MoteIF mote;
    Data data;
    Window window;

    /* The current sampling period. If we receive a message from a mote
       with a newer version, we update our interval. If we receive a message
       with an older version, we broadcast a message with the current interval
       and version. If the user changes the interval, we increment the
       version and broadcast the new interval and version. */
    int interval = Constants.DEFAULT_INTERVAL;
    int version = 0;

    /* Main entry point */
    void run() {
    data = new Data(this);
    window = new Window(this);
    //window.setup();
    mote = new MoteIF(PrintStreamMessenger.err);
    mote.registerListener(new OscilloscopeMsg(), this);
    }

    /* The data object has informed us that nodeId is a previously unknown
       mote. Update the GUI. */
    void newNode(int nodeId) {
    //window.newNode(nodeId);
    }

    public synchronized void messageReceived(int dest_addr, 
            Message msg) {
        if (msg instanceof OscilloscopeMsg) {
            OscilloscopeMsg recv_msg = (OscilloscopeMsg)msg;
            long time;
            long token = 2947395801l;
            int nodeID, seq, temp, humid, light, version, interval;

            if (recv_msg.get_token() != token) {return;}

            /* Get data and convert */
            nodeID = recv_msg.get_nodeID();
            seq = recv_msg.get_seq();
            temp = recv_msg.get_temp();
            humid = recv_msg.get_humid();
            light = recv_msg.get_light();
            time = recv_msg.get_time();
            version = recv_msg.get_version();
            interval = recv_msg.get_interval();

           // temp = -39.6 + temp * 0.01;
           // humid = -4 + 0.0405 * humid - 0.0000028 * humid * humid;

            temp = (int)(-40.1 + temp * 0.01);
            humid = (int)(-4 + 0.0405 * humid - 0.0000028 * humid * humid);
            //light = (int)(6250000000 * light);

            /* print out result.txt */
            try {
                BufferedWriter bw = 
                    new BufferedWriter(
                    new FileWriter(
                    new File("../result.txt"), true));
                bw.write(nodeID + " " 
                       + seq + " " 
                       + temp + " " 
		       + light + " " 
                       + humid + " \n" );
 		System.out.println("reading: " +nodeID + " " 
                       + seq + " " 
                       + temp + " " 
		       + light + " " 
                       + humid + " \n" );
                       //+ light + " " 
                       //+ time + "\n");
                bw.flush();
                bw.close();
    		} catch (IOException e) {
    		}

            /* Update interval and mote data */
            periodUpdate(version, interval);
            data.update(nodeID, seq, temp, humid, light);
            /* Inform the GUI that new data showed up */
            //window.newData();
        }
        }

        /* A potentially new version and interval has been received from the
           mote */
        void periodUpdate(int moteVersion, int moteInterval) {
        }

    /* The user wants to set the interval to newPeriod. Refuse bogus values
       and return false, or accept the change, broadcast it, and return
       true */
    synchronized boolean setInterval(int newPeriod) {
    if (newPeriod < 1 || newPeriod > 65535) {
        return false;
    }
    interval = newPeriod;
    version++;
    sendInterval();
    return true;
    }

    /* Broadcast a version+interval message. */
    void sendInterval() {
    OscilloscopeMsg send_msg = new OscilloscopeMsg();

    send_msg.set_version(version);
    send_msg.set_interval(interval);
    send_msg.set_nodeID(3);
    send_msg.set_temp(0);
    send_msg.set_humid(0);
    send_msg.set_light(0);
    send_msg.set_time(0);
    send_msg.set_seq(0);
    send_msg.set_token(0xAFADB0D9);
    try {
        mote.send(MoteIF.TOS_BCAST_ADDR, send_msg);
    }
    catch (IOException e) {
        window.error("Cannot send message to mote");
    }
    }

    /* User wants to clear all data. */
    void clear() {
    data = new Data(this);
    }

    public static void main(String[] args) {
    Oscilloscope me = new Oscilloscope();
    me.run();
    }
}
