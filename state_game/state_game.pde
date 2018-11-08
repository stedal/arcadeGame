import cc.arduino.*;
import processing.video.*;
import processing.serial.*;
import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;

ArduinoProcessor arduinoProcessor;
Game game;
AnimationManager animationManager;
ScreenManager screenManager;

int limit_cycles = 4;
int cycles = 0;
String xpos;
String ypos;
long gameTime = System.currentTimeMillis();
String longGameTime = Long.valueOf(gameTime).toString();
String[] gameStats = [16];
for (int i

void setup() {

  animationManager = new AnimationManager(this);
  game = new Game(animationManager);

  screenManager = new ScreenManager(game);
    arduinoProcessor = new ArduinoProcessor (
    new Arduino(this, Arduino.list()[0], 57600), // holes
    new Arduino(this, Arduino.list()[1], 57600), // buttons
    game
  );
  size(1920, 1080);
  textSize(32);
  frameRate(30);
  saveStuff(gameStats);
}

public void loadStuff(){
  try{
    String[] stuff = loadStrings(System.getProperty("user.dir") + File.separator + "gamestats.txt");// Can be any file type
    xpos = stuff[0];
    ypos = stuff[1];
    println("xpos is ", xpos);
  }catch(Exception e){
    println("File doesn't exist!");
  }
}

public void saveStuff(String[] arg){
  //String[] stuff = {gameTime, str(ypos)};
  saveStrings(System.getProperty("user.dir") + File.separator + "gamestats.txt", arg);
}

void draw() {
  arduinoProcessor.update();
  game.update();
  background(0);
  loadStuff();
  // THIS IS THE DEBUG VIEW
  /*
  background(0);
  text("" + game.state + "\t Animations: ", width/3, height/7);
  text("Players: " + game.numPlayers + "\nCurrPlayer:" + game.currPlayerIndex, width/10, 2*height/7);
  if (game.state == GameState.RUNNING) {
    text("Score: " + game.players[game.currPlayerIndex].currentScore +
      " Balls Left: " + game.players[game.currPlayerIndex].ballsLeft,
      width/10,
      3*height/7);
    text("Duration: " + game.players[game.currPlayerIndex].turnDuration(),
      width/10,
      4*height/7);

    text("GAME TIME: " + game.getGameTime() + " Total Pause: " + game.totalPauseTime,
      width/10,
      6*height/7);
  } else if (game.state == GameState.FINISHED) {
    text("Score: " + game.players[0].currentScore +
      " Balls Left: " + game.players[0].ballsLeft,
      width/10,
      3*height/7);
    text("Duration: " + game.players[0].turnDuration(),
      width/10,
      4*height/7);
  }
*/

  screenManager.display();
  animationManager.display();

}

interface GameEventListener {
  void updatedGameState(GameState newState);
  void playerBusted(int playerId);
  void playerBlackjack(int playerId);
  void madeShot(int playerIndex, int score);
  void missedShot(int playerIndex);
  void playerStarted(Player player);
  void numPlayersChanged(int playerNum);
}

interface ArduinoEventListener {
  void onArduinoEvent(ArdButton signal);
  void onShotMade(int holeNum);
  void onShotMiss();
}

interface PlayerEventListener {
  void endTurn();
  void busted();
  void blackjack();
}


// Left / Right arrows to select num players
// Enter to replace OK button
// 1-5 to represent holes
// 'm' to represent miss
void keyPressed() {
  if (keyCode == LEFT) {
    game.onArduinoEvent(ArdButton.REMOVE_PLAYER);
  } else if (keyCode == RIGHT) {
    game.onArduinoEvent(ArdButton.ADD_PLAYER);
  } else if (key == ENTER || key == RETURN) {
    game.onArduinoEvent(ArdButton.OK_BUTTON);
  } else {
    int keyVal = Character.getNumericValue(key);
    if (keyVal >= 1 && keyVal <= 5) {
      game.onShotMade((keyVal-1) + 3);
    }
    if (key == 'm') {
      game.onShotMiss();
    }
  }
}

void mousePressed() {
  game.pause();
}

void mouseReleased() {
  game.resume();
}
