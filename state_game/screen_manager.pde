
class ScreenManager {
  PImage rulesScreenImage;
  PImage playerSelectImage;
  PImage lightGolfBall;
  PImage darkGolfBall;
  PImage allPlayerScreens[] = new PImage[4];
  PImage allPlayerNumbers[] = new PImage[4];
  PImage waitScreen;
  PImage allPodiumScreens[] = new PImage[4];
  Game game;
  //List<Integer> rankList;

  ScreenManager(Game game) {
    rulesScreenImage = loadImage("pubstick_rules.png");
    playerSelectImage = loadImage("pubstick_playerselection.png");
    lightGolfBall = loadImage("golf_ball_light.png");
    darkGolfBall = loadImage("golf_ball_dark.png");
    waitScreen = loadImage("ready_next_player.png");
    for (int i = 0; i < 4; i++) {
      String imageToLoad1 = "pubstick_playerscreen_" + i + ".png";
      allPlayerScreens[i] = loadImage(imageToLoad1);
      String imageToLoad2 = "player" + (i) + ".png";
      allPlayerNumbers[i] = loadImage(imageToLoad2);
      String imageToLoad3 = "podium" + (i) + ".png";
      allPodiumScreens[i] = loadImage(imageToLoad3);
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
    println("reverse val list is" + reverse_val_list);
    println("reverse key list is" + reverse_key_list);
    for (int i = 0; i < val_list.size()-1; i++) {
      //println("val_list contains:" + val_list.get(i) + " at position" + i);
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
    println("ordered reverse val list is" + reverse_val_list);
    println("ordered reverse key list is" + reverse_key_list);

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

  void displayImageBallsRemaining() {
    int xLocation = 1780;
    int yLocation = 965;

    for (int i = 0; i < game.currentPlayer().ballsLeft; i++) {
      image(lightGolfBall, xLocation, yLocation);
      yLocation = yLocation - 90;
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
      println("screen manager case set to NEXT PLAYER");
      //set(0,0, waitScreen);
      displayWaitScreen();
      break;
    case SHOW_PODIUM:
      println("screen manager case set to SHOW_PODIUM");
      displayPodium(game.numPlayers);

      break;
    default:
      break;


    }
  }
}
