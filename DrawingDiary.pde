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
boolean isStickerLibraryOverlayVisible = false;
float overlayScrollY = 0;
float minOverlayScrollY = 0;
// 스크롤바
boolean isDraggingScrollbar = false;
float scrollbarDragStartY;
float scrollbarDragStartScrollY;
float scrollbarX, scrollbarY, scrollbarW, scrollbarH;
float thumbY, thumbH;

int isDatePickerVisible = 0;  // 0: 안보임, 1: 달력, 2: 년도
Calendar datePickerCalendar; 
int datePickerWidth = 300;
int datePickerHeight = 280;
int datePickerX;
int datePickerY;
// 년도 설정 좌표
int yearmonthScrollX;
int yearmonthScrollY;
int yearmonthScrollW;
int yearmonthScrollH;
rectButton yearmonthOK;
rectButton yearmonthCancle;
boolean yearmonthOKPressed = false;
boolean yearmonthCanclePressed = false;
int yearmonthButtonA = 96; //  버튼 간격 

float yearPickerX;  // 년도 텍스트 위치
float yearmonthY;

int yearPicker; // 년도 설정의 년도
int monthPicker;  // 년도 설정의 달
int set;  // 드래그 설정 관련 변수

int nowDragInPicker; // 현재 달/년도 드래그중인지 0: 드래그x, 1: 년도, 2: 달

PGraphics yearmonthMask;

boolean datePressed = false;

int diary_day = calendar.get(Calendar.DAY_OF_MONTH);
int diary_month = calendar.get(Calendar.MONTH) + 1;
int diary_year = calendar.get(Calendar.YEAR);

void drawDiary() {

  updateTextUIVisibility();

  pushStyle();
  background(255, 250, 220);
  rectMode(CORNER);
  fill(125,125,125);
  rect(0, textFieldY, width, height);

  pushStyle();
  fill(0);
  textSize(30);
  text("Name : " + username, 20, 30);
  popStyle();
  
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
  dateButton.render();

  if(diary_year != -1 && diary_month != -1 && diary_day != -1) {
    pushStyle();
    textSize(30);
    fill(0);
    text("Date : " + diary_year + ". " + diary_month + ". " + diary_day, 200, 30);
    popStyle();
  }

  // 날짜 선택기(달력)가 활성화되어 있으면 그리기
  if (isDatePickerVisible != 0) {
    drawDatePicker();
    if (isDatePickerVisible == 2) {
      drawYearMonthPicker();
    }
  }
  
  if (isStickerLibraryOverlayVisible) {
    drawStickerLibraryOverlay();
  }
}

