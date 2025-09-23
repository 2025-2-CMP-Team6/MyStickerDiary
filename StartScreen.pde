// 시작화면에 들어갈 캐릭터 변수 선언
PImage meow;

// 마우스가 눌렸는지 확인해줄 변수 선언
boolean isStartButtonPressed = false;

public void drawStartScreen() {
    background(#FFCA1A);

    fill(#FFE880);
    noStroke();
    quad(0, 0, 0, 300, 1280, 400, 1280, 0);

    meow = loadImage("data/images/meow.png");

    drawMeow();
    drawTitle();
    drawClickAnywhere();
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

public void drawClickAnywhere() {
    // 깜빡이는 효과를 위한 투명도 변수 선언
    float alpha = 150 + 105 * sin(frameCount * 0.1);
    
    // 메시지 위치 변수 선언
    float messageX = width/2;
    float messageY = height/2 + 100;
    
    // 텍스트 그림자 효과
    fill(0, alpha * 0.3);
    textAlign(CENTER, CENTER);
    textSize(26);
    text("Click Anywhere to Start!", messageX + 2, messageY + 2);
    
    // 메인 텍스트 (깜빡이는 효과)
    fill(80, 80, 80, alpha);
    textAlign(CENTER, CENTER);
    textSize(26);
    text("Click Anywhere to Start!", messageX, messageY);
}

public void handleStartRelease() {
    currentScreen = menu_screen;
}