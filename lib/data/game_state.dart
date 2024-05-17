enum State {
  home, // home page
  playing, // game playing
  pause, // game pause
  level, // level up
  over, // game over
}

class GameState {
  State state = State.home;

  void backHome() {
    state = State.home;
  }

  void onPlay() {
    state = State.playing;
  }

  void onLevelUp() {
    state = State.level;
  }

  void onGameOver() {
    state = State.over;
  }

  void onLevelNext(bool achieveGoal) {
    state = achieveGoal ? State.level : State.over;
  }

  bool isHome() {
    return state == State.home;
  }

  bool isPlaying() {
    return state == State.playing;
  }

  bool isLevelUp() {
    return state == State.level;
  }

  bool isGameOver() {
    return state == State.over;
  }

  bool isRunning() {
    return state == State.playing || state == State.level;
  }

  bool isGameSettlement() {
    return state == State.level || state == State.over;
  }
}
