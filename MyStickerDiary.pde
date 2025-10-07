import interfascia.*;
import uibooster.*;

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

boolean isMouseOverStartBtn = false; // 마우스가 버튼 위에 있는지 여부

PFont myFont; // 폰트

// 스티커 ArrayList
ArrayList<Sticker> stickerLibrary; // 보관함에 있는 모든 스티커
ArrayList<Sticker> placedStickers; // 일기장에 붙인 스티커

Sticker currentlyDraggedSticker = null; // 현재 드래그 중인 스티커
float offsetX, offsetY; // 스티커를 잡은 지점과 스티커 중심 사이의 간격

// 폰트 변수 선언
PFont font;

// 메뉴 버튼 오브젝트를 한번씩만 만들어줘야 하는 이슈가 발생해서 center control 파일에 선언합니다.
rectButton dsButton, slButton, ddButton, dlButton;
rectButton nameButton;

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

float worldMouseX() { return mouseX + menuScrollX; }
float worldMouseY() { return mouseY; } 

// 메뉴 버튼 초기화 함수입니다. 프레임마다 버튼 오브젝트가 변하지 않게 하기 위함입니다.
void initMenuButtons() {

  int x1 = PAGE_PADDING_X;
  int x2 = PAGE_PADDING_X + BTN_W + MENU_GUTTER_X;
  int x_name = NAME_X;
  int y  = MENU_TOP;
  int y_name = NAME_Y;

  dsButton = new rectButton(x1, y, BTN_W, BTN_H, #FEFD48);
  dsButton.rectButtonText("Drawing\nSticker", 50);

  slButton = new rectButton(x2, y, BTN_W, BTN_H, #FEFD48);
  slButton.rectButtonText("Sticker\nLibrary", 50);

  ddButton = new rectButton(x1 + PAGE_WIDTH, y, BTN_W, BTN_H, #FEFD48);
  ddButton.rectButtonText("drawing\nDiary", 50);

  dlButton = new rectButton(x2 + PAGE_WIDTH, y, BTN_W, BTN_H, #FEFD48);
  dlButton.rectButtonText("Diary\nLibrary", 50);

  nameButton = new rectButton(NAME_X, NAME_Y, NAME_W, NAME_H, #3FE87F);
  nameButton.rectButtonText("Name", 20);
  nameButton.setShadow(false);
}

void setup() {
    size(1280, 720);
    PImage happyStickerImg;
    PImage sadStickerImg;
    
        imageMode(CENTER);
      stickerLibrary = new ArrayList<Sticker>();
      placedStickers = new ArrayList<Sticker>();
      
      // data 폴더에서 이미지 불러오기
      happyStickerImg = loadImage("data/images/happy.png");
      sadStickerImg = loadImage("data/images/sad.png");

      // 불러온 이미지로 스티커 객체를 만들어 보관함에 추가
      stickerLibrary.add(new Sticker(0, 0, happyStickerImg));
      stickerLibrary.add(new Sticker(0, 0, sadStickerImg));
      setupCreator();

    // 실행 창 이름 지정
    surface.setTitle("MyStickerDiary");

    // 실행 창 사이즈 사용자가 임의 조정하지 못하게 설정
    surface.setResizable(false);

    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);

    // 버튼 창 호버링 시 나오는 아이콘 로드입니다.
    cursor = loadImage("data/images/name_edit.png");

    initMenuButtons();
}


void draw() {
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
  }

// 여기에서 모든 pde 파일 마우스 클릭 이벤트를 switch로 받아서 상황별로 처리해주면 될듯?
// 마우스 클릭
void mousePressed() {
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
    }
  }
  
// 마우스 드래그
void mouseDragged() {
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
        //handleLibraryDrag();
        break;
      case making_sticker:
        handleCreatorDrag();
        break;
    }
  }

// 마우스 놓을때
void mouseReleased() {
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
        //handleLibraryRelease();
        break;
        case making_sticker:
        handleCreatorRelease();
        break;
    }
  }