rectButton analyzeButton;
boolean analyzePressed = false;
boolean isAnalyzing = false;
float lastSentimentScore = -1;
String lastSentimentLabel = "";

// Weather
int todayWeather;

Sticker selectedSticker;
float handleSize;
// -1: 조절중x, 0: 왼쪽 위, 1: 왼쪽 아래, 2: 오른쪽 위, 3: 오른쪽 아래
int isResizing = -1;
PVector resizeAnchor = new PVector();

rectButton stickerStoreButton;
rectButton finishButton;
boolean storagePressed = false;
boolean colorPickerPressed = false;
boolean finishPressed = false;
boolean isStickerLibraryOverlayVisible = false; // 스티커 보관함 오버레이 표시 여부
// Right-click 'edit' context UI for StickerLibrary overlay
boolean isStickerEditContextVisible = false;
float editContextX = 0;
float editContextY = 0;
float editContextBtnW = 0;
float editContextBtnH = 0;
int editContextStickerIndex = -1;

float overlayScrollY = 0; // 스티커 보관함 오버레이 스크롤 위치
float minOverlayScrollY = 0; // 스티커 보관함 오버레이 최소 스크롤 위치
boolean isDraggingScrollbar = false; // 스크롤바 드래그 중인지 여부
float scrollbarDragStartY; // 스크롤바 드래그 시작 Y 좌표
float scrollbarDragStartScrollY; // 스크롤바 드래그 시작 시 스크롤 위치
float scrollbarX, scrollbarY, scrollbarW, scrollbarH; // 스크롤바 위치 및 크기
float thumbY, thumbH; // 스크롤바 섬 위치 및 크기

int isDatePickerVisible = 0; // 0: 안보임, 1: 달력, 2: 년도
Calendar datePickerCalendar;
float datePickerWidth;
float datePickerHeight;
float datePickerX;
float datePickerY;
int yearmonthScrollX;
int yearmonthScrollY;
int yearmonthScrollW;
int yearmonthScrollH;
rectButton yearmonthOK;
rectButton yearmonthCancle;
boolean yearmonthOKPressed = false;
boolean yearmonthCanclePressed = false;
int yearmonthButtonA = 96;

float yearPickerX;
float yearmonthY;

int yearPicker;
int monthPicker;
int set;

int nowDragInPicker; // 0: 드래그x, 1: 년도, 2: 달

boolean datePressed = false;

int diary_day = calendar.get(Calendar.DAY_OF_MONTH);
int diary_month = calendar.get(Calendar.MONTH) + 1;
int diary_year = calendar.get(Calendar.YEAR);

color diaryPaperColor = color(251, 218, 176);
color diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);

