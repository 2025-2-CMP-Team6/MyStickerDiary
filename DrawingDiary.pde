// DrawingDiary.pde
// Owner:

rectButton analyzeButton;
boolean analyzePressed = false;
boolean isAnalyzing = false;
float lastSentimentScore = -1;
String lastSentimentLabel = "";

// Weather
int todayWeather;

Sticker selectedSticker;
float handleSize;
// Whether Handling or Not
// -1: Not Handling, 0: Left Top, 1: Left Bottom, 2: Right Top, 3: Right Bottom
int isResizing = -1;
PVector resizeAnchor = new PVector();

rectButton stickerStoreButton;
rectButton finishButton;
boolean storagePressed = false;
boolean colorPickerPressed = false;
boolean finishPressed = false;
boolean isStickerLibraryOverlayVisible = false;
boolean isStickerEditContextVisible = false;
float editContextX = 0;
float editContextY = 0;
float editContextBtnW = 0;
float editContextBtnH = 0;
int editContextStickerIndex = -1;

float overlayScrollY = 0;
float minOverlayScrollY = 0; 
boolean isDraggingScrollbar = false; 
float scrollbarDragStartY;
float scrollbarDragStartScrollY; 
float scrollbarX, scrollbarY, scrollbarW, scrollbarH;
float thumbY, thumbH;

int isDatePickerVisible = 0; // 0: UnVisible, 1: Month, 2: Year
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