void drawStickerLibraryOverlay() {
  pushStyle();
  // 뒷배경 어둡게
  fill(0, 150);
  rect(0, 0, width, height);

  // 보관함 패널
  rectMode(CORNER);
  float panelX = 100, panelY = 100, panelW = width - 200, panelH = height - 200;
  fill(220, 240, 220);
  rect(panelX, panelY, panelW, panelH, 10);

  // 제목
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Sticker Library", panelX + panelW / 2, panelY + 40);

  // 닫기 버튼
  textSize(24);
  fill(100);
  if (mouseHober(panelX + panelW - 50, panelY + 10, 40, 40)) {
    fill(0);
  }
  text("X", panelX + panelW - 30, panelY + 30);
  //
  rectMode(CORNER);
  noFill();
  stroke(0);
  strokeWeight(1);
  rect(panelX + 30, panelY + 80 - 16, panelW - 30 - 40, panelH - 80);
  popStyle();

  // 스티커 목록 그리기

  pushStyle();
  float boxSize = 100;
  int spacing = 120;
  int startX = (int)(panelX + 80);
  int startY = (int)(panelY + 130);
  int cols = floor((panelW - 100) / spacing);
  rectMode(CORNER);

  // 스크롤 범위
  if (stickerLibrary.size() > 0) {
    int numRows = (stickerLibrary.size() - 1) / cols + 1;
    float contentHeight = (numRows - 1) * spacing + boxSize;
    float viewHeight = panelH - (startY - panelY);
    minOverlayScrollY = max(0, contentHeight - viewHeight);
  } else {
    minOverlayScrollY = 0;
  }

  clip(startX - boxSize/2, startY - boxSize/2 - 16, panelW + boxSize/2 - 40, panelH - boxSize/2 - 32);

  for (int i = 0; i < stickerLibrary.size(); i++) {
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;

    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY;
    float w = s.img.width;
    float h = s.img.height;
    float newW, newH;

    if (w > h) {
      newW = boxSize;
      newH = h * (boxSize / w);
    } else {
      newH = boxSize;
      newW = w * (boxSize / h);
    }

    imageMode(CENTER);
    image(s.img, stickerX, stickerY, newW, newH);

    if (mouseHober(stickerX - newW / 2, stickerY - newH / 2, newW, newH)) {
      stroke(0);
      strokeWeight(3);
      noFill();
      rectMode(CENTER);
      rect(stickerX, stickerY, newW, newH);
      rectMode(CORNER);
    }
  }
  noClip();
  // 스크롤바 그리기
  if (minOverlayScrollY > 0) {
    scrollbarW = 12;
    float scrollbarMargin = 20;
    scrollbarX = panelX + panelW - scrollbarMargin - scrollbarW;
    scrollbarY = panelY + 80;
    scrollbarH = panelH - 120;

    // 스크롤바 트랙
    fill(200, 180);
    noStroke();
    rect(scrollbarX, scrollbarY, scrollbarW, scrollbarH, 6);

    // 스크롤바 섬
    float viewHeight = panelH - (startY - panelY);
    int numRows = (stickerLibrary.size() - 1) / cols + 1;
    float contentHeight = (numRows - 1) * spacing + boxSize;
    thumbH = scrollbarH * (viewHeight / contentHeight);
    thumbH = max(thumbH, 25); // 최소 높이
    float scrollableDist = scrollbarH - thumbH;
    float scrollRatio = overlayScrollY / minOverlayScrollY;
    thumbY = scrollbarY + scrollableDist * scrollRatio;
    // 마우스가 섬 위에 있거나 드래그 중이면 색상 변경
    if (isDraggingScrollbar || mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) {
      fill(120);
    } else {
      fill(170);
    }
    rect(scrollbarX, thumbY, scrollbarW, thumbH, 6);
  }
  popStyle();
}
  
void updateTextUIVisibility() {
  boolean onDiary = (currentScreen == drawing_diary);
  if (textArea != null) {
    boolean isOverlayActive = isStickerLibraryOverlayVisible || isDatePickerVisible != 0;
    
    titleArea.setVisible(onDiary);
    titleArea.setEnabled(onDiary && !isOverlayActive);
    
    textArea.setVisible(onDiary);
    textArea.setEnabled(onDiary && !isOverlayActive);
    
    if (isOverlayActive) {
      titleArea.setAlpha(0);
      textArea.setAlpha(0);
    } else {
      titleArea.setAlpha(255);
      textArea.setAlpha(255);
    }
  }
}
void handleDiaryMouse() { // 마우스를 처음 눌렀을 때 호출

  if (isStickerLibraryOverlayVisible) {
    // 오버레이 활성 시 스크롤바 드래그 확인
    if (minOverlayScrollY > 0 && mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) {
      isDraggingScrollbar = true;
      scrollbarDragStartY = mouseY;
      scrollbarDragStartScrollY = overlayScrollY;
    }
    return;
  }

  if (isDatePickerVisible != 0) {
    handleDatePickerMouse();
    return;
  }

  if (isDatePickerVisible != 0) {
    return;
  }
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

  if (stickerStoreButton != null) {
    storagePressed = mouseHober(stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height);
  } else {
    storagePressed = false;
  }

  if (finishButton != null) {
    finishPressed = mouseHober(
      finishButton.position_x, finishButton.position_y,
      finishButton.width, finishButton.height
    );
  } else {
    finishPressed = false;
  }

  if (yearmonthOK != null) {
    yearmonthOKPressed = mouseHober(yearmonthOK.position_x, yearmonthOK.position_y,
      yearmonthOK.width, yearmonthOK.height);
  } else {
    yearmonthOKPressed = false;
  }

  if (yearmonthCancle != null) {
    yearmonthCanclePressed = mouseHober(yearmonthCancle.position_x, yearmonthCancle.position_y,
      yearmonthCancle.width, yearmonthCancle.height);
  } else {
    yearmonthCanclePressed = false;
  }

  if (dateButton != null) {
    datePressed = mouseHober(dateButton.position_x, dateButton.position_y, dateButton.width, dateButton.height
    );
  }
}
  
