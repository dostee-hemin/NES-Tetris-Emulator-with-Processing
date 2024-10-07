color[] levelColors = new color[2];

void DisplayGrid() {
  if (isTetris) {
    // Flashing black and white background during a Tetris
    if (floor(frameCount/4) % 2 == 0) {
      fill(255);
    } else {
      fill(0);
    }
  } else {
    // Regular black background
    fill(0);
  }
  // Display the background of the board
  rectMode(CORNER);
  noStroke();
  rect(blockSize*3, blockSize*6, grid.length*blockSize, grid[0].length*blockSize);

  // Display all the elements in the grid[][] array
  for (int i=0; i<grid.length; i++) {
    for (int j=0; j<grid[0].length; j++) {
      int value = grid[i][j];
      float x = blockSize*(3 + i + 0.5);
      float y = blockSize*(6 + j + 0.5);
      if (value > 0) {
        DisplayBlock(x, y, value);
      }
    }
  }
}

void DisplayTetromino() {
  for (PVector p : tetromino) {
    if (p == null) 
      break;
    float x = blockSize*(3 + p.x + 0.5);
    float y = blockSize*(6 + p.y + 0.5);
    if (y < blockSize*6) {
      continue;
    }
    // Display the block based on its type
    DisplayBlock(x, y, tetrominoType);
  }
}

void DisplayBoardAndUI() {
  /*     UI elements     */

  // Score
  fill(255);
  textSize(0.04*height);
  textAlign(CENTER);
  text("SCORE", blockSize*3 + (grid.length/2*blockSize), blockSize*3);
  textSize(0.06*height);
  text(score, blockSize*3 + int(grid.length/2*blockSize), blockSize*4.5);

  // Highscore
  textSize(0.03*height);
  text("HIGHSCORE", blockSize*19.5, blockSize*3);
  textSize(0.04*height);
  text(highscore, blockSize*19.5, blockSize*4.5);

  // Next tetromino
  for (PVector p : nextTetromino) {
    if (p == null) 
      break;
    DisplayBlock(p.x, p.y, nextTetrominoType);
  }

  // Line count
  textSize(0.03*height);
  text("LINE", blockSize*19.5, blockSize*11);

  // Level count
  text("LV", blockSize*19.5, blockSize*15);

  // Tetris rate count
  text("TRT", blockSize*19.5, blockSize*19);
  int percentage = 0;
  if (lineCount != 0) {
    percentage = int(float(tetrisLineCount)/float(lineCount) * 100);
  }

  // Burn count - Drought count

  // If the drought count is above 13, display a pulsing red drought counter
  if (droughtCount > 12) {
    // Display a flashing I piece
    noStroke();
    rectMode(CORNER);
    for (int i=0; i<4; i++) {
      float x = blockSize*(18+i);

      // I piece
      fill(levelColors[1], droughtTextRedValue);
      rect(x-drawConstants[3], blockSize*22.2, drawConstants[0], drawConstants[0]);

      // White parts
      fill(droughtTextRedValue);
      rect(x-drawConstants[3]+drawConstants[1], blockSize*22.2+drawConstants[1], drawConstants[2], drawConstants[2]);
      rect(x-drawConstants[3], blockSize*22.2, drawConstants[1], drawConstants[1]);

      // Red tint
      fill(droughtTextRedValue, 0, 0, 100);
      rect(x-drawConstants[3], blockSize*22.2, drawConstants[0], drawConstants[0]);
    }

    // Display the drought counter
    fill(255, 0, 0, droughtTextRedValue);
    textSize(0.055*height);
    text(droughtCount, blockSize*19.5, blockSize*24.5);

    // Update the fade value
    droughtTextRedValue-=5;
    if (droughtTextRedValue <= 0) {
      droughtTextRedValue = 255;
    }
  } 

  // If the drought counter should not be displayed, show the burn counter instead
  else {
    fill(255);
    text("BRN", blockSize*19.5, blockSize*23);
    textSize(0.05*height);
    text(burnCount, blockSize*19.5, blockSize*24.5);
  }

  fill(255);
  textSize(0.05*height);
  text(lineCount, blockSize*19.5, blockSize*12.5);
  text(difficultyLevel, blockSize*19.5, blockSize*16.5);
  text(percentage + "%", blockSize*19.5, blockSize*20.5);
}

color[] getCurrentLevelColors() {
  color[] output = new color[2];
  switch((difficultyLevel-startLevel)%10) {
  case 0:
    output[0] = color(160, 30, 30);
    output[1] = color(60, 50, 240);
    break;
  case 1:
    output[0] = color(220, 150, 35);
    output[1] = color(160, 30, 30);
    break;
  case 2:
    output[0] = color(95, 170, 350);
    output[1] = color(60, 50, 240);
    break;
  case 3:
    output[0] = color(135, 235, 15);
    output[1] = color(25, 165, 10);
    break;
  case 4:
    output[0] = color(220, 75, 250);
    output[1] = color(135, 5, 190);
    break;
  case 5:
    output[0] = color(90, 255, 80);
    output[1] = color(60, 50, 245);
    break;
  case 6:
    output[0] = color(70, 240, 120);
    output[1] = color(160, 10, 110);
    break;
  case 7:
    output[0] = color(140, 130, 250);
    output[1] = color(70, 245, 125);
    break;
  case 8:
    output[0] = color(90);
    output[1] = color(160, 35, 30);
    break;
  case 9:
    output[0] = color(85, 0, 55);
    output[1] = color(100, 20, 250);
    break;
  }
  return output;
}

float[] drawConstants = {0.857, 0.143, 0, 0.45};

void DisplayBlock(float x_, float y_, int type) {
  int x = int(x_);
  int y = int(y_);
  int textureType = -1;
  switch(type) {
  case 1: 
  case 2: 
  case 5:
    textureType = 0;
    break;
  case 4: 
  case 6: 
    textureType = 1;
    break;
  case 3: 
  case 7: 
    textureType = 2;
    break;
  }
  //println(blockSize);

  noStroke();
  rectMode(CORNER);

  // The color of the block based on the level
  if (textureType == 2) {
    fill(levelColors[0]);
  } else {
    fill(levelColors[1]);
  }
  rect(x-drawConstants[3], y-drawConstants[3], drawConstants[0], drawConstants[0]);

  // The white parts of the block
  fill(255);
  rect(x-drawConstants[3], y-drawConstants[3], drawConstants[1], drawConstants[1]);
  if (textureType == 0) {
    rect(x-drawConstants[3]+ drawConstants[1], y-drawConstants[3]+ drawConstants[1], drawConstants[2], drawConstants[2]);
  } else {
    rect(x-drawConstants[3] + drawConstants[1], y-drawConstants[3] + drawConstants[1], drawConstants[1], drawConstants[1]);
    rect(x-drawConstants[3] + drawConstants[1]*2, y-drawConstants[3] + drawConstants[1], drawConstants[1], drawConstants[1]);
    rect(x-drawConstants[3] + drawConstants[1], y-drawConstants[3] + drawConstants[1]*2, drawConstants[1], drawConstants[1]);
  }
}
