/*

// 시작버튼 있는 버전 start_screen

// 시작화면에 들어갈 캐릭터 변수 선언
PImage meow;

// 시작 버튼 위치, 크기, 그리고 시작버튼이 눌렸는지 알려주는 변수 선언
// 다른 pde 파일이나 함수에서도 쓸 일 있어서 전역으로 선언


float startButtonX, startButtonY, startButtonW, startButtonH;
boolean isStartButtonPressed = false;

public void drawStartScreen() {
    background(#FFCA1A);

    fill(#FFE880);
    noStroke();
    quad(0, 0, 0, 300, 1280, 400, 1280, 0);

    meow = loadImage("data/images/meow.png");

    drawMeow();
    drawTitle();
    drawStartButton();
}

public void drawMeow() {
    // 캐릭터 변수 미로드시 콘솔 메시지 출력
    if(meow == null) {
        println("meow is not loaded.");
        return;
    }

    // 캐릭터 이미지 위치 변수 선언
    float imageX = 50;
    float imageY = height - 250;

    // 캐릭터 사이즈 변수 선언
    float imageSizeX = 200;
    float imageSizeY = 200;

    image(meow, imageX, imageY, imageSizeX, imageSizeY);
}

public void drawTitle() {
    // 제목 텍스트 위치 변수 선언
    float titleX = width/2;
    float titleY = height/2 - 80;

    fill(0);
    textAlign(CENTER, CENTER);
    textFont(font);
    textSize(100);
    text("MyStickerDiary", titleX, titleY);
}

public void drawStartButton() {
    // 시작 버튼 위치 변수 초기화
    startButtonX = width/2;
    startButtonY = height/2 + 50;

    // 시작 버튼 크기 변수 초기화
    startButtonW = 200;
    startButtonH = 60;
    
    // 버튼이 눌렸을 때 : 버튼이 눌린듯한 이펙트 추가
    if(isStartButtonPressed) {
        fill(180, 100, 0);
        ellipse(startButtonX, startButtonY + 2, startButtonW, startButtonH);

        fill(235, 130, 30);
        stroke(200, 100, 0);
        strokeWeight(3);
        ellipse(startButtonX, startButtonY, startButtonW, startButtonH);

        fill(0);
        textAlign(CENTER, CENTER);
        textSize(40);
        text("start!", startButtonX, startButtonY - 2);
    }
    // 버튼이 마우스에서 떼어졌을 때 : 다시 원래 상태
    else {
        fill(200, 120, 0);
        ellipse(startButtonX, startButtonY + 5, startButtonW, startButtonH);

        fill(255, 150, 50);
        stroke(220, 120, 20);
        strokeWeight(3);
        ellipse(startButtonX, startButtonY, startButtonW, startButtonH);

        fill(0);
        textAlign(CENTER, CENTER);
        textSize(40);
        text("start!", startButtonX, startButtonY - 5);
    }
}

public boolean isStartButtonPressed(float mouseX, float mouseY) {
    float dist = dist(mouseX, mouseY, startButtonX, startButtonY);
    return dist <= startButtonW / 2;
}



// 시작 버튼 있는 버전 MyStickerDiary (메인 컨트롤 pde)

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
            // 임시 구현 (화면 잘 넘어가지는지 테스트용)
            background(100, 200, 100);
            fill(255);
            textAlign(CENTER, CENTER);
            textSize(48);
            text("Menu Screen", width/2, height/2);
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
            // 시작 화면에서 시작 버튼 눌렸는지 판단
            if(isStartButtonPressed(mouseX, mouseY)) {
                isStartButtonPressed = true;
            }
            break;
    }
}

void mouseReleased() {
    switch(currentScreen) {
            case start_screen :
            // 시작 화면에서 시작 버튼이 눌린 상태이고, 여전히 마우스 버튼을 땔 때 시작 버튼 위에 있는지 판단
            // 맞으면 (시작 버튼이 완전히 클릭되면) menu_screen으로 전환
                if(isStartButtonPressed && isStartButtonPressed(mouseX, mouseY)) {
                    currentScreen = menu_screen;
                }
            isStartButtonPressed = false;
            break;
    }
}

*/
