## Real-Time-Temperature-Prediction

Code for multi hop TelosB sensor network for temperature collection and machine learning model for real time prediction.
This project was carried to identify a robust, accurate predictive model that can be stacked upon an existing HVAC(Heating,Ventilation andAir Conditioning) system that can atomatically control the thermal comfort in an indoor setting.

+ Members : J. Dinal Herath, Zhihua Li.
+ E-mails : jherath1@binghamton.edu, zli191@binghamton.edu
+ video - [link](https://www.youtube.com/watch?v=KA2OW528ZYw&t=1s)

Instructions to run data collection code:

1. Put the 3 folders: BaseStation1, Relay, Sender into the App folder under the TinyOS directory. 
2. Run the serial forwarder: sudo java net.tinyos.sf.SerialForwarder -comm serial@/dev/ttyUSB0:telosb
3. Go to Java folder under BaseStation1, run the java code by typing: ./run

Note: to run this part, you need to plug the basestation mote to the usb port. And to compile, we need to run:
make telosB install,NODEID
The node ID for BaseStation is 633, relay is 622, sender is 589. 

Instructions to run predictive model code:

1. open a terminal in Predictive_Model/ directory
2. Activate tensorflow virtual environment
3. type 'python demo#i.py' (here #i = 1,2,3,4,5) {this will automatically run the demonstration code for any of the five datasets}

Note: after each demo is complete the predicted and actual temperature values and the computed RMSE results will be automatically saved to file. Dataset 1-4 were collected from the constructed sensor network, dataset 5 is an online outdoor temperature dataset used for demonstration purposes.
