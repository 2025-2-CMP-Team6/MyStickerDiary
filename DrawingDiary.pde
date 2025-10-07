// DiaryLibrary.pde


int textFieldY = 480;
float defaultStickerSize = 100.0;
Sticker selectedSticker;
int handleSize = 16; // 조절점 크기
// -1: 조절중x, 0: 왼쪽 위, 1: 오른쪽 위, 2: 왼쪽 아래, 3: 오른쪽 아래
int isResizing = -1; // 크기 조절 중인지 확인 

void drawDiary() {
    background(255, 250, 220);
    fill(200, 220, 255);
    rectMode(CENTER);
    rect(120, 60, 200, 60);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(25);
    text("스티커 보관함", 120, 60);
  // 일기장에 붙여진 스티커들을 모두 그리기 // 일기장에 표시될 스티커의 기본 최대 크기
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
    if (selectedSticker != null) {
      // 비율에 맞는 크기를 다시 계산
      Sticker s = selectedSticker;
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
    fill(255);
    stroke(0);
    strokeWeight(1);
    rect(s.x-2-displayW/2,s.y-displayH/2-2,handleSize,handleSize);
    rect(s.x-2-displayW/2,s.y+displayH/2+2,handleSize,handleSize);
    rect(s.x+displayW/2+2,s.y-displayH/2-2,handleSize,handleSize);
    rect(s.x+displayW/2+2,s.y+displayH/2+2,handleSize,handleSize);
  }
}
  
  void handleDiaryMouse() { // 마우스를 처음 눌렀을 때 호출
    if (mouseX > 20 && mouseX < 220 && mouseY > 30 && mouseY < 90) {
      selectedSticker = null;
      currentScreen = sticker_library;
      return; // 버튼을 눌렀으면 스티커 잡기 로직은 실행하지 않음
    }
   // 스티커 위에서 마우스를 눌렀는지 확인
    selectedSticker = null;
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
      if (mouseHober(s.x-displayW/2-8, s.y-displayH/2-8, displayW+16, displayH+16)) {
        currentlyDraggedSticker = s;
        offsetX = mouseX - s.x;
        offsetY = mouseY - s.y;
        selectedSticker = currentlyDraggedSticker;
         // 크기 조절 핸들 위에서 클릭했는지 확인
        float handleX1 = s.x - displayW/2 - handleSize/2;
        float handleY1 = s.y - displayH/2 - handleSize/2;
        float handleX2 = s.x - displayW/2 - handleSize/2;
        float handleY2 = s.y + displayH/2 - handleSize/2;
        float handleX3 = s.x + displayW/2 - handleSize/2;
        float handleY3 = s.y - displayH/2 - handleSize/2;
        float handleX4 = s.x + displayW/2 - handleSize/2;
        float handleY4 = s.y + displayH/2 - handleSize/2;

        if (mouseHober(handleX1, handleY1, handleSize, handleSize)) {
          isResizing = 0;
        }
        else if (mouseHober(handleX2, handleY2, handleSize, handleSize)) {
          isResizing = 1;
        }
        else if (mouseHober(handleX3, handleY3, handleSize, handleSize)) {
          isResizing = 2;
        }
        else if (mouseHober(handleX4, handleY4, handleSize, handleSize)) {
          isResizing = 3;
        }
        else {
            println("handle not clicked");
           // 크기 조절 핸들을 클릭하지 않았을 경우, 스티커 드래그 시작
           isResizing = -1;
           currentlyDraggedSticker = s;
           offsetX = mouseX - s.x;
           offsetY = mouseY - s.y;
          }
        break;
      }
    }
    println(selectedSticker);
  }
  
  void handleDiaryDrag() {  // 드래그하는 동안 호출
    // 현재 잡고 있는 스티커가 있다면
    if (currentlyDraggedSticker != null) {
      // 비율에 맞는 크기를 다시 계산
      Sticker s = currentlyDraggedSticker;
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
      // 스티커의 위치를 마우스 위치로 업데이트
      currentlyDraggedSticker.x = median(0, mouseX - offsetX, width);
      currentlyDraggedSticker.y = median(0, mouseY - offsetY, textFieldY - displayH/2);
    }
  }
  
  // 마우스를 놓을 때 호출
  void handleDiaryRelease() {
    currentlyDraggedSticker = null; // 스티커 놓기
    if(isResizing != -1){
      isResizing = -1;
    }
    else {
     currentlyDraggedSticker = null; // 스티커 놓기
    }
  }