void handleDiaryDrag() {  // 드래그하는 동안 호출
  if (isStickerLibraryOverlayVisible) {
    // 스크롤바 드래그 처리
    if (isDraggingScrollbar) {
      float dy = mouseY - scrollbarDragStartY;
      float scrollablePixelRange = scrollbarH - thumbH;
      if (scrollablePixelRange > 0) {
        float scrollRatio = dy / scrollablePixelRange;
        float scrollDelta = scrollRatio * minOverlayScrollY;
        overlayScrollY = constrain(scrollbarDragStartScrollY + scrollDelta, 0, minOverlayScrollY);
      }
    }
    return;
  }

  if (isDatePickerVisible != 0) {
    handleDatePickerDrag();
    return;
  }
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
  // 크기 계산
  float newDisplayW = abs(mouseX - anchor.x);
  float newDisplayH = abs(min(mouseY, textFieldY) - anchor.y);

  float imgRatio = (float)s.img.width / (float)s.img.height;
  float boxRatio = (newDisplayH == 0) ? 10000 : newDisplayW / newDisplayH;

  if (boxRatio > imgRatio) { // 스티커 정사각형으로
    s.size = (s.img.height >= s.img.width) ? newDisplayH : newDisplayH * imgRatio;
  } else { 
    s.size = (s.img.width >= s.img.height) ? newDisplayW : newDisplayW / imgRatio;
  }

  // 최소 크기 제한
  s.size = max(s.size, 20);
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
  
  if (isStickerLibraryOverlayVisible) {
    if (isDraggingScrollbar) {
      isDraggingScrollbar = false;
      return;
    }
    
    // 스크롤바 트랙 클릭
    if (minOverlayScrollY > 0 && mouseHober(scrollbarX, scrollbarY, scrollbarW, scrollbarH) && !mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) {
      // 스크롤 이동
      float clickRatio = (mouseY - scrollbarY - thumbH / 2) / (scrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      overlayScrollY = clickRatio * minOverlayScrollY;
      return;
    }
    handleStickerLibraryOverlayRelease();
    return;
  }

  if (isDatePickerVisible != 0) {
    handleDatePickerMouseRelease();
    return;
  }
  currentlyDraggedSticker = null; // 스티커 놓기
    isResizing = -1;

  if (finishPressed && mouseHober(
      finishButton.position_x, finishButton.position_y,
      finishButton.width,      finishButton.height)) {
         switchScreen(diary_library);
         loadDiaryDates();
         saveDiary();
       }

  if (storagePressed && mouseHober(
      stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height)) {
    isStickerLibraryOverlayVisible = true;
  }

  if (datePressed && mouseHober(
      dateButton.position_x, dateButton.position_y,
      dateButton.width, dateButton.height)) { openDatePickerDialog(); }

  finishPressed = false;
  storagePressed = false;
  datePressed = false;

}

void handleStickerLibraryOverlayRelease() {
  float panelX = 100, panelY = 100, panelW = width - 200, panelH = height - 200;

  // 닫기 버튼 클릭
  if (mouseHober(panelX + panelW - 50, panelY + 10, 40, 40)) {
    isStickerLibraryOverlayVisible = false;
    return;
  }

  // 스티커 클릭 시 일기장에 추가
  float boxSize = 100;
  int spacing = 120;
  int startX = (int)(panelX + 80);   // drawStickerLibraryOverlay와 동일한 값 사용
  int startY = (int)(panelY + 130);  // drawStickerLibraryOverlay와 동일한 값 사용
  int cols = floor((panelW - 160) / spacing);
  
  for (int i = 0; i < stickerLibrary.size(); i++) {
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;

    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY; // 스크롤 위치 반영
    float w = s.img.width;
    float h = s.img.height;
    float newW, newH;

    if (w > h) {
      newW = boxSize;
      newH = h * (boxSize / w);
    } else {
      newH = boxSize;
      newW = w * (boxSize / h);
    }

    // 스티커가 보이는 영역(패널) 안에 있을 때만 클릭 처리
    boolean isStickerVisible = (stickerY + newH/2 > panelY + 80) && (stickerY - newH/2 < panelY + panelH);

    if (isStickerVisible && mouseHober(stickerX - newW / 2, stickerY - newH / 2, newW, newH)) {
      Sticker newSticker = new Sticker(width / 2, textFieldY / 2, s.img, defaultStickerSize, s.imageName);
      placedStickers.add(newSticker);
      selectedSticker = newSticker;
      isStickerLibraryOverlayVisible = false; // 스티커 추가 후 오버레이 닫기
      return;
    }
  }
}


void openDatePickerDialog() { // 달력 토글
  if (datePickerCalendar == null) {
    datePickerCalendar = (Calendar) calendar.clone();
  } else {
    // 열 때마다 현재 일기 날짜로 달력을 동기화
    datePickerCalendar.setTime(calendar.getTime());
  }

  datePickerX = DATE_X;
  datePickerY = DATE_Y+DATE_H;
  isDatePickerVisible = 1;
}

void closeDatePickerDialog() {
  isDatePickerVisible --;
}

void drawDatePicker() {
  pushStyle();
  fill(0, 150);
  rect(0, 0, width, height);
  textAlign(CENTER, CENTER);
  rectMode(CORNER);
  fill(245, 245, 245);
  stroke(150);
  strokeWeight(1);
  rect(datePickerX, datePickerY, datePickerWidth, datePickerHeight, 8);

  textAlign(CENTER, CENTER);
  fill(0);
  textSize(20);
  String monthString = monthToString(datePickerCalendar.get(Calendar.MONTH));


  text(datePickerCalendar.get(Calendar.YEAR) + " " + monthString, datePickerX + datePickerWidth / 2, datePickerY + 30);

  // 화살표
  textSize(24);
  text("<", datePickerX + 30, datePickerY + 30); // 이전 달
  text(">", datePickerX + datePickerWidth - 30, datePickerY + 30); // 다음 달

  // 요일 레이블
  String[] daysOfWeek = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  textSize(14);
  float cellWidth = datePickerWidth / 7.0;
  for (int i = 0; i < 7; i++) {
    fill(i == 0 ? color(200, 0, 0) : 0); // 일요일
    text(daysOfWeek[i], datePickerX + cellWidth * i + cellWidth / 2, datePickerY + 70);
  }

  // 날짜 그리드
  Calendar tempCal = (Calendar) datePickerCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);

  int day = 1;
  float cellHeight = (datePickerHeight - 100) / 6.0;
  textSize(16);

  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue; // 1일 이전
      if (day > maxDaysInMonth) break; // 마지막 날짜를 넘어가면 중단

      float x = datePickerX + col * cellWidth;
      float y = datePickerY + 90 + row * cellHeight;
      
      // 현재 선택된 날짜 표시
      if (datePickerCalendar.get(Calendar.YEAR) == diary_year &&
          datePickerCalendar.get(Calendar.MONTH) + 1 == diary_month &&
          day == diary_day) {
        fill(200, 220, 255);
        noStroke();
        ellipse(x + cellWidth / 2, y + cellHeight / 2, cellWidth * 0.8, cellHeight * 0.8);
      }
      if (isDatePickerVisible == 1) {
        // 마우스 호버 효과
        if (mouseHober(x, y, cellWidth, cellHeight)) {
          noFill();
          stroke(0, 100);
          strokeWeight(1);
          rect(x+2, y+2, cellWidth-4, cellHeight-4, 4);
        }
        else if (mouseHober(datePickerX, datePickerY, 60, 60)) {
          stroke(1);
          noFill();
          rect(datePickerX, datePickerY, 60, 60, 4);
        }
        else if (mouseHober(datePickerX + datePickerWidth - 60, datePickerY, 60, 60)) {
          stroke(1);
          noFill();
          rect(datePickerX + datePickerWidth - 60, datePickerY, 60, 60, 4);
        }
        if (mouseHober(datePickerX + datePickerWidth / 2 - 60, datePickerY, 128, 64)) {
          stroke(1);
          noFill();
          rect(datePickerX + datePickerWidth / 2 - 60, datePickerY, 128, 64);
        }
      }
      fill(col == 0 ? color(200, 0, 0) : 0); // 일요일 날짜는 빨간색
      text(day, x + cellWidth / 2, y + cellHeight / 2);
      day++;
    }
  }
  popStyle();
}
void openYearMonthPicker() {  // 년도 설정창 토글
  Calendar base = (datePickerCalendar != null) ? datePickerCalendar : calendar;
  yearPicker  = base.get(Calendar.YEAR);
  monthPicker = base.get(Calendar.MONTH) + 1;

  yearmonthScrollX = width/2;
  yearmonthScrollY = height/2;

  yearmonthScrollW = 480;
  yearmonthScrollH = 240;

  yearPickerX = yearmonthScrollX-96;
  yearmonthY = yearmonthScrollY;
  isDatePickerVisible = 2;

  yearmonthScrollX = width/2-yearmonthScrollW/2;
  yearmonthScrollY = height/2-yearmonthScrollH/2;
  initYearMonthButton();
}
void initYearMonthButton() {
  yearmonthOK = new rectButton(yearmonthScrollX-yearmonthButtonA+240,yearmonthScrollY+yearmonthScrollH-32,48,24, #FBDAB0);
  yearmonthOK.rectButtonText("OK", 18);
  yearmonthOK.setShadow(false);
  yearmonthCancle = new rectButton(yearmonthScrollX+yearmonthButtonA+240,yearmonthScrollY+yearmonthScrollH-32,48,24, #D9D9D9);
  yearmonthCancle.rectButtonText("Cancle", 18);
  yearmonthCancle.setShadow(false);
}


void drawYearMonthPicker() {  // 년도 설정창 드로우
  pushStyle();
  // 틀
  fill(0, 150);
  rect(0, 0, width, height);
  rectMode(CORNER);
  stroke(#D9D9D9);
  strokeWeight(1);
  fill(255);
  rect(yearmonthScrollX,yearmonthScrollY,yearmonthScrollW,yearmonthScrollH,24);
  noStroke();
  fill(#FBDAB0);
  rect(yearmonthScrollX,yearmonthScrollY,64,yearmonthScrollH,24,0,0,24);
  fill(#DBFDB4);
  rect(yearmonthScrollX+64,yearmonthY-24,yearmonthScrollW-64,48);
  // 텍스트
  fill(0);
  textAlign(CENTER,CENTER);
  if (nowDragInPicker == 0) {

    if (nowDragInPicker == 0) {

      text(yearPicker, yearPickerX, yearmonthY);  

      text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY);

      fill(125);
      text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY-48);
      text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY+48);

      if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-48); }
      if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+48); }
      
    }
  }
  else if (nowDragInPicker == 1) {

    text(yearPicker, yearPickerX, yearmonthY + set*4.8);  

    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY);

    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY-48);
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY+48);

    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-48 + set*4.8); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+48 + set*4.8); }

  }
  else if (nowDragInPicker == 2) {

    text(yearPicker, yearPickerX, yearmonthY);  // 선택 년도

    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY + set*4.8);

    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY-48 + set*4.8);
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+128, yearmonthY+48 + set*4.8);

    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-48); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+48); }
    
  }
  text("|",yearmonthScrollX+32+yearmonthScrollW/2,yearmonthY);
  fill(150);
  if (yearmonthOK != null) {
    yearmonthOK.render();
  }
  if (yearmonthCancle != null) {
   yearmonthCancle.render();  
  }
   popStyle();


}

