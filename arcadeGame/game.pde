enum GameState {
    STANDBY,
    SHOW_RULES,
    SELECT_PLAYERS,
    RUNNING,
    FINISHED,
    NEXT_PLAYER,
    ENTER_NAME,
    SHOW_PODIUM,
    SHOW_LEADERBOARD
}

public class Game implements PlayerEventListener, ArduinoEventListener {
  final int MAX_NUM_PLAYERS = 4;
  final int turnDuration = 177000; // duration of each turn
  final int holeValues[] = { 1, 2, 3, 5, 7 };

  int numPlayers = 1;
  GameState state;
  GameEventListener listener;
  Player[] players;
  int currPlayerIndex;
  int top_score = 0;
  int startTime;
  int totalTime = 0;
  int pauseStartTime, totalPauseTime = 0;
  boolean paused = false;
  TreeMap<Integer, Integer> map = new TreeMap<Integer, Integer>();
  int letter = 101;
  ArrayList<Integer> letters = new ArrayList<Integer>();

  public Game(GameEventListener eventListener) {
    this.listener=eventListener;
    setState(GameState.STANDBY);
  }

  void update() {
    if (paused) {
      return;
    }
    totalTime = millis() - startTime;
    if (state == GameState.RUNNING) {
      players[currPlayerIndex].update(getGameTime());
    }
  }

  void pause() {
    pauseStartTime = millis();
    paused = true;
  }

  void resume() {
    totalPauseTime += millis() - pauseStartTime;
    paused = false;
  }

  int getGameTime() {
    return totalTime - totalPauseTime;
  }

  void setEventListener(GameEventListener eventListener) {
    listener = eventListener;
  }

 public void startGame() {
    players = new Player[numPlayers];
    for (int i = 0; i < numPlayers; i++) {
      players[i] = new Player(10, i, turnDuration);
      players[i].setEventListener(this);
    }

    currPlayerIndex = 0;
    startTime = millis();
    totalTime = millis() - startTime;
    startCurrPlayer();
    letter = 101;
    letters.clear();
  }

  void busted() {
    listener.playerBusted(players[currPlayerIndex].id);
  }
  void blackjack() {
    listener.playerBlackjack(players[currPlayerIndex].id);
  }

  void endTurn() {
    println("Turn Over!");
    currPlayerIndex += 1;


     if (currPlayerIndex >= numPlayers) {
      println("finished");
      setState(GameState.FINISHED);

      //setState(GameState.STANDBY);
    } else {
      println("setting to next player");
      setState(GameState.NEXT_PLAYER);
      //startCurrPlayer(); Moved this to case NEXT_PLAYER
    }
  }

  Player currentPlayer() {
    return players[currPlayerIndex];
  }
  void startCurrPlayer() {
    players[currPlayerIndex].startTurn(getGameTime());
    listener.playerStarted(players[currPlayerIndex]);
  }

  void setState(GameState newState) {
    state = newState;
    listener.updatedGameState(newState);
  }