void drawDiary() {

  handleSize = width * (16.0f / 1280.0f);
  datePickerWidth = width * (300.0f / 1280.0f);
  datePickerHeight = height * (280.0f / 720.0f);
  yearmonthButtonA = round(width * (96.0f / 1280.0f));


  updateTextUIVisibility();

  pushStyle();
  background(diaryBackgroundColor);
  drawWeatherEffect();
  rectMode(CORNER);
  fill(diaryPaperColor);
  noStroke();
  rect(0, 0, width, navigationBarY);
  rect(0, textFieldY, width, height - textFieldY);
  
  // 공통 뒤로가기 버튼은 항상 그려줍니다.
  drawBackButton(DIARY_BACK_X, DIARY_BACK_Y, DIARY_BACK_W, DIARY_BACK_H);
  
  pushStyle();
  fill(0);
  textSize(30);
  textAlign(LEFT,CENTER);
  text("Name : " + username, width * (100.0f/1280.0f), height * (30.0f/720.0f));
  popStyle();
  
  // 일기장에 붙여진 스티커들을 그리기
  for (Sticker s : placedStickers) {
    s.display();
  }
  // 스티커가 선택되었고, 이동 드래그 중이 아닐 때만 핸들을 그립니다.
  if (selectedSticker != null && !(isResizing == -1 && currentlyDraggedSticker != null)) {
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

  // 스티커를 드래그하여 이동 중일 때 삭제 존 표시
  if (currentlyDraggedSticker != null && isResizing == -1) { // 이동 중에만
    float deleteZoneSize = 64;
    float deleteZoneX = 0;
    float deleteZoneY = textFieldY - deleteZoneSize;

    pushStyle();
    fill(255, 0, 0, 100); // 반투명한 붉은색
    noStroke(); // 외곽선이 생기는 것을 방지합니다.
    rectMode(CORNER);
    rect(deleteZoneX, deleteZoneY, deleteZoneSize, deleteZoneSize);
    imageMode(CENTER);

    boolean isHoveringDelete = mouseHober(deleteZoneX, deleteZoneY, deleteZoneSize, deleteZoneSize);
    if (isHoveringDelete) {
      image(trashOpenIcon, deleteZoneX + deleteZoneSize / 2 - 7, deleteZoneY + deleteZoneSize / 2 - 7, deleteZoneSize * 0.725, deleteZoneSize * 0.84);
    } else {
      image(trashClosedIcon, deleteZoneX + deleteZoneSize / 2, deleteZoneY + deleteZoneSize / 2, deleteZoneSize * 0.7, deleteZoneSize * 0.7);
    }
    popStyle();
  }
  popStyle();

  ensureDiaryUI();
  analyzeButton.render();
  stickerStoreButton.render();
  diaryColorPicker.render();
  finishButton.render();

  // 감정 분석 로딩/결과 UI
  pushStyle();
  textAlign(LEFT, CENTER);
  textSize(16);

  // 버튼 레이아웃과 일관성을 유지하기 위해 Y 좌표를 다시 계산합니다.
  float btnH = height * (60.0f/720.0f);
  float analyzeBtnY = navigationBarY + 20;
  float sentimentTextY = analyzeBtnY + btnH + 4; // 분석 버튼 아래에 텍스트 위치

  if (isAnalyzing) {
    // 로딩 텍스트
    fill(0);
    text("Analyzing sentiment...", width * (1100.0f/1280.0f), sentimentTextY);
    pushMatrix();
    pushStyle();
    float iconX = width * (1100.0f/1280.0f) + textWidth("Analyzing sentiment...") + width * (20.0f/1280.0f);
    float iconY = sentimentTextY;
    translate(iconX, iconY);
    float angle = frameCount * 0.1;
    rotate(angle);
    stroke(50, 50, 200);
    strokeWeight(3);
    noFill();
    arc(0, 0, 19, 19, 0, PI + HALF_PI);
    popStyle();
    popMatrix();
  }
   else if (lastSentimentScore >= 0) {
    fill(0);
    text("Sentiment: " + lastSentimentLabel + String.format(" (%.2f)", lastSentimentScore),
        width * (1100.0f/1280.0f), sentimentTextY);
  }
  popStyle();

  // 날씨 아이콘
  if (weatherIcon != null) {
    pushStyle();
    imageMode(CENTER);
    int iconCount = weatherIcon.length;
    float baseIconSize = width * (40.0f / 1280.0f);
    float rightMargin = width * (300.0f / 1280.0f);
    float iconSpacing = width * (10.0f / 1280.0f); // 아이콘 사이의 간격
    for (int i = 0; i < iconCount; i++) {
      // 아이콘의 고정된 중앙 위치 계산 (오른쪽부터 왼쪽으로)
      float x_center = width - rightMargin - (baseIconSize / 2) - (i * (baseIconSize + iconSpacing));
      float y_center = navigationBarY / 2;

      PImage drawEmotIcon;
      float effectiveIconSize;
      
      if (todayWeather == i) {
        drawEmotIcon = weatherIcon[i];
        // 선택된 아이콘에 펄스 효과 추가
        float pulse = 1.0 + sin(frameCount * 0.1) * 0.05; // 1.0 ~ 1.05 사이로 크기 변화
        effectiveIconSize = baseIconSize * pulse;
      } else {
        drawEmotIcon = weatherIcon[i].get();
        drawEmotIcon.filter(GRAY);
        // 호버 감지 영역은 호버 시의 크기를 기준으로 합니다.
        if (mouseHober(x_center - (baseIconSize * 0.875f) / 2, y_center - (baseIconSize * 0.875f) / 2, baseIconSize * 0.875f, baseIconSize * 0.875f)) {
          effectiveIconSize = baseIconSize * 0.875f;
        }
        else { // 평상시 30/40 크기
          effectiveIconSize = baseIconSize * 0.75f; // 평상시 30/40 크기
        }
      }
      PVector newSize = getScaledImageSize(drawEmotIcon, effectiveIconSize);
      image(drawEmotIcon, x_center, y_center, newSize.x, newSize.y);
    }
    popStyle();
  }

  // 표정 아이콘
  if (emotIcon != null) {
    pushStyle();
    imageMode(CENTER); // 이미지 중앙 정렬
    int iconCount = emotIcon.length;
    float iconSize = width * (40.0f / 1280.0f); // 아이콘 크기
    float rightMargin = width * (20.0f / 1280.0f); // 오른쪽 끝에서의 여백
    float iconSpacing = width * (10.0f / 1280.0f); // 아이콘 사이의 간격
    for (int i = 0; i < iconCount; i++) {
      float currentIconSize = iconSize;
      // 아이콘 x 좌표 계산 (오른쪽부터 왼쪽으로)
      float x = width - rightMargin - (currentIconSize / 2) - (i * (currentIconSize + iconSpacing)); 
      // 아이콘 y 좌표 계산 (상단 바의 중앙)
      float y = navigationBarY / 2; 
      PImage drawEmotIcon;
      if (round(lastSentimentScore * 5) == i) {
        drawEmotIcon = emotIcon[i];
      }
      else {
        drawEmotIcon = emotIcon[i].get();
        drawEmotIcon.filter(GRAY);
        currentIconSize *= 0.75f;
      }
      // image(drawEmotIcon, x, y, currentIconSize, currentIconSize);
      PVector newSize = getScaledImageSize(drawEmotIcon, currentIconSize);
      image(drawEmotIcon, x, y, newSize.x, newSize.y);
    }
    popStyle();
  }

  if(diary_year != -1 && diary_month != -1 && diary_day != -1) {
    pushStyle();
    textSize(30);
    String dateString = "Date : " + diary_year + ". " + diary_month + ". " + diary_day;
    float dateTextW = textWidth(dateString); // 날짜 텍스트 너비
    float dateTextH = 30;
    
    // 날짜 텍스트의 중앙 좌표를 정의합니다.
    float dateTextCenterX = width/2 - width * (120.0f/1280.0f);
    float dateTextCenterY = height * (30.0f/720.0f);
    
    // 호버 감지 및 그리기를 위한 사각형의 좌상단 좌표를 계산합니다.
    float dateRectX = dateTextCenterX - dateTextW / 2;
    float dateRectY = dateTextCenterY - dateTextH / 2;

    if (isDatePickerVisible == 0 && !isStickerLibraryOverlayVisible && mouseHober(dateRectX, dateRectY, dateTextW, dateTextH)) {
      fill(150,100);
      noStroke();
      rect(dateRectX - 4, dateRectY - 4, dateTextW + 8, dateTextH + 8, 8);
    }
    fill(0);
    textAlign(CENTER, CENTER);
    text(dateString, dateTextCenterX, dateTextCenterY);
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
  // 배경 어둡게
  fill(0, 150);
  rect(0, 0, width, height);

  // 보관함 패널
  rectMode(CORNER);
  float panelX = width * (100.0f/1280.0f); // 패널 X 좌표
  float panelY = height * (100.0f/720.0f);
  float panelW = width - 2 * panelX;
  float panelH = height - 2 * panelY;
  fill(220, 240, 220);
  rect(panelX, panelY, panelW, panelH, 10);

  // 제목
  fill(0); // 텍스트 색상
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Sticker Library", panelX + panelW / 2, panelY + height*(40.0f/720.0f));

  // 닫기 버튼
  textSize(24);
  fill(100);
  if (mouseHober(panelX + panelW - width*(50.0f/1280.0f), panelY + height*(10.0f/720.0f), width*(40.0f/1280.0f), height*(40.0f/720.0f))) {
    fill(0);
  }
  text("X", panelX + panelW - width*(30.0f/1280.0f), panelY + height*(30.0f/720.0f));
  rectMode(CORNER);
  fill(255);
  noStroke();
  float contentPaddingX = width * (30.0f/1280.0f);
  float contentPaddingY = height * (80.0f/720.0f);
  float scrollbarAreaWidth = width * (40.0f/1280.0f);
  rect(panelX + contentPaddingX - 16, panelY + contentPaddingY - 20, panelW - contentPaddingX - scrollbarAreaWidth + 42, panelH - contentPaddingY + 8, 4); // 스크롤 영역 배경
  popStyle();

  // 스티커 목록 그리기

  pushStyle();
  float boxSize = width * (100.0f/1280.0f);
  float spacing = width * (120.0f/1280.0f);
  float startX = panelX + width * (80.0f/1280.0f);
  float startY = panelY + height * (130.0f/720.0f);
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
  
  clip(startX - boxSize/2, startY - boxSize/2 - 16, panelW - width*(100.0f/1280.0f), panelH - height*(100.0f/720.0f));

  for (int i = 0; i < stickerLibrary.size(); i++) {
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;

    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY; // 스크롤 위치 반영
    PVector newSize = getScaledImageSize(s.img, boxSize);

    imageMode(CENTER);
    image(s.img, stickerX, stickerY, newSize.x, newSize.y);

    if (mouseHober(stickerX - newSize.x / 2, stickerY - newSize.y / 2, newSize.x, newSize.y)) {
      stroke(0);
      strokeWeight(3);
      noFill();
      rectMode(CENTER);
      rect(stickerX, stickerY, newSize.x, newSize.y);
      rectMode(CORNER);
    }
  }
  noClip(); // 클리핑 해제
  // 스크롤바 그리기
  if (minOverlayScrollY > 0) {
    scrollbarW = width * (12.0f/1280.0f);
    float scrollbarMargin = width * (20.0f/1280.0f);
    scrollbarX = panelX + panelW - scrollbarMargin - scrollbarW;
    scrollbarY = panelY + height * (80.0f/720.0f);
    scrollbarH = panelH - height * (120.0f/720.0f);

    // 스크롤바 트랙 그리기
    fill(200, 180);
    noStroke();
    rect(scrollbarX, scrollbarY, scrollbarW, scrollbarH, 6);

    // 스크롤바 섬 그리기
    float viewHeight = panelH - (startY - panelY);
    int numRows = (stickerLibrary.size() - 1) / cols + 1;
    float contentHeight = (numRows - 1) * spacing + boxSize;
    thumbH = scrollbarH * (viewHeight / contentHeight);
    thumbH = max(thumbH, 25);
    float scrollableDist = scrollbarH - thumbH;
    float scrollRatio = overlayScrollY / minOverlayScrollY; // 스크롤 비율
    thumbY = scrollbarY + scrollableDist * scrollRatio;
  
  // [Added] Draw small 'edit' chip when right-click context is visible
  if (isStickerEditContextVisible) {
    float bw = width * (72.0f/1280.0f);
    float bh = height * (36.0f/720.0f);
    // initial position near cursor
    float bx = editContextX;
    float by = editContextY;
    // ensure within panel bounds
    if (bx + bw > panelX + panelW) bx = (panelX + panelW) - bw;
    if (by + bh > panelY + panelH) by = (panelY + panelH) - bh;
    if (bx < panelX) bx = panelX;
    if (by < panelY) by = panelY;
    editContextBtnW = bw;
    editContextBtnH = bh;
    editContextX = bx;
    editContextY = by;

    noStroke();
    fill(255, 240);
    rect(bx, by, bw, bh, 6);
    stroke(0, 120);
    noFill();
    rect(bx, by, bw, bh, 6);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(height*(16.0f/720.0f));
    text("edit", bx + bw / 2, by + bh / 2);
  }
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
  if (textArea != null) { // 텍스트 필드가 초기화되었는지 확인
    // 오버레이(스티커, 설정, 달력)가 활성화되면 텍스트 필드를 비활성화합니다.
    boolean isOverlayActive = (isStickerLibraryOverlayVisible || isSettingsVisible) || (isDatePickerVisible != 0);
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
void handleDiaryMouse() {

  if (analyzeButton != null) {
    analyzePressed = mouseHober(analyzeButton.position_x, analyzeButton.position_y,
                                analyzeButton.width, analyzeButton.height);
  } else analyzePressed = false;
  
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
  
  if (isDatePickerVisible != 0) { // 달력/년도 선택기가 열려있으면 다른 마우스 이벤트 무시
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
        // 크기 조절을 시작할 때 반대 모서리를 고정점으로 설정
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
    if (selectedSticker != null) {
      break;
    }
    // 스티커 본체를 클릭했는지 확인
    if (mouseHober(s.x - displaySize.x/2, s.y - displaySize.y/2, displaySize.x, displaySize.y)) {
      selectedSticker = s;
      currentlyDraggedSticker = s;
      offsetX = mouseX - s.x;
      offsetY = mouseY - s.y;
      isResizing = -1;
      break; // 가장 위에 있는 스티커만 선택
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

  if (diaryColorPicker != null) {
    colorPickerPressed = mouseHober(diaryColorPicker.position_x, diaryColorPicker.position_y,
      diaryColorPicker.width, diaryColorPicker.height);
  } else {
    colorPickerPressed = false;
  }
  
  // 날짜 텍스트 클릭 여부 확인
  float[] dateRect = getDateTextRect();
  datePressed = mouseHober(dateRect[0], dateRect[1], dateRect[2], dateRect[3]);
}
  
void handleDiaryDrag() {
  if (isStickerLibraryOverlayVisible) {
    // 스크롤바 드래그 처리
    if (isDraggingScrollbar) {
      float dy = mouseY - scrollbarDragStartY;
      float scrollablePixelRange = scrollbarH - thumbH;
      if (scrollablePixelRange > 0) {
        // 마우스 이동 거리에 비례하여 스크롤 양을 계산합니다.
        float scrollAmount = dy * (minOverlayScrollY / scrollablePixelRange);
        overlayScrollY = constrain(scrollbarDragStartScrollY + scrollAmount, 0, minOverlayScrollY);
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
  // 스티커를 드래그(이동 또는 크기 조절)하면 수정된 것으로 간주
  isDiaryModified = true;

  Sticker s = currentlyDraggedSticker;
  if (isResizing == -1) { // 크기 조절 핸들이 아니면 스티커 이동
    PVector displaySize = s.getDisplaySize();
    // 스티커의 위치를 마우스 위치로 업데이트
    s.x = constrain(mouseX - offsetX, 0, width);
    s.y = constrain(mouseY - offsetY, 0, textFieldY - displaySize.y/2);
  } else { // 크기 조절 중
  PVector anchor = resizeAnchor; // 고정점
  // 크기 계산
  float newDisplayW = abs(mouseX - anchor.x);
  float newDisplayH = abs(min(mouseY, textFieldY) - anchor.y);

  float imgRatio = (float)s.img.width / (float)s.img.height;
  float boxRatio = (newDisplayH == 0) ? 10000 : newDisplayW / newDisplayH;

  if (boxRatio > imgRatio) { // 스티커 비율 유지
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
  
// 마우스를 놓았을 때 호출
void handleDiaryRelease() {

  if (analyzePressed && mouseHober(
        analyzeButton.position_x, analyzeButton.position_y,
        analyzeButton.width, analyzeButton.height)) {
    startDiarySentimentAnalysis();
  }
  analyzePressed = false;
  
  // 날씨 아이콘 클릭 처리 (오버레이가 없을 때만)
  if (weatherIcon != null && !isStickerLibraryOverlayVisible && isDatePickerVisible == 0) {
    int iconCount = weatherIcon.length;
    float baseIconSize = width * (40.0f / 1280.0f);
    float rightMargin = width * (300.0f / 1280.0f);
    float iconSpacing = width * (10.0f / 1280.0f);
    for (int i = 0; i < iconCount; i++) {
      float x_center = width - rightMargin - (baseIconSize / 2) - (i * (baseIconSize + iconSpacing));
      float y_center = navigationBarY / 2;

      // 선택되지 않은 아이콘을 클릭했는지 확인
      if (todayWeather != i && mouseHober(x_center - (baseIconSize * 0.875f) / 2, y_center - (baseIconSize * 0.875f) / 2, baseIconSize * 0.875f, baseIconSize * 0.875f)) {
        todayWeather = i;
        isDiaryModified = true;
        initWeatherEffects();
        return; // 한 번에 하나의 동작만 처리
      }
    }
  }
  
  if (isStickerLibraryOverlayVisible) {
    if (isDraggingScrollbar) {
      isDraggingScrollbar = false;
      return;
    }
    
    // 스크롤바 트랙 클릭
    if (minOverlayScrollY > 0 && mouseHober(scrollbarX, scrollbarY, scrollbarW, scrollbarH) && !mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) { // 스크롤바 섬이 아닌 트랙 클릭
      // 스크롤 이동
      float clickRatio = (mouseY - scrollbarY - thumbH / 2) / (scrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      overlayScrollY = clickRatio * minOverlayScrollY;
      return;
    }

    // 패널 영역 계산
    float panelX = width * (100.0f/1280.0f);
    float panelY = height * (100.0f/720.0f);
    float panelW = width - 2 * panelX;
    float panelH = height - 2 * panelY;

    // 패널 내부에서 클릭이 일어났는지 확인
    if (mouseHober(panelX, panelY, panelW, panelH)) {
      // 패널 내부 클릭 시, 세부 동작 처리
      handleStickerLibraryOverlayRelease();
    } else {
      // 패널 외부 클릭 시, 오버레이 닫기
      isStickerLibraryOverlayVisible = false;
      isStickerEditContextVisible = false; // 컨텍스트 메뉴도 함께 닫기
    }
    return;
  }

  if (isDatePickerVisible != 0) {
    handleDatePickerMouseRelease();
    return;
  }

  // 스티커가 삭제 존 위에서 놓아졌는지 확인합니다.
  if (currentlyDraggedSticker != null && isResizing == -1) { // 드래그 중인 스티커가 있고 크기 조절 중이 아닐 때
    float deleteZoneSize = 64;
    if (mouseHober(0, textFieldY - deleteZoneSize, deleteZoneSize, deleteZoneSize)) {
      placedStickers.remove(currentlyDraggedSticker); // 스티커 삭제
      isDiaryModified = true; // 스티커 삭제 시 수정됨
      selectedSticker = null; // 선택된 스티커도 초기화
    }
  }
  currentlyDraggedSticker = null; // 스티커 놓기
    isResizing = -1;

  if (finishPressed && mouseHober(
      finishButton.position_x, finishButton.position_y,
      finishButton.width,      finishButton.height)) {
         // 일기 보관함으로 이동하기 전에, 보관함의 달력을 현재 일기 날짜로 설정
         libraryCalendar.set(diary_year, diary_month - 1, 1);
         switchScreen(diary_library);
         saveDiary();
         loadDiaryDates();
       }

  if (storagePressed && mouseHober(
      stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height)) {
    isStickerLibraryOverlayVisible = true; isStickerEditContextVisible = false;
  }
  
  if (colorPickerPressed && mouseHober(
      diaryColorPicker.position_x, diaryColorPicker.position_y,
      diaryColorPicker.width, diaryColorPicker.height)) {
    UiBooster booster = new UiBooster(); // UI 부스터 객체 생성
    // 현재 네비게이션 바 색상을 기본값으로 설정 (RGB와 불투명 알파 255를 명시적으로 전달)
    java.awt.Color defaultColor = new java.awt.Color(
        round(red(diaryPaperColor)), round(green(diaryPaperColor)), round(blue(diaryPaperColor)), 255
    );
    java.awt.Color awtColor = booster.showColorPicker("Select Navigation Bar Color", "Choose a color for the navigation bar", defaultColor);
    if (awtColor != null) {
        color newColor = color(awtColor.getRed(), awtColor.getGreen(), awtColor.getBlue());
        if (newColor != diaryPaperColor) {
          diaryPaperColor = newColor;
          diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);
          isDiaryModified = true; // 색상 변경 시 수정됨
        }
    }
  }

  // 날짜 텍스트 클릭 시 달력 열기
  float[] dateRect = getDateTextRect();
  if (datePressed && mouseHober(dateRect[0], dateRect[1], dateRect[2], dateRect[3])) { openDatePickerDialog(); }
  
  finishPressed = false;
  colorPickerPressed = false;
  storagePressed = false;
  datePressed = false;
}

void handleStickerLibraryOverlayRelease() {
  
  float panelX = width * (100.0f/1280.0f);
  float panelY = height * (100.0f/720.0f);
  float panelW = width - 2 * panelX;
  float panelH = height - 2 * panelY;
  // [Added] If 'edit' context button is visible, handle its click first
  if (isStickerEditContextVisible && mouseButton == LEFT) {
    float bw = width * (72.0f/1280.0f);
    float bh = height * (36.0f/720.0f);
    float bx = editContextX;
    float by = editContextY;
    // bounds correction same as drawing
    if (bx + bw > panelX + panelW) bx = (panelX + panelW) - bw;
    if (by + bh > panelY + panelH) by = (panelY + panelH) - bh;
    if (bx < panelX) bx = panelX;
    if (by < panelY) by = panelY;
    if (mouseHober(bx, by, bw, bh)) {
// Mark that we came here via DrawingDiary overlay -> MakingSticker edit
returnToDiaryAfterEdit = true;
overlayWasVisibleBeforeEdit = isStickerLibraryOverlayVisible;

      if (editContextStickerIndex >= 0 && editContextStickerIndex < stickerLibrary.size()) {
        stickerToEdit = stickerLibrary.get(editContextStickerIndex);
        stickerCanvas.beginDraw();
        stickerCanvas.clear();
        stickerCanvas.image(stickerToEdit.img, 0, 0, canvasSize, canvasSize);
        stickerCanvas.endDraw();
      }
      isStickerEditContextVisible = false;
      switchScreen(making_sticker);
      return;
    } else {
      // clicked somewhere else -> just close the small button, keep overlay
      isStickerEditContextVisible = false;
      // do not return; allow other clicks (e.g., close button) to be processed
    }
  }

  // 닫기 버튼 클릭
  if (mouseHober(panelX + panelW - width*(50.0f/1280.0f), panelY + height*(10.0f/720.0f), width*(40.0f/1280.0f), height*(40.0f/720.0f))) { // 닫기 버튼 영역
    isStickerLibraryOverlayVisible = false;
    return;
  }

  // 스티커 클릭 시 일기장에 추가
  float boxSize = width * (100.0f/1280.0f);
  float spacing = width * (120.0f/1280.0f);
  int startX = (int)(panelX + 80);   // drawStickerLibraryOverlay와 동일한 값 사용
  int startY = (int)(panelY + 130);  // drawStickerLibraryOverlay와 동일한 값 사용
  int cols = floor((panelW - 100) / spacing);
  
  for (int i = 0; i < stickerLibrary.size(); i++) {
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;

    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY;
    PVector newSize = getScaledImageSize(s.img, boxSize);

    // 스티커가 보이는 영역(패널) 안에 있을 때만 클릭 처리
    boolean isStickerVisible = (stickerY + newSize.y/2 > panelY + height*(80.0f/720.0f)) && (stickerY - newSize.y/2 < panelY + panelH); // 스티커가 패널 내부에 보이는지 확인

    
    if (isStickerVisible && mouseHober(stickerX - newSize.x / 2, stickerY - newSize.y / 2, newSize.x, newSize.y)) {
      if (mouseButton == RIGHT) {
        // show small 'edit' button near cursor; keep overlay open
        isStickerEditContextVisible = true;
        editContextStickerIndex = i;
        editContextX = mouseX + 8;
        editContextY = mouseY + 8;
        return;
      } else {
        // LEFT click: place sticker into diary at clicked position (Y constrained above text area)
        PVector displaySize = getScaledImageSize(s.img, defaultStickerSize);
        float placeX = mouseX;
        float placeY = constrain(mouseY, 0 + displaySize.y/2, textFieldY - displaySize.y/2);
        Sticker newSticker = new Sticker(placeX, placeY, s.img, defaultStickerSize, s.imageName);
        isDiaryModified = true; 
        placedStickers.add(newSticker);
        selectedSticker = newSticker;
        isStickerEditContextVisible = false;
        isStickerLibraryOverlayVisible = false; 
        return;
      }
    }

  }
}


float[] getDateTextRect() {
  pushStyle();
  textSize(30);
  String dateString = "Date : " + diary_year + ". " + diary_month + ". " + diary_day;
  float dateTextW = textWidth(dateString); // 날짜 텍스트 너비
  float dateTextH = 30; // 대략적인 높이
  
  // drawDiary()와 동일한 로직으로 중앙 좌표를 계산합니다.
  float dateTextCenterX = width/2 - width * (120.0f/1280.0f);
  float dateTextCenterY = height * (30.0f/720.0f);
  
  float dateRectX = dateTextCenterX - dateTextW / 2;
  float dateRectY = dateTextCenterY - dateTextH / 2;
  popStyle();
  return new float[] { dateRectX, dateRectY, dateTextW, dateTextH };
}


void openDatePickerDialog() {
  if (datePickerCalendar == null) {
    datePickerCalendar = (Calendar) calendar.clone();
  } else { 
    // 열 때마다 현재 일기 날짜로 달력을 동기화
    datePickerCalendar.setTime(calendar.getTime());
  }

  datePickerX = width/2 - datePickerWidth/2;
  datePickerY = navigationBarY + 10;
  isDatePickerVisible = 1;
}

void closeDatePickerDialog() { // 달력 닫기
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

  textAlign(CENTER, CENTER); // 텍스트 중앙 정렬
  fill(0);
  textSize(20);
  String monthString = monthToString(datePickerCalendar.get(Calendar.MONTH));


  text(datePickerCalendar.get(Calendar.YEAR) + " " + monthString, datePickerX + datePickerWidth / 2, datePickerY + height*(30.0f/720.0f));

  // 이전/다음 달 화살표
  textSize(24);
  text("<", datePickerX + width*(30.0f/1280.0f), datePickerY + height*(30.0f/720.0f)); // 이전 달
  text(">", datePickerX + datePickerWidth - width*(30.0f/1280.0f), datePickerY + height*(30.0f/720.0f)); // 다음 달

  // 요일 레이블
  String[] daysOfWeek = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  textSize(14); // 요일 텍스트 크기
  float cellWidth = datePickerWidth / 7.0;
  for (int i = 0; i < 7; i++) {
    fill(i == 0 ? color(200, 0, 0) : 0); // 일요일 
    text(daysOfWeek[i], datePickerX + cellWidth * i + cellWidth / 2, datePickerY + height*(70.0f/720.0f));
  }

  // 날짜 그리드
  Calendar tempCal = (Calendar) datePickerCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);

  int day = 1;
  float cellHeight = (datePickerHeight - height*(100.0f/720.0f)) / 6.0; // 날짜 셀 높이
  textSize(16);

  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue; // 1일 이전
      if (day > maxDaysInMonth) break; // 마지막 날짜를 넘어가면 중단

      float x = datePickerX + col * cellWidth;
      float y = datePickerY + height*(90.0f/720.0f) + row * cellHeight; // 날짜 셀 Y 좌표
      
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
      }
      fill(col == 0 ? color(200, 0, 0) : 0);
      text(day, x + cellWidth / 2, y + cellHeight / 2);
      day++;
    }
  }
  float arrowArea = width*(60.0f/1280.0f);
  if (mouseHober(datePickerX, datePickerY, arrowArea, arrowArea)) {
    noStroke();
    fill(150,100);
    rect(datePickerX, datePickerY, arrowArea, arrowArea, 4);
  }
  else if (mouseHober(datePickerX + datePickerWidth - arrowArea, datePickerY, arrowArea, arrowArea)) {
    noStroke();
    fill(150,100);
    rect(datePickerX + datePickerWidth - arrowArea, datePickerY, arrowArea, arrowArea, 4);
  }
  if (mouseHober(datePickerX + datePickerWidth / 2 - width*(60.0f/1280.0f), datePickerY, width*(128.0f/1280.0f), height*(64.0f/720.0f))) {
    noStroke();
    fill(150,100);
    rect(datePickerX + datePickerWidth / 2 - width*(58.0f/1280.0f), datePickerY+height*(8.0f/720.0f), width*(128.0f/1280.0f), height*(48.0f/720.0f), 12);
  }

  // 닫기 버튼
  float backBtnW = 100;
  float backBtnH = 30;
  float backBtnX = datePickerX + (datePickerWidth - backBtnW) / 2;
  float backBtnY = datePickerY + datePickerHeight - backBtnH - 10;

  if (mouseHober(backBtnX, backBtnY, backBtnW, backBtnH)) {
      fill(220, 220, 220);
  } else {
      fill(235, 235, 235);
  }
  stroke(150);
  rect(backBtnX, backBtnY, backBtnW, backBtnH, 5);

  fill(0);
  textSize(16);
  text("Back", backBtnX + backBtnW / 2, backBtnY + backBtnH / 2);
  popStyle();
}
void openYearMonthPicker() {
  Calendar base = (datePickerCalendar != null) ? datePickerCalendar : calendar;
  yearPicker  = base.get(Calendar.YEAR);
  monthPicker = base.get(Calendar.MONTH) + 1;

  yearmonthScrollX = width/2;
  yearmonthScrollY = height/2;

  yearmonthScrollW = round(width * (480.0f/1280.0f));
  yearmonthScrollH = round(height * (240.0f/720.0f));

  yearPickerX = yearmonthScrollX - width * (96.0f/1280.0f);
  yearmonthY = yearmonthScrollY;
  isDatePickerVisible = 2;

  yearmonthScrollX = width/2-yearmonthScrollW/2;
  yearmonthScrollY = height/2-yearmonthScrollH/2;
  initYearMonthButton(); 
}
void initYearMonthButton() {
  yearmonthOK = new rectButton(this, round(yearmonthScrollX-yearmonthButtonA+width*(240.0f/1280.0f)), round(yearmonthScrollY+yearmonthScrollH-height*(32.0f/720.0f)), round(width*(48.0f/1280.0f)), round(height*(24.0f/720.0f)), #FBDAB0); // 확인 버튼
  yearmonthOK.rectButtonText("OK", 18);
  yearmonthOK.setShadow(false);
  yearmonthCancle = new rectButton(this, round(yearmonthScrollX+yearmonthButtonA+width*(240.0f/1280.0f)), round(yearmonthScrollY+yearmonthScrollH-height*(32.0f/720.0f)), round(width*(48.0f/1280.0f)), round(height*(24.0f/720.0f)), #D9D9D9);
  yearmonthCancle.rectButtonText("Cancle", 18);
  yearmonthCancle.setShadow(false);
}


void drawYearMonthPicker() {
  pushStyle();
  fill(0, 150);
  rect(0, 0, width, height);
  rectMode(CORNER);
  stroke(#D9D9D9);
  strokeWeight(1);
  fill(255);
  rect(yearmonthScrollX,yearmonthScrollY,yearmonthScrollW,yearmonthScrollH,24);
  noStroke();
  fill(#FBDAB0); 
  rect(yearmonthScrollX,yearmonthScrollY,width*(64.0f/1280.0f),yearmonthScrollH,24,0,0,24);
  fill(#DBFDB4); 
  rect(yearmonthScrollX+width*(64.0f/1280.0f),yearmonthY-height*(24.0f/720.0f),yearmonthScrollW-width*(64.0f/1280.0f),height*(48.0f/720.0f));
  fill(0);
  textAlign(CENTER,CENTER);
  if (nowDragInPicker == 0) { // 드래그 중이 아닐 때
    text(yearPicker, yearPickerX, yearmonthY);  

    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY);

    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY-height*(48.0f/720.0f));
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY+height*(48.0f/720.0f));

    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-height*(48.0f/720.0f)); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+height*(48.0f/720.0f)); }
  }
  
  else if (nowDragInPicker == 1) {

    text(yearPicker, yearPickerX, yearmonthY + set*height*(4.8f/720.0f));  

    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY);

    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY-height*(48.0f/720.0f));
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY+height*(48.0f/720.0f));

    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-height*(48.0f/720.0f) + set*height*(4.8f/720.0f)); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+height*(48.0f/720.0f) + set*height*(4.8f/720.0f)); }

  } 
  else if (nowDragInPicker == 2) {

    text(yearPicker, yearPickerX, yearmonthY);  // 선택 년도

    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY + set*height*(4.8f/720.0f));

    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY-height*(48.0f/720.0f) + set*height*(4.8f/720.0f));
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY+height*(48.0f/720.0f) + set*height*(4.8f/720.0f));

    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-height*(48.0f/720.0f)); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+height*(48.0f/720.0f)); }
    
  } 
  text("|",yearmonthScrollX+width*(32.0f/1280.0f)+yearmonthScrollW/2,yearmonthY);
  fill(150);
  if (yearmonthOK != null) {
    yearmonthOK.render();
  }
  if (yearmonthCancle != null) {
   yearmonthCancle.render();  
  }
   popStyle();


}
void handleDatePickerMouse() {
  if (isDatePickerVisible == 2) { // 년도 설정창이 열려있으면
    handleYearMonthMouse();
    return;
  }
  // 달력 클릭 로직 (이전/다음 달, 날짜 선택 등)
}

