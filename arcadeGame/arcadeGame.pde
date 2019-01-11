import cc.arduino.*;
import processing.video.*;
import processing.serial.*;
import java.io.*;
import java.util.*;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import java.text.DecimalFormat;

ArduinoProcessor arduinoProcessor;
Game game;
AnimationManager animationManager;
ScreenManager screenManager;

// limit cycles to shut down game.
int limit_cycles = 4;
int cycles = 0;

// setup variables for leaderboard time checking

long day = 86400;  // 86400 seconds per day
long week = 604800;  // 604800 seconds per week
long month = 2419200;  // 2419200 seconds per month

String[] gameStats = new String[20];
int[] dayStats = new int[5];
int[] weekStats = new int[5];
int[] monthStats = new int[5];
int[] allTimeStats = new int[5];
Arduino arduino0 = new Arduino(this, Arduino.list()[0], 57600);
Arduino arduino1 = new Arduino(this, Arduino.list()[1], 57600);
//  arduino0 = new Arduino(this, Arduino.list()[0], 57600);
//  arduino1 = new Arduino(this, Arduino.list()[1], 57600);


void setup() {
  arduino0.pinMode(0, Arduino.INPUT);
  arduino1.pinMode(0, Arduino.INPUT);
  
  // Warm up ADC
  for ( int i = 0; i<4; i++){
    arduino0.analogRead(0);
    arduino1.analogRead(0);
    delay(1250);
  }

 /*
  //DEBUG
  for (int i = 0; i < 5; i++){
    println("Arduino 0");
    for (int j = 0; j < 6; j++) {
      int pin =j;
      print("pin " + pin + " = " + arduino0.analogRead(pin) + " ");
    }
    println("");
    println("Arduino 1");
    for (int j= 0; j < 6; j ++) {
      int pin = j;
      print("pin " + pin + " = " + arduino1.analogRead(pin) + " ");
    }
    println("");  
    delay(1250);
  };
  */
  
  animationManager = new AnimationManager(this);
  game = new Game(animationManager);
  screenManager = new ScreenManager(game);
  
  // Find arduino with voltage divider and assign it to bottons arduino.
  if (arduino0.analogRead(0) < 525 && arduino0.analogRead(0) > 475) {
      arduinoProcessor = new ArduinoProcessor (
      arduino0, // buttons
      arduino1, // holes
      game
    );
  }
  else if (arduino1.analogRead(0) < 525 && arduino1.analogRead(0) > 475) {
    arduinoProcessor = new ArduinoProcessor (
    arduino1, // buttons
    arduino0, // holess
    game
    );
  };
 /*
  arduinoProcessor = new ArduinoProcessor (
    new Arduino(this, Arduino.list()[1], 57600), // holes
    new Arduino(this, Arduino.list()[0], 57600), // buttons
    game
  );
*/

  size(1920, 1080);
  textSize(32);
  frameRate(30);
}

