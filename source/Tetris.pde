import ddf.minim.*;

Minim minim;
boolean canPlaySound = true;

int[][] grid = new int[10][20];
int[] speeds = {48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1};
int tetrominoType;
int nextTetrominoType;
int blockSize = 28;
int GameState;
int resetIndex;
int gameOverCounter;
int turnCorrection = 1;

PVector[] tetromino = new PVector[4];
PVector[] nextTetromino = new PVector[4];

PFont zigFont;
PImage backgroundImage;
PImage baseImage;

void settings() {
  blockSize = floor(displayHeight/203)*7;
  size(25*blockSize, 29*blockSize);
}

void setup() {
  for (int i=0; i<drawConstants.length; i++) {
    drawConstants[i] = turnIntoEven(int(drawConstants[i]*blockSize));
  }
  drawConstants[2] = drawConstants[0] - 2*drawConstants[1];

  // Load all sounds used in the game
  loadAllSounds();

  // Load the font style and apply it
  zigFont = createFont("zig.ttf", 90);
  textFont(zigFont);

  baseImage = loadImage("base.png");
  backgroundImage = loadImage("background.png");
  if (backgroundImage == null || backgroundImage.height != height) {
    createBackground();
  }

  // Load the 'highscore' value from memory if it exists
  try {
    highscore = int(loadStrings("HIGHSCORE.txt")[0]);
  } 
  catch (NullPointerException e) {
    highscore = 0;
  }
}

void createBackground() {
  noStroke();
  baseImage.loadPixels();
  float scl = round(blockSize/7);
  for (int x=0; x<baseImage.width; x++) {
    for (int y=0; y<baseImage.height; y++) {
      int index = x + y*baseImage.width;
      color c = baseImage.pixels[index];
      fill(c);
      rect(x*scl, y*scl, scl, scl);
    }
  }
  save("background.png");
  backgroundImage = loadImage("background.png");
}

