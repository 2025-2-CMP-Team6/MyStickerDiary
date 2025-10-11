import java.util.HashSet;

Calendar libraryCalendar;
HashSet<String> diaryDates;

int libraryPickerState = 0; // 0: hidden, 1: year/month picker visible
int libYearPicker, libMonthPicker;
rectButton libYearMonthOK, libYearMonthCancle;
int libYearmonthScrollX, libYearmonthScrollY, libYearmonthScrollW, libYearmonthScrollH;
float libYearPickerX, libYearmonthY;
int libNowDragInPicker = 0; // 0: none, 1: year, 2: month
int libSet = 0;
int libYearmonthButtonA = 96;

void initDiaryLibrary() {
  libraryCalendar = Calendar.getInstance();
  
  backToMenuButton = new rectButton(20, 20, 150, 50, #DDDDDD);
  backToMenuButton.rectButtonText("Back to Menu", 18);
  backToMenuButton.setShadow(false);

  prevMonthButton = new rectButton(width/2 - 200, 80, 40, 40, #EEEEEE);
  prevMonthButton.rectButtonText("<", 24);
  prevMonthButton.setShadow(false);
  
  nextMonthButton = new rectButton(width/2 + 160, 80, 40, 40, #EEEEEE);
  nextMonthButton.rectButtonText(">", 24);
  nextMonthButton.setShadow(false);
}

void loadDiaryDates() {
  if (diaryDates == null) {
    diaryDates = new HashSet<String>();
  }
  diaryDates.clear();
  File diaryFolder = new File(dataPath("diaries"));
  
  if (!diaryFolder.exists()) {
    diaryFolder.mkdirs();
  }
  
  File[] files = diaryFolder.listFiles();
  if (files != null) {
    for (File file : files) {
      String name = file.getName();
      if (name.startsWith("diary_") && name.endsWith(".json")) {
        String[] parts = name.substring(6, name.length() - 5).split("_");
        if (parts.length == 3) {
          String dateKey = parts[0] + "-" + Integer.parseInt(parts[1]) + "-" + Integer.parseInt(parts[2]);
          diaryDates.add(dateKey);
        }
      }
    }
  }
}

void openLibYearMonthPicker() {
  libYearPicker = libraryCalendar.get(Calendar.YEAR);
  libMonthPicker = libraryCalendar.get(Calendar.MONTH) + 1;

  libYearmonthScrollW = 480;
  libYearmonthScrollH = 240;
  libYearmonthScrollX = width/2 - libYearmonthScrollW/2;
  libYearmonthScrollY = height/2 - libYearmonthScrollH/2;

  libYearPickerX = libYearmonthScrollX + 160;
  libYearmonthY = libYearmonthScrollY + libYearmonthScrollH/2;
  
  libraryPickerState = 1;
  initLibYearMonthButton();
}

void initLibYearMonthButton() {
  libYearMonthOK = new rectButton(libYearmonthScrollX + libYearmonthScrollW/2 - libYearmonthButtonA/2 - 30, libYearmonthScrollY + libYearmonthScrollH - 48, 60, 24, #FBDAB0);
  libYearMonthOK.rectButtonText("OK", 18);
  libYearMonthOK.setShadow(false);
  libYearMonthCancle = new rectButton(libYearmonthScrollX + libYearmonthScrollW/2 + libYearmonthButtonA/2, libYearmonthScrollY + libYearmonthScrollH - 48, 70, 24, #D9D9D9);
  libYearMonthCancle.rectButtonText("Cancel", 18);
  libYearMonthCancle.setShadow(false);
}

void drawLibYearMonthPicker() {
  pushStyle();
  fill(0, 150);
  rect(0, 0, width, height);
  
  rectMode(CORNER);
  stroke(#D9D9D9);
  strokeWeight(1);
  fill(255);
  rect(libYearmonthScrollX, libYearmonthScrollY, libYearmonthScrollW, libYearmonthScrollH, 24);
  noStroke();
  fill(#FBDAB0);
  rect(libYearmonthScrollX, libYearmonthScrollY, 64, libYearmonthScrollH, 24, 0, 0, 24);
  fill(#DBFDB4);
  rect(libYearmonthScrollX + 64, libYearmonthY - 24, libYearmonthScrollW - 64, 48);

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);

  float yearTextY = libYearmonthY;
  float monthTextY = libYearmonthY;
  
  if (libNowDragInPicker == 1) {
    yearTextY += libSet * 4.8;
  } else if (libNowDragInPicker == 2) {
    monthTextY += libSet * 4.8;
  }

  text(libYearPicker, libYearPickerX, yearTextY);
  fill(125);
  if (libYearPicker > 0)    text(libYearPicker - 1, libYearPickerX, yearTextY - 48);
  if (libYearPicker < 9999) text(libYearPicker + 1, libYearPickerX, yearTextY + 48);

  fill(0);
  text(monthToString(monthToIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + 96, monthTextY);
  fill(125);
  text(monthToString(prevMonthIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + 96, monthTextY - 48);
  text(monthToString(nextMonthIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + 96, monthTextY + 48);

  fill(0);
  text("|", libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthY);

  libYearMonthOK.render();
  libYearMonthCancle.render();
  
  popStyle();
}

void drawDiaryLibrary() {
   background(255, 250, 240); 
   
   backToMenuButton.render();
   prevMonthButton.render();
   nextMonthButton.render();

   if (libraryPickerState == 0 && mouseHober(width/2 - 150, 80, 300, 40)) {
     fill(230, 230, 230, 200);
     noStroke();
     rect(width/2 - 150, 80, 300, 40, 5);
   }

   textAlign(CENTER, CENTER);
   fill(0);
   textSize(32);
   String monthName = monthToString(libraryCalendar.get(Calendar.MONTH));
   text(libraryCalendar.get(Calendar.YEAR) + " " + monthName, width/2, 100);

   drawCalendarGrid();

   if (libraryPickerState == 1) {
     drawLibYearMonthPicker();
   }
}

void drawCalendarGrid() {
  pushStyle();
  
  int calX = 100;
  int calY = 150;
  int calWidth = width - 200;
  int calHeight = height - 200;

  float cellWidth = calWidth / 7.0;
  float cellHeight = (float)calHeight / 6.0;

  String[] daysOfWeek = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  textSize(16);
  for (int i = 0; i < 7; i++) {
    fill(i == 0 ? color(200, 0, 0) : 0);
    textAlign(CENTER, TOP);
    text(daysOfWeek[i], calX + i * cellWidth + cellWidth / 2, calY);
  }

  Calendar tempCal = (Calendar) libraryCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);

  int day = 1;
  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) {
        continue;
      }
      if (day > maxDaysInMonth) {
        break;
      }

      float x = calX + col * cellWidth;
      float y = calY + 25 + row * cellHeight;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        stroke(100, 100, 255, 150);
        strokeWeight(3);
        noFill();
        rect(x, y, cellWidth, cellHeight);
      } else {
        stroke(220);
        strokeWeight(1);
        fill(255);
        rect(x, y, cellWidth, cellHeight);
      }

      String dateKey = tempCal.get(Calendar.YEAR) + "-" + (tempCal.get(Calendar.MONTH) + 1) + "-" + day;
      if (diaryDates != null && diaryDates.contains(dateKey)) {
        fill(#FFCA1A);
        noStroke();
        ellipse(x + cellWidth - 20, y + 20, 15, 15);
      }

      textAlign(LEFT, TOP);
      fill(col == 0 ? color(200, 0, 0) : 0);
      textSize(18);
      text(day, x + 10, y + 10);

      day++;
    }
    if (day > maxDaysInMonth) {
      break;
    }
  }
  
  popStyle();
}

void handleDiaryLibraryMousePressed() {
  if (libraryPickerState == 1) {
    handleLibYearMonthMousePressed();
    return;
  }

  backToMenuButton.onPress(mouseX, mouseY);
  prevMonthButton.onPress(mouseX, mouseY);
  nextMonthButton.onPress(mouseX, mouseY);

}

void handleDiaryLibraryMouseReleased() {
  if (libraryPickerState == 1) {
    handleLibYearMonthMouseReleased();
    return;
  }
  if (backToMenuButton.onRelease(mouseX, mouseY)) {
    switchScreen(menu_screen);
    return;
  }
  if (prevMonthButton.onRelease(mouseX, mouseY)) {
    libraryCalendar.add(Calendar.MONTH, -1);
    return;
  }
  if (nextMonthButton.onRelease(mouseX, mouseY)) {
    libraryCalendar.add(Calendar.MONTH, 1);
    return;
  }
  if (mouseHober(width/2 - 150, 80, 300, 40)) {
    openLibYearMonthPicker();
  }

  // 달력 날짜 클릭 확인
  int calX = 100;
  int calY = 150;
  int calWidth = width - 200;
  int calHeight = height - 200;
  float cellWidth = calWidth / 7.0;
  float cellHeight = (float)calHeight / 6.0;

  Calendar tempCal = (Calendar) libraryCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);

  int day = 1;
  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue;
      if (day > maxDaysInMonth) break;

      float x = calX + col * cellWidth;
      float y = calY + 25 + row * cellHeight;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        int clickedYear = libraryCalendar.get(Calendar.YEAR);
        int clickedMonth = libraryCalendar.get(Calendar.MONTH) + 1;
        String dateKey = clickedYear + "-" + clickedMonth + "-" + day;

        if (diaryDates != null && diaryDates.contains(dateKey)) {
          loadDiary(clickedYear, clickedMonth, day);
          switchScreen(drawing_diary);
          return;
        }
      }
      day++;
    }
    if (day > maxDaysInMonth) break;
  }
}

void handleLibYearMonthMousePressed() {
  libYearMonthOK.onPress(mouseX, mouseY);
  libYearMonthCancle.onPress(mouseX, mouseY);

  if (libNowDragInPicker == 0) {
    // 년도 영역 드래그 시작 감지
    if (mouseHober(libYearPickerX - 64, libYearmonthScrollY, 128, libYearmonthScrollH)) {
      libNowDragInPicker = 1;
      return;
    }
    // 월 영역 드래그 시작 감지
    if (mouseHober(libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthScrollY, 192, libYearmonthScrollH)) {
      libNowDragInPicker = 2;
      return;
    }
  }
}

void handleLibYearMonthMouseReleased() {
  if (libYearMonthOK.onRelease(mouseX, mouseY)) {
    libraryCalendar.set(libYearPicker, libMonthPicker - 1, 1);
    libraryPickerState = 0;
    return;
  }
  if (libYearMonthCancle.onRelease(mouseX, mouseY)) {
    libraryPickerState = 0;
    return;
  }

  // 드래그 상태였다면 초기화
  if (libNowDragInPicker != 0) {
    libNowDragInPicker = 0;
    libSet = 0;
    return;
  }
  
  // 피커 바깥 영역을 클릭했다면 닫기
  if (!mouseHober(libYearmonthScrollX, libYearmonthScrollY, libYearmonthScrollW, libYearmonthScrollH)) {
    libraryPickerState = 0;
  }
}

void handleDiaryLibraryDragged() {
  if (libraryPickerState != 1 || libNowDragInPicker == 0) return;

  if (mouseY > pmouseY) libSet += 2;
  if (mouseY < pmouseY) libSet -= 2;

  if (libSet >= 10) {
    if (libNowDragInPicker == 1) {
      if (libYearPicker > 0) libYearPicker--;
    } else if (libNowDragInPicker == 2) { 
      if (libMonthPicker > 1) libMonthPicker--; else libMonthPicker = 12;
    }
    libSet = 0;
  }
  if (libSet <= -10) {
    if (libNowDragInPicker == 1) {
      if (libYearPicker < 9999) libYearPicker++;
    } else if (libNowDragInPicker == 2) {
      if (libMonthPicker < 12) libMonthPicker++; else libMonthPicker = 1;
    }
    libSet = 0;
  }
}

void handleDiaryLibraryMouseWheel(MouseEvent ev) {
  if (libraryPickerState != 1) return;
  
  // 년도 영역에서 마우스 휠
  if (mouseHober(libYearPickerX - 64, libYearmonthScrollY, 128, libYearmonthScrollH)) {
    libYearPicker -= ev.getCount();
    libYearPicker = constrain(libYearPicker, 1, 9998);
  }
  // 월 영역에서 마우스 휠
  if (mouseHober(libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthScrollY, 192, libYearmonthScrollH)) {
    libMonthPicker -= ev.getCount();
    if (libMonthPicker > 12) libMonthPicker = 1;
    if (libMonthPicker < 1) libMonthPicker = 12;
  }
}
