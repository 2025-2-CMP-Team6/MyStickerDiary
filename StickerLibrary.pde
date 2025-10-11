// Library.pde

void drawLibrary() {
  
    background(220, 240, 220);
    imageMode(CENTER);
    rectMode(CENTER);
    // UI그리기
    // 타이틀
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("스티커 보관함", width/2, 60);
    
    // 일기장으로
    fill(200);
    rectMode(CENTER); // rectMode는 한 번만 설정해도 됩니다.
    rect(width - 100, 50, 150, 50);
    fill(0);
    textSize(20);
    text("일기장으로", width - 100, 50);
  
    // '새 스티커 만들기' 버튼
    fill(220, 220, 150);
    rect(width/2, height - 80, 250, 60);
    fill(0);
    textSize(30);
    text("+ 새 스티커 만들기", width/2, height - 80);
  
    // 스티커 목록 그리기
  
    float boxSize = 150;   // 스티커가 들어갈 칸의 최대 크기
    int spacing = 180;  // 스티커 간격
    int startX = 200; // X좌표
    int startY = 200; // Y좌표
    int cols = 5; // 한 줄당 개수
  
    for (int i = 0; i < stickerLibrary.size(); i++) {
      Sticker s = stickerLibrary.get(i);
      int c = i % cols;
      int r = i / cols;
      
      s.x = startX + c * spacing;
      s.y = startY + r * spacing;
      
      // 원본 비율을 유지하는 새로운 너비와 높이
      float w = s.img.width;
      float h = s.img.height;
      float newW, newH;
      
      if (w > h) { // 이미지가 가로로 넓다면
        newW = boxSize;
        newH = h * (boxSize / w);
      } else { // 이미지가 세로로 길거나 정사각형이라면
        newH = boxSize;
        newW = w * (boxSize / h);
      }
  
      // 계산된 새 크기로 이미지 그리기
      image(s.img, s.x, s.y, newW, newH);
      
      // 마우스 영역 확인
      if (mouseHober(s.x-newW/2, s.y-newH/2, newW, newH)) {
        stroke(0);
        strokeWeight(3);
        noFill();
        rect(s.x, s.y, newW, newH);
        strokeWeight(1);
        fill(0);
      }
      
    }

    rectMode(CORNER); // rectMode를 다시 CORNER로 설정
  }
  
  void handleLibraryMouse() {
    // 일기장으로 버튼
    if (mouseX > width - 175 && mouseX < width - 25 && mouseY > 25 && mouseY < 75) {
      switchScreen(drawing_diary);
      return;
    }
    
    // 새 스티커 만들기 버튼
    if (mouseX > width/2 - 125 && mouseX < width/2 + 125 && 
        mouseY > height - 110 && mouseY < height - 50) {
      setupCreator(); 
      switchScreen(making_sticker);
      return;
    }
    
    // 스티커 클릭
    float boxSize = 150.0;
    for (Sticker s : stickerLibrary) {
      float w = s.img.width;
      float h = s.img.height;
      float newW, newH;
      
      if (w > h) {
        newW = boxSize;
        newH = h * (boxSize / w);
      }
      else {
        newH = boxSize;
        newW = w * (boxSize / h);
      }
  
      if (mouseHober(s.x-newW/2, s.y-newH/2, newW, newH)) {
        Sticker newSticker = new Sticker(width/2, height/2, s.img, defaultStickerSize, s.imageName);
        placedStickers.add(newSticker);
        switchScreen(drawing_diary);
        selectedSticker = newSticker;
        break; 
      }
    }
  } 
  