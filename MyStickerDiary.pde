/* 
 * MyStickerDiary.pde
 * Owner: 신이철
 * SubOwner: 김동현
  */

import interfascia.*;
import uibooster.*;
import java.io.File;
import java.util.Arrays;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.awt.Font;
import g4p_controls.*;
import processing.sound.*;

String username;

final int start_screen = 0;
final int menu_screen = 1;
final int making_sticker = 2;
final int sticker_library = 3;
final int drawing_diary = 4;
final int diary_library = 5;
final int name_screen = 6;

int currentScreen = start_screen;
int previousScreen = start_screen;

boolean returnToDiaryAfterEdit = false;
boolean overlayWasVisibleBeforeEdit = false;
int diaryReturnScreen = menu_screen; // Screen to Return to from Diary

int loadingStage = 0; // 0: Before Start, 1: Background Loading, 2: Main Thread Loading Complete, 3: All Loading Complete.
float loadingProgress = 0.0;
float displayLoadingProgress = 0.0;
String loadingMessage = "";
boolean readyToTransition = false;

boolean isSettingsVisible = false;
boolean isMouseOverStartBtn = false;
ArrayList<Bubble> bubbles;
PFont myFont;
ArrayList<Sticker> stickerLibrary;
ArrayList<Sticker> placedStickers;
Sticker currentlyDraggedSticker = null;
Sticker stickerToEdit = null;
float offsetX, offsetY;
float defaultStickerSize = 100.0;
PFont font;

PImage meow;
PImage loadingImage;

PImage[] emotIcon;
PImage[] weatherIcon;
PImage undoIcon;
PImage trashClosedIcon, trashOpenIcon;

// Sticker Creator Tool Icons and Cursors
PImage saveImg;
PImage backImg;
PImage brushImg;
PImage paintImg;
PImage eraserImg;
PImage brushCursor;
PImage paintCursor;
PImage eraserCursor;
PImage catImg, foxImg, cloudImg, owlImg;
PImage spoideCursor;
PGraphics lineCursor;
PGraphics rectCursor;
PGraphics circleCursor;

boolean isStickerModified = false;
boolean isDiaryModified = false;

color[] palleteColor;

GTextField titleArea;
GTextArea textArea;
float titlespace;
float textFieldY;
float navigationBarY;

Calendar calendar = Calendar.getInstance();

SoundFile song;
float bgmVolume = 0.5;
float sfxVolume = 0.8;
SoundFile clickSound;
boolean bgmStarted = false;

rectButton dsButton, slButton, ddButton, dlButton;
GImageButton nameEditButton;
GSlider dragSpeedSlider;
rectButton settings_goToMainButton;
GSlider sdr;
GSlider sfxSlider;
rectButton prevMonthButton;
rectButton nextMonthButton;

rectButton diaryColorPicker;
rectButton diaryWeather;
rectButton diaryEmotion;

float menuScrollX = 0;              
float menuTargetScrollX = 0;        
boolean isMenuDragging = false;
float dragStartX = 0;
float dragStartScroll = 0;
float totalDragDist = 0;
float menuDragSpeed = 1.0;

float BACK_W, BACK_H;
float BACK_X, BACK_Y;

float DIARY_BACK_W, DIARY_BACK_H;
float DIARY_BACK_X, DIARY_BACK_Y;

boolean isBackButtonPressed = false;
void drawBackButton(float x, float y, float w, float h) {
  if (backImg != null) {
    pushStyle();
    if (mouseHober(x, y, w, h)) {
      fill(255, 50);
      noStroke();
      rect(x - 4, y - 4, w + 8, h + 8, 8);
    }
    
    imageMode(CORNER);
    PVector newSize = getScaledImageSize(backImg, w, h);
    image(backImg, x + (w - newSize.x) / 2, y + (h - newSize.y) / 2, newSize.x, newSize.y);
    popStyle();
  }
}

void drawBackButton() {
  drawBackButton(BACK_X, BACK_Y, BACK_W, BACK_H);
}

