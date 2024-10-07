AudioSample lineClearSound;
AudioSample tetrisClearSound;
AudioSample moveSound;
AudioSample rotateSound;
AudioSample placeTetrominoSound;
AudioSample startSound;
AudioSample gameOverSound;
AudioSample levelUpSound;


void loadAllSounds() {
  minim = new Minim(this);
  
  // Load the sounds from the "Sound" file in memory
  lineClearSound = minim.loadSample("Sounds/Line Clear.mp3");
  tetrisClearSound = minim.loadSample("Sounds/Tetris Clear.mp3");
  moveSound = minim.loadSample("Sounds/Move.mp3");
  rotateSound = minim.loadSample("Sounds/Rotate.mp3");
  placeTetrominoSound = minim.loadSample("Sounds/Place.mp3");
  startSound = minim.loadSample("Sounds/Start.mp3");
  gameOverSound = minim.loadSample("Sounds/Game Over.mp3");
  levelUpSound = minim.loadSample("Sounds/Level Up.mp3");
  rotateSound.setVolume(0.6);
}
