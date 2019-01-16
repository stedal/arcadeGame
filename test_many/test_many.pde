import cc.arduino.*;
import processing.video.*;
import processing.serial.*;
import java.io.IOException;

Arduino arduino1;
Arduino arduino2;

final int Pins1[] = { 10, 11, 12, 13};
final int Pins2[] = { 3,4,5,6,7};

int pin = 0;
int cycle = 0;


void setup() {

  arduino1 = new Arduino(this, Arduino.list()[1], 57600); //holes
  arduino2= new Arduino(this, Arduino.list()[0], 57600);  //buttons
  println(Arduino.list());
  for(int i=0; i<= Pins1.length-1; i++) {
    arduino1.pinMode(Pins1[i], Arduino.INPUT); 
  }
  for(int i=0; i<= Pins2.length-1; i++) {
    arduino2.pinMode(Pins2[i], Arduino.INPUT); 
  }

}

void draw() {
  cycle +=1;
  //println(cycle);
  println("Arduino1:");
  for (int i = 10; i < Pins1.length+10; i++) {
   int pin = i;
    if (arduino1.digitalRead(pin) == Arduino.HIGH) {
      print(pin + " high  ");
    }
    
    if (arduino1.digitalRead(pin) == Arduino.LOW) {
      print(pin + " low  ");
    }
  }
  println("");
  println("Arduino2:");
  for (int i = 3; i < Pins2.length+3; i++) {
   int pin = i;
    if (arduino2.digitalRead(pin) == Arduino.HIGH) {
      print(pin + " high  ");
    }
    
    if (arduino2.digitalRead(pin) == Arduino.LOW) {
      print(pin + " low  ");
    }
  }
  println("");
  delay(1250);

}
      
