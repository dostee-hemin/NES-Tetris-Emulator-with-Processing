void keyPressed() {
  // If the user presses 'ENTER' in the main menu, start the game
  if (GameState == 0) {
    if (int(key) >= 48 && int(key) <= 57) {
      difficultyLevel = int(key) - 48;
      StartGame();
    } else {
      switch(key) {
      case ')':
        difficultyLevel = 10;
        break;
      case '!':
        difficultyLevel = 11;
        break;
      case '@':
        difficultyLevel = 12;
        break;
      case '#':
        difficultyLevel = 13;
        break;
      case '$':
        difficultyLevel = 14;
        break;
      case '%':
        difficultyLevel = 15;
        break;
      case '^':
        difficultyLevel = 16;
        break;
      case '&':
        difficultyLevel = 17;
        break;
      case '*':
        difficultyLevel = 18;
        break;
      case '(':
        difficultyLevel = 19;
        break;
      }
      if (difficultyLevel > 9) {
        StartGame();
      }
    }
  } 


  // If the game is currently being played
  else if (GameState == 1) {
    // Move the tetromino based on the arrow keys
    switch(keyCode) {
    case LEFT: 
      isUsingDAS = true;
      movementDIR = -1;
      break;
    case RIGHT: 
      isUsingDAS = true;
      movementDIR = 1;
      break;
    case DOWN: 
      if (!isPlacingPiece && waitStartCounter == 0)
        isSoftDropping = true;
      break;
    }

    // Rotate the tetromino based on the letter keys
    if (!isPlacingPiece) {
      switch(key) {
      case 'a': 
      case 'A':
        rotateTetromino(-1);
        break;
      case 'd': 
      case 'D':
        rotateTetromino(1);
        break;
      }
    }
  }

  if (key == 'm') {
    canPlaySound = !canPlaySound;
  }

  if (key == '[') {
    blockSize -= 7;
    surface.setSize(blockSize*25, blockSize*29);
    createBackground();
  } else if (key == ']') {
    blockSize += 7;
    surface.setSize(blockSize*25, blockSize*29);
    createBackground();
  }
}

void keyReleased() {
  // Once the user has released the DOWN arrow, stop soft dropping
  switch(keyCode) {
  case DOWN: 
    isSoftDropping = false;
    softDropScore = 0;
    break;
  case LEFT: 
  case RIGHT:
    isUsingDAS = false;
    DAScounter = 0;
    break;
  }
}