void handleYearMonthMouse() {  // 년도 설정창 클릭
  if (nowDragInPicker == 0) {
    if (mouseHober(yearPickerX-width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) {
      nowDragInPicker = 1;
      return;
    }
    if (mouseHober(yearmonthScrollX+yearmonthScrollW/2+width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) {
      nowDragInPicker = 2;
      return;
    }
  }
  // 년도/월 선택 로직
}

void handleDatePickerDrag() {
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
      if (yearPicker > 0) yearPicker--; // 년도 감소
    } else if (nowDragInPicker == 2) {
      monthPicker--;
      if (monthPicker < 1) monthPicker = 12; // 월 감소 (1월 미만이면 12월로)
    }
    set = 0;
  }
  if (set <= -10) {
    if (nowDragInPicker == 1) { // 년도
      if (yearPicker < 9999) yearPicker++;
    } else if (nowDragInPicker == 2) {
      monthPicker++;
      if (monthPicker > 12) monthPicker = 1; // 월 증가 (12월 초과면 1월로)
    }
    set = 0;
  }
}
void handleDatePickerMouseRelease() {
  float cellWidth = datePickerWidth / 7.0;
  if ((isDatePickerVisible == 2)) {
    
    if (yearmonthOK != null &&
        mouseHober(yearmonthOK.position_x, yearmonthOK.position_y, yearmonthOK.width, yearmonthOK.height)) {
      datePickerCalendar.set(yearPicker, monthPicker - 1, 1);
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

  // 닫기 버튼 클릭
  float backBtnW = 100;
  float backBtnH = 30;
  float backBtnX = datePickerX + (datePickerWidth - backBtnW) / 2;
  float backBtnY = datePickerY + datePickerHeight - backBtnH - 10;
  if (mouseHober(backBtnX, backBtnY, backBtnW, backBtnH)) {
      closeDatePickerDialog();
      return;
  }

  // 이전 달 화살표
  float arrowArea = width*(60.0f/1280.0f);
  if (mouseHober(datePickerX, datePickerY, arrowArea, arrowArea)) {
    datePickerCalendar.add(Calendar.MONTH, -1);
    return;
  }
  // 다음 달 화살표
  if (mouseHober(datePickerX + datePickerWidth - arrowArea, datePickerY, arrowArea, arrowArea)) {
    datePickerCalendar.add(Calendar.MONTH, 1);
    return;
  }
  // 년도/월 텍스트 클릭
  if (mouseHober(datePickerX + datePickerWidth / 2 - width*(60.0f/1280.0f), datePickerY, width*(128.0f/1280.0f), height*(64.0f/720.0f))) {
    openYearMonthPicker();
    return;
  }

  // 날짜 클릭 확인
  Calendar tempCal = (Calendar) datePickerCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);
  int day = 1;
  float cellHeight = (datePickerHeight - height*(100.0f/720.0f)) / 6.0;

  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue;
      if (day > maxDaysInMonth) break;

      float x = datePickerX + col * cellWidth;
      float y = datePickerY + height*(90.0f/720.0f) + row * cellHeight;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        // 날짜 선택 및 적용
        int newYear = datePickerCalendar.get(Calendar.YEAR);
        int newMonth = datePickerCalendar.get(Calendar.MONTH) + 1;
        int newDay = day;

        if (newYear != diary_year || newMonth != diary_month || newDay != diary_day) {
          isDiaryModified = true;
        }
        diary_year = newYear;
        diary_month = newMonth;
        diary_day = newDay;

        // 메인 calendar 업데이트
        calendar.set(diary_year, diary_month - 1, diary_day);
        closeDatePickerDialog();
        return;
      }
      day++;
    }
  }
  
  // 달력 바깥 영역 클릭 시 닫기
  if ((!mouseHober(datePickerX, datePickerY, datePickerWidth, datePickerHeight))&&(isDatePickerVisible == 1)) {
    closeDatePickerDialog();
  }