int nowDragInPicker; // 0: Not Dragged, 1: Year, 2: Month

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
  
  drawBackButton(DIARY_BACK_X, DIARY_BACK_Y, DIARY_BACK_W, DIARY_BACK_H);
  
  pushStyle();
  fill(0);
  textSize(30);
  textAlign(LEFT,CENTER);
  text("Name : " + username, width * (100.0f/1280.0f), height * (30.0f/720.0f));
  popStyle();
  
  // Draw Stickers Placed in Diary
  for (Sticker s : placedStickers) {
    s.display();
  }
  // When Sticker is Selected, Draw Handle
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

  // When Sticker Moving, Draw Delete Zone
  if (currentlyDraggedSticker != null && isResizing == -1) {
    float deleteZoneSize = 64;
    float deleteZoneX = 0;
    float deleteZoneY = textFieldY - deleteZoneSize;

    pushStyle();
    fill(255, 0, 0, 100);
    noStroke();
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

  // Anlaysis Button
  pushStyle();
  textAlign(LEFT, CENTER);
  textSize(16);
  float btnH = height * (60.0f/720.0f);
  float analyzeBtnY = navigationBarY + 20;
  float sentimentTextY = analyzeBtnY + btnH + 4;

  if (isAnalyzing) {  // When Analayzing, Draw text
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
   else if (lastSentimentScore >= 0) {  // When Finish Analayzing, Draw Sentiment Text
    fill(0);
    text("Sentiment: " + lastSentimentLabel + String.format(" (%.2f)", lastSentimentScore),
        width * (1100.0f/1280.0f), sentimentTextY);
  }
  popStyle();

  // Weather Icon
  if (weatherIcon != null) {  // Draw Weather Icon
    pushStyle();
    imageMode(CENTER);
    int iconCount = weatherIcon.length;
    float baseIconSize = width * (40.0f / 1280.0f);
    float rightMargin = width * (300.0f / 1280.0f);
    float iconSpacing = width * (10.0f / 1280.0f);
    for (int i = 0; i < iconCount; i++) {
      float x_center = width - rightMargin - (baseIconSize / 2) - (i * (baseIconSize + iconSpacing));
      float y_center = navigationBarY / 2;

      PImage drawEmotIcon;
      float effectiveIconSize;
      
      if (todayWeather == i) {
        drawEmotIcon = weatherIcon[i];
        float pulse = 1.0 + sin(frameCount * 0.1) * 0.05; // Pulse Effect
        effectiveIconSize = baseIconSize * pulse;
      } else {
        drawEmotIcon = weatherIcon[i].get();
        drawEmotIcon.filter(GRAY);
        // Hober Effect
        if (mouseHober(x_center - (baseIconSize * 0.875f) / 2, y_center - (baseIconSize * 0.875f) / 2, baseIconSize * 0.875f, baseIconSize * 0.875f)) {
          effectiveIconSize = baseIconSize * 0.875f;
        }
        else { 
          effectiveIconSize = baseIconSize * 0.75f;
        }
      }
      PVector newSize = getScaledImageSize(drawEmotIcon, effectiveIconSize);
      image(drawEmotIcon, x_center, y_center, newSize.x, newSize.y);
    }
    popStyle();
  }

  // Emotion Icon
  if (emotIcon != null) {
    pushStyle();
    imageMode(CENTER);
    int iconCount = emotIcon.length;
    float iconSize = width * (40.0f / 1280.0f);
    float rightMargin = width * (20.0f / 1280.0f);
    float iconSpacing = width * (10.0f / 1280.0f);
    for (int i = 0; i < iconCount; i++) { // Draw Emotion Icon
      float currentIconSize = iconSize;
      float x = width - rightMargin - (currentIconSize / 2) - (i * (currentIconSize + iconSpacing)); 
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
      PVector newSize = getScaledImageSize(drawEmotIcon, currentIconSize);
      image(drawEmotIcon, x, y, newSize.x, newSize.y);
    }
    popStyle();
  }

  if(diary_year != -1 && diary_month != -1 && diary_day != -1) {  // Draw Diary Date
    pushStyle();
    textSize(30);
    String dateString = "Date : " + diary_year + ". " + diary_month + ". " + diary_day;
    float dateTextW = textWidth(dateString);
    float dateTextH = 30;
    float dateTextCenterX = width/2 - width * (120.0f/1280.0f);
    float dateTextCenterY = height * (30.0f/720.0f);
    float dateRectX = dateTextCenterX - dateTextW / 2;
    float dateRectY = dateTextCenterY - dateTextH / 2;
    // When Mouse Hober on Date, Draw Rectangle
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
  
  // Draw Date Picker
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
// Draw Sticker Library When Overlay is Visible
void drawStickerLibraryOverlay() {
  pushStyle();
  fill(0, 150);
  rect(0, 0, width, height);
  // Library
  rectMode(CORNER);
  float panelX = width * (100.0f/1280.0f);
  float panelY = height * (100.0f/720.0f);
  float panelW = width - 2 * panelX;
  float panelH = height - 2 * panelY;
  fill(220, 240, 220);
  rect(panelX, panelY, panelW, panelH, 10);
  // Title
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Sticker Library", panelX + panelW / 2, panelY + height*(40.0f/720.0f));
  // Close Button
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
  rect(panelX + contentPaddingX - 16, panelY + contentPaddingY - 20, panelW - contentPaddingX - scrollbarAreaWidth + 42, panelH - contentPaddingY + 8, 4);
  popStyle();
  // Draw Sticker List
  pushStyle();
  float boxSize = width * (100.0f/1280.0f);
  float spacing = width * (120.0f/1280.0f);
  float startX = panelX + width * (80.0f/1280.0f);
  float startY = panelY + height * (130.0f/720.0f);
  int cols = floor((panelW - 100) / spacing);
  rectMode(CORNER);
  
  // Mouse Scroll 
  if (stickerLibrary.size() > 0) {
    int numRows = (stickerLibrary.size() - 1) / cols + 1;
    float contentHeight = (numRows - 1) * spacing + boxSize;
    float viewHeight = panelH - (startY - panelY);
    minOverlayScrollY = max(0, contentHeight - viewHeight);
  } else {
    minOverlayScrollY = 0;
  }
  
  clip(startX - boxSize/2, startY - boxSize/2 - 16, panelW - width*(100.0f/1280.0f), panelH - height*(100.0f/720.0f));

  for (int i = 0; i < stickerLibrary.size(); i++) { // Draw Stickers
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;
    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY;
    PVector newSize = getScaledImageSize(s.img, boxSize);

    imageMode(CENTER);
    image(s.img, stickerX, stickerY, newSize.x, newSize.y);
    // Hober Effect
    if (mouseHober(stickerX - newSize.x / 2, stickerY - newSize.y / 2, newSize.x, newSize.y)) {
      stroke(0);
      strokeWeight(3);
      noFill();
      rectMode(CENTER);
      rect(stickerX, stickerY, newSize.x, newSize.y);
      rectMode(CORNER);
    }
  }
  noClip();
  // Draw ScrollBar
  if (minOverlayScrollY > 0) {
    scrollbarW = width * (12.0f/1280.0f);
    float scrollbarMargin = width * (20.0f/1280.0f);
    scrollbarX = panelX + panelW - scrollbarMargin - scrollbarW;
    scrollbarY = panelY + height * (80.0f/720.0f);
    scrollbarH = panelH - height * (120.0f/720.0f);

    // ScrollBar Track
    fill(200, 180);
    noStroke();
    rect(scrollbarX, scrollbarY, scrollbarW, scrollbarH, 6);

    // ScrollBar Thumb
    float viewHeight = panelH - (startY - panelY);
    int numRows = (stickerLibrary.size() - 1) / cols + 1;
    float contentHeight = (numRows - 1) * spacing + boxSize;
    thumbH = scrollbarH * (viewHeight / contentHeight);
    thumbH = max(thumbH, 25);
    float scrollableDist = scrollbarH - thumbH;
    float scrollRatio = overlayScrollY / minOverlayScrollY;
    thumbY = scrollbarY + scrollableDist * scrollRatio;
  
  // Draw small 'edit' chip when right-click context is visible
  if (isStickerEditContextVisible) {
    float bw = width * (72.0f/1280.0f);
    float bh = height * (36.0f/720.0f);
    float bx = editContextX;
    float by = editContextY;
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
  // When Mouse Hober on ScrollBar Thumb
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
    // When Overy Activate, DisActive Text Area
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
// Mouse Handle in Drawing Diary
void handleDiaryMouse() {
  // on Analyze Button
  if (analyzeButton != null) {
    analyzePressed = mouseHober(analyzeButton.position_x, analyzeButton.position_y,
                                analyzeButton.width, analyzeButton.height);
  } else analyzePressed = false;
  // on Sticker Library Overlay
  if (isStickerLibraryOverlayVisible) {
    if (minOverlayScrollY > 0 && mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) {
      isDraggingScrollbar = true;
      scrollbarDragStartY = mouseY;
      scrollbarDragStartScrollY = overlayScrollY;
    }
    return;
  } 
  // on Date Picker
  if (isDatePickerVisible != 0) {
    handleDatePickerMouse();
    return;
  }
  // If on Sticker,
  isResizing = -1;
  selectedSticker = null;
  currentlyDraggedSticker = null;
  // Get Sticker on which Mouse Hober
  for (int i = placedStickers.size() - 1; i >= 0; i--) {
    Sticker s = placedStickers.get(i);
    PVector displaySize = s.getDisplaySize();
    // on Sticker Handle
    for (int j = 0; j < 4; j++) {
      float[] handle = s.getHandleRect(j, handleSize);
      if (mouseHober(handle[0], handle[1], handle[2], handle[3])) {
        isResizing = j;
        selectedSticker = s;
        currentlyDraggedSticker = s;
        // Set Anchor Point 
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
    // on Sticker
    if (mouseHober(s.x - displaySize.x/2, s.y - displaySize.y/2, displaySize.x, displaySize.y)) {
      selectedSticker = s;
      currentlyDraggedSticker = s;
      offsetX = mouseX - s.x;
      offsetY = mouseY - s.y;
      isResizing = -1;
      break;
    }
  }
  // on Sticker Store Button
  if (stickerStoreButton != null) {
    storagePressed = mouseHober(stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height);
  } else {
    storagePressed = false;
  }
  // on Finish Button
  if (finishButton != null) {
    finishPressed = mouseHober(
      finishButton.position_x, finishButton.position_y,
      finishButton.width, finishButton.height
    );
  } else {
    finishPressed = false;
  }
  // on Date Picker OK Button
  if (yearmonthOK != null) {
    yearmonthOKPressed = mouseHober(yearmonthOK.position_x, yearmonthOK.position_y,
      yearmonthOK.width, yearmonthOK.height);
  } else {
    yearmonthOKPressed = false;
  }
  // on Date Picker Back Button
  if (yearmonthCancle != null) {
    yearmonthCanclePressed = mouseHober(yearmonthCancle.position_x, yearmonthCancle.position_y,
      yearmonthCancle.width, yearmonthCancle.height);
  } else {
    yearmonthCanclePressed = false;
  }
  // on Color Picker
  if (diaryColorPicker != null) {
    colorPickerPressed = mouseHober(diaryColorPicker.position_x, diaryColorPicker.position_y,
      diaryColorPicker.width, diaryColorPicker.height);
  } else {
    colorPickerPressed = false;
  }
  
  // on Date
  float[] dateRect = getDateTextRect();
  datePressed = mouseHober(dateRect[0], dateRect[1], dateRect[2], dateRect[3]);
}
// Mouse Drag in Drawing Diary
void handleDiaryDrag() {
  if (isStickerLibraryOverlayVisible) { // on Sticker Library Overlay
    // on ScrollBar
    if (isDraggingScrollbar) {
      float dy = mouseY - scrollbarDragStartY;
      float scrollablePixelRange = scrollbarH - thumbH;
      if (scrollablePixelRange > 0) {
        float scrollAmount = dy * (minOverlayScrollY / scrollablePixelRange);
        overlayScrollY = constrain(scrollbarDragStartScrollY + scrollAmount, 0, minOverlayScrollY);
      } 
    }
    return;
  }
  // on Date Picker
  if (isDatePickerVisible != 0) {
    handleDatePickerDrag();
    return;
  }
  if (currentlyDraggedSticker == null) {
    return;
  }
  isDiaryModified = true;
  // on Sticker
  Sticker s = currentlyDraggedSticker;
  if (isResizing == -1) { // If Handle Not Clicked,
    PVector displaySize = s.getDisplaySize();
    // Move Sticker
    s.x = constrain(mouseX - offsetX, 0, width);
    s.y = constrain(mouseY - offsetY, 0, textFieldY - displaySize.y/2);
  } else { // If Resizing
  PVector anchor = resizeAnchor;  // Get Anchor Point 
  float newDisplayW = abs(mouseX - anchor.x);
  float newDisplayH = abs(min(mouseY, textFieldY) - anchor.y);
  float imgRatio = (float)s.img.width / (float)s.img.height;
  float boxRatio = (newDisplayH == 0) ? 10000 : newDisplayW / newDisplayH;
   if (boxRatio > imgRatio) { // Fix Sticker Ratio
    s.size = (s.img.height >= s.img.width) ? newDisplayH : newDisplayH * imgRatio;
  } else { 
    s.size = (s.img.width >= s.img.height) ? newDisplayW : newDisplayW / imgRatio;
  }
  // Minimum Size
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
  
// Mouse Release in Drawing Diary
void handleDiaryRelease() {
  // on Analyze Button
  if (analyzePressed && mouseHober(
        analyzeButton.position_x, analyzeButton.position_y,
        analyzeButton.width, analyzeButton.height)) {
    startDiarySentimentAnalysis();
  }
  analyzePressed = false;
  
  // on Weather Icon
  if (weatherIcon != null && !isStickerLibraryOverlayVisible && isDatePickerVisible == 0) {
    int iconCount = weatherIcon.length;
    float baseIconSize = width * (40.0f / 1280.0f);
    float rightMargin = width * (300.0f / 1280.0f);
    float iconSpacing = width * (10.0f / 1280.0f);
    for (int i = 0; i < iconCount; i++) {
      float x_center = width - rightMargin - (baseIconSize / 2) - (i * (baseIconSize + iconSpacing));
      float y_center = navigationBarY / 2;

      if (todayWeather != i && mouseHober(x_center - (baseIconSize * 0.875f) / 2, y_center - (baseIconSize * 0.875f) / 2, baseIconSize * 0.875f, baseIconSize * 0.875f)) {
        todayWeather = i;
        isDiaryModified = true;
        initWeatherEffects();
        return;
      }
    }
  }
  // on Sticker Library Overlay
  if (isStickerLibraryOverlayVisible) {
    if (isDraggingScrollbar) {
      isDraggingScrollbar = false;
      return;
    }
    
    // on ScrollBar Track
    if (minOverlayScrollY > 0 && mouseHober(scrollbarX, scrollbarY, scrollbarW, scrollbarH) && !mouseHober(scrollbarX, thumbY, scrollbarW, thumbH)) {
      float clickRatio = (mouseY - scrollbarY - thumbH / 2) / (scrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      overlayScrollY = clickRatio * minOverlayScrollY;
      return;
    }
    // on Sticker Library Overlay Panel
    float panelX = width * (100.0f/1280.0f);
    float panelY = height * (100.0f/720.0f);
    float panelW = width - 2 * panelX;
    float panelH = height - 2 * panelY;

    if (mouseHober(panelX, panelY, panelW, panelH)) { // on Panel
      handleStickerLibraryOverlayRelease();
    } else {  // outside Panel, Close Overlay
      isStickerLibraryOverlayVisible = false;
      isStickerEditContextVisible = false;
    }
    return;
  }
  // on Date Picker
  if (isDatePickerVisible != 0) {
    handleDatePickerMouseRelease();
    return;
  }

  // If Sticker is on DeleteZone,
  if (currentlyDraggedSticker != null && isResizing == -1) {  // When Sticker Drag
    float deleteZoneSize = 64;
    if (mouseHober(0, textFieldY - deleteZoneSize, deleteZoneSize, deleteZoneSize)) {
      placedStickers.remove(currentlyDraggedSticker); // Delete Sticker
      isDiaryModified = true;
      selectedSticker = null;
    }
  }
  // If not Clicked Sticker,
  currentlyDraggedSticker = null; // Initialize Select
  isResizing = -1;
  // on Finish Button
  if (finishPressed && mouseHober(  
      finishButton.position_x, finishButton.position_y,
      finishButton.width,      finishButton.height)) {
         // Set Librarys' Date to Diary's Date
         libraryCalendar.set(diary_year, diary_month - 1, 1);
         switchScreen(diary_library);
         saveDiary();
         loadDiaryDates();
       }
  // on Sticker Store Button
  if (storagePressed && mouseHober(
      stickerStoreButton.position_x, stickerStoreButton.position_y,
      stickerStoreButton.width, stickerStoreButton.height)) {
    isStickerLibraryOverlayVisible = true; isStickerEditContextVisible = false;
  }
  // on Color Picker
  if (colorPickerPressed && mouseHober(
      diaryColorPicker.position_x, diaryColorPicker.position_y,
      diaryColorPicker.width, diaryColorPicker.height)) {
    UiBooster booster = new UiBooster();
    java.awt.Color defaultColor = new java.awt.Color(
        round(red(diaryPaperColor)), round(green(diaryPaperColor)), round(blue(diaryPaperColor)), 255
    );
    java.awt.Color awtColor = booster.showColorPicker("Select Navigation Bar Color", "Choose a color for the navigation bar", defaultColor);
    if (awtColor != null) {
        color newColor = color(awtColor.getRed(), awtColor.getGreen(), awtColor.getBlue());
        if (newColor != diaryPaperColor) {
          diaryPaperColor = newColor;
          diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);
          isDiaryModified = true;
        }
    }
  }

  // on Date
  float[] dateRect = getDateTextRect();
  if (datePressed && mouseHober(dateRect[0], dateRect[1], dateRect[2], dateRect[3])) { openDatePickerDialog(); }
  
  finishPressed = false;
  colorPickerPressed = false;
  storagePressed = false;
  datePressed = false;
}

// Mouse Release in Sticker Library Overlay 
void handleStickerLibraryOverlayRelease() {
  
  float panelX = width * (100.0f/1280.0f);
  float panelY = height * (100.0f/720.0f);
  float panelW = width - 2 * panelX;
  float panelH = height - 2 * panelY;
  // If 'edit' Context Button is Visible, Handle Its Click First
  if (isStickerEditContextVisible && mouseButton == LEFT) {
    float bw = width * (72.0f/1280.0f);
    float bh = height * (36.0f/720.0f);
    float bx = editContextX;
    float by = editContextY;
    if (bx + bw > panelX + panelW) bx = (panelX + panelW) - bw;
    if (by + bh > panelY + panelH) by = (panelY + panelH) - bh;
    if (bx < panelX) bx = panelX;
    if (by < panelY) by = panelY;
    if (mouseHober(bx, by, bw, bh)) { // Hober Effect
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
    } else { // If Click outside, 
      isStickerEditContextVisible = false;
    }
  }

  // on Close Button
  if (mouseHober(panelX + panelW - width*(50.0f/1280.0f), panelY + height*(10.0f/720.0f), width*(40.0f/1280.0f), height*(40.0f/720.0f))) {
    isStickerLibraryOverlayVisible = false;
    return;
  }

  // on Sticker Library Overlay Panel
  
  float boxSize = width * (100.0f/1280.0f);
  float spacing = width * (120.0f/1280.0f);
  int startX = (int)(panelX + 80); 
  int startY = (int)(panelY + 130);
  int cols = floor((panelW - 100) / spacing);
  
  for (int i = 0; i < stickerLibrary.size(); i++) {
    Sticker s = stickerLibrary.get(i);
    int c = i % cols;
    int r = i / cols;

    float stickerX = startX + c * spacing;
    float stickerY = startY + r * spacing - overlayScrollY;
    PVector newSize = getScaledImageSize(s.img, boxSize);

    boolean isStickerVisible = (stickerY + newSize.y/2 > panelY + height*(80.0f/720.0f)) && (stickerY - newSize.y/2 < panelY + panelH); // Whether Sticker is Visible

    if (isStickerVisible && mouseHober(stickerX - newSize.x / 2, stickerY - newSize.y / 2, newSize.x, newSize.y)) {
      if (mouseButton == RIGHT) {
        // Show Small 'edit' Button Near Cursor; Keep Overlay Open
        isStickerEditContextVisible = true;
        editContextStickerIndex = i;
        editContextX = mouseX + 8;
        editContextY = mouseY + 8;
        return;
      } else {
        // LEFT Click: Place Sticker into Diary at Clicked Position
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

/** 
 * Get Date Pickers Position and Size
 * @return float[] Date Rect and Texts' Position
 **/
float[] getDateTextRect() {
  pushStyle();
  textSize(30);
  String dateString = "Date : " + diary_year + ". " + diary_month + ". " + diary_day;
  float dateTextW = textWidth(dateString);
  float dateTextH = 30;
  
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
    datePickerCalendar.setTime(calendar.getTime());
  }

  datePickerX = width/2 - datePickerWidth/2;
  datePickerY = navigationBarY + 10;
  isDatePickerVisible = 1;
}

void closeDatePickerDialog() {
  isDatePickerVisible --;
}
// Draw Date Picker
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


  text(datePickerCalendar.get(Calendar.YEAR) + " " + monthString, datePickerX + datePickerWidth / 2, datePickerY + height*(30.0f/720.0f));

  textSize(24);
  text("<", datePickerX + width*(30.0f/1280.0f), datePickerY + height*(30.0f/720.0f)); // Previous
  text(">", datePickerX + datePickerWidth - width*(30.0f/1280.0f), datePickerY + height*(30.0f/720.0f)); // Next

  // Week Text
  String[] daysOfWeek = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  textSize(14);
  float cellWidth = datePickerWidth / 7.0;
  for (int i = 0; i < 7; i++) {
    fill(i == 0 ? color(200, 0, 0) : 0); // Red Sunday
    text(daysOfWeek[i], datePickerX + cellWidth * i + cellWidth / 2, datePickerY + height*(70.0f/720.0f));
  }

  // Date Grid
  Calendar tempCal = (Calendar) datePickerCalendar.clone();
  tempCal.set(Calendar.DAY_OF_MONTH, 1);
  int firstDayOfWeek = tempCal.get(Calendar.DAY_OF_WEEK);
  int maxDaysInMonth = tempCal.getActualMaximum(Calendar.DAY_OF_MONTH);

  int day = 1;
  float cellHeight = (datePickerHeight - height*(100.0f/720.0f)) / 6.0;
  textSize(16);
  // Each Day
  for (int row = 0; row < 6; row++) {
    for (int col = 0; col < 7; col++) {
      if (row == 0 && col < firstDayOfWeek - 1) continue;
      if (day > maxDaysInMonth) break;

      float x = datePickerX + col * cellWidth;
      float y = datePickerY + height*(90.0f/720.0f) + row * cellHeight;
      
      // Selected Day
      if (datePickerCalendar.get(Calendar.YEAR) == diary_year &&
          datePickerCalendar.get(Calendar.MONTH) + 1 == diary_month &&
          day == diary_day) {
        fill(200, 220, 255);
        noStroke();
        ellipse(x + cellWidth / 2, y + cellHeight / 2, cellWidth * 0.8, cellHeight * 0.8);
      } 
      if (isDatePickerVisible == 1) {
        // Hober Effect
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

  // Close Button
  float backBtnW = 100;
  float backBtnH = 30;
  float backBtnX = datePickerX + (datePickerWidth - backBtnW) / 2;
  float backBtnY = datePickerY + datePickerHeight - backBtnH - 10;
  // Hober Effect
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

// Open and Initialize Year Month Picker
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
// Initialize Buttons in Year Month Picker
void initYearMonthButton() {
  yearmonthOK = new rectButton(this, round(yearmonthScrollX-yearmonthButtonA+width*(240.0f/1280.0f)), round(yearmonthScrollY+yearmonthScrollH-height*(32.0f/720.0f)), round(width*(48.0f/1280.0f)), round(height*(24.0f/720.0f)), #FBDAB0);
  yearmonthOK.rectButtonText("OK", 18);
  yearmonthOK.setShadow(false);
  yearmonthCancle = new rectButton(this, round(yearmonthScrollX+yearmonthButtonA+width*(240.0f/1280.0f)), round(yearmonthScrollY+yearmonthScrollH-height*(32.0f/720.0f)), round(width*(48.0f/1280.0f)), round(height*(24.0f/720.0f)), #D9D9D9);
  yearmonthCancle.rectButtonText("Cancle", 18);
  yearmonthCancle.setShadow(false);
}

// Draw Year Month Picker
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
  if (nowDragInPicker == 0) {
    text(yearPicker, yearPickerX, yearmonthY);  
    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY);
    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY-height*(48.0f/720.0f));
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY+height*(48.0f/720.0f));
    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-height*(48.0f/720.0f)); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+height*(48.0f/720.0f)); }
  }
  
  else if (nowDragInPicker == 1) {  // Drag Year
    text(yearPicker, yearPickerX, yearmonthY + set*height*(4.8f/720.0f));  
    text(monthToString(monthToIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY);
    fill(125);
    text(monthToString(prevMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY-height*(48.0f/720.0f));
    text(monthToString(nextMonthIdx0(monthPicker)), yearmonthScrollX+yearmonthScrollW/2+width*(128.0f/1280.0f), yearmonthY+height*(48.0f/720.0f));
    if (yearPicker > 0)    { text(yearPicker-1, yearPickerX, yearmonthY-height*(48.0f/720.0f) + set*height*(4.8f/720.0f)); }
    if (yearPicker < 9999) { text(yearPicker+1, yearPickerX, yearmonthY+height*(48.0f/720.0f) + set*height*(4.8f/720.0f)); }

  } 
  else if (nowDragInPicker == 2) {  // Drag Month

    text(yearPicker, yearPickerX, yearmonthY);
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
  if (isDatePickerVisible == 2) { // If Year Month Picker is Visible
    handleYearMonthMouse();
    return;
  }
}

void handleYearMonthMouse() {  // on Year Month Picker
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
}

void handleDatePickerDrag() { // Mouse Darg in Date Picker
  if (isDatePickerVisible == 2) { // If Year Month Picker is Visible
    handleYearMonthDrag();
    return;
  }
}
void handleYearMonthDrag() {  // Mouse Drag in Year Month Picker
  if (mouseY > pmouseY) set += 2;
  if (mouseY < pmouseY) set -= 2;
  // Range of Year(0~9999) Month(1~12) 
  if (set >= 10) {
    if (nowDragInPicker == 1) {
      if (yearPicker > 0) yearPicker--;
    } else if (nowDragInPicker == 2) {
      monthPicker--;
      if (monthPicker < 1) monthPicker = 12;
    }
    set = 0;
  }
  if (set <= -10) {
    if (nowDragInPicker == 1) {
      if (yearPicker < 9999) yearPicker++;
    } else if (nowDragInPicker == 2) {
      monthPicker++;
      if (monthPicker > 12) monthPicker = 1;
    }
    set = 0;
  }
}
// Mouse Release in Date Picker
void handleDatePickerMouseRelease() {
  float cellWidth = datePickerWidth / 7.0;
  if ((isDatePickerVisible == 2)) { // If Year Month Picker is Visible
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

  // on Close Button
  float backBtnW = 100;
  float backBtnH = 30;
  float backBtnX = datePickerX + (datePickerWidth - backBtnW) / 2;
  float backBtnY = datePickerY + datePickerHeight - backBtnH - 10;
  if (mouseHober(backBtnX, backBtnY, backBtnW, backBtnH)) {
      closeDatePickerDialog();
      return;
  }

  // on Previous Month
  float arrowArea = width*(60.0f/1280.0f);
  if (mouseHober(datePickerX, datePickerY, arrowArea, arrowArea)) {
    datePickerCalendar.add(Calendar.MONTH, -1);
    return;
  }
  // on Next Month
  if (mouseHober(datePickerX + datePickerWidth - arrowArea, datePickerY, arrowArea, arrowArea)) {
    datePickerCalendar.add(Calendar.MONTH, 1);
    return;
  }
  // on Year/Month Text
  if (mouseHober(datePickerX + datePickerWidth / 2 - width*(60.0f/1280.0f), datePickerY, width*(128.0f/1280.0f), height*(64.0f/720.0f))) {
    openYearMonthPicker();
    return;
  }

  // on Each Day
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
        // Select Day
        int newYear = datePickerCalendar.get(Calendar.YEAR);
        int newMonth = datePickerCalendar.get(Calendar.MONTH) + 1;
        int newDay = day;
        if (newYear != diary_year || newMonth != diary_month || newDay != diary_day) {
          isDiaryModified = true;
        }
        diary_year = newYear;
        diary_month = newMonth;
        diary_day = newDay;

        // Update Diary Calendar
        calendar.set(diary_year, diary_month - 1, diary_day);
        closeDatePickerDialog();
        return;
      }
      day++;
    }
  }
  // on Outside
  if ((!mouseHober(datePickerX, datePickerY, datePickerWidth, datePickerHeight))&&(isDatePickerVisible == 1)) {
    closeDatePickerDialog();
  }

if ((!mouseHober(yearmonthScrollX, yearmonthScrollY, yearmonthScrollW, yearmonthScrollH))&&(isDatePickerVisible == 2)) {
    isDatePickerVisible = 1;
  }
}
// Mouse Wheel in Diary
void handleDrawingDiaryMouseWheel(MouseEvent ev) {
  // Dide edit Chip on Scroll
  isStickerEditContextVisible = false;

  if (isStickerLibraryOverlayVisible) { // If Sticker Library Overlay is Visible
    if (mouseHober(width*(130.0f/1280.0f), height*(164.0f/720.0f), width - width*(270.0f/1280.0f), height - height*(280.0f/720.0f))) {
      float scrollAmount = ev.getCount() * 10;
      overlayScrollY = constrain(overlayScrollY + scrollAmount, 0, minOverlayScrollY);
    }
  }


  if (isDatePickerVisible == 2) { // Year Month Picker is Visible
    if (mouseHober(yearPickerX-width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) { // Scroll Year
      yearPicker -= ev.getCount();
      yearPicker = constrain(yearPicker, 1, 9998);
    }
    if (mouseHober(yearmonthScrollX+yearmonthScrollW/2+width*(64.0f/1280.0f),yearmonthScrollY,width*(192.0f/1280.0f),yearmonthScrollH)) { // Scroll Month
      monthPicker -= ev.getCount();
      monthPicker = clampMonth1to12(monthPicker);
    }
  }
}

// Mouse Release in Year Month Picker
void handleYearMonthMouseRelease() {
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
  // If There Exist Same Day Diary, Delete it
  File diaryFolder = new File(dataPath("diaries"));
  String filePrefix = "diary_" + diary_year + "_" + diary_month + "_" + diary_day + "_";
  if (diaryFolder.exists() && diaryFolder.isDirectory()) {
    File[] files = diaryFolder.listFiles();
    if (files != null) {
      for (File file : files) {
        if (file.getName().startsWith(filePrefix) && file.getName().endsWith(".json")) {
          if (!file.delete()) {
          }
        }
      }
    }
  }

  // Create JSONEObject Contain Information of Diary
  JSONObject diaryData = new JSONObject();
  // Save Colors
  diaryData.setInt("paperColor", diaryPaperColor);
  diaryData.setInt("backgroundColor", diaryBackgroundColor);
  // Save Weather
  diaryData.setInt("weather", todayWeather);
  // Save Texts
  diaryData.setString("title", titleArea.getText());
  diaryData.setString("content", textArea.getText());
  // Save Stickers Datas
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
  // Create File (File Name : YYYY_MM_DD_(SentimentScore).json)
  String newFileName = "diary_" + diary_year + "_" + diary_month + "_" + diary_day + "_(" + (lastSentimentScore * 10) + ").json";
  saveJSONObject(diaryData, "data/diaries/" + newFileName);
}

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
    return;
  }
  // Get Loaded Diary Data and Set Current Diary
  placedStickers.clear();
  selectedSticker = null;
  currentlyDraggedSticker = null;
  isResizing = -1;
  resizeAnchor.set(0, 0);
  titleArea.setText(diaryData.getString("title", ""));
  textArea.setText(diaryData.getString("content", ""));
  
  // Update Calendar
  diary_year = year;
  diary_month = month;
  diary_day = day;
  calendar.set(diary_year, diary_month - 1, diary_day);

  // Load Colors
  color defaultPaperColor = color(251, 218, 176); 
  color defaultBackgroundColor = lerpColor(defaultPaperColor, color(255), 0.8);
  diaryPaperColor = diaryData.getInt("paperColor", defaultPaperColor);
  diaryBackgroundColor = diaryData.getInt("backgroundColor", defaultBackgroundColor);
  // Load Weather
  todayWeather = diaryData.getInt("weather", 0);
  
  // Load Emotion
  lastSentimentScore = -1.0f; // Default
  lastSentimentLabel = "";
  //Get Emotion Data form FileName
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
  
  // Load Stickers
  JSONArray stickerArray = diaryData.getJSONArray("stickers");
  if (stickerArray != null) {
    for (int i = 0; i < stickerArray.size(); i++) {
      JSONObject stickerData = stickerArray.getJSONObject(i);
      String imageName = stickerData.getString("imageName");
      float x = stickerData.getFloat("x");
      float y = stickerData.getFloat("y");
      float size = stickerData.getFloat("size");
      PImage stickerImg = null;
      for (Sticker libSticker : stickerLibrary) { // Get Sticker Image From Library
        if (libSticker.imageName.equals(imageName)) {
          stickerImg = libSticker.img;
          break;
        }
      }
      
      if (stickerImg == null) {
        println("Sticker image not found in library: " + imageName + ". Trying to load from file."); // Sticker Image not Exist in Library, Try to Load in File
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
  isDiaryModified = false;
}

void resetDiary() {
  // Reset Texts
  if (titleArea != null) {
    titleArea.setText("");
  }
  if (textArea != null) {
    textArea.setText("");
  }
  
  // Reset Date
  calendar = Calendar.getInstance();
  diary_year = calendar.get(Calendar.YEAR);
  diary_month = calendar.get(Calendar.MONTH) + 1;
  diary_day = calendar.get(Calendar.DAY_OF_MONTH);
  
  // Reset Stickers
  if (placedStickers != null) {
    placedStickers.clear();
  }
  selectedSticker = null;
  currentlyDraggedSticker = null;
  isResizing = -1;
  resizeAnchor.set(0, 0);

  // Reset Sentiment
  lastSentimentScore = -1;
  lastSentimentLabel = "";

  // Reset Weather
  todayWeather = getWeather();

  // Reset Colors
  diaryPaperColor = color(251, 218, 176);
  diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);
  initWeatherEffects();

  isDiaryModified = false;
}
// Get Sentiment Analysis Result from API
void startDiarySentimentAnalysis() {
  if (isAnalyzing) return;
  isAnalyzing = true;

  final String text = (textArea != null) ? textArea.getText() : "";

  new Thread(new Runnable() {
    public void run() {
      SentimentResult r = EA_analyzeText(text);         // ← EmotionAnalysisAPI.pde
      lastSentimentScore = r.score01;
      lastSentimentLabel = r.label;
      String key = makeDateKey(diary_year, diary_month, diary_day);
      diarySentiments.put(key, lastSentimentScore);
      isDiaryModified = true;

      isAnalyzing = false;
    }
  }).start();
}