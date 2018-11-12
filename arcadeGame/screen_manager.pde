
class ScreenManager {
  PImage rulesScreenImage;
  PImage playerSelectImage;
  PImage lightGolfBall;
  PImage darkGolfBall;
  PImage enterName;
  PImage leaderBoard;
  PImage allPlayerScreens[] = new PImage[4];
  PImage allPlayerNumbers[] = new PImage[4];
  PImage waitScreen;
  PImage allPodiumScreens[] = new PImage[4];
  PImage allLetters[] = new PImage[27];
  Game game;

  ScreenManager(Game game) {
    rulesScreenImage = loadImage("pubstick_rules.png");
    playerSelectImage = loadImage("pubstick_playerselection.png");
    lightGolfBall = loadImage("golf_ball_light.png");
    darkGolfBall = loadImage("golf_ball_dark.png");
    waitScreen = loadImage("ready_next_player.png");
    enterName = loadImage("enter_name.png");
    leaderBoard = loadImage("leaderboard.png");
    for (int i = 0; i < 4; i++) {
      String imageToLoad1 = "pubstick_playerscreen_" + i + ".png";
      allPlayerScreens[i] = loadImage(imageToLoad1);
      String imageToLoad2 = "player" + (i) + ".png";
      allPlayerNumbers[i] = loadImage(imageToLoad2);
      String imageToLoad3 = "podium" + (i) + ".png";
      allPodiumScreens[i] = loadImage(imageToLoad3);
    }
    for (int i = 101; i < 127; i++) {
      String letterToLoad = (i) + ".png";
      allLetters[i-100] = loadImage(letterToLoad);
    }

    initSvgDrawing();

    this.game = game;
  }

  void displayWaitScreen(){
    set(0, 0, waitScreen);
  }

  void displayPodium(int number_players){
    // Converting sorted dictionary to lists to sort on values
    List<Integer> val_list = new ArrayList<Integer>(game.map.values());
    List<Integer> key_list = new ArrayList<Integer>(game.map.keySet());
    List<Integer> reverse_val_list = new ArrayList<Integer>();
    List<Integer> reverse_key_list = new ArrayList<Integer>();
    // Reverse list in order to cycle through with normal for loop
    for (int i = 0; i < val_list.size(); i++) {
      reverse_val_list.add((val_list.get((val_list.size()-1) - i)));
      reverse_key_list.add((key_list.get((val_list.size()-1) - i)));
    }
    for (int i = 0; i < val_list.size()-1; i++) {
      if (reverse_val_list.get(i) < reverse_val_list.get(i+1)){
        int temp_val1 = reverse_val_list.get(i);
        int temp_val2 = reverse_val_list.get(i+1);
        reverse_val_list.set(i+1, temp_val1);
        reverse_val_list.set(i, temp_val2);
        int temp_val3 = reverse_key_list.get(i);
        int temp_val4 = reverse_key_list.get(i+1);
        reverse_key_list.set(i+1, temp_val3);
        reverse_key_list.set(i, temp_val4);
      }
    }

    set(0,0, allPodiumScreens[number_players-1]);
    int xLocation1 = 550;
    int yLocation1 = 270;
    int xLocation2 = 1055;
    int yLocation2 = 365;
    int xLocation3 = 180;
    int yLocation3 = 553;
    int xLocation4 = 1437;
    int yLocation4 = 691;
    switch(number_players) {
    case 1:
      image(allPlayerNumbers[reverse_key_list.get(0)], xLocation1, yLocation1);
      break;
    case 2:
      image(allPlayerNumbers[reverse_key_list.get(0)], xLocation1, yLocation1);
      image(allPlayerNumbers[reverse_key_list.get(1)], xLocation2, yLocation2);
      break;
    case 3:
      image(allPlayerNumbers[reverse_key_list.get(0)], xLocation1, yLocation1);
      image(allPlayerNumbers[reverse_key_list.get(1)], xLocation2, yLocation2);
      image(allPlayerNumbers[reverse_key_list.get(2)], xLocation3, yLocation3);
      break;
    case 4:
      image(allPlayerNumbers[reverse_key_list.get(0)], xLocation1, yLocation1);
      image(allPlayerNumbers[reverse_key_list.get(1)], xLocation2, yLocation2);
      image(allPlayerNumbers[reverse_key_list.get(2)], xLocation3, yLocation3);
      image(allPlayerNumbers[reverse_key_list.get(3)], xLocation4, yLocation4);
      break;
    default:
      break;
    }
  }