if ((!mouseHober(yearmonthScrollX, yearmonthScrollY, yearmonthScrollW, yearmonthScrollH))&&(isDatePickerVisible == 2)) {
    isDatePickerVisible = 1;
  }
}
void handleDrawingDiaryMouseWheel(MouseEvent ev) {
  // hide edit chip on scroll
  isStickerEditContextVisible = false;

  if (isStickerLibraryOverlayVisible) { // 스티커 보관함 오버레이가 열려있을 때
    if (mouseHober(width*(130.0f/1280.0f), height*(164.0f/720.0f), width - width*(270.0f/1280.0f), height - height*(280.0f/720.0f))) {
      float scrollAmount = ev.getCount() * 10; // 스크롤 속도
      overlayScrollY = constrain(overlayScrollY + scrollAmount, 0, minOverlayScrollY);
    }
  }


  if (isDatePickerVisible == 2) { // 년도/월 선택기가 열려있을 때
    if (mouseHober(yearPickerX-width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) {
      yearPicker -= ev.getCount();
      yearPicker = constrain(yearPicker, 1, 9998);
    }
    if (mouseHober(yearmonthScrollX+yearmonthScrollW/2+width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) { // 월 선택 영역
      monthPicker -= ev.getCount();
      monthPicker = clampMonth1to12(monthPicker);
    }
  }
}



void handleYearMonthMouseRelease() {
  if (nowDragInPicker != 0) { // 드래그 중이었다면
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
  // 같은 날짜의 기존 일기 삭제
  File diaryFolder = new File(dataPath("diaries"));
  String filePrefix = "diary_" + diary_year + "_" + diary_month + "_" + diary_day + "_";

  if (diaryFolder.exists() && diaryFolder.isDirectory()) {
    File[] files = diaryFolder.listFiles();
    if (files != null) {
      for (File file : files) {
        if (file.getName().startsWith(filePrefix) && file.getName().endsWith(".json")) {
          println("Deleting old diary file: " + file.getName());
          if (!file.delete()) {
            println("Warning: Failed to delete old diary file: " + file.getName());
          }
        }
      }
    }
  }

  JSONObject diaryData = new JSONObject();

  // 색상 저장
  diaryData.setInt("paperColor", diaryPaperColor);
  diaryData.setInt("backgroundColor", diaryBackgroundColor);
  
  // Save weather
  diaryData.setInt("weather", todayWeather);

  diaryData.setString("title", titleArea.getText());
  diaryData.setString("content", textArea.getText());

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

  String newFileName = "diary_" + diary_year + "_" + diary_month + "_" + diary_day + "_(" + (lastSentimentScore * 10) + ").json";
  saveJSONObject(diaryData, "data/diaries/" + newFileName);
  println("Diary saved to data/diaries/" + newFileName);
}

// 일기 로드
void loadDiary(int year, int month, int day) {
  File diaryFolder = new File(dataPath("diaries"));
  String filePrefix = "diary_" + year + "_" + month + "_" + day;
  String foundFilePath = null;

  if (diaryFolder.exists() && diaryFolder.isDirectory()) {
    File[] files = diaryFolder.listFiles();
    if (files != null) {
      for (File file : files) {
        if (file.getName().startsWith(filePrefix) && file.getName().endsWith(".json")) {
          foundFilePath = file.getAbsolutePath();
          break;
        }
      }
    }
  }
  
  JSONObject diaryData = loadJSONObject(foundFilePath);
  if (diaryData == null) {
    println("Failed to load or parse diary file: " + foundFilePath);
    return;
  }
  
  // 현재 일기 상태 초기화
  placedStickers.clear();
  // 스티커 선택/조작 상태 초기화
  selectedSticker = null;
  currentlyDraggedSticker = null;
  isResizing = -1;
  resizeAnchor.set(0, 0);

  titleArea.setText(diaryData.getString("title", ""));
  textArea.setText(diaryData.getString("content", ""));
  
  // 일기 날짜 업데이트
  diary_year = year;
  diary_month = month;
  diary_day = day;
  calendar.set(diary_year, diary_month - 1, diary_day);

  // 색상 로드 (이전 파일 호환을 위한 기본값 포함)
  color defaultPaperColor = color(251, 218, 176); 
  color defaultBackgroundColor = lerpColor(defaultPaperColor, color(255), 0.8);

  diaryPaperColor = diaryData.getInt("paperColor", defaultPaperColor);
  diaryBackgroundColor = diaryData.getInt("backgroundColor", defaultBackgroundColor);

  // Load weather, with a default if not present
  todayWeather = diaryData.getInt("weather", 0); // Default to sunny (0) if not saved
  
  // Load Emotion

  lastSentimentScore = -1.0f;
  lastSentimentLabel = "";
  if (foundFilePath != null && foundFilePath.contains("(") && foundFilePath.contains(")")) {
    int startIndex = foundFilePath.indexOf('(') + 1;
    int endIndex = foundFilePath.lastIndexOf(')');

	if (startIndex > 0 && endIndex > startIndex) {
      try {
        String scoreStr = foundFilePath.substring(startIndex, endIndex);
        lastSentimentScore = Float.parseFloat(scoreStr) / 10.0f;
        lastSentimentLabel = labelFromScore(lastSentimentScore);
      } catch (NumberFormatException e) {
        println("Warning: Could not parse sentiment score from filename: " + foundFilePath);
      }
    }
  }
  
  // 스티커 로드
  JSONArray stickerArray = diaryData.getJSONArray("stickers");
  if (stickerArray != null) {
    for (int i = 0; i < stickerArray.size(); i++) {
      JSONObject stickerData = stickerArray.getJSONObject(i);
      
      String imageName = stickerData.getString("imageName");
      float x = stickerData.getFloat("x");
      float y = stickerData.getFloat("y");
      float size = stickerData.getFloat("size");
      
      PImage stickerImg = null;
      for (Sticker libSticker : stickerLibrary) { // 스티커 라이브러리에서 이미지 찾기
        if (libSticker.imageName.equals(imageName)) {
          stickerImg = libSticker.img;
          break;
        }
      }
      
      if (stickerImg == null) {
        println("Sticker image not found in library: " + imageName + ". Trying to load from file."); // 라이브러리에 없으면 파일에서 로드 시도
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
  
  initWeatherEffects();
  isDiaryModified = false; // 일기 로드 후 수정 상태 초기화
  println("Diary loaded for " + year + "-" + month + "-" + day);
}

void resetDiary() {
  // 텍스트 필드 초기화
  if (titleArea != null) {
    titleArea.setText("");
  }
  if (textArea != null) {
    textArea.setText("");
  }
  
  // 날짜를 오늘 날짜로 초기화
  calendar = Calendar.getInstance(); // 오늘 날짜로 새로고침
  diary_year = calendar.get(Calendar.YEAR);
  diary_month = calendar.get(Calendar.MONTH) + 1;
  diary_day = calendar.get(Calendar.DAY_OF_MONTH);
  
  // 스티커 관련 모든 상태 초기화
  if (placedStickers != null) {
    placedStickers.clear();
  }
  selectedSticker = null;
  currentlyDraggedSticker = null;
  isResizing = -1;
  resizeAnchor.set(0, 0); // 스티커 리사이즈 기준점 초기화

  // 감정 분석 상태 초기화
  lastSentimentScore = -1;
  lastSentimentLabel = "";    // 표시용

  // 날씨를 현재 날씨로 다시 가져오기
  todayWeather = getWeather();

  // 색상 초기화
  diaryPaperColor = color(251, 218, 176);
  diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);
  initWeatherEffects();
  isDiaryModified = false; // 새 일기 시작 시 수정 상태 초기화
  
  
  println("Diary has been reset for a new entry.");
}

void startDiarySentimentAnalysis() {
  if (isAnalyzing) return;
  isAnalyzing = true;

  final String text = (textArea != null) ? textArea.getText() : "";

  new Thread(new Runnable() {
    public void run() {
      SentimentResult r = EA_analyzeText(text);         // ← EmotionAnalysisAPI.pde
      lastSentimentScore = r.score01;
      lastSentimentLabel = r.label;

      String key = makeDateKey(diary_year, diary_month, diary_day); // 날짜 키 생성
      diarySentiments.put(key, lastSentimentScore);

      isDiaryModified = true; // 감정 분석 결과가 나오면 수정된 것으로 간주

      isAnalyzing = false;
      println("[Sentiment] " + key + " -> " + r.label + " (" + nf(lastSentimentScore,1,2) + ")");
    }
  }).start();
}