/*
 * DiaryLibrary.pde
 * Owner: 최은영
 * SubOwner: 신이철
 */

import java.util.HashSet;

color lerpSentimentColor(float t) {
  t = constrain(t, 0, 1);
  color cNeg = color(230, 70, 60); 
  color cNeu = color(255, 204, 0); 
  color cPos = color(60, 190, 100);
  if (t < 0.5f) return lerpColor(cNeg, cNeu, t/0.5f);
  return lerpColor(cNeu, cPos, (t-0.5f)/0.5f);
}

Calendar libraryCalendar;
HashSet<String> diaryDates;
HashMap<String, Float> diaryEmots;

int libraryPickerState = 0; // 0: hidden, 1: year/month picker visible
int libYearPicker, libMonthPicker;
rectButton libYearMonthOK, libYearMonthCancle;
int libYearmonthScrollX, libYearmonthScrollY, libYearmonthScrollW, libYearmonthScrollH;
float libYearPickerX, libYearmonthY;
int libNowDragInPicker = 0; // 0: none, 1: year, 2: month
int libSet = 0;
int libYearmonthButtonA = 96;
 
final float DIARY_DELETE_BTN_RADIUS = 6; // Diary Delete Button Radius

void initDiaryLibrary() {
  libraryCalendar = Calendar.getInstance();

  prevMonthButton = new rectButton(this, round(width/2 - width*(200.0f/1280.0f)), round(height*(80.0f/720.0f)), round(width*(40.0f/1280.0f)), round(height*(40.0f/720.0f)), #EEEEEE);
  prevMonthButton.rectButtonText("<", 24);
  prevMonthButton.setShadow(false);
  
  nextMonthButton = new rectButton(this, round(width/2 + width*(160.0f/1280.0f)), round(height*(80.0f/720.0f)), round(width*(40.0f/1280.0f)), round(height*(40.0f/720.0f)), #EEEEEE);
  nextMonthButton.rectButtonText(">", 24);
  nextMonthButton.setShadow(false);
}

void loadDiaryDates() {
  if (diaryDates == null) {
    diaryDates = new HashSet<String>();
    diaryEmots = new HashMap<String, Float>();
  }
  diaryDates.clear();
  diaryEmots.clear();
  File diaryFolder = new File(dataPath("diaries"));
  
  if (!diaryFolder.exists()) {
    diaryFolder.mkdirs();
  }
  
  File[] files = diaryFolder.listFiles();
  if (files != null) {
    for (File file : files) {
      String name = file.getName();
      if (name.startsWith("diary_") && name.endsWith(".json")) { // diary_YYYY_M_D_<score>.json
        String namePart = name.substring(6, name.length() - 5); // YYYY_M_D_<score>
        String[] parts = namePart.split("_");
        if (parts.length >= 4 && parts[3].startsWith("(")) {
          String dateKey = parts[0] + "-" + Integer.parseInt(parts[1]) + "-" + Integer.parseInt(parts[2]);
          diaryDates.add(dateKey);
          try {
            float score = Float.parseFloat(parts[3].substring(1,parts[3].indexOf(')'))); // Remove '()'
            diaryEmots.put(dateKey, score / 10.0f);
          } catch (NumberFormatException e) {
            diaryEmots.put(dateKey, -1.0f); // Default
          }
        }
      }
    }
  }
}

void openLibYearMonthPicker() {
  libYearPicker = libraryCalendar.get(Calendar.YEAR);
  libMonthPicker = libraryCalendar.get(Calendar.MONTH) + 1;

  libYearmonthScrollW = round(width * (480.0f/1280.0f));
  libYearmonthScrollH = round(height * (240.0f/720.0f));
  libYearmonthScrollX = width/2 - libYearmonthScrollW/2;
  libYearmonthScrollY = height/2 - libYearmonthScrollH/2;

  libYearPickerX = libYearmonthScrollX + width * (160.0f/1280.0f);
  libYearmonthY = libYearmonthScrollY + libYearmonthScrollH/2;
  
  libraryPickerState = 1;
  initLibYearMonthButton();
}

void initLibYearMonthButton() {
  libYearMonthOK = new rectButton(this, round(libYearmonthScrollX + libYearmonthScrollW/2 - libYearmonthButtonA/2 - width*(30.0f/1280.0f)), round(libYearmonthScrollY + libYearmonthScrollH - height*(48.0f/720.0f)), round(width*(60.0f/1280.0f)), round(height*(24.0f/720.0f)), #FBDAB0);
  libYearMonthOK.rectButtonText("OK", 18);
  libYearMonthOK.setShadow(false);
  libYearMonthCancle = new rectButton(this, round(libYearmonthScrollX + libYearmonthScrollW/2 + libYearmonthButtonA/2), round(libYearmonthScrollY + libYearmonthScrollH - height*(48.0f/720.0f)), round(width*(70.0f/1280.0f)), round(height*(24.0f/720.0f)), #D9D9D9);
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
  rect(libYearmonthScrollX, libYearmonthScrollY, width*(64.0f/1280.0f), libYearmonthScrollH, 24, 0, 0, 24);
  fill(#DBFDB4); 
  rect(libYearmonthScrollX + width*(64.0f/1280.0f), libYearmonthY - height*(24.0f/720.0f), libYearmonthScrollW - width*(64.0f/1280.0f), height*(48.0f/720.0f));

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);

  float yearTextY = libYearmonthY;
  float monthTextY = libYearmonthY;
  
  if (libNowDragInPicker == 1) {
    yearTextY += libSet * height*(4.8f/720.0f);
  } else if (libNowDragInPicker == 2) {
    monthTextY += libSet * height*(4.8f/720.0f);
  }

  text(libYearPicker, libYearPickerX, yearTextY);
  fill(125);
  if (libYearPicker > 0)    text(libYearPicker - 1, libYearPickerX, yearTextY - height*(48.0f/720.0f));
  if (libYearPicker < 9999) text(libYearPicker + 1, libYearPickerX, yearTextY + height*(48.0f/720.0f));

  fill(0);
  text(monthToString(monthToIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + width*(96.0f/1280.0f), monthTextY);
  fill(125);
  text(monthToString(prevMonthIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + width*(96.0f/1280.0f), monthTextY - height*(48.0f/720.0f));
  text(monthToString(nextMonthIdx0(libMonthPicker)), libYearmonthScrollX + libYearmonthScrollW / 2 + width*(96.0f/1280.0f), monthTextY + height*(48.0f/720.0f));

  fill(0);
  text("|", libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthY);

  libYearMonthOK.render();
  libYearMonthCancle.render();
  
  popStyle();
}

void drawDiaryLibrary() {
   background(255, 250, 240); 
   
   drawBackButton(); // Call Common Back Button
   prevMonthButton.render();
   nextMonthButton.render();

   if (libraryPickerState == 0 && mouseHober(width/2 - width*(150.0f/1280.0f), height*(80.0f/720.0f), width*(300.0f/1280.0f), height*(40.0f/720.0f))) {
     fill(230, 230, 230, 200);
     noStroke();
     rect(width/2 - width*(150.0f/1280.0f), height*(80.0f/720.0f), width*(300.0f/1280.0f), height*(40.0f/720.0f), 5);
   }

   textAlign(CENTER, CENTER);
   fill(0);
   textSize(32);
   String monthName = monthToString(libraryCalendar.get(Calendar.MONTH));
   text(libraryCalendar.get(Calendar.YEAR) + " " + monthName, width/2, height*(100.0f/720.0f));

   drawCalendarGrid();

   if (libraryPickerState == 1) {
     drawLibYearMonthPicker();
   }
}

void drawCalendarGrid() {
  pushStyle();
  
  float calX = width * (100.0f/1280.0f);
  float calY = height * (150.0f/720.0f);
  float calWidth = width - 2 * calX;
  float calHeight = height - calY - height*(50.0f/720.0f); // Leave Space at Bottom

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
      float y = calY + height*(25.0f/720.0f) + row * cellHeight;

      String dateKey = tempCal.get(Calendar.YEAR) + "-" + (tempCal.get(Calendar.MONTH) + 1) + "-" + day;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        stroke(100, 100, 255, 150);
        strokeWeight(3);
        noFill();
        rect(x, y, cellWidth, cellHeight);

        // Show Delete Button Only on Dates with a Diary
        if (diaryDates != null && diaryDates.contains(dateKey)) {
            float deleteBtnRadius = DIARY_DELETE_BTN_RADIUS; 
            float deleteBtnX = x + cellWidth - deleteBtnRadius - 4; // 4px Padding
            float deleteBtnY = y + deleteBtnRadius + 4;

            pushStyle();
            if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
                fill(255, 50, 50); // Hover
            } else {
                fill(200, 0, 0);
            }
            stroke(255);
            strokeWeight(1.5);
            circle(deleteBtnX, deleteBtnY, deleteBtnRadius * 2);
            line(deleteBtnX - deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX + deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
            line(deleteBtnX + deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX - deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
            popStyle();
        }
      } else {
        stroke(220);
        strokeWeight(1);
        fill(255);
        rect(x, y, cellWidth, cellHeight);
      }

      if (diaryDates != null && diaryDates.contains(dateKey)) {
        noStroke();
        Float s = (diaryEmots != null) ? diaryEmots.get(dateKey) : null;
        if ((s == null)||(s == -1.0f)) {
          // Use Default if No Score Yet
          fill(#FFCA1A);
          float indicatorSize = min(cellWidth, cellHeight) * 0.2f;
          ellipse(x + cellWidth / 2, y + cellHeight / 2, indicatorSize, indicatorSize);
        } else {
          fill(lerpSentimentColor(s));
          PImage icon = emotIcon[round(s * 5)];
          float iconBoxSize = min(cellWidth, cellHeight) * 0.3f;
          PVector newSize = getScaledImageSize(icon, iconBoxSize);
          imageMode(CENTER);
          image(icon, x + cellWidth / 2, y + cellHeight / 2, newSize.x, newSize.y);
        }
      }
      textAlign(LEFT, TOP);
      fill(col == 0 ? color(200, 0, 0) : 0);
      textSize(18);
      text(day, x + width*(10.0f/1280.0f), y + height*(10.0f/720.0f));

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

  prevMonthButton.onPress(mouseX, mouseY);
  nextMonthButton.onPress(mouseX, mouseY);

}

void handleDiaryLibraryMouseReleased() {
  if (libraryPickerState == 1) {
    handleLibYearMonthMouseReleased();
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
  if (mouseHober(width/2 - width*(150.0f/1280.0f), height*(80.0f/720.0f), width*(300.0f/1280.0f), height*(40.0f/720.0f))) {
    openLibYearMonthPicker();
  }

  // Check Calendar Date Click
  float calX = width * (100.0f/1280.0f);
  float calY = height * (150.0f/720.0f);
  float calWidth = width - 2 * calX;
  float calHeight = height - calY - height*(50.0f/720.0f);
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
      float y = calY + height*(25.0f/720.0f) + row * cellHeight;

      if (mouseHober(x, y, cellWidth, cellHeight)) {
        int clickedYear = libraryCalendar.get(Calendar.YEAR);
        int clickedMonth = libraryCalendar.get(Calendar.MONTH) + 1;
        String dateKey = clickedYear + "-" + clickedMonth + "-" + day;


        if (diaryDates != null && diaryDates.contains(dateKey)) {
            // Check Delete Button Click
            float deleteBtnRadius = DIARY_DELETE_BTN_RADIUS;
            float deleteBtnX = x + cellWidth - deleteBtnRadius - 4;
            float deleteBtnY = y + deleteBtnRadius + 4;

            if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
                UiBooster booster = new UiBooster();
                boolean confirmed = booster.showConfirmDialog("Are you sure you want to delete this diary?", "Delete Diary");
                if (confirmed) {
                    // Delete Diary File
                    deleteDiary(clickedYear, clickedMonth, day);
                    // Remove from Dataset
                    diaryDates.remove(dateKey);
                    diaryEmots.remove(dateKey);
                }
                return; // Action Complete Since Delete was Attempted or Canceled
            }

            // If Not Deleting, Load Diary
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

void deleteDiary(int year, int month, int day) {
    File diaryFolder = new File(dataPath("diaries"));
    String filePrefix = "diary_" + year + "_" + month + "_" + day;

    if (diaryFolder.exists() && diaryFolder.isDirectory()) {
        File[] files = diaryFolder.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.getName().startsWith(filePrefix) && file.getName().endsWith(".json")) {
                    if (file.delete()) {
                        println("Deleted diary: " + file.getName());
                    } else {
                        println("Failed to delete diary: " + file.getName());
                    }
                    return; // Find and Delete Only One
                }
            }
        }
    }
}

void handleLibYearMonthMousePressed() {
  libYearMonthOK.onPress(mouseX, mouseY);
  libYearMonthCancle.onPress(mouseX, mouseY);

  if (libNowDragInPicker == 0) {
    // Detect Year Area Drag Start
    if (mouseHober(libYearPickerX - width*(64.0f/1280.0f), libYearmonthScrollY, width*(128.0f/1280.0f), libYearmonthScrollH)) {
      libNowDragInPicker = 1;
      return;
    }
    // Detect Month Area Drag Start
    if (mouseHober(libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthScrollY, width*(192.0f/1280.0f), libYearmonthScrollH)) {
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

  // If in Drag State, Reset
  if (libNowDragInPicker != 0) {
    libNowDragInPicker = 0;
    libSet = 0;
    return;
  }
  
  // If Clicked Outside Picker, Close
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
  
  // Mouse Wheel on Year Area
  if (mouseHober(libYearPickerX - width*(64.0f/1280.0f), libYearmonthScrollY, width*(128.0f/1280.0f), libYearmonthScrollH)) {
    libYearPicker -= ev.getCount();
    libYearPicker = constrain(libYearPicker, 1, 9998);
  }
  // Mouse Wheel on Month Area
  if (mouseHober(libYearmonthScrollX + libYearmonthScrollW / 2, libYearmonthScrollY, width*(192.0f/1280.0f), libYearmonthScrollH)) {
    libMonthPicker -= ev.getCount();
    if (libMonthPicker > 12) libMonthPicker = 1;
    if (libMonthPicker < 1) libMonthPicker = 12;
  }
}
