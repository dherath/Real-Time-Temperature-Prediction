BUILD_EXTRA_DEPS += Sense.class
CLEAN_EXTRA = *.class SenseMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

Sense.class: $(wildcard *.java) SenseMsg.java
	javac -target 1.4 -source 1.4 SenseMsg.java

SenseMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=SenseMsg Sense.h sense_msg_t -o $@
