//OSC echo by arvid jense

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

int high =-1;
int mid = -1;
int low = -1;
int left = -1;
int right = -1;
int currentcamera =-1;

void setup() {
  size(400, 400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1", 7000);
}


void draw() {
  background(0);
  text("high  : "+high, 10, 10);
  text("mid   : "+mid, 10, 30);
  text("low   : "+low, 10, 50);
  text("left  : "+left, 10, 70);
  text("right : "+right, 10, 90);

  text("currentcamera :"+currentcamera, 10, 110);
}

void mousePressed() {
  /* in the following different ways of creating osc messages are shown by example */
  OscMessage myMessage = new OscMessage("/test");

  myMessage.add(123); /* add an int to the osc message */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" value: "+theOscMessage.get(0).intValue());

  if (theOscMessage.addrPattern().equals("/high"))high=theOscMessage.get(0).intValue();
  else if (theOscMessage.addrPattern().equals("/mid"))mid=theOscMessage.get(0).intValue();
  else if (theOscMessage.addrPattern().equals("/low"))low=theOscMessage.get(0).intValue();
  else if (theOscMessage.addrPattern().equals("/left"))left=theOscMessage.get(0).intValue();
  else if (theOscMessage.addrPattern().equals("/right"))right=theOscMessage.get(0).intValue();
  else if (theOscMessage.addrPattern().equals("/currentcamera"))currentcamera=theOscMessage.get(0).intValue();



  OscMessage myMessage = new OscMessage(theOscMessage.netAddress().address());

  myMessage.add(theOscMessage.get(0).intValue()); /* add an int to the osc message */

  oscP5.send(myMessage, myRemoteLocation);
}