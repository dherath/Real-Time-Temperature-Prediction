# python
import os
##---------------------
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
##---------------------
import numpy as np
from sklearn import linear_model
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys
import time

from fileprocessor import *
from preprocessor import *
from calculateError import *

# obtaining the Data ------------------------

x_length = 50 # the input sequence length
y_length = 20 # the output sequence length
filename = "data5.txt"
name_flag = "5_demo5_extra" # the name flag for the test case

train_test_seperation = 0.6 # 60% - train data, 40% - all test (validation - 20%, test - 20%)

X_train,Y_train,X_T,Y_T = getData(filename,x_length,y_length,train_test_seperation)

sz = len(X_T)/2 # split the generated test set 50-50 for validationa dn testing

X_train_data = np.array(X_train)
Y_train_data = np.array(Y_train)
X_validate_data = np.array(X_T[0:sz]) # validation set
Y_validate_data = np.array(Y_T[0:sz])

X_test_data = np.array(X_T[sz+1:-1]) # testing set
Y_test_data = np.array(Y_T[sz+1:-1])

name = name_flag+"_Y_test_x_"+str(x_length)+"_y_"+str(y_length)+"data.txt"
writetofile(name,Y_test_data)
print "-- loaded data : demo 5 - 1m Online Dataset --"
#--------------------------------------------
learning_rate = 0.01 # same learning rate as deep seq2seq model
complete_set = [i+1 for i in range(x_length+y_length)]
x_input = np.array(complete_set[0:x_length]).reshape(-1,1)
x_next = np.array(complete_set[x_length:len(complete_set)]).reshape(-1,1)

##---------------------------------------------------------------
## starting trnsorflow session
##---------------------------------------------------------------

length = len(X_test_data)
Y_found = []
regr = linear_model.LinearRegression()

initial_time = time.time()

for data_num in range(length):
    temp = np.array(X_test_data[data_num,:]).reshape(-1,1) #the value to train with
    regr.fit(x_input,temp)
    out_val = regr.predict(x_next)
    Y_found.append(out_val.tolist())

Y_found = np.array(Y_found)
Y_found.reshape(-1,y_length)

last_time = time.time()

avg_prediction_time = ((last_time - initial_time)/length) * 1000 # calculate time taken for a prediction
#print avg_prediction_time #for debugging

print "-- prediction complete --"

name = name_flag+"_Y_found_x_"+str(x_length)+"_y_"+str(y_length)+"data.txt"
writetofile(name,Y_found)
#print len(Y_found), len(Y_test_data)
err = RMSE(Y_test_data,Y_found)
name = name_flag+"_RMSE_x_"+str(x_length)+"_y_"+str(y_length)+"data.txt"
writeErrResult(name,err)

#------ plotting

predicted = []
for data in Y_found:
	predicted.append(data[0])

actual = []
for data in Y_test_data:
	actual.append(data[0])

x = [y for y in range(len(Y_found))]
plot_length = 50 # first 100 datapoint
enum_no = int(round(len(x)/plot_length))#enumeration number
#print enum_no # for debugging

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)

def animate(i):
	x_temp = x[i:i+plot_length]
	actual_temp = actual[i:i+plot_length]
	predicted_temp = predicted[i:i+plot_length]
	ax1.clear()
	ax1.plot(x_temp,actual_temp,'-k',x_temp,predicted_temp,'--r',linewidth=2)
	ax1.legend(["Actual","Predicted"], loc = "upper left")
	plt.title("Temperature Prediction (1 prediction = %.3f msec)"  %avg_prediction_time)
	plt.ylabel("Temperature")
	plt.xlabel("Time (m)")

ani = animation.FuncAnimation(fig,animate,interval=1000)
plt.show()

fig = plt.figure()
ax1 = fig.add_subplot(1,1,1)
ax1.plot(x,actual,'-k',x,predicted,'--r',linewidth=2)
ax1.legend(["Actual","Predicted"], loc = "upper right")
plt.title("Temperature Prediction (1 prediction = %.3f msec)"  %avg_prediction_time)
plt.ylabel("Temperature")
plt.xlabel("Time (m)")
plt.show()

print "----- run complete-------"









    
