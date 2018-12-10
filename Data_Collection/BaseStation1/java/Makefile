GEN=OscilloscopeMsg.java Constants.java

all: oscilloscope.jar

oscilloscope.jar: Oscilloscope.class
	jar cf $@ *.class

OscilloscopeMsg.java: ../Sense.h
	nescc-mig -java-classname=OscilloscopeMsg java ../Sense.h sense_msg_t -o $@

Constants.java: ../Sense.h
	nescc-ncg -java-classname=Constants java ../Sense.h NREADINGS DEFAULT_INTERVAL -o $@

Oscilloscope.class: $(wildcard *.java) $(GEN)
	javac *.java

clean:
	rm -f *.class $(GEN)

veryclean: clean
	rm oscilloscope.jar
