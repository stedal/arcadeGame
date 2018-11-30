


class AnimationManager implements GameEventListener {
  Movie shotMadeOnePoint;
  Movie playerAnimation;
  Movie bustAnimation;
  Movie blackjackAnimation;
  Movie missAnimation;
  Movie standby;
  Movie allScoreVideos[] = new Movie[5];
  Movie allPlayerVideos[] = new Movie[4];
  Movie allWinVideos[] = new Movie[5];
  Movie currAnim;
  float startAnimTime;
  GameState gameState;
  ArrayList<Movie> queuedAnimations;




 AnimationManager(PApplet parent) {
    standby = new Movie(parent, "press_any_key_beer.mp4");

    bustAnimation = new Movie(parent, "pubstick_bust_animation.mp4");
    blackjackAnimation = new Movie(parent, "pubstick_blackjack_animation.mp4");
    missAnimation = new Movie(parent, "pubstick_miss_animation.mp4");

    //initializing score animations
    for (int i = 0; i < 5; i++) {
      String videoToLoad1 = i + "_pubstick_score_point" + ".mp4";
      String videoToLoad2 = i + "_pubstick_win.mp4";
      allScoreVideos[i] = new Movie(parent, videoToLoad1);
      allWinVideos[i] = new Movie(parent, videoToLoad2);
      allScoreVideos[i].stop();
      allWinVideos[i].stop();
    }

    //initializing player turn animations
    for (int i = 0; i < 4; i++) {
      String videoToLoad1 = i + "_pubstick_player_turn" + ".mp4";
      allPlayerVideos[i] = new Movie(parent, videoToLoad1);
      allPlayerVideos[i].stop();
    }

    queuedAnimations = new ArrayList();
  }

  void playerBusted(int playerId) {
    queueAnimation(bustAnimation);
  }

  void playerBlackjack(int playerId) {
    queueAnimation(blackjackAnimation);
  }

  void madeShot(int playerIndex, int holeNum) {
    queueAnimation(allScoreVideos[holeNum]);
  }

  void missedShot(int playerIndex) {
    queueAnimation(missAnimation);
  }


  public void updatedGameState(GameState newState) {
    println("Game State updated: ", newState);
    gameState = newState;
    standby.stop();
    switch(newState) {
    case STANDBY:
      standby.loop();
      break;
    case FINISHED:


      ArrayList<Player> winners = game.getWinningPlayer();
      if (winners.size() == 1) {
        int playerIndex = winners.get(0).id;
        queueAnimation(allWinVideos[playerIndex]);
        println("increasing cycle count");
        //cycles += 1;
        startAnimTime = millis();
        println("start animation time is: " + startAnimTime);
        println("queued animations length");
        int arraylength = queuedAnimations.size();
        println(arraylength);
      } else {
        queueAnimation(allWinVideos[4]); // This is tie video
        //cycles += 1;
        }
      break;
    default:
      break;
    }
  }

  void playerStarted(Player player) {
    queueAnimation(allPlayerVideos[player.id]);
  }

  void numPlayersChanged(int numPlayers) {
    // no op
  }

  // TODO if we queue the current animation again, this actually stops the current movie and adds it to the queue again.
  // not sure if thats expected
  void queueAnimation(Movie m) {
    queuedAnimations.add(m);
  }

 void display() {
    if (currAnim != null) {
      if (millis() > startAnimTime + currAnim.duration()*1000) {
        println("removing a vid, ", startAnimTime, currAnim.duration()*1000, millis());
        currAnim = null;
        queuedAnimations.remove(0);
        if (queuedAnimations.size() == 0){
          println("queued animation size is: ", queuedAnimations.size());
          //if (cycles == limit_cycles){
           // println("cycles met, exiting");
          //  exit();
          //}
        }
        game.resume();
      }
    }




    if (queuedAnimations.size() > 0) {
      if (currAnim == null) {
        currAnim = queuedAnimations.get(0);
        currAnim.stop();
        currAnim.play();
        startAnimTime = millis();
        println(currAnim);
        game.pause();
      } else if (currAnim != null) {
        set(0, 0, currAnim);
      }
    } else if (gameState == GameState.STANDBY) {
      set(0, 0, standby);
      //else if (gameState == GameState.FINISHED)
      //game.setState(GameState.SHOW_PODIUM);
    } else if (gameState == GameState.FINISHED) {
      game.setState(GameState.SHOW_PODIUM);
    }
  }
}

void movieEvent(Movie m) {
  m.read();
}

/// Added this class in order to create file that python script can monitor
class Logger {
  String m_fileName;
  Logger(String fileName) {
    m_fileName = fileName;
  }

  void log(String line) {
    PrintWriter pw = null;
    try {
      pw = GetWriter();
      pw.println(line);
      println("printing from logger");
      println(line);
    }
    catch (IOException e) {
      e.printStackTrace(); // Dumb and primitive exception handling...
      println("ouch 1");
    }
    finally {
      if (pw != null) {
        pw.close();
      }
    }
  }

  void log(String[] lines) {
    PrintWriter pw = null;
    try {
      pw = GetWriter();
      for (int i = 0; i < lines.length; i++) {
        pw.println(lines[i]);
      }
    }
    catch (IOException e) {
      e.printStackTrace(); // Dumb and primitive exception handling...
      println("ouch 2");
    }
    finally {
      if (pw != null) {
        pw.close();
      }
    }
  }

  void log(String errorMessage, StackTraceElement[] ste) {
    PrintWriter pw = null;
    try {
      pw = GetWriter();
      pw.println(errorMessage);
      for (int i = 0; i < ste.length; i++) {
        pw.println("\tat " + ste[i].getClassName() + "." + ste[i].getMethodName() +
          "(" + ste[i].getFileName() + ":" + ste[i].getLineNumber() + ")"
          );
      }
    }
    catch (IOException e) {
      e.printStackTrace(); // Dumb and primitive exception handling...
      println("ouch 3");
    }
    finally {
      if (pw != null) {
        pw.close();
      }
    }
  }

  private PrintWriter GetWriter() throws IOException
  {
    // FileWriter with append, BufferedWriter for performance
    // (although we close each time, not so efficient...), PrintWriter for convenience
    return new PrintWriter(new BufferedWriter(new FileWriter(m_fileName, true)));
  }
}
// =================================================
