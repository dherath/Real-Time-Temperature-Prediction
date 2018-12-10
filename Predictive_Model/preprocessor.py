import numpy as np

#-----------------------------------------
# helper functions for getData()
#-----------------------------------------

def openFile(filename):
    data = []
    with open(filename) as f:
        for line in f:
            words = line.split()
            data.append(words[0])
    return data


def sampleData(dataset,x_length,y_length):
    x_data_limit = len(dataset) - (x_length+y_length)
    X = []
    Y = []
    for i in range(x_data_limit):
        # for the inputs
        temp_x = []
        for j in range(x_length):
            temp_x.append(dataset[i+j])
        X.append(temp_x)
        # for the outputs
        temp_y = []
        for j in range(y_length):
            temp_y.append(dataset[i+x_length+j])
        Y.append(temp_y)
    return X,Y
        

    
#-----------------------------------------
# main method to obtain data
#-----------------------------------------

# obtains the datasets -> used for the RNN model
# filename : the string name for the file
# x_length : length of the input(timesteps of the past)
# y_length : length of output(timesteps into future)
# percentage : the percentage of data to use for training and testing

def getData(filename,x_length,y_length,percentage):
    data = openFile(filename) # open the file and get data
    #print "data size:",len(data)
    
    #-- seperate training and testing --------
    train_size = int(percentage*len(data))
    #test_size = int(len(data)-train_size)
    
    train_data = data[1:train_size]
    test_data = data[train_size+1:-1]

    X_Train,Y_Train = sampleData(train_data,x_length,y_length)
    X_Test,Y_Test = sampleData(test_data,x_length,y_length)

    return X_Train,Y_Train,X_Test,Y_Test

# second method to obtain data, used for the LSTM code
#def getDataAsBatch(filename,x_length,y_length,percentage,no_batches):
#    data =openFile(filename)

    

    




#-----------------------------------------
# main
#-----------------------------------------

#def main():
#    x_length = 5
#    y_length = 10
#    percentage = 0.8
#    X_Train,Y_Train,X_Test,Y_Test = getData("combined_wimax_OutdoorData.txt",x_length,y_length,percentage)
#    print "X_Train data: ",len(X_Train)
#    print "Y_Train data: ",len(Y_Train)
#    print "X_Test data:  ",len(X_Test)
#    print "Y_Test data: ",len(Y_Test)

#    print "X_Train[0]: ",X_Train[0]
#    print "X_Train[1]: ",X_Train[1]
#    print "X_Train[2]: ",X_Train[2]
    
#    print ""

#    print "Y_Train[0]: ",Y_Train[0]
#    print "Y_Train[1]: ",Y_Train[1]
#    print "Y_Train[2]: ",Y_Train[2]
    

#main()

#batch_size = 20
#t = 1000 - 10 - 20
#start_x = np.random.choice(range(t),batch_size)

#print start_x # so accoridng to the batch size it creates mini batches with random start location

