/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Class holding all data received from a mote.
 */
class Node {
    /* Data is hold in an array whose size is a multiple of INCREMENT, and
       INCREMENT itself must be a multiple of Constant.NREADINGS. This
       simplifies handling the extension and clipping of old data
       (see setEnd) */
    final static int INCREMENT = 100 * Constants.NREADINGS;
    final static int MAX_SIZE = 100 * INCREMENT; // Must be multiple of INCREMENT

    /* The mote's identifier */
    int id;

    /* Data received from the mote. data[0] is the dataStart'th sample
       Indexes 0 through dataEnd - dataStart - 1 hold data.
       Samples are 16-bit unsigned numbers, -1 indicates missing data. */
    int[] data_temp, data_humid, data_light;
    int dataStart, dataEnd;

    Node(int _id) {
    id = _id;
    }

    /* Update data to hold received samples newDataIndex .. newEnd.
       If we receive data with a lower index, we discard newer data
       (we assume the mote rebooted). */
    private void setEnd(int newDataIndex, int newEnd) {
    if (newDataIndex < dataStart || data_temp == null) {
        /* New data is before the start of what we have. Just throw it
           all away and start again */
        dataStart = newDataIndex;
        data_temp = new int[INCREMENT];
        data_humid = new int[INCREMENT];
        data_light = new int[INCREMENT];
    }
    if (newEnd > dataStart + data_temp.length) {
        /* Try extending first */
        if (data_temp.length < MAX_SIZE) {
        int newLength = (newEnd - dataStart + INCREMENT - 1) / INCREMENT * INCREMENT;
        if (newLength >= MAX_SIZE) {
            newLength = MAX_SIZE;
        }

        int[] temp_newData = new int[newLength];
        System.arraycopy(data_temp, 0, temp_newData, 0, data_temp.length);
        data_temp = temp_newData;

        int[] humid_newData = new int[newLength];
        System.arraycopy(data_humid, 0, humid_newData, 0, data_humid.length);
        data_humid = humid_newData;

        int[] light_newData = new int[newLength];
        System.arraycopy(data_light, 0, light_newData, 0, data_light.length);
        data_light = light_newData;
        }

        if (newEnd > dataStart + data_temp.length) {
        /* Still doesn't fit. Squish.
           We assume INCREMENT >= (newEnd - newDataIndex), and ensure
           that dataStart + data.length - INCREMENT = newDataIndex */
        int newStart = newDataIndex + INCREMENT - data_temp.length;

        if (dataStart + data_temp.length > newStart) {
            System.arraycopy(data_temp, newStart - dataStart, 
                data_temp, 0, data_temp.length - (newStart - dataStart));
            System.arraycopy(data_humid, newStart - dataStart,
                data_humid, 0, data_humid.length - (newStart - dataStart));
            System.arraycopy(data_light, newStart - dataStart,
                data_light, 0, data_light.length - (newStart - dataStart));
        }
        dataStart = newStart;
        }
    }
    /* Mark any missing data as invalid */
    for (int i = dataEnd < dataStart ? dataStart : dataEnd;
         i < newDataIndex; i++) {
        data_temp[i - dataStart] = -1;
        data_humid[i - dataStart] = -1;
        data_light[i - dataStart] = -1;
    }

    /* If we receive a count less than the old count, we assume the old
       data is invalid */
    dataEnd = newEnd;

    }

    /* Data received containing NREADINGS samples from messageId * NREADINGS 
       onwards */
    void update(int messageId, int temp, int humid, int light) {
    int start = messageId * Constants.NREADINGS;
    setEnd(start, start + Constants.NREADINGS);
    data_temp[start - dataStart] = temp;
    data_humid[start - dataStart] = humid;
    data_light[start - dataStart] = light;
    }

    /* Return value of sample x, or -1 for missing data */
    int getTemp(int x) {
    if (x < dataStart || x >= dataEnd) {
        return -1;
    } else {
        return data_temp[x - dataStart];
    }
    }

    int getHumid(int x) {
    if (x < dataStart || x >= dataEnd) {
        return -1;
    } else {
        return data_humid[x - dataStart];
    }
    }

    int getLight(int x) {
    if (x < dataStart || x >= dataEnd) {
        return -1;
    } else {
        return data_light[x - dataStart];
    }
    }

    /* Return number of last known sample */
    int maxX() {
    return dataEnd - 1;
    }
}
