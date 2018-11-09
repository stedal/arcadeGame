enum ArdButton {
    OK_BUTTON,
    ADD_PLAYER,
    REMOVE_PLAYER
}

class ArduinoProcessor {
  Arduino buttonArduino, holesArduino;
  ArduinoEventListener listener;
  final int holePins[] = { 3, 4, 5, 6, 7};
  final int buttonPins[] = { 10, 11, 12, 13};// the pins that the sensors are attached to

  ArduinoProcessor(Arduino buttonArduino, Arduino holesArduino, ArduinoEventListener eventListener) {
    // Arduino initializer
    for (int i = 0; i < holePins.length; i++) {
      int pinHit = holePins[i];
      holesArduino.pinMode(pinHit, Arduino.INPUT);
    }

    for (int i = 0; i < buttonPins.length; i++) {
      int pinHit = buttonPins[i];
      buttonArduino.pinMode(pinHit, Arduino.INPUT);
    }
    buttonArduino.pinMode(8, Arduino.INPUT);
    this.buttonArduino = buttonArduino;
    this.holesArduino = holesArduino;
    this.listener = eventListener;
  }

  void update() {
    if (buttonArduino.digitalRead(11) == Arduino.HIGH) {
      delay(600);
      listener.onArduinoEvent(ArdButton.OK_BUTTON);
    }

    if (buttonArduino.digitalRead(12) == Arduino.HIGH) {
      delay(300);
      listener.onArduinoEvent(ArdButton.ADD_PLAYER);
    }

    if (buttonArduino.digitalRead(13) == Arduino.HIGH) {
      delay(300);
      listener.onArduinoEvent(ArdButton.REMOVE_PLAYER);
    }

    for (int i = 0; i <= 4; i++) {
      int pin = i + 3;
      if (holesArduino.digitalRead(pin) == Arduino.LOW) {
              delay(5); // Needed to elminate false positives
              if (holesArduino.digitalRead(pin) == Arduino.LOW){
                delay(300); // Needed to eliminate double read
                listener.onShotMade(pin);
              }
      

      }
    }

    if (buttonArduino.digitalRead(8) == Arduino.LOW) {
              delay(300);
      listener.onShotMiss();
    }
  }
}
