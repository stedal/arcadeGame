

// A game has N players with K balls 
// A player has K balls, with U used and V unused where U + V  = K

// Why does this need lastScore??
public class Player { 
  int ballsPerTurn;
  int ballsLeft;
  int id;
  int currentScore; 
  PlayerEventListener eventListener;
  int startTime, stopTime;
  int maxTurnDuration;


  Player(int ballsPerTurn, int id, int maxTurnDuration) {
    this.id = id;
    this.ballsPerTurn = ballsPerTurn;
    this.ballsLeft = ballsPerTurn;
    this.currentScore = 0;
    this.maxTurnDuration = maxTurnDuration;
  }

  void startTurn(int startTime) {
    this.startTime = startTime;
  }

  void setEventListener(PlayerEventListener pel) {
    println("called setEventListener");
    this.eventListener = pel;
  }

  void useBall() {
    ballsLeft--;
   //This doesn't make sense to have in this method but im just fixing bugs right now
   // if (ballsLeft == 0) {
   //    eventListener.endTurn();
   //  }
  }

  void addPointsToScore(int points) {
    currentScore += points;
    if (currentScore > 21) {
      eventListener.busted();
      useBall();

      currentScore = 14;
    } else if (currentScore == 21) {
      eventListener.blackjack();
      useBall();
      eventListener.endTurn();
      return;
    }
    useBall();
    if (ballsLeft < 1) {
      eventListener.endTurn();
    }

  }

  //This just updates the timer
  void update(int gameTime) {
    stopTime = gameTime;
    if (turnDuration() > maxTurnDuration) {
      eventListener.endTurn();
    }
  }

  int turnDuration() {
    return stopTime - startTime;
  }

  int remainingTime() {
    return maxTurnDuration - turnDuration();
  }
}