float d3(float x1, float y1, float z1, float x2, float y2, float z2) {
  return (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
}

void draw() {
  image(backgroundImage, -1, -1);

  // Display everything in the game
  DisplayBoardAndUI();
  DisplayGrid();
  if (!isPlacingPiece) {
    DisplayTetromino();
  }

  switch(GameState) {

    /*      Main Menu      */
  case 0:
    // Tint the entire screen black
    noStroke();
    fill(0, 200);
    rectMode(CORNER);
    rect(0, 0, width, height);

    // Display the "Press 'Enter'" text
    if (floor(frameCount/30) % 2 == 0) {
      fill(255, 0, 0);
      textSize(0.05*height);
      textAlign(CENTER);
      text("Select Level (0-19)", width/2, height/2);
    }
    break;



    /*      Playing Game      */
  case 1:
    if (waitStartCounter != 0) {
      waitStartCounter--;
    }

    if (isRemovingLines) {
      if (frameCount % 4 == 0) {
        // If the line removal process is complete,
        // shift everything down and prepare for the next piece
        if (removingIndex < 0) {
          for (Integer j : linesToBeRemoved) {
            dropTheRowsAbove(j);      // Move the grid down
            lineCount ++;             // Count the number of lines removed
            checkLevelDifficulty();   // Check if the line count reaches a new level
          }

          // If the move was a tetris (i.e. 4 lines were removed)
          if (isTetris) {
            // Count the number of tetris lines and reset the burn counter
            tetrisLineCount += 4;
            burnCount = 0;
          } 
          // If the move wasn't a tetris (i.e. 1, 2, or 3 lines were removed)
          else {
            // Add the number of lines removed to the burn counter
            burnCount += linesToBeRemoved.size();
          }

          // Calculate the player's score based on the lines removed
          calculateScore();

          // Reset everything and setup the next piece
          linesToBeRemoved.clear();
          setupNextPiece();
          removingIndex = floor(grid.length/2);
          isRemovingLines = false;
          isTetris = false;
        }

        // Remove every block of the completed rows
        removeLine();
      }
    }

    // If the game should move the tetromino down...
    else {
      // Move the tetromino down based on the current fall rate
      if (isPlacingPiece) {
        // After placement, check for completed lines
        checkLines();

        if (hasCalculatedARE) {
          if (ARE != 0) {
            ARE--;
          } else {
            setupNextPiece();
          }
        }
      } else {
        if (isUsingDAS) {
          if (DAScounter == 0) {
            moveHorizontally(movementDIR);
          } else if (DAScounter > 15) {
            if ((DAScounter-16)%6 == 0) {
              moveHorizontally(movementDIR);
            }
          }
        }
        if (frameCount % calculateCurrentSpeed() == 0) {
          if (waitStartCounter == 0) {
            moveDown();
          }

          // If the player is using soft drop, 
          // increase the score every time the tetromino goes down
          if (isSoftDropping) {
            softDropScore++;
          }
        }
      }
      if (isUsingDAS) {
        DAScounter++;
      }
    }
    break;



    /*      Kill Screen (Game Over)      */
  case 2:
    if (gameOverCounter != 0) {
      gameOverCounter--;
    } else if (frameCount % 5 == 0) {
      // Once the grid is filled, reset the game
      if (resetIndex == grid[0].length) {
        ResetGame();
        return;
      }
      resetIndex++;
    }

    for (int j=0; j<resetIndex; j++) {
      float x = blockSize*8;
      float y = blockSize*(j + 0.5 + 6);
      rectMode(CENTER);
      noStroke();
      fill(0);
      rect(x, y, blockSize*grid.length, blockSize);
      fill(levelColors[0]);
      rect(x, y-blockSize/4, blockSize*grid.length, blockSize/3);
      fill(levelColors[1]);
      rect(x, y+blockSize/4, blockSize*grid.length, blockSize/3);
      fill(255);
      rect(x, y, blockSize*grid.length, blockSize/3);
      for (int i=0; i<10; i++) {
        grid[i][resetIndex-1] = 0;
      }
    }
    break;
  }
}



void GenerateTetromino() {
  // Create the current tetromino's coordinates
  // (units are indecies |    (x,y) = (i,j)
  switch(tetrominoType) {
  case 1:
    // O block
    tetromino[0] = new PVector(4, 0);
    tetromino[1] = new PVector(4, 1);
    tetromino[2] = new PVector(5, 0);
    tetromino[3] = new PVector(5, 1);
    break;
  case 2:
    // T block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(4, 0);
    tetromino[2] = new PVector(6, 0);
    tetromino[3] = new PVector(5, 1);
    break;
  case 3:
    // L block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(4, 0);
    tetromino[2] = new PVector(4, 1);
    tetromino[3] = new PVector(6, 0);
    break;
  case 4:
    // J block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(4, 0);
    tetromino[2] = new PVector(6, 0);
    tetromino[3] = new PVector(6, 1);
    break;
  case 5:
    // I block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(3, 0);
    tetromino[2] = new PVector(4, 0);
    tetromino[3] = new PVector(6, 0);
    break;
  case 6:
    // S block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(5, 1);
    tetromino[2] = new PVector(4, 1);
    tetromino[3] = new PVector(6, 0);
    break;
  case 7:
    // Z block
    tetromino[0] = new PVector(5, 0);
    tetromino[1] = new PVector(5, 1);
    tetromino[2] = new PVector(4, 0);
    tetromino[3] = new PVector(6, 1);
    break;
  }

  // If the current tetromino is not an I piece, increase the dought count
  if (tetrominoType != 5) {
    droughtCount ++;
  } 
  // If the current tetromino is an I piece, set the drought count to 0
  else {
    droughtCount = 0;
  }


  // If the current tetromino touches another block (i.e. it can not spawn),
  // the game has ended
  for (PVector p : tetromino) {
    if (touchesOtherBlock(int(p.x), int(p.y))) {
      EndGame();
      return;
    }
  }
}


void GenerateNextTetromino() {
  // Create the next tetromino's coordinates
  // (units are in block sizes |    1 unit = 1 block size   )
  switch(nextTetrominoType) {
  case 1:
    // O block
    nextTetromino[0] = new PVector(-0.5, -0.5);
    nextTetromino[1] = new PVector(-0.5, 0.5);
    nextTetromino[2] = new PVector(0.5, -0.5);
    nextTetromino[3] = new PVector(0.5, 0.5);
    break;
  case 2:
    // T block
    nextTetromino[0] = new PVector(0, -0.5);
    nextTetromino[1] = new PVector(-1, -0.5);
    nextTetromino[2] = new PVector(1, -0.5);
    nextTetromino[3] = new PVector(0, 0.5);
    break;
  case 3:
    // L block
    nextTetromino[0] = new PVector(0, -0.5);
    nextTetromino[1] = new PVector(-1, -0.5);
    nextTetromino[2] = new PVector(-1, 0.5);
    nextTetromino[3] = new PVector(1, -0.5);
    break;
  case 4:
    // J block
    nextTetromino[0] = new PVector(0, -0.5);
    nextTetromino[1] = new PVector(-1, -0.5);
    nextTetromino[2] = new PVector(1, -0.5);
    nextTetromino[3] = new PVector(1, 0.5);
    break;
  case 5:
    // I block
    nextTetromino[0] = new PVector(0.5, 0);
    nextTetromino[1] = new PVector(-1.5, 0);
    nextTetromino[2] = new PVector(-0.5, 0);
    nextTetromino[3] = new PVector(1.5, 0);
    break;
  case 6:
    // S block
    nextTetromino[0] = new PVector(0, -0.5);
    nextTetromino[1] = new PVector(1, -0.5);
    nextTetromino[2] = new PVector(0, 0.5);
    nextTetromino[3] = new PVector(-1, 0.5);
    break;
  case 7:
    // Z block
    nextTetromino[0] = new PVector(0, -0.5);
    nextTetromino[1] = new PVector(1, 0.5);
    nextTetromino[2] = new PVector(0, 0.5);
    nextTetromino[3] = new PVector(-1, -0.5);
    break;
  }

  // Magnify the coordinates of each block and move it into the display panel
  for (PVector p : nextTetromino) {
    p.mult(blockSize);
    p.add(blockSize*19.5, blockSize*7.5);
  }
}

void StartGame() {
  fallSpeed = speeds[difficultyLevel];
  GameState = 1;
  startLevel = difficultyLevel;
  nextTetrominoType = floor(random(1, 8));
  setupNextPiece();
  for (int i=0; i<grid.length; i++) {
    for (int j=0; j<grid[0].length; j++) {
      grid[i][j] = 0;
    }
  }
  if (canPlaySound)
    startSound.trigger();
  if (difficultyLevel < 10) {
    advanceAmount = difficultyLevel*10 + 10;
  } else {
    advanceAmount = max(100, (difficultyLevel*10)-50);
  }

  levelColors = getCurrentLevelColors();
}

void ResetGame() {
  // Reset all values
  GameState = 0;
  resetIndex = 0;
  if (score > highscore) {
    highscore = score;
    String[] s = {str(highscore)};
    saveStrings("HIGHSCORE.txt", s);
  }
  score = 0;
  softDropScore = 0;
  lineCount = 0;
  tetrisLineCount = 0;
  difficultyLevel = 0;
  burnCount = 0;
  droughtTextRedValue = 255;
  droughtCount = 0;
  fallSpeed = 30;
  waitStartCounter = 80;
}

int turnIntoEven(int n) {
  if (n % 2 != 0) {
    return n+1;
  }
  return n;
}