void handleDatePickerMouse() {  // 달력 클릭
  if (isDatePickerVisible == 2) { // 년도 설정창 클릭
    handleYearMonthMouse();
    return;
  }
}

void handleYearMonthMouse() {  // 년도 설정창 클릭
  if (nowDragInPicker == 0) {
    if (mouseHober(yearPickerX-64,yearmonthScrollY,192,yearmonthScrollH)) {
      nowDragInPicker = 1;
      return;
    }
    if (mouseHober(yearmonthScrollX+yearmonthScrollW/2+64,yearmonthScrollY,192,yearmonthScrollH)) {
      nowDragInPicker = 2;
      return;
    }
  }
}

void handleDatePickerDrag() { // 달력 드래그
  if (isDatePickerVisible == 2) {
    handleYearMonthDrag();
    return;
  }
}

void handleYearMonthDrag() {  // 년도 설정창 드래그
  println(set);
  if (mouseY > pmouseY) set += 2;
  if (mouseY < pmouseY) set -= 2;

  if (set >= 10) {
    if (nowDragInPicker == 1) { // 년도
      if (yearPicker > 0) yearPicker--;
    } else if (nowDragInPicker == 2) { 
      if (monthPicker > 1) monthPicker--;
    }
    set = 0;
  }
  if (set <= -10) {
    if (nowDragInPicker == 1) { // 년도
      if (yearPicker < 9999) yearPicker++;
    } else if (nowDragInPicker == 2) {
      if (monthPicker < 12) monthPicker++;
    }
    set = 0;
  }
}


