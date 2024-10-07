int lineCount;
int tetrisLineCount;
int droughtCount;
int droughtTextRedValue;
int burnCount;
int score;
int highscore;
int softDropScore;
int advanceAmount;
int difficultyLevel;
int startLevel;

void moveToNextLevel() {
  // Increase the difficulty level and decrease the fall speed of the tetromino
  difficultyLevel++;
  if (canPlaySound)
    levelUpSound.trigger();

  fallSpeed = speeds[constrain(difficultyLevel, 0, 29)];
  levelColors = getCurrentLevelColors();
}


void checkLevelDifficulty() {
  if (lineCount < advanceAmount) {
    return;
  }

  // Move to the next level every 10 line clears
  if (lineCount % 10 == 0) {
    moveToNextLevel();
  }
}


void calculateScore() {
  // Give points to the player based on the number of lines cleared and the current level
  switch(linesToBeRemoved.size()) {
  case 1:
    score += 40 * (difficultyLevel + 1);
    break;
  case 2:
    score += 100 * (difficultyLevel + 1);
    break;
  case 3:
    score += 300 * (difficultyLevel + 1);
    break;
  case 4:
    score += 1200 * (difficultyLevel + 1);
    break;
  }
}


void EndGame() {
  // Move to the kill screen and reset both the tetromino and the next tetromino
  GameState = 2;
  for (PVector p : tetromino) {
    if (p.y < 0) {
      continue;
    }
    grid[int(p.x)][int(p.y)] = tetrominoType;
  }
  if (isSoftDropping) {
    softDropScore--;
  }
  tetromino = new PVector[4];
  nextTetromino = new PVector[4];
  if (canPlaySound)
    gameOverSound.trigger();
  gameOverCounter = 30;
}