  void displayPlayerScreen() {
    set(0, 0, allPlayerScreens[game.currentPlayer().id]);
    //draw a layer of dark balls
    int xLocation = 1780;
    int yLocation = 965;
    for (int i = 0; i < 10; i++) {
      image(darkGolfBall, xLocation, yLocation);
      yLocation = yLocation - 90;
    }
  }
  void enterNameScreen() {
   // create function that shows letter indicator in middle of the screen with
   // the selected initials below


   //println("game.letters.size = ", game.letters.size());
   if (game.letters.size() >= 0) {
     switch(game.letters.size()){
       case 0:
         image(allLetters[game.letter-100], 832, 550);
        // println("case 0");
         break;
       case 1:
         image(allLetters[game.letter-100], 924, 550);
         image(allLetters[game.letters.get(0)-100], 832, 550);
         //println("case 1");
         break;
       case 2:
        // println("case 2");
         image(allLetters[game.letter-100], 1016, 550);
         image(allLetters[game.letters.get(0)-100], 832, 550);
         image(allLetters[game.letters.get(1)-100], 924, 550);
         break;
       case 3:
         image(allLetters[game.letters.get(0)-100], 832, 550);
         image(allLetters[game.letters.get(1)-100], 924, 550);
         image(allLetters[game.letters.get(2)-100], 1016, 550);
         //for (int i = 0; i < game.letters.size(); i++) {
         //  println("game.letters at " + i + " =" + game.letters.get(i));
         //}
         getLeaderboard();
         saveStuff(gameStats);
         break;
     }
   }
  }

  void displayImageBallsRemaining() {
    int xLocation = 1780;
    int yLocation = 965;

    for (int i = 0; i < game.currentPlayer().ballsLeft; i++) {
      image(lightGolfBall, xLocation, yLocation);
      yLocation = yLocation - 90;
    }
  }

  void showLeaders() {
    int xLocations[] = {113-36, 636-36, 1128-36, 1608-36};
    int yLocation = 570;

    int dailyBest[] = {Integer.valueOf(gameStats[4].substring(0,3))- 100, Integer.valueOf(gameStats[4].substring(3,6))- 100, Integer.valueOf(gameStats[4].substring(6,9))- 100};
    int weeklyBest[] = {Integer.valueOf(gameStats[9].substring(0,3))- 100, Integer.valueOf(gameStats[9].substring(3,6))- 100, Integer.valueOf(gameStats[9].substring(6,9))- 100};
    int monthlyBest[] = {Integer.valueOf(gameStats[14].substring(0,3))- 100, Integer.valueOf(gameStats[14].substring(3,6))- 100, Integer.valueOf(gameStats[14].substring(6,9))- 100};
    int allTimeBest[] = {Integer.valueOf(gameStats[19].substring(0,3))- 100, Integer.valueOf(gameStats[19].substring(3,6))- 100, Integer.valueOf(gameStats[19].substring(6,9))- 100};
    int[][] initials = { dailyBest, weeklyBest, monthlyBest, allTimeBest};
    for (int j = 0; j < 4; j++) {
      for (int i = 0; i < 3; i++) {
        image(allLetters[initials[j][i]], xLocations[j]+i*92, yLocation);
      }
    }
  }

  void display() {
    switch(game.state) {
    case SHOW_RULES:
      set(0, 0, rulesScreenImage);
      break;
    case SELECT_PLAYERS:
      set(0, 0, playerSelectImage);
      drawPlayerSelectIndicator(game.numPlayers);
      break;
    case RUNNING:
      displayPlayerScreen();
      displayImageBallsRemaining();
      updateTimerSvgValues(game.currentPlayer().remainingTime());
      displaySvgTimer();
      // TODO: Display all scores at same time? Or just one?
      scoreDisplay(game.currentPlayer().currentScore); // only shows current players score right now
      bottomScoreDisplay(game.players);
      break;
    case NEXT_PLAYER:
      displayWaitScreen();
      break;
    case SHOW_PODIUM:
      displayPodium(game.numPlayers);
      break;
    case ENTER_NAME:
      //println("show enter name screen");
      set(0, 0, enterName);
      enterNameScreen();
      break;
    case SHOW_LEADERBOARD:
      set(0, 0, leaderBoard);
      showLeaders();
      break;
    default:
      break;


    }
  }
}