void handleDatePickerMouseRelease() { // 달력 마우스 떼기
  float cellWidth = datePickerWidth / 7.0;
  if ((isDatePickerVisible == 2)) {
    
    if (yearmonthOK != null &&
        mouseHober(yearmonthOK.position_x, yearmonthOK.position_y, yearmonthOK.width, yearmonthOK.height)) {
      datePickerCalendar.set(yearPicker,monthPicker -1, diary_day);
      calendar.set(diary_year, diary_month - 1, diary_day);
      closeDatePickerDialog();
      return;

    }

    if (yearmonthCancle != null &&
      mouseHober(yearmonthCancle.position_x, yearmonthCancle.position_y, yearmonthCancle.width, yearmonthCancle.height)) {
      isDatePickerVisible = 1;
      return;
    }

    handleYearMonthMouseRelease();
    return;
  }
  // 이전 달 화살표 클릭
  if (mouseHober(datePickerX, datePickerY, 60, 60)) {
    datePickerCalendar.add(Calendar.MONTH, -1);
    return;
  }
  // 다음 달 화살표 클릭
  if (mouseHober(datePickerX + datePickerWidth - 60, datePickerY, 60, 60)) {
    datePickerCalendar.add(Calendar.MONTH, 1);
    return;
  }
  // 달/년도 클릭
  if (mouseHober(datePickerX + datePickerWidth / 2 - 60, datePickerY, 128, 64)) {
    openYearMonthPicker();
    return;
  }

  // 날짜 클릭 확인
  Calendar tempCal = (Calendar) datePickerCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);
  int day = 1;
  float cellHeight = (datePickerHeight - 100) / 6.0;

  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue;
      if (day > maxDaysInMonth) break;

      float x = datePickerX + col * cellWidth;
      float y = datePickerY + 90 + row * cellHeight;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        // 날짜 선택
        diary_year = datePickerCalendar.get(Calendar.YEAR);
        diary_month = datePickerCalendar.get(Calendar.MONTH) + 1;
        diary_day = day;

        // 메인 calendar 업데이트
        calendar.set(diary_year, diary_month - 1, diary_day);
        closeDatePickerDialog();
        return;
      }
      day++;
    }
  }
  
  // 달력 바깥 영역을 클릭하면 닫기
  if ((!mouseHober(datePickerX, datePickerY, datePickerWidth, datePickerHeight))&&(isDatePickerVisible == 1)) {
    closeDatePickerDialog();
  }

