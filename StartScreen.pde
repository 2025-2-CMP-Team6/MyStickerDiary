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
