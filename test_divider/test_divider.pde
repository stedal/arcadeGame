import cc.arduino.*;
import processing.video.*;
import processing.serial.*;

Arduino arduino0;
Arduino arduino1;


final int Pins[] = { 10, 11, 12, 13};
int analogPin = 0;

void setup() {
  
  arduino0 = new Arduino(this, Arduino.list()[0], 57600); //holes
  arduino1 = new Arduino(this, Arduino.list()[1], 57600);  //buttons
  arduino0.pinMode(analogPin, Arduino.INPUT);
  arduino1.pinMode(analogPin, Arduino.INPUT);
  
  println("arduino0 at pin 14 is: ");
  println(arduino0.analogRead(analogPin));
  println("arduino1 at pin 14 is: ");
  println(arduino1.analogRead(analogPin));
  
  println(Arduino.list());
  
  //arduino.pinMode(pin, Arduino.INPUT); 
}

void draw() {
  for (int i = 0; i < 6; i++) {
   int pin = i;
    if (arduino0.digitalRead(pin) == Arduino.HIGH) {
      print(pin + " high  ");
    }
    
    if (arduino0.digitalRead(pin) == Arduino.LOW) {
      print(pin + " low  ");
    }
  }
  println("arduino0 at pin 14 is: ");
  println(arduino0.analogRead(analogPin));
  println("arduino1 at pin 14 is: ");
  println(arduino1.analogRead(analogPin));
  println("");
  delay(1250);
}
      