if ((!mouseHober(yearmonthScrollX, yearmonthScrollY, yearmonthScrollW, yearmonthScrollH))&&(isDatePickerVisible == 2)) {
    isDatePickerVisible = 1;
  }
}
void handleDrawingDiaryMouseWheel(MouseEvent ev) {
  if (isStickerLibraryOverlayVisible) {
    if (mouseHober(130, 164, width - 270, height - 280)) {
      float scrollAmount = ev.getCount() * 10; // 스크롤 속도
      overlayScrollY = constrain(overlayScrollY - scrollAmount, 0, minOverlayScrollY);
    }
  }


  if (isDatePickerVisible == 2) {
    if (mouseHober(yearPickerX-64,yearmonthScrollY,192,yearmonthScrollH)) {
      yearPicker -= ev.getCount();
      yearPicker = constrain(yearPicker, 1, 9998);
    }
    if (mouseHober(yearmonthScrollX+yearmonthScrollW/2+64,yearmonthScrollY,192,yearmonthScrollH)) {
      monthPicker -= ev.getCount();
      monthPicker = clampMonth1to12(monthPicker);
    }
  }
}



void handleYearMonthMouseRelease() {  // 년도 설정창 마우스 떼기
  if (nowDragInPicker != 0) {
      nowDragInPicker = 0;
      set = 0;
      return;
  }
  else if (!mouseHober(yearmonthScrollX,yearmonthScrollY,yearmonthScrollW,yearmonthScrollH)) {
    isDatePickerVisible = 1;
    return;
  }
}
void saveDiary() {
  JSONObject diaryData = new JSONObject();

  // 제목과 내용 저장
  diaryData.setString("title", titleArea.getText());
  diaryData.setString("content", textArea.getText());

  // 스티커 저장
  JSONArray stickerArray = new JSONArray();
  for (Sticker s : placedStickers) {
    JSONObject stickerData = new JSONObject();
    stickerData.setFloat("x", s.x);
    stickerData.setFloat("y", s.y);
    stickerData.setFloat("size", s.size);
    stickerData.setString("imageName", s.imageName);
    stickerArray.append(stickerData);
  }
  diaryData.setJSONArray("stickers", stickerArray);

  // JSON 파일로 저장
  saveJSONObject(diaryData, "data/diaries/diary_" + diary_year + "_" + diary_month + "_" + diary_day + ".json");
  println("Diary saved to data/diaries/diary_" + diary_year + "_" + diary_month + "_" + diary_day + ".json");
}

