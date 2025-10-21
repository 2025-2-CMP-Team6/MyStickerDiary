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
int[] volume;


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

// 표정 아이콘
PImage[] emotIcon;
// 날씨 아이콘
PImage[] weatherIcon;
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

// 사운드
SoundFile song;
float currentVolume = 0.5; // 볼륨 설정 (0.0 ~ 1.0)


// 메뉴 버튼 오브젝트를 한번씩만 만들어줘야 하는 이슈가 발생해서 center control 파일에 선언합니다.
rectButton dsButton, slButton, ddButton, dlButton;
//rectButton nameButton;
GImageButton nameEditButton; // G4P 이미지 버튼 선언
//설정 화면 내 버튼
rectButton settings_goToMainButton; // 메인으로
GSlider sdr; // 슬라이더
// 다이어리 보관함 버튼
rectButton backToMenuButton;
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
  float pagePaddingX = width * (120.0f / 1280.0f);
  float menuGutterX = width * (80.0f / 1280.0f);
  float btnW = (width - pagePaddingX * 2 - menuGutterX) / 2;
  float btnH = height * (360.0f / 720.0f);
  float menuTop = height * (200.0f / 720.0f);

  int x1 = round(pagePaddingX);
  int x2 = round(pagePaddingX + btnW + menuGutterX);
  int y  = round(menuTop);

  dsButton = new rectButton(x1, y, round(btnW), round(btnH), #FEFD48);
  dsButton.rectButtonText("Drawing\nSticker", 50);

  slButton = new rectButton(x2, y, round(btnW), round(btnH), #FEFD48);
  slButton.rectButtonText("Sticker\nLibrary", 50);

  ddButton = new rectButton(x1 + width, y, round(btnW), round(btnH), #FEFD48);
  ddButton.rectButtonText("drawing\nDiary", 50);

  dlButton = new rectButton(x2 + width, y, round(btnW), round(btnH), #FEFD48);
  dlButton.rectButtonText("Diary\nLibrary", 50);

}

void ensureDiaryUI() {
  if(stickerStoreButton == null) {
    stickerStoreButton = new rectButton(round(width * (1100.0f/1280.0f)), round(textFieldY - height*(120.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #c8dcff);
    stickerStoreButton.rectButtonText("Sticker storage", 25);
    stickerStoreButton.setShadow(false);
  }

  if (finishButton == null) {
    finishButton = new rectButton(round(width * (1100.0f/1280.0f)), round(textFieldY - height*(60.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #F9E4B7);
    finishButton.rectButtonText("Finish", 20);
    finishButton.setShadow(false);
  }

  if (analyzeButton == null) {
    analyzeButton = new rectButton(round(width * (1100.0f/1280.0f)), round(textFieldY - height*(180.0f/720.0f)), round(width*(180.0f/1280.0f)), round(height*(60.0f/720.0f)), #B4F0C2);
    analyzeButton.rectButtonText("Analyze", 22);
    analyzeButton.setShadow(false);
  }
}

void setup() { // 앱 시작 시 최소한의 초기화만 수행
    size(1200, 840);
    pixelDensity(1);
  
    // 실행 창 이름 지정
    surface.setTitle("MyStickerDiary");
    // 실행 창 사이즈 사용자가 임의 조정하지 못하게 설정
    surface.setResizable(false);

    // 컬러 팔레트 초기화 (Bubble 생성보다 먼저)
    palleteColor = new color[]{color(0, 0, 0), color(255, 0, 0), color(255, 165, 0), color(255, 255, 0), color(0, 255, 0), color(0, 255, 255), color(0, 0, 255), color(255, 0, 255), color(139, 69, 19), color(128, 128, 128), color(211, 211, 211), color(255, 255, 255)};

    // 배경 이펙트 초기화
    bubbles = new ArrayList<Bubble>();
    for (int i = 0; i < 20; i++) { // 원 개수 줄임 (50 -> 20)
      bubbles.add(new Bubble());
    }

    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);
    
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
    
    loadingMessage = "Loading settings...";
    initializeSetting();
    loadingProgress = 0.1;

    loadingMessage = "Loading sounds...";
    thread("loadSong");
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
    loadingProgress = 0.40;

    loadingMessage = "Preparing sticker list...";
    loadStickersFromFolder("sticker", 0.40, 0.90); // 스티커 로딩에 50% 할당

    loadingMessage = "Initializing UI...";
    initMenuButtons();
    initDiaryLibrary();
    loadingProgress = 0.92;

    loadingMessage = "Fetching weather data...";
    todayWeather = getWeather();
    loadingProgress = 0.95;

    loadingMessage = "Finalizing...";
    settings_goToMainButton = new rectButton(width/2 - 100, height/2 + 100, 200, 50, color(100, 150, 255));
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
    sdr = new GSlider(this, round(width*(400.0f/1280.0f)), round(height*(250.0f/720.0f)), round(width*(200.0f/1280.0f)), round(height*(100.0f/720.0f)), 15);
    sdr.setVisible(false);
}

// G4P 컨트롤 이벤트를 처리하는 핸들러
void handleButtonEvents(GImageButton button, GEvent event) {
  if (button == nameEditButton && event == GEvent.CLICKED) { // nameEditButton clicked -> name_screen으로 전환
    switchScreen(name_screen);
  }
}

void loadSong() {
  song = new SoundFile(this, "cutebgm.mp3");

  if (song == null) {
    println("Sound file failed to load.");
    return;
  }

  song.loop();
  song.amp(currentVolume);
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
  rectMode(CENTER); 
  fill(255);
  stroke(0); 
  rect(width/2, height/2, width*(600.0f/1280.0f), height*(500.0f/720.0f), 15); 
  rectMode(CORNER);
  
  // 내부 내용
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("설정 (Settings)", width/2, height/2 - 200);

    // 메인으로 가기 버튼
  settings_goToMainButton.render(); 
  //아래에 계속해서 내부 내용 추가
    // 슬라이더 테스트
}

public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if (slider == sdr)  // The slider being configured?
    currentVolume = sdr.getValueF();
    println(sdr.getValueS()+ "    " +  currentVolume + "    " + event);    
    song.amp(currentVolume);    
}

void drawLoadingScreen() {
    // 목표 진행률(loadingProgress)을 향해 현재 표시되는 진행률(displayLoadingProgress)을 부드럽게 업데이트합니다.
    displayLoadingProgress = lerp(displayLoadingProgress, loadingProgress, 0.05);

    background(#FFCA1A);
    drawBackgroundEffect();
    
    textAlign(CENTER, CENTER);
    fill(0);
    textFont(font);
    textSize(50);
    text("Loading...", width/2, height/2 - 80);
    
    // 진행 메시지
    textSize(22);
    text(loadingMessage, width/2, height/2);

    // 진행률 바
    float barW = width * 0.6;
    float barH = 30;
    float barX = width/2 - barW/2;
    float barY = height/2 + 50;

    // 바 배경
    noStroke();
    fill(100, 80);
    rect(barX, barY, barW, barH, 15);

    // 채워지는 바
    fill(#4CAF50); // 초록색
    if (displayLoadingProgress > 0) {
      rect(barX, barY, barW * displayLoadingProgress, barH, 15);
    }

    // 퍼센트 텍스트
    fill(255);
    textSize(18);
    // 소수점 없이 정수로 표시
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
  if (key == ESC) { // ESC 키 -> 설정화면 
    isSettingsVisible = !isSettingsVisible;
    sdr.setVisible(isSettingsVisible);
    key = 0; // ESC 키가 프로그램 종료로 이어지지 않도록 방지

    if (isSettingsVisible) {
      // 설정 창이 켜졌을 때 둘 다 숨깁니다.
      if (titleArea != null) {
        titleArea.setVisible(false);
        titleArea.setAlpha(0);
      }
      if (textArea != null) {
        textArea.setVisible(false);
        textArea.setAlpha(0);
      }
    } else {
      // 설정 창이 꺼졌을 때 원래 상태로 되돌립니다.
      updateTextUIVisibility();
    }

  
  }
}



// 여기에서 모든 pde 파일 마우스 클릭 이벤트를 switch로 받아서 상황별로 처리해주면 될듯?
// 마우스 클릭
void mousePressed() {
  // 설정 화면이 보이는 상태에선 설정 화면 내의 기능만 처리하도록 함
  if (isSettingsVisible) {
    // 메인으로 가기 버튼 처리
    if (settings_goToMainButton.isMouseOverButton()) {
      isSettingsVisible = false; 
      sdr.setVisible(false);
      switchScreen(start_screen);  
    }
    return; // 뒤 버튼 눌리지 않도록
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
  }
}

void initializeSetting() {
  String filePath = "data/user_setting.json";  
  JSONObject settingData = loadJSONObject(filePath);
  if (settingData == null) {
    println("settingData file not found or is invalid: " + filePath);
    username = "";
    isNameEntered = false;
    volume = new int[]{100, 100, 100}; // 기본 볼륨 값 (예: 마스터, BGM, 효과음)
    return;
  }
  
  // 이름
  username = settingData.getString("Name", "");
  isNameEntered = !username.isEmpty();
  
  // 볼륨 데이터
  JSONArray volumeArray = settingData.getJSONArray("Volume");
  if (volumeArray != null) {
    volume = volumeArray.getIntArray();
  } else {
    volume = new int[]{100, 100, 100};
  }
}


void dispose() {  // 종료될때 실행 함수
  // 설정 저장
    JSONObject settingData = new JSONObject();
    // 이름
    settingData.setString("Name", username);
    // 볼륨 데이터
    JSONArray volumeArray = new JSONArray();
    for (int i = 0; i < volume.length; i++) {
      volumeArray.append(volume[i]);
    }
    settingData.setJSONArray("Volume", volumeArray);
  
    saveJSONObject(settingData, "data/user_setting.json");
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