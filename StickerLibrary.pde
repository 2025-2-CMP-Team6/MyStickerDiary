// Library.pde

float libraryScrollY = 0;
float minLibraryScrollY = 0;

// 스크롤바 관련 변수
boolean isDraggingLibScrollbar = false;
float libScrollbarDragStartY;
float libScrollbarDragStartScrollY;
float libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH;
float libThumbY, libThumbH;

void drawLibrary() {
  
    background(220, 240, 220);
    imageMode(CENTER);
    rectMode(CENTER);
    // UI그리기
    // 타이틀
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("Sticker Library", width/2, 60);
    
    // 일기장으로
    if (mouseHober(width - 175, 25, 150, 50)) {
      fill(220);
    } else {
      fill(200);
    }
    rect(width - 100, 50, 150, 50);
    fill(0);
    textSize(20);
    text("Back to diary", width - 100, 50);
  
    // '새 스티커 만들기' 버튼
    if (mouseHober(width/2 - 125, height - 110, 250, 60)) {
      fill(230, 230, 160);
    } else {
      fill(220, 220, 150);
    }
    rect(width/2, height - 80, 250, 60);
    fill(0);
    textSize(30);
    text("+ Making new Sticker!", width/2, height - 80);
  
    // 스티커 목록 그리기

    pushStyle();
    rectMode(CORNER);
    float boxSize = 150;   // 스티커가 들어갈 칸의 최대 크기
    int spacing = 180;  // 스티커 간격
    int startX = 200; // X좌표
    int startY = 200; // Y좌표
    int cols = 6; // 한 줄당 개수
    // 스크롤 범위
    if (stickerLibrary.size() > 0) {
      int numRows = (stickerLibrary.size() - 1) / cols + 1;
      float contentHeight = (numRows - 1) * spacing + boxSize;
      float viewHeight = height - (startY);
      minLibraryScrollY = max(0, contentHeight - viewHeight);
    } else {
      minOverlayScrollY = 0;
    }
    //clip(startX - boxSize/2, startY - boxSize/2 - 16, width + boxSize/2 - 40, height - boxSize/2 - 32);
    rectMode(CORNER);
    clip(0, startY + spacing - 32, width*2, height - boxSize - 48);
  
    for (int i = 0; i < stickerLibrary.size(); i++) {
      Sticker s = stickerLibrary.get(i);
      int c = i % cols;
      int r = i / cols;
      
      s.x = startX + c * spacing;
      s.y = startY + r * spacing - libraryScrollY;
      
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
        rectMode(CORNER);
        stroke(0);
        strokeWeight(3);
        noFill();
        rect(s.x-newW/2, s.y-newH/2, newW, newH);
        strokeWeight(1);
        fill(0);
      }
      
    }
    noClip();
    // 스크롤바 그리기
    if (minLibraryScrollY > 0) {
      libScrollbarW = 12;
      float scrollbarMargin = 20;
      libScrollbarX = width - scrollbarMargin - libScrollbarW;
      libScrollbarY = 80;
      libScrollbarH = height - 120;
  
      // 스크롤바 트랙
      fill(200, 180);
      noStroke();
      rect(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH, 6);
  
      // 스크롤바 섬
      float viewHeight = height;
      int numRows = (stickerLibrary.size() - 1) / cols + 1;
      float contentHeight = (numRows - 1) * spacing + boxSize;
      thumbH = libScrollbarH * (viewHeight / contentHeight);
      thumbH = max(thumbH, 25); // 최소 높이
      float scrollableDist = libScrollbarH - thumbH;
      float scrollRatio = libraryScrollY / minLibraryScrollY;
      thumbY = libScrollbarY + scrollableDist * scrollRatio;
      // 마우스가 섬 위에 있거나 드래그 중이면 색상 변경
      if (isDraggingLibScrollbar || mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
        fill(120);
      } else {
        fill(170);
      }
      rect(libScrollbarX, thumbY, libScrollbarW, thumbH, 6);
    }
    popStyle();
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
        // 스티커를 클릭하면 편집 화면으로 이동
        stickerToEdit = s;
        stickerCanvas.beginDraw();
        stickerCanvas.clear();
        stickerCanvas.image(stickerToEdit.img, 0, 0, canvasSize, canvasSize);
        stickerCanvas.endDraw();
        switchScreen(making_sticker);
        break; 
      }
    }
    // 스크롤바 드래그 확인
    if (minLibraryScrollY > 0 && mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      isDraggingLibScrollbar = true;
      libScrollbarDragStartY = mouseY;
      libScrollbarDragStartScrollY = libraryScrollY;
    }
  } 
  void handleLibraryDrag() {
    // 스크롤바 드래그 처리
    if (isDraggingLibScrollbar) {
      float dy = mouseY - libScrollbarDragStartY;
      float libScrollablePixelRange = libScrollbarH - thumbH;
      if (libScrollablePixelRange > 0) {
        float libScrollRatio = dy / libScrollablePixelRange;
        float libScrollDelta = libScrollRatio * minLibraryScrollY;
        libraryScrollY = constrain(libScrollbarDragStartScrollY + libScrollDelta, 0, minLibraryScrollY);
      }
    }
  }

  void handleLibraryMouseReleased() {
    if (isDraggingLibScrollbar) {
      isDraggingLibScrollbar = false;
      return;
    }
    // 스크롤바 트랙 클릭
    if ((minLibraryScrollY > 0) && mouseHober(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH) && !mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      // 스크롤 이동
      float clickRatio = (mouseY - libScrollbarY - thumbH / 2) / (libScrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      libraryScrollY = clickRatio * minLibraryScrollY;
    }
}

void handleLibraryMouseWheel(MouseEvent ev) {
  if (mouseHober(130, 164, width - 270, height - 280)) {
    float scrollAmount = ev.getCount() * 10; // 스크롤 속도
    libraryScrollY = constrain(libraryScrollY - scrollAmount, 0, minLibraryScrollY);
  }
}