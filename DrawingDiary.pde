// DrawingDiary.pde

int textFieldY = 480;
Sticker selectedSticker;
int handleSize = 16; // 조절점 크기
// -1: 조절중x, 0: 왼쪽 위, 1: 왼쪽 아래, 2: 오른쪽 위, 3: 오른쪽 아래
int isResizing = -1; // 크기 조절 중인지 확인
PVector resizeAnchor = new PVector(); // 크기 조절 시 고정점

rectButton stickerStoreButton;
rectButton finishButton;
boolean storagePressed = false;
boolean finishPressed = false;


void drawDiary() {

  pushStyle();
  background(255, 250, 220);
  rectMode(TOP);
  fill(125,125,125);
  rect(0, textFieldY, width, height);
  // 기존 "스티커보관함" 버튼 프레스 & 릴리스 최적화를 위해
  // rectButton으로 다시 만들었습니다! 양해 부탁드립니다.
  /*fill(200, 220, 255);
  rect(20, 30, 200, 60);
  rectMode(CENTER);
  rect(120, 60, 200, 60);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("스티커 보관함", 120, 60);*/
  
  // 일기장에 붙여진 스티커들을 모두 그리기
  for (Sticker s : placedStickers) {
    s.display();
  }
  // 선택된 스티커가 있으면 조절 핸들을 그린다
  if (selectedSticker != null) {
    pushStyle();
    fill(255);
    stroke(0);
    strokeWeight(1);
    rectMode(CORNER);
    for (int i = 0; i < 4; i++) {
      float[] handle = selectedSticker.getHandleRect(i, handleSize);
      rect(handle[0], handle[1], handle[2], handle[3]);
    }
    popStyle();
  }
  popStyle();

  ensureDiaryUI();
  finishButton.render();
  stickerStoreButton.render();

}
  
void handleDiaryMouse() { // 마우스를 처음 눌렀을 때 호출


  storagePressed = mouseHober(stickerStoreButton.position_x, stickerStoreButton.position_y,
                              stickerStoreButton.width, stickerStoreButton.height);

  // 스티커 위에서 마우스를 눌렀는지 확인
  isResizing = -1; // 리사이징 상태 초기화
  selectedSticker = null;
  currentlyDraggedSticker = null;

  for (int i = placedStickers.size() - 1; i >= 0; i--) {
    Sticker s = placedStickers.get(i);
    PVector displaySize = s.getDisplaySize();
    
    // 먼저 조절 핸들을 클릭했는지 확인 (핸들이 스티커보다 위에 그려지므로)
    for (int j = 0; j < 4; j++) {
      float[] handle = s.getHandleRect(j, handleSize);
      if (mouseHober(handle[0], handle[1], handle[2], handle[3])) {
        isResizing = j;
        selectedSticker = s;
        currentlyDraggedSticker = s; // 리사이징 중에도 드래그 대상으로 설정
        // 크기 조절을 시작할 때 반대 모서리를 고정점으로
        if (j == 0) { 
          resizeAnchor.set(s.x + displaySize.x/2, s.y + displaySize.y/2);
        } else if (j == 1) {
          resizeAnchor.set(s.x + displaySize.x/2, s.y - displaySize.y/2);
        } else if (j == 2) {
          resizeAnchor.set(s.x - displaySize.x/2, s.y + displaySize.y/2);
        } else if (j == 3) {
          resizeAnchor.set(s.x - displaySize.x/2, s.y - displaySize.y/2);
        }
        break;
      }
    }
    if (selectedSticker != null) { // 핸들을 찾았으면
      break;
    }
    // 스티커 본체를 클릭했는지 확인
    if (mouseHober(s.x - displaySize.x/2, s.y - displaySize.y/2, displaySize.x, displaySize.y)) {
      selectedSticker = s;
      currentlyDraggedSticker = s;
      offsetX = mouseX - s.x;
      offsetY = mouseY - s.y;
      isResizing = -1;
      break;
    }
  }
  
  finishPressed = mouseHober(
    finishButton.position_x, finishButton.position_y,
    finishButton.width, finishButton.height
  );
  
}
  
void handleDiaryDrag() {  // 드래그하는 동안 호출
  if (currentlyDraggedSticker == null) {
    return;
  }
  Sticker s = currentlyDraggedSticker;
  if (isResizing == -1) { // 크기 핸들이 아니면 스티커 이동
    PVector displaySize = s.getDisplaySize();
    // 스티커의 위치를 마우스 위치로 업데이트
    s.x = median(0, mouseX - offsetX, width);
    s.y = median(0, mouseY - offsetY, textFieldY - displaySize.y/2);
  } else {  // 크기 조절
  PVector anchor = resizeAnchor;
  // 마우스와 고정점 사이의 거리를 기반으로 새 크기 계산
  float newDisplayW = abs(mouseX - anchor.x);
  float newDisplayH = abs(min(mouseY, textFieldY) - anchor.y);

  // 이미지와 바운딩 박스의 가로세로 비율 계산
  float imgRatio = (float)s.img.width / (float)s.img.height;
  float boxRatio = (newDisplayH == 0) ? 10000 : newDisplayW / newDisplayH; // 0으로 나누는 경우를 방지합니다.

  // 바운딩 박스에 딱 맞도록, 이미지 비율을 유지하면서 크기를 다시 계산합니다.
  // 이 로직은 스티커의 가로/세로 방향에 관계없이 일관되게 작동합니다.
  if (boxRatio > imgRatio) { // 박스가 이미지보다 넓으면, 높이에 맞춥니다.
    s.size = (s.img.height >= s.img.width) ? newDisplayH : newDisplayH * imgRatio;
  } else { // 박스가 이미지보다 좁거나 같으면, 너비에 맞춥니다.
    s.size = (s.img.width >= s.img.height) ? newDisplayW : newDisplayW / imgRatio;
  }

  // 최소 크기 제한
  s.size = max(s.size, 20);
  // 비율이 적용된 새로운 표시 크기를 가져옵니다.
  PVector newCalculatedDisplaySize = s.getDisplaySize();

  float newCornerX = 0, newCornerY = 0;
  if (isResizing == 0) {
    newCornerX = anchor.x - newCalculatedDisplaySize.x; newCornerY = anchor.y - newCalculatedDisplaySize.y;
  } else if (isResizing == 1) {
    newCornerX = anchor.x - newCalculatedDisplaySize.x; newCornerY = anchor.y + newCalculatedDisplaySize.y;
  } else if (isResizing == 2) {
    newCornerX = anchor.x + newCalculatedDisplaySize.x; newCornerY = anchor.y - newCalculatedDisplaySize.y;
  } else if (isResizing == 3) {
    newCornerX = anchor.x + newCalculatedDisplaySize.x; newCornerY = anchor.y + newCalculatedDisplaySize.y;
  }

    PVector newCenter = midpoint(anchor.x, anchor.y, newCornerX, newCornerY);
    s.x = newCenter.x;
    s.y = newCenter.y;
  }
}
  
// 마우스를 놓을 때 호출
void handleDiaryRelease() {
  
  currentlyDraggedSticker = null; // 스티커 놓기
    isResizing = -1;

   if (finishPressed && mouseHober(
        finishButton.position_x, finishButton.position_y,
        finishButton.width,      finishButton.height)) { switchScreen(diary_library); }

   if (storagePressed && mouseHober(
        stickerStoreButton.position_x, stickerStoreButton.position_y,
        stickerStoreButton.width, stickerStoreButton.height)) { switchScreen(sticker_library); }

  finishPressed = false;
  storagePressed = false;

}



