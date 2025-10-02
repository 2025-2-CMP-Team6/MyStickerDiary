import interfascia.*;
import uibooster.*;

// 화면 통제 변수 선언
final int start_screen = 0;
final int menu_screen = 1;
final int making_sticker = 2;
final int sticker_library = 3;
final int drawing_diary = 4;
final int diary_library = 5;



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
        handleMenuMouse();
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
        //handleMenuDrag();
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
        handleMenuRelease();
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