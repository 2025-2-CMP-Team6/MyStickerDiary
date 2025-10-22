// 시작화면에 들어갈 캐릭터 변수 선언
// 마우스가 눌렸는지 확인해줄 변수 선언
boolean isStartButtonPressed = false;

public void drawStartScreen() {
    background(#FFCA1A);
    drawBackgroundEffect();
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

    // 이미지를 화면 전체에 채우면서 비율을 유지하도록 크기를 계산합니다.
    // 이미지가 화면보다 넓으면 높이를 맞추고, 화면보다 높으면 너비를 맞춥니다.
    imageMode(CENTER);
    float imgRatio = (float)meow.width / (float)meow.height;
    float screenRatio = (float)width / (float)height;
    
    float newW, newH;
    if (imgRatio > screenRatio) {
      // 이미지가 화면보다 넓은 경우 (좌우가 잘릴 수 있음)
      newH = height;
      newW = newH * imgRatio;
    } else {
      // 이미지가 화면보다 높은 경우 (상하가 잘릴 수 있음)
      newW = width;
      newH = newW / imgRatio;
    }

    // 계산된 크기로 이미지를 화면 중앙에 그립니다.
    image(meow, width/2, height/2, newW, newH);
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
    switchScreen(menu_screen);
    if(ddButton == null) initMenuButtons();
}