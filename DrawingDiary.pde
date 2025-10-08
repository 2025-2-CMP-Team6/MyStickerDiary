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

boolean isDatePickerVisible = false;
Calendar datePickerCalendar; 
int datePickerWidth = 300;
int datePickerHeight = 280;
int datePickerX;
int datePickerY;

boolean datePressed = false;

int diary_day = calendar.get(Calendar.DAY_OF_MONTH);
int diary_month = calendar.get(Calendar.MONTH) + 1;
int diary_year = calendar.get(Calendar.YEAR);

void drawDiary() {

  pushStyle();
  background(255, 250, 220);
  rectMode(TOP);
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
  if (isDatePickerVisible) {
    drawDatePicker();
  }
}
  
void updateTextUIVisibility() {
  boolean onDiary = (currentScreen == drawing_diary);
  if (textArea != null) {
    titleArea.setVisible(onDiary);
    titleArea.setEnabled(onDiary);
    textArea.setVisible(onDiary);
    textArea.setEnabled(onDiary);
  }
  
}
void handleDiaryMouse() { // 마우스를 처음 눌렀을 때 호출

  // 날짜 선택기가 활성화되어 있으면, 다른 UI 요소와의 상호작용을 막습니다.
  if (isDatePickerVisible) {
    // 클릭 처리는 mouseReleased에서 하므로 여기서는 아무것도 하지 않고 반환합니다.
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

  storagePressed = mouseHober(stickerStoreButton.position_x, stickerStoreButton.position_y,
    stickerStoreButton.width, stickerStoreButton.height);
  
  finishPressed = mouseHober(
    finishButton.position_x, finishButton.position_y,
    finishButton.width, finishButton.height
  );

  datePressed = mouseHober(
    dateButton.position_x, dateButton.position_y,
    dateButton.width, dateButton.height
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
  
  // 날짜 선택기가 활성화되어 있으면, 날짜 선택기 관련 클릭만 처리합니다.
  if (isDatePickerVisible) {
    handleDatePickerMouseRelease();
    return;
  }

  currentlyDraggedSticker = null; // 스티커 놓기
    isResizing = -1;

  if (finishPressed && mouseHober(
      finishButton.position_x, finishButton.position_y,
      finishButton.width,      finishButton.height)) { switchScreen(diary_library); }

  if (storagePressed && mouseHober(
      stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height)) { switchScreen(sticker_library); }

  if (datePressed && mouseHober(
      dateButton.position_x, dateButton.position_y,
      dateButton.width, dateButton.height)) { openDatePickerDialog(); }

  finishPressed = false;
  storagePressed = false;
  datePressed = false;

}

void openDatePickerDialog() {
  if (datePickerCalendar == null) {
    datePickerCalendar = (Calendar) calendar.clone();
  } else {
    // 열 때마다 현재 일기 날짜로 달력을 동기화
    datePickerCalendar.setTime(calendar.getTime());
  }
  datePickerX = DATE_X;
  datePickerY = DATE_Y+DATE_H;
  isDatePickerVisible = true;
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
  String monthString;
  switch (datePickerCalendar.get(Calendar.MONTH)) { // 달 string 으로
    case 0:
      monthString = "Jan";
      break;
    case 1:
      monthString = "Feb";
      break;
    case 2:
      monthString = "Mar";
      break;
    case 3:
      monthString = "Apr";
      break;
    case 4:
      monthString = "May";
      break;
    case 5:
      monthString = "Jun";
      break;
    case 6:
      monthString = "Jul";
      break;
    case 7:
      monthString = "Aug";
      break;
    case 8:
      monthString = "Sep";
      break;
    case 9:
      monthString = "Oct";
      break;
    case 10:
      monthString = "Nov";
      break;
    case 11:
      monthString = "Dec";
      break;
    default:
      monthString = "";
      break;
  }
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
      
      // 마우스 호버 효과
      if (mouseHober(x, y, cellWidth, cellHeight)) {
        noFill();
        stroke(0, 100);
        strokeWeight(1);
        rect(x+2, y+2, cellWidth-4, cellHeight-4, 4);
      }
      else if (mouseHober(datePickerX, datePickerY, 60, 60)) {
        noStroke();
        fill(0,50);
        rect(datePickerX, datePickerY, 60, 60, 4);
      }
      else if (mouseHober(datePickerX + datePickerWidth - 60, datePickerY, 60, 60)) {
        noStroke();
        fill(0,50);
        rect(datePickerX + datePickerWidth - 60, datePickerY, 60, 60, 4);
      }
      
      fill(col == 0 ? color(200, 0, 0) : 0); // 일요일 날짜는 빨간색
      text(day, x + cellWidth / 2, y + cellHeight / 2);
      day++;
    }
  }
  popStyle();
}

void handleDatePickerMouseRelease() {
  float cellWidth = datePickerWidth / 7.0;

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

        isDatePickerVisible = false;
        return;
      }
      day++;
    }
  }
  
  // 달력 바깥 영역을 클릭하면 닫기
  if (!mouseHober(datePickerX, datePickerY, datePickerWidth, datePickerHeight)) {
      isDatePickerVisible = false;
  }
}