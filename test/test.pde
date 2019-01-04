import cc.arduino.*;
import processing.video.*;
import processing.serial.*;

Arduino arduino;
Arduino arduino2;

int pin = 4;

void setup() {
  
  //arduino = new Arduino(this, Arduino.list()[1], 57600); //holes
  arduino = new Arduino(this, Arduino.list()[0], 57600);  //buttons
  println(Arduino.list());
  arduino.pinMode(pin, Arduino.INPUT); 
}

void draw() {
  
    if (arduino.digitalRead(pin) == Arduino.HIGH) {
      println("high");
    }
    
     
    if (arduino.digitalRead(pin) == Arduino.LOW) {
      println("low");
    }
    delay(350);
}
      
