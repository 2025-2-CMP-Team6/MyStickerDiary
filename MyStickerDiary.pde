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

boolean isSettingsVisible = false; // 설정 화면 표시 여부
boolean isMouseOverStartBtn = false; // 마우스가 버튼 위에 있는지 여부

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

// 호버링 이펙트 아이콘 이미지 변수 선언
PImage cursorImage;

// 표정 아이콘
PImage happyIcon;

// 텍스트UI 변수 선언
GTextField titleArea;  // 제목
GTextArea textArea; // 내용
float titlespace = 48;

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
final int PAGE_WIDTH = 1280;        
float menuScrollX = 0;              
float menuTargetScrollX = 0;        
boolean isMenuDragging = false;
float dragStartX = 0;
float dragStartScroll = 0;
float totalDragDist = 0;

final int MENU_TOP = 200;        
final int PAGE_PADDING_X = 120;   
final int MENU_GUTTER_X = 80;     
final int NAME_X = 1100;
final int NAME_Y = 50;

final int BTN_W = (PAGE_WIDTH - PAGE_PADDING_X*2 - MENU_GUTTER_X) / 2;
final int BTN_H = 360;      

final int NAME_W = 100;
final int NAME_H = 50;

final int DATE_W = 50;
final int DATE_H = 30;

final int DATE_X = 140;
final int DATE_Y = 45;


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

  int x1 = PAGE_PADDING_X;
  int x2 = PAGE_PADDING_X + BTN_W + MENU_GUTTER_X;
  // int x_name = NAME_X;
  int y  = MENU_TOP;
  // int y_name = NAME_Y;

  dsButton = new rectButton(x1, y, BTN_W, BTN_H, #FEFD48);
  dsButton.rectButtonText("Drawing\nSticker", 50);

  slButton = new rectButton(x2, y, BTN_W, BTN_H, #FEFD48);
  slButton.rectButtonText("Sticker\nLibrary", 50);

  ddButton = new rectButton(x1 + PAGE_WIDTH, y, BTN_W, BTN_H, #FEFD48);
  ddButton.rectButtonText("drawing\nDiary", 50);

  dlButton = new rectButton(x2 + PAGE_WIDTH, y, BTN_W, BTN_H, #FEFD48);
  dlButton.rectButtonText("Diary\nLibrary", 50);

  /*nameButton = new rectButton(NAME_X, NAME_Y, NAME_W, NAME_H, #3FE87F);
  nameButton.rectButtonText("Name", 20);
  nameButton.setShadow(false);*/
}

void ensureDiaryUI() {
  if(stickerStoreButton == null) {
    stickerStoreButton = new rectButton(1100, textFieldY - 120, 180, 60, #c8dcff);
    stickerStoreButton.rectButtonText("Sticker storage", 25);
    stickerStoreButton.setShadow(false);
  }

  if (finishButton == null) {
    finishButton = new rectButton(1100, textFieldY - 60, 180, 60, #F9E4B7);
    finishButton.rectButtonText("Finish", 20);
    finishButton.setShadow(false);
  }

  if (analyzeButton == null) {
    analyzeButton = new rectButton(1100, textFieldY - 180, 180, 60, #B4F0C2);
    analyzeButton.rectButtonText("Analyze", 22);
    analyzeButton.setShadow(false);
  }
}

void setup() {
    size(1280, 720);
    pixelDensity(1);
    imageMode(CENTER);
    stickerLibrary = new ArrayList<Sticker>();
    placedStickers = new ArrayList<Sticker>();
    initializeSetting();
    setupCreator();
    textAreaUI();
    thread("loadSong");
  
    // 실행 창 이름 지정
    surface.setTitle("MyStickerDiary");

    // 실행 창 사이즈 사용자가 임의 조정하지 못하게 설정
    surface.setResizable(false);

    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);

    // 버튼 창 호버링 시 나오는 아이콘 로드입니다.
    cursorImage = loadImage("data/images/name_edit.png");

    // 표정 아이콘 로드
    happyIcon = loadImage("images/icon_face_happy.png");

    initMenuButtons();

    initDiaryLibrary();
    loadStickersFromFolder("sticker");

    // GImageButton 초기화 수정된 부분
    String[] nameButtonImages = {
      "images/name_edit_off.png", "images/name_edit_over.png", "images/name_edit_down.png"
    };
    // 우측 상단에 버튼 위치
    nameEditButton = new GImageButton(this, width - 80, 30, nameButtonImages, "images/name_edit_masks.png");
    nameEditButton.setVisible(false); // 프로그램 시작 시 버튼을 보이지 않게 설정

    //설정
    // 설정 창의 '메인으로 가기' 버튼 초기화
    settings_goToMainButton = new rectButton(width/2 - 100, height/2 + 100, 200, 50, color(100, 150, 255));
    settings_goToMainButton.rectButtonText("Main", 24);

    // 슬라이더 초기화
    G4P.setCursor(CROSS);
    sdr = new GSlider(this, 400, 250, 200, 100, 15);
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

void loadStickersFromFolder(String folderPath) {
  File folder = new File(dataPath(folderPath));
  if (folder.exists() && folder.isDirectory()) {
    File[] files = folder.listFiles();
    if (files != null) {
      Arrays.sort(files); // 파일 이름순으로 정렬
      for (File file : files) {
        if (file.isFile()) {
          String fileName = file.getName().toLowerCase();
          // .DS_Store 같은 시스템 파일을 제외하고 이미지 파일만 로드하도록 수정
          if (fileName.endsWith(".png") || fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") || fileName.endsWith(".gif")) {
            String filePath = file.getAbsolutePath();
            PImage img = loadImage(filePath);
            stickerLibrary.add(new Sticker(0, 0, img, defaultStickerSize, file.getName()));
            println("file load success :"+filePath);
          }
        }
      }
    }
    else {
      println("file load fail");
    }
  }
  else {
        println("Folder not found: " + folderPath);
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
  rect(width/2, height/2, 600, 500, 15); 
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

void draw() {
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