void textAreaUI() {
  if (titleArea == null) {
    titleArea = new GTextField(this, 4, textFieldY+4, width-8, titlespace);
    titleArea.setOpaque(true);
    titleArea.setVisible(false);
    titleArea.setPromptText("Title");
    titleArea.setFont(new Font("Dialog", Font.PLAIN, 24));
  }

  if(textArea == null) {

    textArea = new GTextArea(this, 4, textFieldY + titlespace + 8, width-8, height - textFieldY - 8 - titlespace, G4P.SCROLLBARS_VERTICAL_ONLY);
    textArea.setOpaque(true);
    textArea.setVisible(false);
    textArea.setPromptText("Text");
    textArea.setFont(new Font("Dialog", Font.PLAIN, 24));

  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) {
  if (currentScreen == drawing_diary && (textcontrol == titleArea || textcontrol == textArea)) {
    if (event == GEvent.CHANGED) {
      isDiaryModified = true;
    }
  }
}
// When Switch Screen, Record the Next/Previous Screen.
void switchScreen(int next) {
  int from = currentScreen;
  if (next == drawing_diary && (from == menu_screen || from == diary_library)) {
    diaryReturnScreen = from;
  }
  previousScreen = from;
// Reset Sticker overlay state when entering DrawingDiary
if (next == drawing_diary) {
  isStickerEditContextVisible = false;
  if (!returnToDiaryAfterEdit) {
    isStickerLibraryOverlayVisible = false;
  }
  isDraggingScrollbar = false;
  returnToDiaryAfterEdit = false;
  overlayWasVisibleBeforeEdit = false;
}

  isMenuDragging = false;
  pressedOnNameBtn = false;
  totalDragDist = 0;

  if (from == making_sticker) {
    stickerToEdit = null; // Reset Sticker Edit State.
    resetCreator(); // Reset the Entire Sticker Creator Screen State.
  }

  menuTargetScrollX = menuScrollX;

  isDrawingShape = false;
  isBrushSizeChange = false;
  cursor(ARROW);

  if (next == making_sticker) {
    clearUndoStack(); // Initialize Undo and Redo Stacks.
    saveUndoState();  // Save the Initial State of the Canvas (Blank or Sticker to Edit).
    isStickerModified = false; // Reset Sticker Modified State.
  }

  currentScreen = next;

  updateTextUIVisibility();

  if (nameEditButton != null) {
    // When the Screen Changes, Make nameEditButton Visible Only if the Next Screen is the Menu.
    nameEditButton.setVisible(next == menu_screen);
  }
  if (next == diary_library) {
    loadDiaryDates();
  }
}



float worldMouseX() { return mouseX + menuScrollX; }
float worldMouseY() { return mouseY; } 

// Initialize Menu Button
void initMenuButtons() {
  float menuGutterX = width * (120.0f / 1280.0f);
  float pagePaddingX = menuGutterX / 2.0f;

  float btnW = (width - pagePaddingX * 2 - menuGutterX) / 2;
  float btnH = height * (360.0f / 720.0f);
  
  float menuTop = height * (200.0f / 720.0f);

  int x1 = round(pagePaddingX);
  int x2 = round(pagePaddingX + btnW + menuGutterX);
  int y  = round(menuTop);

  dsButton = new rectButton(this, x1, y, round(btnW), round(btnH), #F0B950);
  dsButton.rectButtonText("Drawing\nSticker", 50);
  slButton = new rectButton(this, x2, y, round(btnW), round(btnH), #F0B950);
  slButton.rectButtonText("Sticker\nLibrary", 50);

  ddButton = new rectButton(this, x1 + width, y, round(btnW), round(btnH), #F0B950);
  ddButton.rectButtonText("Drawing\nDiary", 50);
  dlButton = new rectButton(this, x2 + width, y, round(btnW), round(btnH), #F0B950);
  dlButton.rectButtonText("Diary\nLibrary", 50);

  // Apply Style Only to Menu Buttons.
  dsButton.setStyle(rectButton.ButtonStyle.FANCY);
  slButton.setStyle(rectButton.ButtonStyle.FANCY);
  ddButton.setStyle(rectButton.ButtonStyle.FANCY);
  dlButton.setStyle(rectButton.ButtonStyle.FANCY);

  // Set Images to Buttons.
  dsButton.setImage(catImg);
  slButton.setImage(foxImg);
  ddButton.setImage(cloudImg);
  dlButton.setImage(owlImg);
}
// Initialize Diary Library UI.
void ensureDiaryUI() {
  float btnColumnX = width * (1100.0f/1280.0f);
  float btnW = width * (180.0f/1280.0f);
  float btnH = height * (60.0f/720.0f);

  float analyzeBtnY = navigationBarY;
  float finishBtnY = textFieldY - btnH;
  float colorBtnY = finishBtnY - btnH;
  float stickerBtnY = colorBtnY - btnH;

  if (analyzeButton == null) {
    analyzeButton = new rectButton(this, round(btnColumnX), round(analyzeBtnY), round(btnW), round(btnH), #B4F0C2);
    analyzeButton.rectButtonText("Analyze", 22);
    analyzeButton.setShadow(false);
  }

  if(stickerStoreButton == null) {
    stickerStoreButton = new rectButton(this, round(btnColumnX), round(stickerBtnY), round(btnW), round(btnH), #c8dcff);
    stickerStoreButton.rectButtonText("Sticker storage", 25);
    stickerStoreButton.setShadow(false);
  }

  if (diaryColorPicker == null) {
    diaryColorPicker = new rectButton(this, round(btnColumnX), round(colorBtnY), round(btnW), round(btnH), #D0E0F0);
    diaryColorPicker.rectButtonText("Change Color", 22);
    diaryColorPicker.setShadow(false);
  }

  if (finishButton == null) {
    finishButton = new rectButton(this, round(btnColumnX), round(finishBtnY), round(btnW), round(btnH), #F9E4B7);
    finishButton.rectButtonText("Finish", 20);
    finishButton.setShadow(false);
  }
}
// Perform Minimal Initialization on App Start.
void setup() { 
    size(1200, 800);
    pixelDensity(1);
  
    // Set Window Title.
    surface.setTitle("MyStickerDiary");
    // Prevent User from Resizing the Window.
    surface.setResizable(false);
    // Set App Icon.
    PImage icon = loadImage("images/icon.png");
    surface.setIcon(icon);

    // Load the Default Font Needed for the Loading Screen First.
    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);

    // Initialize Color Palette.
    palleteColor = new color[]{
      color(0, 0, 0),        // 1. Black
      color(255, 0, 0),      // 2. Red
      color(255, 165, 0),    // 3. Orange
      color(255, 255, 0),    // 4. Yellow
      color(0, 255, 0),      // 5. Green
      color(0, 0, 255),      // 6. Blue
      color(0, 255, 255),    // 7. Sky Blue
      color(255, 0, 255),    // 8. Magenta
      color(128, 128, 128),  // 9. Gray
      color(211, 211, 211),  // 10. Light Gray
      color(255, 255, 255),  // 11. White
      color(255, 255, 255)   // 12. Placeholder for Color Picker (Color is Irrelevant)
    };

    // Initialize Background Effect Bubbles.
    bubbles = new ArrayList<Bubble>();
    for (int i = 0; i < 20; i++) {
      bubbles.add(new Bubble());
    }
    // Load the Loading Image First.
    loadingImage = loadImage("data/images/running_friends.png");
    loadingStage = 1;
    thread("performHeavySetup");
}

// Process Time-Consuming Tasks in a Background Thread.
void performHeavySetup() { 
    loadingMessage = "Initializing...";
    imageMode(CENTER);
    stickerLibrary = new ArrayList<Sticker>();
    placedStickers = new ArrayList<Sticker>();
    titlespace = height * (48.0f / 720.0f);
    textFieldY = height * (480.0f / 720.0f);
    navigationBarY = height * (64.0f / 720.0f);
    loadingProgress = 0.05;
    
    BACK_W = width * (64.0f / 1280.0f);
    BACK_H = height * (64.0f / 720.0f);
    BACK_X = width * (24.0f / 1280.0f);
    BACK_Y = height * (24.0f / 720.0f);

    // Set Values for the Diary-Specific Back Button.
    DIARY_BACK_W = width * (48.0f / 1280.0f);
    DIARY_BACK_H = height * (48.0f / 720.0f);
    DIARY_BACK_X = width * (16.0f / 1280.0f);
    DIARY_BACK_Y = height * (8.0f / 720.0f);

    // Load Setting
    loadingMessage = "Loading settings...";
    initializeSetting();
    loadingProgress = 0.1;
    
    // Load Sounds.
    loadingMessage = "Loading sounds...";
    loadSong();
    clickSound = new SoundFile(this, "data/sounds/click.mp3");
    loadingProgress = 0.15;

    // Load Fonts.
    loadingMessage = "Loading fonts...";
    loadingProgress = 0.20;

    // Load Icon Images.
    loadingMessage = "Loading UI icons...";
    meow = loadImage("data/images/meow.png");
    emotIcon = new PImage[5];
    emotIcon[0] = loadImage("images/icon_face_angry.png");
    emotIcon[1] = loadImage("images/icon_face_anger.png");
    emotIcon[2] = loadImage("images/icon_face_crying.png");
    emotIcon[3] = loadImage("images/icon_face_neutral.png");
    emotIcon[4] = loadImage("images/icon_face_happy.png");
    weatherIcon = new PImage[6];
    weatherIcon[0] = loadImage("images/icon_weather_sunny.png");
    weatherIcon[1] = loadImage("images/icon_weather_windy.png");
    weatherIcon[2] = loadImage("images/icon_weather_cloudy.png");
    weatherIcon[3] = loadImage("images/icon_weather_rainy.png");
    weatherIcon[4] = loadImage("images/icon_weather_snow.png");
    weatherIcon[5] = loadImage("images/icon_weather_storm.png");
    undoIcon = loadImage("images/undo.png");
    trashClosedIcon = loadImage("images/trash_closed.png");
    trashOpenIcon = loadImage("images/trash_open.png");
    loadingProgress = 0.30;

    // Load Sticker Creator Tool Resources.
    loadingMessage = "Loading creator tools...";
    saveImg = loadImage("data/images/saveIcon.png");
    backImg = loadImage("data/images/backIcon.png");
    brushImg = loadImage("data/images/brush.png");
    paintImg = loadImage("data/images/paint.png");
    eraserImg = loadImage("data/images/eraser.png");
    brushCursor = loadImage("data/images/brush.png");
    paintCursor = loadImage("data/images/paint.png");
    eraserCursor = loadImage("data/images/eraser.png");
    spoideCursor = loadImage("data/images/spoide.png");
    loadingProgress = 0.40;

    loadingMessage = "Loading menu button images...";
    catImg = loadImage("images/cat.png");
    foxImg = loadImage("images/fox.png");
    cloudImg = loadImage("images/cloud.png");
    owlImg = loadImage("images/owl.png");
    loadingProgress = 0.45;

    loadingMessage = "Preparing sticker list...";
    loadStickersFromFolder("sticker", 0.45, 0.90);

    loadingMessage = "Initializing UI...";
    initMenuButtons();
    initDiaryLibrary();
    loadingProgress = 0.92;

    loadingMessage = "Fetching weather data...";
    todayWeather = getWeather();
    initWeatherEffects();
    loadingProgress = 0.95;

    loadingMessage = "Finalizing...";
    settings_goToMainButton = new rectButton(this, width/2 - 100, height/2 + 150, 200, 50, color(100, 150, 255));
    settings_goToMainButton.rectButtonText("Main", 24);
    loadingProgress = 1.0;

    loadingStage = 2; // Loading Complete.
}

// Initialization that Must Run on the Main Thread.
void finishSetupOnMainThread() { 
    setupCreator();
    textAreaUI();

    // Create G4P Controls
    String[] nameButtonImages = {
      "images/name_edit_off.png", "images/name_edit_over.png", "images/name_edit_down.png"
    };
    nameEditButton = new GImageButton(this, round(width - width*(80.0f/1280.0f)), round(height*(30.0f/720.0f)), nameButtonImages, "images/name_edit_masks.png");
    nameEditButton.setVisible(false);

    G4P.setCursor(CROSS);

    float sliderW = width * (200.0f / 1280.0f);
    float sliderX = width / 2 - sliderW / 2;

    // BGM Slider.
    sdr = new GSlider(this, round(sliderX), round(height*(250.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    sdr.setVisible(false);
    sdr.setValue(bgmVolume);

    // SFX Slider.
    sfxSlider = new GSlider(this, round(sliderX), round(height*(330.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    sfxSlider.setVisible(false);
    sfxSlider.setValue(sfxVolume);

    // Drag Speed Slider.
    dragSpeedSlider = new GSlider(this, round(sliderX), round(height*(410.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    dragSpeedSlider.setLimits(1.0f, 0.5f, 2.0f);
    dragSpeedSlider.setValue(menuDragSpeed);
    dragSpeedSlider.setNbrTicks(4); // 0.5, 1.0, 1.5, 2.0
    dragSpeedSlider.setStickToTicks(true);
    dragSpeedSlider.setVisible(false);

}

// Handler for G4P Control Events.
void handleButtonEvents(GImageButton button, GEvent event) {
  if (button == nameEditButton && event == GEvent.CLICKED) {
    switchScreen(name_screen);
  }
}

void loadSong() {
  song = new SoundFile(this, "sounds/cutebgm.mp3");

  if (song == null) {
    println("Sound file failed to load.");
    return;
  }
  song.loop(); // Loop Background Music.
  song.amp(bgmVolume);
}

void loadStickersFromFolder(String folderPath, float startProgress, float endProgress) {
  File folder = new File(dataPath(folderPath));
  if (folder.exists() && folder.isDirectory()) {
    File[] files = folder.listFiles(new FilenameFilter() {
      public boolean accept(File dir, String name) {
        String lower = name.toLowerCase();
        return lower.endsWith(".png") || lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".gif");
      }
    });
    if (files != null && files.length > 0) {
      Arrays.sort(files);
      float progressStep = (endProgress - startProgress) / files.length;
      for (int i = 0; i < files.length; i++) {
        File file = files[i];
        stickerLibrary.add(new Sticker(0, 0, defaultStickerSize, file.getName()));
        loadingProgress = startProgress + ((i + 1) * progressStep);
        loadingMessage = "Loading sticker " + (i + 1) + " / " + files.length;
      }
    } else {
      loadingProgress = endProgress;
    }
  }
  else {
    println("Folder not found: " + folderPath);
    loadingProgress = endProgress;
  }
}

// Draw Settings Screen.
void drawSettingsScreen() {
  fill(0, 180);
  noStroke();
  rect(0, 0, width, height);
  
  // Settings Window UI.
  float panelW = width*(600.0f/1280.0f);
  float panelH = height*(500.0f/720.0f);
  rectMode(CENTER); 
  fill(255);
  stroke(0); 
  rect(width/2, height/2, panelW, panelH, 15);
  rectMode(CORNER);
  
  // Close (X) Button.
  float closeBtnSize = 40;
  float closeBtnX = (width/2 + panelW/2) - closeBtnSize;
  float closeBtnY = (height/2 - panelH/2);
  pushStyle();
  textSize(24);
  textAlign(CENTER, CENTER);
  if (mouseHober(closeBtnX, closeBtnY, closeBtnSize, closeBtnSize)) { // Mouse Hobering
    fill(255, 0, 0);
  } else {
    fill(100);
  }
  text("X", closeBtnX + closeBtnSize/2, closeBtnY + closeBtnSize/2);
  popStyle();
  
  // Internal Content.
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Settings", width/2, height/2 - 200);

  // Slider Labels.
  textAlign(RIGHT, CENTER);
  textSize(20);
  text("BGM Volume", sdr.getX() - 10, sdr.getY() + sdr.getHeight()/2);
  text("SFX Volume", sfxSlider.getX() - 10, sfxSlider.getY() + sfxSlider.getHeight()/2);
  text("Drag Speed", dragSpeedSlider.getX() - 10, dragSpeedSlider.getY() + dragSpeedSlider.getHeight()/2);

  // Display Slider Values.
  textAlign(LEFT, CENTER);
  text(String.format("%d%%", round(sdr.getValueF() * 100)), sdr.getX() + sdr.getWidth() + 10, sdr.getY() + sdr.getHeight()/2);
  text(String.format("%d%%", round(sfxSlider.getValueF() * 100)), sfxSlider.getX() + sfxSlider.getWidth() + 10, sfxSlider.getY() + sfxSlider.getHeight()/2);
  text(String.format("%.1fx", dragSpeedSlider.getValueF()), dragSpeedSlider.getX() + dragSpeedSlider.getWidth() + 10, dragSpeedSlider.getY() + dragSpeedSlider.getHeight()/2);
  // Go to Main Button.
  settings_goToMainButton.render();
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == sdr) {
    bgmVolume = sdr.getValueF();
    song.amp(bgmVolume);    
  } else if (slider == dragSpeedSlider) {
    menuDragSpeed = dragSpeedSlider.getValueF();
  } else if (slider == sfxSlider) {
    sfxVolume = sfxSlider.getValueF();
  }
}

void drawLoadingScreen() { // Displayed Loading Progress Towards the Loading Progress.
    displayLoadingProgress = lerp(displayLoadingProgress, loadingProgress, 0.05);

    background(#FFCA1A);
    drawBackgroundEffect();
    
    // Calculate the Position of All UI Elements Based on the Loading Bar.
    float barW = width * 0.6;
    float barH = 30;
    float barX = width/2 - barW/2;
    float barY = height/2 + 80;

    float imgSize = 360;
    float loadingTextSize = 50;
    float messageTextSize = 22;

    float imgY = barY - (imgSize / 4);
    float loadingTextY = imgY - (imgSize / 6);
    float messageTextY = barY + barH + 2;

    // --- Start Drawing ---
    textAlign(CENTER, BOTTOM);
    fill(0);
    textFont(font);
    textSize(loadingTextSize);
    text("Loading...", width/2, loadingTextY);
    
    // Draw Loading Image.
    if (loadingImage != null) {
      imageMode(CENTER);
      float travelWidth = barW - imgSize;
      float imgX = barX + imgSize / 2 + travelWidth * displayLoadingProgress;
      image(loadingImage, imgX, imgY, imgSize, imgSize);
      imageMode(CORNER);
    }
    
    // Progress Bar.
    noStroke();
    fill(100, 80);
    rect(barX, barY, barW, barH, 15);
    fill(#4CAF50);
    if (displayLoadingProgress > 0) {
      rect(barX, barY, barW * displayLoadingProgress, barH, 15);
    }

    // Progress Message.
    fill(0);
    textAlign(CENTER, TOP);
    textSize(messageTextSize);
    text(loadingMessage, width/2, messageTextY);

    // Percentage Text.
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(floor(displayLoadingProgress * 100) + "%", width/2, barY + barH/2);
}

void draw() {
  // Play BackGroundMusic
    if (!bgmStarted && song != null) {
      song.loop();
      song.amp(bgmVolume);
      bgmStarted = true;
    }
    
    if (loadingStage < 3) {
      drawLoadingScreen();
      if (readyToTransition) {
        finishSetupOnMainThread();
        loadingStage = 3;
      } else if (loadingStage == 2) {
        if (displayLoadingProgress >= 0.99f) {
          displayLoadingProgress = 1.0f;
          readyToTransition = true;
        }
      }
      return;
    }
    // Default Mode Settings.
    imageMode(CORNER);
    rectMode(CORNER);
    ellipseMode(CENTER);
    textAlign(LEFT, BASELINE);
    // Call the Appropriate Function Based on the Current State.
    switch (currentScreen) {
      case start_screen:
        drawStartScreen();
        break;
      case menu_screen:
        drawMenuScreen();
        break;
      case making_sticker:
        drawCreator();
        break;
      case sticker_library:
          drawLibrary();
          break;
      case drawing_diary:
        drawDiary();
        break;
      case diary_library:
        drawDiaryLibrary();
        break;
      case name_screen:
        drawNameScreen();
        break;
      default :
      break;
      }
      if (isSettingsVisible) {
        drawSettingsScreen();
      }
  }


// Keyboard Input.
void keyPressed() {
  if (key == ESC) { // Toggle Settings Screen on ESC Key Press.
    playClickSound();
    toggleSettingsScreen(!isSettingsVisible);
    key = 0;
  }
}


// Mouse Click.
void mousePressed() {
  if (isSettingsVisible) {
    // If the Settings Screen is Visible, Only Process Functions Within it.]
    float panelW = width * (600.0f / 1280.0f);
    float panelH = height * (500.0f / 720.0f);
    float panelX = width / 2 - panelW / 2;
    float panelY = height / 2 - panelH / 2;

    float closeBtnSize = 40;
    float closeBtnX = (width / 2 + panelW / 2) - closeBtnSize;
    float closeBtnY = (height / 2 - panelH / 2);
    
    if (mouseHober(closeBtnX, closeBtnY, closeBtnSize, closeBtnSize) || !mouseHober(panelX, panelY, panelW, panelH)) {
        // Check for Click on Close Button or Outside the Panel.
        playClickSound();
        toggleSettingsScreen(false);
        return;
    }
    
    if (settings_goToMainButton.isMouseOverButton()) {
      // Handle 'Main' Button Click.
      playClickSound();
      toggleSettingsScreen(false);
      switchScreen(start_screen);  
    }
    return;
  }

  // Common Handling for Back Button Press Across All Screens.
  float btnX, btnY, btnW, btnH;
  if (currentScreen == drawing_diary) {
    btnX = DIARY_BACK_X;
    btnY = DIARY_BACK_Y;
    btnW = DIARY_BACK_W;
    btnH = DIARY_BACK_H;
  } else {
    btnX = BACK_X;
    btnY = BACK_Y;
    btnW = BACK_W;
    btnH = BACK_H;
  }
  if (currentScreen != start_screen && currentScreen != menu_screen && mouseHober(btnX, btnY, btnW, btnH)) {
    isBackButtonPressed = true;
    return;
  }

  switch (currentScreen) {
  case start_screen:
    //handleStartMouse();
    break;
  case menu_screen:
    handleMenuMousePressed();
    break;
  case drawing_diary:
    handleDiaryMouse();
    break;
  case sticker_library:
  handleLibraryMouse();
    break;
  case making_sticker:
    handleCreatorMouse();
    break;
  case diary_library:
    handleDiaryLibraryMousePressed();
    break;
  }
}
// Mouse Drag.
void mouseDragged() {

  if (isSettingsVisible) {
    return;
  }

  switch (currentScreen) {
    case start_screen:
      //handleStartDrag();
      break;
    case menu_screen:
      handleMenuDragged();
      break;
    case drawing_diary:
      handleDiaryDrag();
      break;
    case sticker_library:
      handleLibraryDrag();
      break;
    case making_sticker:
      handleCreatorDrag();
      break;
    case diary_library:
      handleDiaryLibraryDragged();
      break;
  }
}
// Mouse Release.
void mouseReleased() {
  if (isSettingsVisible) { // Ignore Other Events if Settings Screen is Open.
    return;
  }

  if (isBackButtonPressed) {
    // Common Handling for Back Button Release Across All Screens.
    float btnX, btnY, btnW, btnH;
    if (currentScreen == drawing_diary) {
      btnX = DIARY_BACK_X;
      btnY = DIARY_BACK_Y;
      btnW = DIARY_BACK_W;
      btnH = DIARY_BACK_H;
    } else {
      btnX = BACK_X;
      btnY = BACK_Y;
      btnW = BACK_W;
      btnH = BACK_H;
    }
    if (mouseHober(btnX, btnY, btnW, btnH)) { // When Mouse is Released Over the Back Button.
      playClickSound();

      if (currentScreen == making_sticker) {
        if (isStickerModified) {
          UiBooster booster = new UiBooster();
          boolean confirmed = booster.showConfirmDialog("Do you want to save your changes?", "Save Sticker");
          if (confirmed) {
            saveSticker();
          }
        }
        // Return to the Previous Screen Regardless of Saving.
        switchScreen(previousScreen);
      } else if (currentScreen == drawing_diary) {
    if (isDiaryModified) {
      UiBooster booster = new UiBooster();
      boolean confirmed = booster.showConfirmDialog("Do you want to save your diary?", "Save Diary");
      if (confirmed) {
        saveDiary();
        libraryCalendar.set(diary_year, diary_month - 1, 1);
        loadDiaryDates();
      }
    }
    // Return to the Previously Recorded Screen (Menu or Diary Library).
    switchScreen(diaryReturnScreen);
  } else if (currentScreen == diary_library) {
        // From the Diary Library, Go to the Menu Screen.
        switchScreen(menu_screen);
      } else if (currentScreen == sticker_library) {
        // From the Sticker Library, Go to the Menu Screen.
        switchScreen(menu_screen);
      } else {
        switchScreen(previousScreen); // Default Back Action.
      }
    }
    isBackButtonPressed = false; // Reset the flag
    return;
  }

  switch (currentScreen) {
  case start_screen:
    handleStartRelease();
    break;
  case menu_screen:
    handleMenuReleased();
    break;
  case drawing_diary:
    handleDiaryRelease();
    break;
  case sticker_library:
    handleLibraryMouseReleased();
    break;
  case making_sticker:
    handleCreatorRelease();
    break;
  case diary_library:
    handleDiaryLibraryMouseReleased();
    break;
  }
}


void mouseWheel(MouseEvent ev) {
  switch (currentScreen) {
    case drawing_diary:
      handleDrawingDiaryMouseWheel(ev);
      break;
    case sticker_library:
      handleLibraryMouseWheel(ev);
      break;
    case diary_library:
      handleDiaryLibraryMouseWheel(ev);
      break;
    case menu_screen:
      handleMenuMouseWheel(ev);
      break;
  }
}

void initializeSetting() { // Initialize User Settings.
  String filePath = "data/user_setting.json";  
  JSONObject settingData = loadJSONObject(filePath);
  if (settingData == null) {
    println("user_setting.json not found. Using default settings.");
    username = "";
    isNameEntered = false;
    bgmVolume = 0.5f;
    sfxVolume = 0.8f;
    menuDragSpeed = 1.0f;
    return;
  }

  // Name.
  username = settingData.getString("Name", "");
  isNameEntered = !username.isEmpty();

  // Volume and Drag Speed.
  bgmVolume = settingData.getFloat("bgmVolume", 0.5f);
  sfxVolume = settingData.getFloat("sfxVolume", 0.8f);
  menuDragSpeed = settingData.getFloat("dragSpeed", 1.0f);
}


void dispose() {  // Executes on Program Exit.
  // Save Settings.
    JSONObject settingData = new JSONObject();
    // Save Name, Volume, and Drag Speed.
    settingData.setString("Name", username);
    settingData.setFloat("bgmVolume", bgmVolume);
    settingData.setFloat("sfxVolume", sfxVolume);
    settingData.setFloat("dragSpeed", menuDragSpeed);
  
    saveJSONObject(settingData, "data/user_setting.json");
    println("Settings saved.");
}

void playClickSound() {
  if (clickSound != null) {
    clickSound.amp(sfxVolume);
    clickSound.play();
  }
}

// Toggle the Visibility of the Settings Screen.
void toggleSettingsScreen(boolean show) {
  isSettingsVisible = show;
  sdr.setVisible(show);
  sfxSlider.setVisible(show);
  dragSpeedSlider.setVisible(show);
  updateTextUIVisibility();
}

// Class for Background Effects.
class Bubble {
  PVector pos;
  float size;
  float speed;
  color c;

  Bubble() {
    // Set Y-coordinate to Start from the Bottom of the Screen.
    pos = new PVector(random(width), random(height, height + 200));
    size = random(20, 150);
    speed = random(0.5, 2.0);
    // Select a Random Color from the Palette.
    color baseColor = palleteColor[int(random(palleteColor.length))];
    c = color(red(baseColor), green(baseColor), blue(baseColor), random(50, 150));
  }

  void update() {
    pos.y -= speed; // Move Upwards.
    // If Completely off the Top of the Screen, Reset Position to Start from the Bottom Again.
    if (pos.y < -size) {
      pos.y = height + size;
      pos.x = random(width);
      size = random(20, 150);
      speed = random(0.5, 2.0);
    }
  }

  void display() {
    noStroke();
    fill(c);
    ellipse(pos.x, pos.y, size, size);
  }
}

void drawBackgroundEffect() {
  for (Bubble b : bubbles) {
    b.update();
    b.display();
  }
}