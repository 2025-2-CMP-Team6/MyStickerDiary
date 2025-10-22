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

// 저장해야 할 변수
String username;


// 화면 통제 변수 선언
final int start_screen = 0;
final int menu_screen = 1;
final int making_sticker = 2;
final int sticker_library = 3;
final int drawing_diary = 4;
final int diary_library = 5;
final int name_screen = 6;

// 현재 보이는 화면 저장하는 변수 선언
// 초기화면은 시작화면 (StartScreen)
int currentScreen = start_screen;
int previousScreen = start_screen;

int loadingStage = 0; // 0: 시작 전, 1: 백그라운드 로딩 중, 2: 메인 스레드 로딩, 3: 완료
float loadingProgress = 0.0; // 로딩 진행률 (0.0 ~ 1.0)
float displayLoadingProgress = 0.0; // 화면에 표시될 부드러운 진행률
String loadingMessage = ""; // 현재 로딩 작업 메시지
boolean readyToTransition = false; // 로딩 완료 후 화면 전환 준비 플래그

boolean isSettingsVisible = false; // 설정 화면 표시 여부
boolean isMouseOverStartBtn = false; // 마우스가 버튼 위에 있는지 여부

ArrayList<Bubble> bubbles; // 배경 이펙트용 원

PFont myFont; // 폰트

// 스티커 ArrayList
ArrayList<Sticker> stickerLibrary; // 보관함에 있는 모든 스티커
ArrayList<Sticker> placedStickers; // 일기장에 붙인 스티커

Sticker currentlyDraggedSticker = null; // 현재 드래그 중인 스티커
Sticker stickerToEdit = null; // 편집할 스티커
float offsetX, offsetY; // 스티커를 잡은 지점과 스티커 중심 사이의 간격
float defaultStickerSize = 100.0; // 스티커의 기본 크기

// 폰트 변수 선언
PFont font;

// 시작화면 캐릭터
PImage meow;
PImage loadingImage;

// 표정 아이콘
PImage[] emotIcon;
// 날씨 아이콘
PImage[] weatherIcon;
PImage undoIcon; // Added for undo/redo buttons
PImage trashClosedIcon, trashOpenIcon; // 휴지통 아이콘

// 스티커 제작 도구 아이콘 및 커서 (MakingSticker.pde에서 이동)
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

// 컬러 팔레트 (MakingSticker.pde에서 이동)
color[] palleteColor;

// 텍스트UI 변수 선언
GTextField titleArea;  // 제목
GTextArea textArea; // 내용
float titlespace;
float textFieldY;
float navigationBarY;

// 달력 
Calendar calendar = Calendar.getInstance();

// 사운드 변수
SoundFile song;
float bgmVolume = 0.5; // 배경음 볼륨 (0.0 ~ 1.0)
float sfxVolume = 0.8; // 효과음 볼륨 (0.0 ~ 1.0)
SoundFile clickSound;


// 메뉴 버튼 오브젝트를 한번씩만 만들어줘야 하는 이슈가 발생해서 center control 파일에 선언합니다.
rectButton dsButton, slButton, ddButton, dlButton;
//rectButton nameButton;
GImageButton nameEditButton; // G4P 이미지 버튼 선언
//설정 화면 내 버튼
GSlider dragSpeedSlider; // 메뉴 드래그 속도 조절 슬라이더
rectButton settings_goToMainButton; // 메인으로
GSlider sdr; // BGM 슬라이더
GSlider sfxSlider; // 효과음 슬라이더
// 다이어리 보관함 버튼
rectButton prevMonthButton;
rectButton nextMonthButton;

rectButton diaryColorPicker;
rectButton diaryWeather;
rectButton diaryEmotion;

// 메뉴 스와이프 기능 관련 전역 변수입니다.
float menuScrollX = 0;              
float menuTargetScrollX = 0;        
boolean isMenuDragging = false;
float dragStartX = 0;
float dragStartScroll = 0;
float totalDragDist = 0;
float menuDragSpeed = 1.0; // 메뉴 드래그 속도 (1.0이 기본)

// 뒤로가기 버튼
float BACK_W, BACK_H;
float BACK_X, BACK_Y;
// 일기 쓰기 화면 전용 뒤로가기 버튼
float DIARY_BACK_W, DIARY_BACK_H;
float DIARY_BACK_X, DIARY_BACK_Y;

