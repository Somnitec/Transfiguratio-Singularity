import controlP5.*;
ControlP5 cp5;

int wobLeft =1;
int wobRight=1;
int currentLeft=0;
int currentRight=0;

int amountofwobs = 2;
String currentlyActive="";
int leftvalue = -1;
int rightvalue =-1;

import themidibus.*; //Import the library

MidiBus[] bus; //array for every bus
String[] busses;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400, 400);
  cp5 = new ControlP5(this);
  cp5.addSlider("wobLeft", 1, 7).linebreak();
  cp5.addSlider("wobRight", 1, 7);

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  bus = new MidiBus[amountofwobs];
  busses = new String[amountofwobs];
  for (int i=0; i<amountofwobs; i++) {
    bus[i]=new MidiBus(this, i, -1, "bus"+i);
    busses[i] = "bus"+i;
  }

  oscP5 = new OscP5(this, 7001);
  myRemoteLocation = new NetAddress("127.0.0.1", 7000);
}

void draw() {
  background(0);
  fill(255);
  text("currently active = "+currentLeft+currentRight, 100, 100);
  text("left value = "+leftvalue, 100, 200);
  text("right value = "+rightvalue, 100, 300);
}

void controllerChange(int channel, int number, int value, long timestamp, String bus_name) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  println("Recieved on Bus:"+bus_name);
  String adress = "";
  if (channel<7) { 
    adress="/left";
  leftvalue=value;
  }
  else {
    adress="/right";
    rightvalue = value;
  }


  OscMessage myMessage = new OscMessage(adress);
  myMessage.add(value);

  oscP5.send(myMessage, myRemoteLocation); 
  println("OSC mssg send: "+value);
}

void noteOn(int channel, int pitch, int velocity, long timestamp, String bus_name) {
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println("Timestamp:"+timestamp);
  println("Recieved on Bus:"+bus_name);

  if (channel<7)  currentLeft=wobLeft;
  else currentRight=wobRight;

  if (currentlyActive.equals("")) {
    currentlyActive=bus_name;


    int currentWob =-1;
    for (int i=0; i<amountofwobs; i++) {
      if (currentlyActive.equals(busses[i]))currentWob=i;
    }
    OscMessage myMessage = new OscMessage("/currentcamera");
    myMessage.add(currentLeft*10+currentRight);
    oscP5.send(myMessage, myRemoteLocation); 
    println("OSC mssg send currentcamera: "+currentLeft+currentRight);
  }
}

void noteOff(int channel, int pitch, int velocity, long timestamp, String bus_name) {
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println("Timestamp:"+timestamp);
  println("Recieved on Bus:"+bus_name);

  if (channel<7)  currentLeft=0;
  else  currentRight=0;

  if (bus_name.equals(currentlyActive)) {
    //reset the parameters
    currentlyActive="";

    OscMessage myMessage = new OscMessage("/currentcamera");
    myMessage.add(currentLeft+currentRight);
    oscP5.send(myMessage, myRemoteLocation); 
    println("OSC mssg send currentcamera: "+currentLeft+currentRight);
  }
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  println(" addrpattern: "+theOscMessage.addrPattern());
}