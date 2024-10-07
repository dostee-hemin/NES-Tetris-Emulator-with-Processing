int removingIndex = floor(grid.length/2);
boolean isRemovingLines;
boolean isTetris;
ArrayList<Integer> linesToBeRemoved = new ArrayList<Integer>();


void checkLines() {
  if (hasCalculatedARE) {
    return;
  }
  // Check each row and see if it is completed
  for (int j=0; j<grid[0].length; j++) {
    int total = 0;
    for (int i=0; i<grid.length; i++) {
      if (grid[i][j] > 0) {
        total++;
      }
    }

    // If the row is completed, add it to the "linesToBeRemoved" list
    if (total == grid.length) {
      linesToBeRemoved.add(j);
    }
  }


  // If there are no lines to be removed...
  if (linesToBeRemoved.isEmpty()) {
    // Calculate the ARE (the number of frames we wait before the next piece comes in)
    // Find the row the tetromino is placed
    float maxY = 0;
    for (PVector p : tetromino) {
      maxY = max(p.y, maxY);
    }

    // Calculate the ARE based on the row
    ARE = 10 + floor((21-maxY)/4)*2;
    hasCalculatedARE = true;
    if (canPlaySound)
      placeTetrominoSound.trigger();
  } 
  // If we have lines to remove...
  else {
    isRemovingLines = true;

    // If the number of lines removed is 4, the move is a tetris
    if (linesToBeRemoved.size() == 4) {
      isTetris = true;
      if (canPlaySound)
        tetrisClearSound.trigger();
    } 
    // If not, then its just a normal line clear
    else {
      if (canPlaySound)
        lineClearSound.trigger();
    }
  }
}

void setupNextPiece() {
  // Set the type of the current and next tetromino
  tetrominoType = nextTetrominoType;
  nextTetrominoType = floor(random(1, 8));

  // Create the current and next tetromino
  GenerateNextTetromino();
  GenerateTetromino();

  // Give points to the player based on how long they have soft dropped
  score += softDropScore;

  // Reset the soft drop score
  softDropScore = 0;

  // Reset variables for next piece
  isPlacingPiece = false;
  hasCalculatedARE = false;
  turnCorrection = 1;

  // Save the current score if its greater than the highscore.
  // We do it here so that if the game quits accidentally, the score is saved
  if (score > highscore) {
    String[] s = {str(highscore)};
    saveStrings("HIGHSCORE.txt", s);
  }
}


void removeLine() {
  // Every few frames, remove a block from the completed rows
  for (Integer j : linesToBeRemoved) {
    grid[removingIndex][j] = 0;
    grid[grid.length-1-removingIndex][j] = 0;
  }
  removingIndex--;
}

void dropTheRowsAbove(int bottom) {
  // Move all the blocks above the given row down
  for (int j=bottom; j>=0; j--) {
    for (int i=0; i<grid.length; i++) {
      if (j == 0) {
        grid[i][j] = 0;
      } else {
        grid[i][j] = grid[i][j-1];
      }
    }
  }
}
