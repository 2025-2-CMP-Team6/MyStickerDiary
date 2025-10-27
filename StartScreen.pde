// StartScreen.pde


// Check if Mouse is Pressed
boolean isStartButtonPressed = false;

public void drawStartScreen() {
    background(#FFCA1A);
    drawBackgroundEffect();
    drawMeow();
    drawTitle();
    drawClickAnywhere();
}

public void drawMeow() {
    // Print Console Message if Character is Not Loaded
    if(meow == null) {
        println("meow is not loaded.");
        return;
    }

    // Calculate Size to Fill Screen While Maintaining Aspect Ratio
    // If Image is Wider than Screen, Match Height. If Taller, Match Width.
    imageMode(CENTER);
    float imgRatio = (float)meow.width / (float)meow.height;
    float screenRatio = (float)width / (float)height;
    
    float newW, newH;
    if (imgRatio > screenRatio) {
      // If Image is Wider than Screen (Can be Cropped Left/Right)
      newH = height;
      newW = newH * imgRatio;
    } else {
      // If Image is Taller than Screen (Can be Cropped Top/Bottom)
      newW = width;
      newH = newW / imgRatio;
    }
    // Draw Image in the Center with Calculated Size
    image(meow, width/2, height/2, newW, newH);
}

public void drawTitle() {
    // Declare Title Text Position Variables
    float titleX = width/2;
    float titleY = height/2 - 80;

    fill(0);
    textAlign(CENTER, CENTER);
    textFont(font);
    textSize(100);
    text("MyStickerDiary", titleX, titleY);
}

public void drawClickAnywhere() {
    // Declare Alpha Variable for Blinking Effect
    float alpha = 150 + 105 * sin(frameCount * 0.1);
    
    // Declare Message Position Variables
    float messageX = width/2;
    float messageY = height/2 + 100;
    
    // Text Shadow Effect
    fill(0, alpha * 0.3);
    textAlign(CENTER, CENTER);
    textSize(26);
    text("Click Anywhere to Start!", messageX + 2, messageY + 2);
    
    // Main Text (Blinking Effect)
    fill(80, 80, 80, alpha);
    textAlign(CENTER, CENTER);
    textSize(26);
    text("Click Anywhere to Start!", messageX, messageY);
}

public void handleStartRelease() {
    switchScreen(menu_screen);
    if(ddButton == null) initMenuButtons();
}