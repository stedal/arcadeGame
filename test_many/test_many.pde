import cc.arduino.*;
import processing.video.*;
import processing.serial.*;

Arduino arduino;
Arduino arduino2;

final int Pins[] = { 10, 11, 12, 13};
int pin = 0;

void setup() {
  
  //arduino = new Arduino(this, Arduino.list()[1], 57600); //holes
  arduino = new Arduino(this, Arduino.list()[0], 57600);  //buttons
  println(Arduino.list());
  arduino.pinMode(pin, Arduino.INPUT); 
}

void draw() {
  for (int i = 10; i < Pins.length+10; i++) {
   int pin = i;
    if (arduino.digitalRead(pin) == Arduino.HIGH) {
      print(pin + " high  ");
    }
    
    if (arduino.digitalRead(pin) == Arduino.LOW) {
      print(pin + " low  ");
    }
  }
  println("");
  delay(1250);
}
      
