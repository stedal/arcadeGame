
class ScreenManager {
  PImage rulesScreenImage;
  PImage playerSelectImage;
  PImage lightGolfBall;
  PImage darkGolfBall;
  PImage allPlayerScreens[] = new PImage[4];
  PImage waitScreen;
  PImage podiumScreen;
  Game game;

  ScreenManager(Game game) {
    rulesScreenImage = loadImage("pubstick_rules.png");
    playerSelectImage = loadImage("pubstick_playerselection.png");
    lightGolfBall = loadImage("golf_ball_light.png");
    darkGolfBall = loadImage("golf_ball_dark.png");
    waitScreen = loadImage("ready_next_player.png");
    podiumScreen = loadImage("podium4.png");
    for (int i = 0; i < 4; i++) {
      String imageToLoad = "pubstick_playerscreen_" + i + ".png";
      allPlayerScreens[i] = loadImage(imageToLoad);
    }

    initSvgDrawing();

    this.game = game;
  }

  void displayWaitScreen(){
    set(0, 0, waitScreen);
  }

  void displayPodium(){
    set(0,0, podiumScreen);
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
      displayPodium();
      break;
    default:
      break;


    }
  }
}
