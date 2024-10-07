int fallSpeed = speeds[0];
boolean isSoftDropping;
int waitStartCounter = 80;
float ARE;
boolean isPlacingPiece;
boolean hasCalculatedARE;
boolean isUsingDAS;
int DAScounter;
int movementDIR;

void moveDown() {
  // Don't move down if the tetromino touches the floor or another block,
  // place it instead
  for (PVector p : tetromino) {
    if (p == null) 
      return;
    if (touchesFloor(int(p.y + 1)) || touchesOtherBlock(int(p.x), int(p.y+1))) {
      placeTetromino();
      return;
    }
  }

  // If the tetromino can move down, move all of its blocks down
  for (PVector p : tetromino) {
    p.y++;
  }
}

void moveHorizontally(int direction) {
  // Don't move horizontally if the tetromino touches the walls or another block,
  for (PVector p : tetromino) {
    if (touchesWall(int(p.x + direction), direction) || touchesOtherBlock(int(p.x+direction), int(p.y))) {
      return;
    }
  }

  // If the tetromino can move horizontally, move all of its blocks in the given direction
  if (canPlaySound)
    moveSound.trigger();
  for (PVector p : tetromino) {
    p.x += direction;
  }
}

void rotateTetromino(int direction) {
  // If the tetromino is an "O" piece, there is no need for rotation so leave the function
  if (tetrominoType == 1) {
    return;
  }

  // Create a temporary tetromino to test if the real one can actually rotate
  PVector[] newTetromino = new PVector[4];
  for (int i=0; i<4; i++) {
    newTetromino[i] = tetromino[i].copy();
  }

  if (tetrominoType == 5) {
    direction = turnCorrection;
  } else if(tetrominoType > 5) {
    direction = -turnCorrection;
  }

  // Get the center of the real tetromino
  PVector center = tetromino[0];
  for (int i=1; i<4; i++) {
    // Loop through every other block and rotate it based on the given direction
    PVector oldP = tetromino[i];
    float xOff = oldP.x - center.x;
    float yOff = oldP.y - center.y;
    float newX = center.x - yOff * direction;
    float newY = center.y + xOff * direction;

    // If the new rotated position of the block is outside of the grid or touches another block,
    // quit rotating
    if (newX < 0 || newX > grid.length-1 || touchesOtherBlock(int(newX), int(newY))) {
      return;
    }

    // Set the temporary tetromino's position
    newTetromino[i].set(newX, newY);
  }

  // At this point, we know that the real tetromino can rotate
  // so set its position to the temporary tetromino's position
  if (canPlaySound)
    rotateSound.trigger();
  for (int i=0; i<4; i++) {
    tetromino[i] = newTetromino[i].copy();
  }

  turnCorrection *= -1;
}


// Return true if the given element in the grid is a block
boolean touchesOtherBlock(int i, int j) {
  if (j < 0)
    return false;
  return grid[i][j] > 0;
}

// Return true if the given row is the bottom most row
boolean touchesFloor(int j) {
  return j > grid[0].length-1;
} 

// Return true if the given column is outside of the grid's boundaries
boolean touchesWall(int i, int side) {
  if (side == -1) {
    return i < 0;
  } else if (side == 1) {
    return i > grid.length-1;
  }
  return false;
}

// Calculate the current fall speed of the tetromino
int calculateCurrentSpeed() {
  int currentSpeed = fallSpeed;
  if (isSoftDropping) {
    currentSpeed = 2;
  }
  return currentSpeed;
}


void placeTetromino() {
  // Place every block of the tetromino into the grid
  for (PVector p : tetromino) {
    // If the block is about to be placed outside of the grid,
    // the player has lost so end the game
    if (p.y < 0) {
      EndGame();
      return;
    }
    grid[int(p.x)][int(p.y)] = tetrominoType;
  }
  isPlacingPiece = true;
}
