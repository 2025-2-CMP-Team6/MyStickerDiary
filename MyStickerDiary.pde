import processing.pdf.*;
import grab.*;
Grab grab = new Grab(this);


// 화면 통제 변수 선언
final int start_screen = 0;
final int menu_screen = 1;
final int name_screen = 2;
final int making_sticker = 3;
final int sticker_library = 4;
final int drawing_diary = 5;
final int diary_library = 6;



// 현재 보이는 화면 저장하는 변수 선언
// 초기화면은 시작화면 (StartScreen)
int currentScreen = start_screen;

// 폰트 변수 선언
PFont font;

void setup() {
    size(1280, 720);

    // 실행 창 이름 지정
    surface.setTitle("MyStickerDiary");

    // 실행 창 사이즈 사용자가 임의 조정하지 못하게 설정
    surface.setResizable(false);

    font = createFont("data/fonts/nanumHandWriting_babyLove.ttf", 24);
}

void draw() {
    switch (currentScreen) {
        case start_screen : 
            drawStartScreen();
            break;

        case menu_screen :
            drawMenuScreen();
            break;

        case name_screen : 
            break;

        case making_sticker :
            break;

        case sticker_library : 
            break;

        case drawing_diary :
            break;

        case diary_library :
            break; 
    }
}

// 마우스 눌렸을 때 이벤트 처리
// 여기에서 모든 pde 파일 마우스 클릭 이벤트를 switch로 받아서 상황별로 처리해주면 될듯?
void mousePressed() {
    switch(currentScreen) {
        case start_screen :
            break;
    }
}

void mouseReleased() {
    switch(currentScreen) {
            case start_screen :
            currentScreen = menu_screen;
            break;
    }
}