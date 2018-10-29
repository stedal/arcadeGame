enum GameState {
  STANDBY,
    SHOW_RULES,
    SELECT_PLAYERS,
    RUNNING,
    FINISHED,
    NEXT_PLAYER,
    SHOW_PODIUM
}

class Game implements PlayerEventListener, ArduinoEventListener {
  final int MAX_NUM_PLAYERS = 4;
  final int turnDuration = 177000;              // duration of each turn
  final int holeValues[] = { 1, 2, 3, 5, 7 };

  int numPlayers = 1;
  GameState state;
  GameEventListener listener;
  Player[] players;
  int currPlayerIndex;

  int startTime;
  int totalTime = 0;
  int pauseStartTime, totalPauseTime = 0;
  boolean paused = false;

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

  void startGame() {
    players = new Player[numPlayers];
    for (int i = 0; i < numPlayers; i++) {
      players[i] = new Player(10, i, turnDuration);
      players[i].setEventListener(this);
    }

    currPlayerIndex = 0;
    startTime = millis();
    totalTime = millis() - startTime;
    startCurrPlayer();
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
/*
      if (queuedAnimations.size() == 0){
      setState(GameState.SHOW_PODIUM);
      }
      try
      {
          Thread.sleep(1000);
      }
      catch(InterruptedException ex)
      {
          Thread.currentThread().interrupt();
      }
*/
      setState(GameState.STANDBY);
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
        break;
      case SELECT_PLAYERS:
        this.startGame();
        setState(GameState.RUNNING);
        break;
      case FINISHED:
        setState(GameState.STANDBY);
        break;
      case NEXT_PLAYER: // switches back to running condition once OK button pressed
        println("Arduino Event switched to case Next Player");
        setState(GameState.RUNNING);
        startCurrPlayer();
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
      break;
    case REMOVE_PLAYER:
      if (state == GameState.SELECT_PLAYERS) {
        numPlayers = max(numPlayers - 1, 1);
        listener.numPlayersChanged(numPlayers);
      }
      break;
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
      Player tempPlayer = players[i];
      int playerScore = tempPlayer.currentScore;

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
      // Added to count number of games played while program is running

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