boolean isBackButtonPressed = false; // 뒤로가기 버튼 눌림 상태 추적

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

void switchScreen(int next) {
  int from = currentScreen;
  previousScreen = from;

  isMenuDragging = false;
  pressedOnNameBtn = false;
  totalDragDist = 0;

  if (from == making_sticker) {
    stickerToEdit = null; // 스티커 편집기에서 나갈 때 편집 상태 초기화
  }

  menuTargetScrollX = menuScrollX;

  isDrawingShape = false;
  isBrushSizeChange = false;
  cursor(ARROW);

  if (next == making_sticker) {
    clearUndoStack(); // 되돌리기 및 다시 실행 스택 초기화
    saveUndoState();  // 캔버스의 초기 상태(빈 화면 또는 편집할 스티커) 저장
  }

  currentScreen = next;

  updateTextUIVisibility();

  // 수정된 부분 : 화면이 전환될 때, 다음 화면이 메뉴 화면일 경우에만 nameEditButton을 보이도록 => 이거 어케 못하나
  if (nameEditButton != null) {
    nameEditButton.setVisible(next == menu_screen);
  }
  if (next == diary_library) {
    loadDiaryDates();
  }
}



float worldMouseX() { return mouseX + menuScrollX; }
float worldMouseY() { return mouseY; } 

// 메뉴 버튼 초기화 함수
void initMenuButtons() {
  // 버튼 사이의 간격(menuGutterX)을 일관되게 유지하고, 페이지 가장자리 여백(pagePaddingX)을 그 절반으로 설정합니다.
  // 이렇게 하면 페이지가 넘어갈 때의 버튼 간격과 페이지 내의 버튼 간격이 동일해집니다.
  float menuGutterX = width * (120.0f / 1280.0f); // 버튼 사이의 주된 간격
  float pagePaddingX = menuGutterX / 2.0f;       // 페이지 가장자리 여백

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

  // 메뉴 버튼에만 FANCY 스타일 적용
  dsButton.setStyle(rectButton.ButtonStyle.FANCY);
  slButton.setStyle(rectButton.ButtonStyle.FANCY);
  ddButton.setStyle(rectButton.ButtonStyle.FANCY);
  dlButton.setStyle(rectButton.ButtonStyle.FANCY);

  // 버튼에 이미지 할당
  dsButton.setImage(catImg);
  slButton.setImage(foxImg);
  ddButton.setImage(cloudImg);
  dlButton.setImage(owlImg);
}

