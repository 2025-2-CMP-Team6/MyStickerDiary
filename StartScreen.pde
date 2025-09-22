// 시작화면에 들어갈 캐릭터 변수
PImage meow;

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
    // 시작 버튼 위치 변수 선언
    float buttonX = width/2;
    float buttonY = height/2 + 50;

    // 시작 버튼 크기 변수 선언
    float buttonW = 200;
    float buttonH = 60;
    
    // 버튼 입체감을 위한 그림자
    fill(200, 120, 0);
    ellipse(buttonX, buttonY + 5, buttonW, buttonH);
    
    // 메인 버튼
    fill(255, 150, 50);
    stroke(220, 120, 20);
    strokeWeight(3);
    ellipse(buttonX, buttonY, buttonW, buttonH);
    
    // 메인 버튼 안에 텍스트 적기
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("start!", buttonX, buttonY - 5);
}