// 불러오기
void loadDiary(int year, int month, int day) {
  String filePath = "data/diaries/diary_" + year + "_" + month + "_" + day + ".json";  
  JSONObject diaryData = loadJSONObject(filePath);
  
  if (diaryData == null) {
    // loadJSONObject는 파일이 없거나 유효한 JSON이 아니면 null을 반환합니다.
    println("Diary file not found or is invalid: " + filePath);
    return;
  }
  
  // Clear current diary state
  placedStickers.clear();
  titleArea.setText(diaryData.getString("title", ""));
  textArea.setText(diaryData.getString("content", ""));
  
  // Update diary date
  diary_year = year;
  diary_month = month;
  diary_day = day;
  calendar.set(diary_year, diary_month - 1, diary_day);
  
  // Load stickers
  JSONArray stickerArray = diaryData.getJSONArray("stickers");
  if (stickerArray != null) {
    for (int i = 0; i < stickerArray.size(); i++) {
      JSONObject stickerData = stickerArray.getJSONObject(i);
      
      String imageName = stickerData.getString("imageName");
      float x = stickerData.getFloat("x");
      float y = stickerData.getFloat("y");
      float size = stickerData.getFloat("size");
      
      PImage stickerImg = null;
      for (Sticker libSticker : stickerLibrary) {
        if (libSticker.imageName.equals(imageName)) {
          stickerImg = libSticker.img;
          break;
        }
      }
      
      if (stickerImg == null) {
        println("Sticker image not found in library: " + imageName + ". Trying to load from file.");
        stickerImg = loadImage(dataPath("sticker/" + imageName));
      }
      
      if (stickerImg != null) {
        Sticker newSticker = new Sticker(x, y, stickerImg, size, imageName);
        placedStickers.add(newSticker);
      } else {
        println("Failed to load sticker image: " + imageName);
      }
    }
  }
  
  println("Diary loaded for " + year + "-" + month + "-" + day);
}

void resetDiary() {
  // 1. 스티커 목록 초기화
  if (placedStickers != null) {
    placedStickers.clear();
  }
  
  // 2. 텍스트 필드 초기화
  if (titleArea != null) {
    titleArea.setText("");
  }
  if (textArea != null) {
    textArea.setText("");
  }
  
  // 3. 날짜를 오늘 날짜로 초기화
  calendar = Calendar.getInstance(); // 오늘 날짜로 새로고침
  diary_year = calendar.get(Calendar.YEAR);
  diary_month = calendar.get(Calendar.MONTH) + 1;
  diary_day = calendar.get(Calendar.DAY_OF_MONTH);
  
  // 4. 선택된 스티커 및 상태 초기화
  selectedSticker = null;
  currentlyDraggedSticker = null;
  isResizing = -1;
  
  println("Diary has been reset for a new entry.");
}