void ensureDiaryUI() {
  if(stickerStoreButton == null) {
    stickerStoreButton = new rectButton(this, round(width * (1100.0f/1280.0f)), round(textFieldY - height*(120.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #c8dcff);
    stickerStoreButton.rectButtonText("Sticker storage", 25);
    stickerStoreButton.setShadow(false);
  }

  if (finishButton == null) {
    finishButton = new rectButton(this, round(width * (1100.0f/1280.0f)), round(textFieldY - height*(60.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #F9E4B7);
    finishButton.rectButtonText("Finish", 20);
    finishButton.setShadow(false);
  }

  if (analyzeButton == null) {
    analyzeButton = new rectButton(this, round(width * (1100.0f/1280.0f)), round(textFieldY - height*(180.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #B4F0C2);
    analyzeButton.rectButtonText("Analyze", 22);
    analyzeButton.setShadow(false);
  }

  if (diaryColorPicker == null) {
    diaryColorPicker = new rectButton(this, round(width * (1100.0f/1280.0f)), round(textFieldY - height*(240.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #D0E0F0);
    diaryColorPicker.rectButtonText("Change Color", 22);
    diaryColorPicker.setShadow(false);
  }
}

void setup() { // 앱 시작 시 최소한의 초기화만 수행
    size(1200, 800);
    pixelDensity(1);
  
    // 실행 창 이름 지정
    surface.setTitle("MyStickerDiary");
    // 실행 창 사이즈 사용자가 임의 조정하지 못하게 설정
    surface.setResizable(false);

    // 컬러 팔레트 초기화 (Bubble 생성보다 먼저)
    palleteColor = new color[]{
      color(0, 0, 0),        // 1. 검정 (맨 위)
      color(255, 0, 0),      // 2. 빨강
      color(255, 165, 0),    // 3. 주황
      color(255, 255, 0),    // 4. 노랑
      color(0, 255, 0),      // 5. 초록
      color(0, 0, 255),      // 6. 파랑
      color(0, 255, 255),    // 7. 하늘색
      color(255, 0, 255),    // 8. 자홍색
      color(128, 128, 128),  // 9. 회색
      color(211, 211, 211),  // 10. 밝은 회색
      color(255, 255, 255),  // 11. 하양 (맨 아래)
      color(255, 255, 255)   // 12. 컬러피커용 자리 (색상 무관)
    };

    // 배경 이펙트 초기화
    bubbles = new ArrayList<Bubble>();
    for (int i = 0; i < 20; i++) { // 원 개수 줄임 (50 -> 20)
      bubbles.add(new Bubble());
    }

    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);
    
    // 로딩 이미지를 가장 먼저 로드하여 즉시 표시될 수 있도록 합니다.
    loadingImage = loadImage("data/images/running_friends.png");

    loadingStage = 1;
    thread("performHeavySetup");
}

void performHeavySetup() { // 시간이 오래 걸리는 작업들을 백그라운드 스레드에서 처리
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

    // 일기 쓰기 화면 전용 뒤로가기 버튼 값 설정 (좌상단으로 8px 이동, 크기 48x48로 축소)
    DIARY_BACK_W = width * (48.0f / 1280.0f);
    DIARY_BACK_H = height * (48.0f / 720.0f);
    DIARY_BACK_X = width * (16.0f / 1280.0f);
    DIARY_BACK_Y = height * (8.0f / 720.0f);

    loadingMessage = "Loading settings...";
    initializeSetting();
    loadingProgress = 0.1;

    loadingMessage = "Loading sounds...";
    thread("loadSong");
    clickSound = new SoundFile(this, "data/sounds/click.mp3"); // 효과음 로드
    loadingProgress = 0.15;

    // 아이콘 이미지 로드
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
    undoIcon = loadImage("images/undo.png"); // Load undo icon
    trashClosedIcon = loadImage("images/trash_closed.png");
    trashOpenIcon = loadImage("images/trash_open.png");
    loadingProgress = 0.25;

    // 스티커 제작 도구 리소스 로딩
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
    loadingProgress = 0.35;

    loadingMessage = "Loading menu button images...";
    catImg = loadImage("images/cat.png");
    foxImg = loadImage("images/fox.png");
    cloudImg = loadImage("images/cloud.png");
    owlImg = loadImage("images/owl.png");
    loadingProgress = 0.40;

    loadingMessage = "Preparing sticker list...";
    loadStickersFromFolder("sticker", 0.40, 0.90);

    loadingMessage = "Initializing UI...";
    initMenuButtons();
    initDiaryLibrary();
    loadingProgress = 0.92;

    loadingMessage = "Fetching weather data...";
    todayWeather = getWeather();
    initWeatherEffects(); // 날씨 효과 초기화
    loadingProgress = 0.95;

    loadingMessage = "Finalizing...";
    settings_goToMainButton = new rectButton(this, width/2 - 100, height/2 + 150, 200, 50, color(100, 150, 255));
    settings_goToMainButton.rectButtonText("Main", 24);
    loadingProgress = 1.0;

    loadingStage = 2; // 백그라운드 로딩 완료
}

void finishSetupOnMainThread() { // 메인 스레드에서만 실행해야 하는 초기화 작업
    setupCreator();
    textAreaUI();

    // G4P 컨트롤(GImageButton, GSlider 등)은 메인 스레드에서 생성해야 합니다.
    String[] nameButtonImages = {
      "images/name_edit_off.png", "images/name_edit_over.png", "images/name_edit_down.png"
    };
    nameEditButton = new GImageButton(this, round(width - width*(80.0f/1280.0f)), round(height*(30.0f/720.0f)), nameButtonImages, "images/name_edit_masks.png");
    nameEditButton.setVisible(false);

    G4P.setCursor(CROSS);

    float sliderW = width * (200.0f / 1280.0f);
    float sliderX = width / 2 - sliderW / 2;

    // BGM 슬라이더
    sdr = new GSlider(this, round(sliderX), round(height*(250.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    sdr.setVisible(false);
    sdr.setValue(bgmVolume); // 파일에서 불러온 값으로 설정

    // 효과음 슬라이더
    sfxSlider = new GSlider(this, round(sliderX), round(height*(330.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    sfxSlider.setVisible(false);
    sfxSlider.setValue(sfxVolume); // 파일에서 불러온 값으로 설정

    // 드래그 속도 슬라이더
    dragSpeedSlider = new GSlider(this, round(sliderX), round(height*(410.0f/720.0f)), round(sliderW), round(height*(60.0f/720.0f)), 15);
    dragSpeedSlider.setLimits(1.0f, 0.5f, 2.0f); // 범위 설정 (초기값은 1.0)
    dragSpeedSlider.setValue(menuDragSpeed); // 파일에서 불러온 값으로 설정
    dragSpeedSlider.setNbrTicks(4); // 0.5, 1.0, 1.5, 2.0
    dragSpeedSlider.setStickToTicks(true);
    dragSpeedSlider.setVisible(false);

}

// G4P 컨트롤 이벤트를 처리하는 핸들러
void handleButtonEvents(GImageButton button, GEvent event) {
  if (button == nameEditButton && event == GEvent.CLICKED) { // nameEditButton clicked -> name_screen으로 전환
    switchScreen(name_screen);
  }
}

void loadSong() {
  song = new SoundFile(this, "sounds/cutebgm.mp3");

  if (song == null) {
    println("Sound file failed to load.");
    return;
  }

  song.loop();
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
      Arrays.sort(files); // 파일 이름순으로 정렬
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

// 설정 화면 그리기
void drawSettingsScreen() {
  // 뒷배경 흐리게
  fill(0, 180);
  noStroke();
  rect(0, 0, width, height);
  
  // 설정 창 UI
  float panelW = width*(600.0f/1280.0f);
  float panelH = height*(500.0f/720.0f);
  rectMode(CENTER); 
  fill(255);
  stroke(0); 
  rect(width/2, height/2, panelW, panelH, 15); 
  rectMode(CORNER);
  
  // 닫기(X) 버튼
  float closeBtnSize = 40;
  float closeBtnX = (width/2 + panelW/2) - closeBtnSize;
  float closeBtnY = (height/2 - panelH/2);
  pushStyle();
  textSize(24);
  textAlign(CENTER, CENTER);
  if (mouseHober(closeBtnX, closeBtnY, closeBtnSize, closeBtnSize)) {
    fill(255, 0, 0); // Hover color
  } else {
    fill(100);
  }
  text("X", closeBtnX + closeBtnSize/2, closeBtnY + closeBtnSize/2);
  popStyle();

  // 내부 내용
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Settings", width/2, height/2 - 200);

  // 슬라이더 레이블
  textAlign(RIGHT, CENTER);
  textSize(20);
  text("BGM Volume", sdr.getX() - 10, sdr.getY() + sdr.getHeight()/2);
  text("SFX Volume", sfxSlider.getX() - 10, sfxSlider.getY() + sfxSlider.getHeight()/2);
  text("Drag Speed", dragSpeedSlider.getX() - 10, dragSpeedSlider.getY() + dragSpeedSlider.getHeight()/2);

  // 슬라이더 값 표시
  textAlign(LEFT, CENTER);
  text(String.format("%d%%", round(sdr.getValueF() * 100)), sdr.getX() + sdr.getWidth() + 10, sdr.getY() + sdr.getHeight()/2);
  text(String.format("%d%%", round(sfxSlider.getValueF() * 100)), sfxSlider.getX() + sfxSlider.getWidth() + 10, sfxSlider.getY() + sfxSlider.getHeight()/2);
  text(String.format("%.1fx", dragSpeedSlider.getValueF()), dragSpeedSlider.getX() + dragSpeedSlider.getWidth() + 10, dragSpeedSlider.getY() + dragSpeedSlider.getHeight()/2);

    // 메인으로 가기 버튼
  settings_goToMainButton.render(); 
  //아래에 계속해서 내부 내용 추가
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

void drawLoadingScreen() {
    // 목표 진행률(loadingProgress)을 향해 현재 표시되는 진행률(displayLoadingProgress)을 부드럽게 업데이트합니다.
    displayLoadingProgress = lerp(displayLoadingProgress, loadingProgress, 0.05);

    background(#FFCA1A);
    drawBackgroundEffect();
    
    // --- 레이아웃 변수 정의 ---
    // 로딩 바를 기준으로 모든 UI 요소의 위치를 계산합니다.
    float barW = width * 0.6;
    float barH = 30;
    float barX = width/2 - barW/2;
    float barY = height/2 + 80; // 수직 레이아웃의 기준점

    float imgSize = 360;
    float loadingTextSize = 50;
    float messageTextSize = 22;

    // 각 요소의 Y 좌표를 barY를 기준으로 계산합니다.
    float imgY = barY - (imgSize / 4); // 이미지가 로딩 바 위에 바로 앉도록 조정합니다.
    float loadingTextY = imgY - (imgSize / 6);      // "Loading..." 텍스트를 이미지 바로 위에 붙입니다.
    float messageTextY = barY + barH + 2;       // 로딩 메시지를 로딩 바 바로 아래에 붙입니다.

    // --- 그리기 시작 ---
    // "Loading..." 텍스트
    textAlign(CENTER, BOTTOM); // 텍스트의 하단(baseline)을 기준으로 위치를 잡습니다.
    fill(0);
    textFont(font);
    textSize(loadingTextSize);
    text("Loading...", width/2, loadingTextY);

    // 로딩 이미지 그리기
    if (loadingImage != null) {
      imageMode(CENTER);
      float travelWidth = barW - imgSize;
      float imgX = barX + imgSize / 2 + travelWidth * displayLoadingProgress;
      image(loadingImage, imgX, imgY, imgSize, imgSize);
      imageMode(CORNER);
    }

    // 진행률 바
    noStroke();
    fill(100, 80); // 바 배경
    rect(barX, barY, barW, barH, 15);
    fill(#4CAF50); // 채워지는 바 (초록색)
    if (displayLoadingProgress > 0) {
      rect(barX, barY, barW * displayLoadingProgress, barH, 15);
    }

    // 진행 메시지
    fill(0);
    textAlign(CENTER, TOP); // 텍스트의 상단을 기준으로 위치를 잡습니다.
    textSize(messageTextSize);
    text(loadingMessage, width/2, messageTextY);

    // 퍼센트 텍스트
    fill(0);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(floor(displayLoadingProgress * 100) + "%", width/2, barY + barH/2);
}

void draw() {
    if (loadingStage < 3) {
      drawLoadingScreen();
      if (readyToTransition) {
        // 100%가 그려진 다음 프레임에 전환 실행
        finishSetupOnMainThread();
        loadingStage = 3; // 모든 로딩 완료
      } else if (loadingStage == 2) {
        // 백그라운드 로딩이 완료되었고, 이제 화면 표시가 100%에 도달하기를 기다립니다.
        if (displayLoadingProgress >= 0.99f) {
          displayLoadingProgress = 1.0f; // 100%로 강제 설정
          readyToTransition = true;      // 다음 프레임에 전환하도록 플래그 설정
        }
      }
      return;
    }
    // 디폴트 모드 세팅
    imageMode(CORNER);
    rectMode(CORNER);
    ellipseMode(CENTER);
    textAlign(LEFT, BASELINE);
    // 현재 상태(currentScreen)에 따라 적절한 함수를 호출
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


// 키보드 입력
void keyPressed() {
  if (key == ESC) { // ESC 키 -> 설정화면 토글
    playClickSound();
    toggleSettingsScreen(!isSettingsVisible);
    key = 0; // ESC 키가 프로그램 종료로 이어지지 않도록 방지
  }
}



// 여기에서 모든 pde 파일 마우스 클릭 이벤트를 switch로 받아서 상황별로 처리해주면 될듯?
// 마우스 클릭
void mousePressed() {
  // 설정 화면이 보이는 상태에선 설정 화면 내의 기능만 처리하도록 함
  if (isSettingsVisible) {
    // 패널 및 닫기 버튼 영역 정의
    float panelW = width * (600.0f / 1280.0f);
    float panelH = height * (500.0f / 720.0f);
    float panelX = width / 2 - panelW / 2;
    float panelY = height / 2 - panelH / 2;

    float closeBtnSize = 40;
    float closeBtnX = (width / 2 + panelW / 2) - closeBtnSize;
    float closeBtnY = (height / 2 - panelH / 2);

    // 닫기 버튼 클릭 또는 패널 외부 클릭 확인
    if (mouseHober(closeBtnX, closeBtnY, closeBtnSize, closeBtnSize) || !mouseHober(panelX, panelY, panelW, panelH)) {
        playClickSound();
        toggleSettingsScreen(false);
        return;
    }

    // 'Main' 버튼 클릭 처리
    if (settings_goToMainButton.isMouseOverButton()) {
      playClickSound();
      toggleSettingsScreen(false);
      switchScreen(start_screen);  
    }
    return; // 설정 창 내부의 다른 곳을 클릭했으면 다른 이벤트가 발생하지 않도록 함
  }

  // 모든 화면에서 뒤로가기 버튼 공통 처리 (누름 감지)
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
// 마우스 드래그
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
// 마우스 놓을때
void mouseReleased() {
  if (isSettingsVisible) {
    return;
  }

  // 모든 화면에서 뒤로가기 버튼 공통 처리 (놓음 감지)
  if (isBackButtonPressed) {
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
    if (mouseHober(btnX, btnY, btnW, btnH)) {
      playClickSound();

      if (currentScreen == making_sticker) {
        UiBooster booster = new UiBooster();
        boolean confirmed = booster.showConfirmDialog("Do you want to save your changes?", "Save Sticker");
        if (confirmed) {
          saveSticker();
        }
        // 저장 여부와 관계없이 이전 화면으로 돌아갑니다.
        switchScreen(previousScreen);
      } else if (currentScreen == drawing_diary) {
        UiBooster booster = new UiBooster();
        boolean confirmed = booster.showConfirmDialog("Do you want to save your diary?", "Save Diary");
        if (confirmed) {
          saveDiary();
          libraryCalendar.set(diary_year, diary_month - 1, 1);
          loadDiaryDates();
          switchScreen(diary_library);
        } else {
          switchScreen(previousScreen);
        }
      } else if (currentScreen == diary_library) {
        // 일기 보관함에서는 항상 메뉴 화면으로 이동
        switchScreen(menu_screen);
      } else if (currentScreen == sticker_library) {
        // 스티커 보관함에서도 항상 메뉴 화면으로 이동
        switchScreen(menu_screen);
      } else {
        switchScreen(previousScreen); // Default back button behavior
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
    case menu_screen: // Add this case for menu scrolling
      handleMenuMouseWheel(ev);
      break;
  }
}

void initializeSetting() {
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
  
  // 이름
  username = settingData.getString("Name", "");
  isNameEntered = !username.isEmpty();

  // 볼륨 및 드래그 속도
  bgmVolume = settingData.getFloat("bgmVolume", 0.5f);
  sfxVolume = settingData.getFloat("sfxVolume", 0.8f);
  menuDragSpeed = settingData.getFloat("dragSpeed", 1.0f);
}


void dispose() {  // 종료될때 실행 함수
  // 설정 저장
    JSONObject settingData = new JSONObject();
    // 이름, 볼륨, 드래그 속도 저장
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

/**
 * 설정 화면의 가시성을 토글하고 관련 UI 요소들의 상태를 업데이트합니다.
 * @param show 설정 화면을 표시할지 여부
 */
void toggleSettingsScreen(boolean show) {
  isSettingsVisible = show;
  sdr.setVisible(show);
  sfxSlider.setVisible(show);
  dragSpeedSlider.setVisible(show);

  // isSettingsVisible 상태가 변경되었으므로,
  // 다이어리 텍스트 필드의 가시성을 다시 계산하여 업데이트합니다.
  updateTextUIVisibility();
}

// 배경 이펙트용 클래스
class Bubble {
  PVector pos;
  float size;
  float speed;
  color c;

  Bubble() {
    // 화면 아래쪽에서 시작하도록 y 좌표를 설정
    pos = new PVector(random(width), random(height, height + 200));
    size = random(20, 150);
    speed = random(0.5, 2.0);
    // 팔레트에서 무작위 색상 선택
    color baseColor = palleteColor[int(random(palleteColor.length))];
    c = color(red(baseColor), green(baseColor), blue(baseColor), random(50, 150));
  }

  void update() {
    pos.y -= speed; // 위로 이동
    // 화면 위로 완전히 사라지면 아래에서 다시 시작
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