  void onArduinoEvent(ArdButton signal) {
    println("Here");
    switch(signal) {
    case OK_BUTTON:
      switch(state) {
      case STANDBY:
        setState(GameState.SHOW_RULES);
        // TODO lets play
        break;
      case SHOW_RULES:
        setState(GameState.SELECT_PLAYERS);
        loadStuff();
        break;
      case SELECT_PLAYERS:
        this.startGame();
        setState(GameState.RUNNING);
        break;
      case FINISHED: // Don't think this does anything. Only if hit OK during final movie sequence
        println("from state of finished, setting state to standby");
        setState(GameState.STANDBY);
        break;
      case NEXT_PLAYER: // switches back to running condition once OK button pressed
        println("Arduino Event switched to case Next Player");
        setState(GameState.RUNNING);
        startCurrPlayer();
        break;
      case SHOW_PODIUM:
        ArrayList<Player> winners = game.getWinningPlayer();
        long gameTime = System.currentTimeMillis()/1000; // Seconds since epoch
        long timeSincePlayed = timeSincePlayed(gameTime);
        if (winners.get(0).currentScore > int(gameStats[1])){
          setState(GameState.ENTER_NAME);
        }
        else if ((winners.get(0).currentScore == int(gameStats[1]) &&  (winners.get(0).ballsLeft > Integer.valueOf(gameStats[2])))) {
          setState(GameState.ENTER_NAME);
        }
        else if (timeSincePlayed > day) {
          setState(GameState.ENTER_NAME);
        }
        else {
          setState(GameState.SHOW_LEADERBOARD);
        }
        break;
      case ENTER_NAME:
          if (letters.size() == 3) {
            setState(GameState.SHOW_LEADERBOARD);
          }
        else assignLetters();
        break;
      case SHOW_LEADERBOARD:
        setState(GameState.STANDBY);
        set(0, 0, animationManager.standby);
        // Begin file output stuff
        Logger loggerObject;
        loggerObject = new Logger (sketchPath("") + "data1.txt");
        loggerObject.log("1");
        // end file output stuff
        cycles += 1;
        if (cycles == limit_cycles){
          println("cycles met, exiting");
          exit();
        }
        break;
      default:
        println("Skipping OK button, not relevant");
        break;
      }
      println("Updated game state: ", state);
      break;
    case ADD_PLAYER:
      if (state == GameState.SELECT_PLAYERS) {
        numPlayers = min(numPlayers + 1, MAX_NUM_PLAYERS);
        listener.numPlayersChanged(numPlayers);
      }
      if (state == GameState.ENTER_NAME) {
        increaseLetter();
      }
      break;
    case REMOVE_PLAYER:
      if (state == GameState.SELECT_PLAYERS) {
        numPlayers = max(numPlayers - 1, 1);
        listener.numPlayersChanged(numPlayers);
      }
      if (state == GameState.ENTER_NAME) {
        decreaseLetter();
      }
      break;
    }
  }
  void assignLetters() {
    letters.add(letter);
  }
  void decreaseLetter(){
    if ( letter > 101 ) {
      letter = letter - 1;
    }
  }

  void increaseLetter(){
    if ( letter < 126 ) {
      letter = letter + 1;
    }
    }

  void onShotMade(int pinNumber) {
    println("Shot made. game state:", state);
    if (state != GameState.RUNNING) {
      return;
    }

    //Update current player
    int points = getPointsForHole(pinNumber - 3);

    listener.madeShot(currPlayerIndex, pinNumber - 3);

    players[currPlayerIndex].addPointsToScore(points);
    println("onShotMade finished");
  }

  void onShotMiss() {
    if (state != GameState.RUNNING) {
      return;
    }
    listener.missedShot(currPlayerIndex);
    players[currPlayerIndex].useBall();
  }

  int getPointsForHole(int holeNum) {
    return holeValues[holeNum];
  }

  // Method to return the winner player at the end of game.
  ArrayList<Player> getWinningPlayer() {
    int winningValue = Integer.MIN_VALUE; // Set to a big negative so our first comparison works
    ArrayList<Player> winners = new ArrayList<Player>();

    // Find player(s) with the highest score
    for (int i = 0; i < players.length; i++) {
      println("players[i]: ", players[i]);
      Player tempPlayer = players[i];
      int playerScore = tempPlayer.currentScore;

      map.put(players[i].id, playerScore);

      println("printing map value" , map.get(i));

      if (tempPlayer.currentScore > winningValue) {
        winners.clear();
        winners.add(tempPlayer);
        winningValue = playerScore;
      } else if (playerScore == winningValue) {
        winners.add(tempPlayer);
      }
    }

    if (winners.size() == 1) {
      // Added to count number of games played while program is running

      return winners;
    }

    // Find the player with the lowest balls used if there is a tie.
    int winningBallsUsed = 100;
    ArrayList<Player> ballWinners = new ArrayList<Player>();
    for (Player tempPlayer : winners) {
      int playerBallsUsed = tempPlayer.ballsLeft;
      if (playerBallsUsed < winningBallsUsed) {
        ballWinners.clear();
        ballWinners.add(tempPlayer);
        winningBallsUsed = playerBallsUsed;
      } else if (playerBallsUsed == winningBallsUsed) {
        ballWinners.add(tempPlayer);
      }
    }
    winners = ballWinners;

    if (winners.size() == 1) {
      return winners;
    }

    // Find the player with the lowest time used if there is still a tie
    // after checking how many balls were used
    int winningTime = 1000000000;
    ArrayList<Player> timeWinners = new ArrayList<Player>();
    for (Player tempPlayer : winners) {
      int playerTime = tempPlayer.turnDuration();
      if (playerTime < winningTime) {
        timeWinners.clear();
        timeWinners.add(tempPlayer);
        winningTime = playerTime;
      } else if (playerTime == winningTime) {
        timeWinners.add(tempPlayer);
      }
    }
    winners = timeWinners;
    // Added to count number of games played while program is running

    return winners;
  }
}
