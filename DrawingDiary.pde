// DiaryLibrary.pde

void drawDiary() {
    background(255, 250, 220);
    
    // 스티커 보관함 버튼
    fill(200, 220, 255);
    rectMode(CENTER);
    rect(120, 60, 200, 60);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(25);
    text("스티커 보관함", 120, 60);
  // 일기장에 붙여진 스티커들을 모두 그리기
    float defaultStickerSize = 200.0; // 일기장에 표시될 스티커의 기본 최대 크기
    for (Sticker s : placedStickers) {
      // 비율에 맞는 크기를 계산
      float w = s.img.width;
      float h = s.img.height;
      float displayW, displayH;
  
      if (w > h) {
        displayW = defaultStickerSize;
        displayH = h * (defaultStickerSize / w);
      } else {
        displayH = defaultStickerSize;
        displayW = w * (defaultStickerSize / h);
      }
      imageMode(CENTER);
      image(s.img, s.x, s.y, displayW, displayH); // 스티커 그리기
    }
  }
  
  void handleDiaryMouse() { // 마우스를 처음 눌렀을 때 호출
    if (mouseX > 20 && mouseX < 220 && mouseY > 30 && mouseY < 90) {
      currentScreen = sticker_library;
      return; // 버튼을 눌렀으면 스티커 잡기 로직은 실행하지 않음
    }
    
   // 스티커 위에서 마우스를 눌렀는지 확인 
    float defaultStickerSize = 200.0; // 위 drawDiary와 동일한 크기 사용
    
    for (int i = placedStickers.size() - 1; i >= 0; i--) {
      Sticker s = placedStickers.get(i);
      // 표시되는 크기를 다시 계산
      float w = s.img.width;
      float h = s.img.height;
      float displayW, displayH;
  
      if (w > h) {
        displayW = defaultStickerSize;
        displayH = h * (defaultStickerSize / w);
      } else {
        displayH = defaultStickerSize;
        displayW = w * (defaultStickerSize / h);
      }
      
      // 계산된 크기를 기준으로 마우스 위치를 확인
      if (mouseHober(s.x-displayW/2, s.y-displayH/2, displayW, displayH)) {
        currentlyDraggedSticker = s;
        offsetX = mouseX - s.x;
        offsetY = mouseY - s.y;
        break;
      }
    }
  }
  
  void handleDiaryDrag() {  // 드래그하는 동안 호출
    // 현재 잡고 있는 스티커가 있다면
    if (currentlyDraggedSticker != null) {
      // 스티커의 위치를 마우스 위치로 업데이트
      currentlyDraggedSticker.x = mouseX - offsetX;
      currentlyDraggedSticker.y = mouseY - offsetY;
    }
  }
  
  // 마우스를 놓을 때 호출
  void handleDiaryRelease() {
    currentlyDraggedSticker = null; // 스티커 놓기
  }
  