void draw() {
  arduinoProcessor.update();
  game.update();
  background(0);
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

public void loadStuff(){
  try{
    gameStats = loadStrings(System.getProperty("user.dir") + File.separator + "gamestats.txt");// Can be any file type
    for (int i = 0; i < gameStats.length; i++) {
        println("printing gameStats at " + i + " " + gameStats[i]);
        }
    /*
    String day_Time = gameStats[0];
    String day_Score = gameStats[1];
    String day_Balls = gameStats[2];
    String day_Duration = gameStats[3];
    String day_Initials = gameStats[4];

    String week_Time = gameStats[5];
    String week_Score = gameStats[6];
    String week_Balls = gameStats[7];
    String week_Duration = gameStats[8];
    String week_Initials = gameStats[9];

    String month_Time = gameStats[10];
    String month_Score = gameStats[11];
    String month_Balls = gameStats[12];
    String month_Duration = gameStats[13];
    String month_Initials = gameStats[14];

    String all_Time = gameStats[15];
    String all_Score = gameStats[16];
    String all_Balls = gameStats[17];
    String all_Duration = gameStats[18];
    String all_Initials = gameStats[19];
    */
  }catch(Exception e){
    println("File doesn't exist!");
  }
}

public void saveStuff(String[] arg){
  saveStrings(System.getProperty("user.dir") + File.separator + "gamestats.txt", arg);
}

public long timeSincePlayed(long time) {
long recordTime = Long.valueOf(gameStats[0]);
long gameTime = time - recordTime;
println(" time since played is ", gameTime);
return gameTime;
}

public void overWriteDay(long gameTime){
  ArrayList<Player> winners = game.getWinningPlayer();
  String longGameTime = Long.valueOf(gameTime).toString();
  gameStats[0] = longGameTime;
  gameStats[1] = Integer.toString(winners.get(0).currentScore);
  gameStats[2] = Integer.toString(winners.get(0).ballsLeft);
  gameStats[3] = Integer.toString(winners.get(0).stopTime - winners.get(0).startTime);
  gameStats[4] = Integer.toString(game.letters.get(0))+Integer.toString(game.letters.get(1)) + Integer.toString(game.letters.get(2));
  println("the long gameTime is " + gameTime);
  println("the integer value of longGameTime string is : " + Long.valueOf(longGameTime));
  println("the integer value of gameStats 0 is: " + Long.valueOf(gameStats[0]));
}

public void overWriteWeek(long gameTime){
  ArrayList<Player> winners = game.getWinningPlayer();
  String longGameTime = Long.valueOf(gameTime).toString();
  gameStats[5] = longGameTime;
  gameStats[6] = Integer.toString(winners.get(0).currentScore);
  gameStats[7] = Integer.toString(winners.get(0).ballsLeft);
  gameStats[8] = Integer.toString(winners.get(0).stopTime - winners.get(0).startTime);
  gameStats[9] = Integer.toString(game.letters.get(0))+Integer.toString(game.letters.get(1)) + Integer.toString(game.letters.get(2));
  println("the long gameTime is " + gameTime);
  println("the integer value of longGameTime string is : " + Long.valueOf(longGameTime));
  println("the integer value of gameStats 0 is: " + Long.valueOf(gameStats[0]));
}

public void overWriteMonth(long gameTime){
  ArrayList<Player> winners = game.getWinningPlayer();
  String longGameTime = Long.valueOf(gameTime).toString();
  gameStats[10] = longGameTime;
  gameStats[11] = Integer.toString(winners.get(0).currentScore);
  gameStats[12] = Integer.toString(winners.get(0).ballsLeft);
  gameStats[13] = Integer.toString(winners.get(0).stopTime - winners.get(0).startTime);
  gameStats[14] = Integer.toString(game.letters.get(0))+Integer.toString(game.letters.get(1)) + Integer.toString(game.letters.get(2));
  println("the long gameTime is " + gameTime);
  println("the integer value of longGameTime string is : " + Long.valueOf(longGameTime));
  println("the integer value of gameStats 0 is: " + Long.valueOf(gameStats[0]));
}

public void getLeaderboard(){
  ArrayList<Player> winners = game.getWinningPlayer();
  long gameTime = System.currentTimeMillis()/1000; // Seconds since epoch
  println("gameTime is :", gameTime);


  long timeSincePlayed = timeSincePlayed(gameTime);
  println("timeSincePlayed is: ", timeSincePlayed);

  if (timeSincePlayed > day) {
    overWriteDay(gameTime);
    println("overwrote DAY on time");
  }

  if (timeSincePlayed > week) {
    overWriteWeek(gameTime);
    println("overwrote WEEK on time");
  }

  if (timeSincePlayed > month) {
    overWriteMonth(gameTime);
    println("overwrote MONTH on time");
  }

  if (winners.get(0).currentScore > int(gameStats[1])){
    overWriteDay(gameTime);
    println("overwrote DAY on SCORE");
  }
  if (winners.get(0).currentScore == int(gameStats[1])) { // If tie check for ball superiority
    if (winners.get(0).ballsLeft > Integer.valueOf(gameStats[2])){
      overWriteDay(gameTime);
      println("overwrote DAY on TIE");
    }
  }

  if (winners.get(0).currentScore > int(gameStats[6])) { // Check for week score win
    overWriteWeek(gameTime);
    println("overwrote WEEK on SCORE");
  }
  if (winners.get(0).currentScore == int(gameStats[6])) { // If tie check for ball superiority
    if (winners.get(0).ballsLeft > Integer.valueOf(gameStats[7])){
      overWriteWeek(gameTime);
      println("overwrote WEEK on TIE");
    }
  }

  if (winners.get(0).currentScore > int(gameStats[11])) { // check for month score win
    overWriteMonth(gameTime);
    println("overwrote MONTH on SCORE");
  }
  if (winners.get(0).currentScore == int(gameStats[11])) { // If tie check for ball superiority
    if (winners.get(0).ballsLeft > Integer.valueOf(gameStats[12])){
    overWriteMonth(gameTime);
    println("overwrote MONTH on TIE");
    }
  }
  if (winners.get(0).currentScore > int(gameStats[16])) {
    gameStats[15] = gameStats[0];
    gameStats[16] = gameStats[1];
    gameStats[17] = gameStats[2];
    gameStats[18] = gameStats[3];
    gameStats[19] = gameStats[4];
  }
  if (winners.get(0).currentScore == int(gameStats[16])) { // If tie check for ball superiority
    if (winners.get(0).ballsLeft > Integer.valueOf(gameStats[17])){
      gameStats[15] = gameStats[0];
      gameStats[16] = gameStats[1];
      gameStats[17] = gameStats[2];
      gameStats[18] = gameStats[3];
      gameStats[19] = gameStats[4];
    }
  }
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
