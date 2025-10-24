PGraphics stickerCanvas;
float canvasSize;
float canvasX, canvasY;

String tool = "";
float toolGab;
float toolPos[] = new float[2];
String posTool;

color selectedColor = color(0, 0, 0);
float brushSize = 20;
boolean isBrushSizeChange = false;
float brushPos[] = new float[2];
PGraphics sizeCursor;

boolean isDrawingShape = false;
int[] pmousePos = new int[2];
int[] linePos = new int[2];
int[] circlePos = new int[2];
int[] rectPos = new int[2];
boolean isPalleteOpen = true;
float[] colorPos = new float[2];
float colorSize;
float colorGab_palette;
boolean colorToggle = false;
boolean rainbowPickerClicked = false; // 컬러피커 버튼 클릭 여부
boolean clearAllPressed = false; // 모두 지우기 버튼 클릭 여부
boolean undoPressed = false;     // 되돌리기 버튼 클릭 여부
boolean redoPressed = false;     // 다시 실행 버튼 클릭 여부

// Undo/Redo
ArrayList<PImage> undoStack;
ArrayList<PImage> redoStack;
final int MAX_UNDO_STATES = 30;
float SAVE_W, SAVE_H;

void setupCreator() {
  // 해상도에 따라 크기/위치 조정
  canvasSize = height * (680.0f / 720.0f);
  // 정사각형 크기의 그래픽 버퍼를 생성
  stickerCanvas = createGraphics(round(canvasSize), round(canvasSize));
  canvasX = (width - canvasSize) / 2; 
  canvasY = (height - canvasSize) / 2; 
  strokeJoin(ROUND); // 선이 만나는 부분을 둥글게
  strokeCap(ROUND);  // 선의 끝부분을 둥글게
  stickerCanvas.beginDraw();
  stickerCanvas.clear();
  stickerCanvas.endDraw();
  
  undoStack = new ArrayList<PImage>();
  redoStack = new ArrayList<PImage>();
  toolGab = height * (72.0f / 720.0f);
  toolPos[0] = width * (48.0f / 1280.0f);
  toolPos[1] = height * (104.0f / 720.0f);
  brushPos[0] = width * (80.0f / 1280.0f);
  brushPos[1] = height * (600.0f / 720.0f);
  colorPos[0] = width * (1128.0f / 1280.0f);
  colorPos[1] = height * (104.0f / 720.0f);
  colorSize = width * (64.0f / 1280.0f);
  colorGab_palette = height * (72.0f / 720.0f);
  SAVE_W = BACK_W = width * (64.0f / 1280.0f);
  SAVE_H = BACK_H = height * (64.0f / 720.0f);
  BACK_X = width * (24.0f / 1280.0f);
  BACK_Y = height * (24.0f / 720.0f);
 lineCursor = createGraphics(32,32);
 lineCursor.noSmooth();
 lineCursor.beginDraw();
 lineCursor.stroke(0);
 lineCursor.strokeWeight(1);
 lineCursor.line(0,2,4,2);
 lineCursor.line(2,0,2,4);
 lineCursor.line(14,3,3,14);
 lineCursor.endDraw();
 rectCursor = createGraphics(32,32);
 rectCursor.noSmooth();
 rectCursor.beginDraw();
 rectCursor.stroke(0);
 rectCursor.strokeWeight(1);
 rectCursor.line(0,2,4,2);
 rectCursor.line(2,0,2,4);
 rectCursor.rect(4,4,12,12);
 rectCursor.endDraw();
 
 circleCursor = createGraphics(32,32);
 circleCursor.noSmooth();
 circleCursor.beginDraw();
 circleCursor.stroke(0);
 circleCursor.strokeWeight(1);
 circleCursor.line(0,2,4,2);
 circleCursor.line(2,0,2,4);
 circleCursor.circle(8,8,10);
 circleCursor.endDraw();
 sizeCursor = createGraphics(8,8);
 sizeCursor.noSmooth(); 
 sizeCursor.beginDraw();
 sizeCursor.noStroke(); 
 sizeCursor.fill(0);
 sizeCursor.triangle(3,0, 0,3, 3,7);
 sizeCursor.triangle(4,0, 7,3, 4,7);
 sizeCursor.endDraw();
}
void drawCreator() {
  pushStyle();
  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  background(#FBDAB0); // 배경
  stroke(0,1);
  fill(255,255,255);
  rect(canvasX, canvasY, canvasSize, canvasSize); // 캔버스 사각형 그리기
  // 중앙에 정사각형 캔버스 그리기
  image(stickerCanvas, canvasX, canvasY);
  
  // --- UI ---
  rectMode(CORNER);
  float toolIconSize = width * (56.0f / 1280.0f);
  float toolGabX = toolIconSize + width * (16.0f/1280.0f);
  float toolGabY = toolGab;
  // Hover effect
  for (int i = 0; i < 9; i++) {
    int c = i % 2; // column
    int r = i / 2; // row
    float x = toolPos[0] + c * toolGabX;
    float y = toolPos[1] + r * toolGabY;
    if (mouseHober(x, y, toolIconSize, toolIconSize)) {
      fill(255, 50);
      noStroke();
      rect(x, y, toolIconSize, toolIconSize);
    }
  }
  // Icon drawing (2x5 grid)
  imageMode(CORNER);
  for (int i = 0; i < 9; i++) {
    int c = i % 2;
    int r = i / 2;
    float x = toolPos[0] + c * toolGabX;
    float y = toolPos[1] + r * toolGabY;
    switch(i) {
      case 0: // brush
        PVector brushIconSize = getScaledImageSize(brushImg, toolIconSize);
        image(brushImg, x + (toolIconSize - brushIconSize.x) / 2, y + (toolIconSize - brushIconSize.y) / 2, brushIconSize.x, brushIconSize.y);
        break;
      case 1: // paint
        PVector paintIconSize = getScaledImageSize(paintImg, toolIconSize);
        image(paintImg, x + (toolIconSize - paintIconSize.x) / 2, y + (toolIconSize - paintIconSize.y) / 2, paintIconSize.x, paintIconSize.y);
        break;
      case 2: // eraser
        PVector eraserIconSize = getScaledImageSize(eraserImg, toolIconSize);
        image(eraserImg, x + (toolIconSize - eraserIconSize.x) / 2, y + (toolIconSize - eraserIconSize.y) / 2, eraserIconSize.x, eraserIconSize.y);
        break;
      case 3: // line
        pushStyle(); fill(255); stroke(0); strokeWeight(3);
        line(x + toolIconSize*0.15, y + toolIconSize*0.15, x + toolIconSize*0.85, y + toolIconSize*0.85);
        popStyle();
        break;
      case 4: // rect
        pushStyle(); fill(255); stroke(0); strokeWeight(3); rectMode(CENTER);
        rect(x + toolIconSize/2, y + toolIconSize/2, toolIconSize*0.75, toolIconSize*0.75);
        popStyle();
        break;
      case 5: // circle
        pushStyle(); fill(255); stroke(0); strokeWeight(3);
        circle(x + toolIconSize/2, y + toolIconSize/2, toolIconSize*0.75);
        popStyle();
        break;
      case 6: // undo
        PVector undoImgSize = getScaledImageSize(undoIcon, toolIconSize);
        image(undoIcon, x + (toolIconSize - undoImgSize.x) / 2, y + (toolIconSize - undoImgSize.y) / 2, undoImgSize.x, undoImgSize.y);
        break;
      case 7: // redo
        PVector redoImgSize = getScaledImageSize(undoIcon, toolIconSize);
        pushMatrix();
        translate(x + toolIconSize / 2, y + toolIconSize / 2);
        scale(-1, 1);
        image(undoIcon, -redoImgSize.x / 2, -redoImgSize.y / 2, redoImgSize.x, redoImgSize.y);
        popMatrix();
        break;
      case 8: // clear all
        PVector trashIconSize = getScaledImageSize(trashClosedIcon, toolIconSize * 0.8);
        image(trashClosedIcon, x + (toolIconSize - trashIconSize.x) / 2, y + (toolIconSize - trashIconSize.y) / 2, trashIconSize.x, trashIconSize.y);
        break;
    }
  }
 // 브러쉬 크기 조절
  noFill();
  stroke(0);
  strokeWeight(1);
  float brushAreaRadius = width * (64.0f/1280.0f);
  float d = dist(brushPos[0],brushPos[1],mouseX,mouseY);
  if (d < brushAreaRadius + 2) {circle(brushPos[0], brushPos[1], (brushAreaRadius+2)*2);}
  else {circle(brushPos[0], brushPos[1], brushAreaRadius*2);}
  fill(selectedColor);
  circle(brushPos[0], brushPos[1], brushSize);
  popStyle();
    // 도형 그리기 미리보기
  pushStyle();
    if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
      stroke(selectedColor);
      strokeWeight(brushSize);
      noFill();
      if (tool.equals("line")) {
        // 화면 좌표계에 직접 그리기
        line(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("rect")) {
        rectMode(CORNERS);
        rect(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("circle")) {
        ellipseMode(CORNERS);
        ellipse(pmousePos[0], pmousePos[1], mouseX, mouseY);
      }
    }
  popStyle();
  pushStyle();
  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  // 컬러 팔레트
  if (isPalleteOpen) { 
    fill(255);
    noStroke();
    rect(colorPos[0] - colorSize/2 - 8, colorPos[1] - colorSize/2 - 8, colorGab_palette*2,colorGab_palette*6 + colorSize/2, 16);
    int[] p = new int[2];
    for (int i = 0; i < palleteColor.length; i++) {
      paletteCenter(i, p);
      if (i == palleteColor.length - 1) { // 마지막 슬롯은 컬러피커
        drawRainbowCircle(p[0], p[1], colorSize);
      } else {
        fill(palleteColor[i]);
        stroke(0);
        strokeWeight(1);
        circle(p[0], p[1], colorSize);
      }
    }
    if (mouseHober(colorPos[0]-(colorGab_palette/2), colorPos[1]-(colorGab_palette/2), 2*colorGab_palette, colorGab_palette*6)) {
      cursor(spoideCursor,0,30);
    }
    else {
      switch (tool) {
        case "brush":
          cursor(brushCursor,0,0);
          break;
        case "paint":
          cursor(paintCursor,0,0);
          break;
        case "eraser":
        cursor(eraserCursor,0,31);
          break;
        case "line":
          cursor(lineCursor.get(),2,2);
          break;
        case "rect":
          cursor(rectCursor.get(),2,2);
          break;
        case "circle":
          cursor(circleCursor.get(),2,2);
          break;
        default:
          cursor(ARROW);
      }
    }
  }
  // 저장 버튼
  if (mouseHober(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H)) { // Use BACK_X/Y as margin
    fill(255, 50);
    noStroke();
    rect(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H);
  }
  // image(saveImg, width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H);
  PVector newSize = getScaledImageSize(saveImg, SAVE_W, SAVE_H);
  image(saveImg, width - SAVE_W - BACK_X + (SAVE_W - newSize.x) / 2, height - SAVE_H - BACK_Y + (SAVE_H - newSize.y) / 2, newSize.x, newSize.y);
  drawBackButton();
  popStyle();
}
void handleCreatorMouse() {
  // 도구 선택
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    for (int i = 0; i < 9; i++) { // 9개 도구
      int c = i % 2;
      int r = i / 2;
      float x = toolPos[0] + c * toolGabX;
      float y = toolPos[1] + r * toolGabY;
      if (mouseHober(x, y, toolIconSize, toolIconSize)) {
        switch (i) { // 0-8 in order
          case 0:
            tool = "brush";
            cursor(brushCursor,0,0);
            break;
          case 1:
            tool = "paint";
            cursor(paintCursor,0,0);
            break;
          case 2:
            tool = "eraser";
            cursor(eraserCursor,0,31);
            break;
          case 3:
            tool = "line";
            cursor(lineCursor.get(),2,2);
            break;
          case 4:
            tool = "rect";
            cursor(rectCursor.get(),2,2);
            break;
          case 5:
            tool = "circle";
            cursor(circleCursor.get(),2,2);
            break;
          case 6: // 되돌리기
            undoPressed = true;
            break;
          case 7: // 다시 실행
            redoPressed = true;
            break;
          case 8: // 모두 지우기
            clearAllPressed = true;
            break;
        }
        return; // 도구가 선택되었으면 함수 종료
        }
    }
    // 색상 선택
    for (int i = 0; i < palleteColor.length; i++) {
      int[] p = new int[2];
      paletteCenter(i, p);
      float d2 = dist(mouseX, mouseY, p[0], p[1]);
      if (d2 < colorSize / 2.0f) {
        if (i == palleteColor.length - 1) { // 마지막 슬롯(컬러피커) 클릭
          rainbowPickerClicked = true;
        } else {
          selectedColor = palleteColor[i];
        }
        return; // 도구가 선택되었으면 함수 종료
      }
    }
    // 캔버스 내에서 도형 그리기 시작 확인
    if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
        if (tool.equals("brush") || tool.equals("eraser") || tool.equals("paint") || tool.equals("line") || tool.equals("rect") || tool.equals("circle")) {
            saveUndoState();
        }
    }
    if (tool.equals("line") || tool.equals("rect") || tool.equals("circle")) {
      if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
        isDrawingShape = true;
        pmousePos[0] = mouseX;
        pmousePos[1] = mouseY;
      }
    }
}
void handleCreatorDrag() {
  if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
     if (tool.equals("brush")) {
    // 마우스가 캔버스 안쪽에 있을 때만 그림
      // 화면 좌표를 캔버스 내부 좌표로 변환
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();
      stickerCanvas.stroke(selectedColor);
      stickerCanvas.strokeWeight(brushSize);
      stickerCanvas.strokeJoin(ROUND); // 선 연결부 둥글게
      stickerCanvas.strokeCap(ROUND);  // 선 끝 둥글게
      stickerCanvas.noFill();
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY); // 선 그리기
      stickerCanvas.endDraw();
    }
    if (tool.equals("paint")) {}
    if (tool.equals("eraser")) {
      // 화면 좌표를 캔버스 내부 좌표로 변환
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();
      stickerCanvas.blendMode(REPLACE); // 픽셀을 직접 교체하는 모드로 변경
      stickerCanvas.stroke(0, 0); // 완전히 투명한 색으로 설정
      stickerCanvas.strokeWeight(brushSize);
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY);
      stickerCanvas.blendMode(BLEND); // 기본 블렌딩 모드로 
      stickerCanvas.endDraw();
    }
  }
  float d = dist(brushPos[0],brushPos[1],mouseX,mouseY);
  float brushAreaRadius = width * (66.0f/1280.0f);
  if (d < brushAreaRadius) {
    brushSize += mouseX - pmouseX;
    cursor(sizeCursor.get());
    isBrushSizeChange = true;
    float maxBrushSize = width * (128.0f/1280.0f);
    if (brushSize > maxBrushSize) {
      brushSize = maxBrushSize;
    }
    if (brushSize < 1) {
      brushSize = 1;
    }
  }
}
void handleCreatorRelease() {
  // 모두 지우기 버튼 클릭 처리
  if (clearAllPressed) {
    clearAllPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    // i=8 -> c=0, r=4
    if (mouseHober(toolPos[0] + 0 * toolGabX, toolPos[1] + 4 * toolGabY, toolIconSize, toolIconSize)) {
      UiBooster booster = new UiBooster();
      boolean confirmed = booster.showConfirmDialog("Do you want to erase everything?", "Clear Canvas");
      if (confirmed) {
        saveUndoState(); // 지우기 전에 현재 상태 저장
        stickerCanvas.beginDraw();
        stickerCanvas.clear(); // 캔버스 내용을 모두 지웁니다.
        stickerCanvas.endDraw();
      }
    }
    return; // 다른 release 로직이 실행되지 않도록 함
  }
  // 되돌리기 버튼 클릭 처리
  if (undoPressed) {
    undoPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    // i=6 -> c=0, r=3
    if (mouseHober(toolPos[0] + 0 * toolGabX, toolPos[1] + 3 * toolGabY, toolIconSize, toolIconSize)) {
      performUndo();
    }
    return; // 다른 release 로직이 실행되지 않도록 함
  }
  // 다시 실행 버튼 클릭 처리
  if (redoPressed) {
    redoPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    // i=7 -> c=1, r=3
    if (mouseHober(toolPos[0] + 1 * toolGabX, toolPos[1] + 3 * toolGabY, toolIconSize, toolIconSize)) {
      performRedo();
    }
    return;
  }
  // 컬러피커 버튼 클릭 처리
  if (rainbowPickerClicked) {
    rainbowPickerClicked = false; // 플래그 리셋
    // 마우스를 놓은 위치가 여전히 컬러피커 아이콘 위인지 확인
    int[] p = new int[2];
    paletteCenter(palleteColor.length - 1, p);
    if (dist(mouseX, mouseY, p[0], p[1]) < colorSize / 2.0f) {
      UiBooster booster = new UiBooster();
      // 컬러피커를 열 때 기본 색상을 빨간색으로 설정합니다.
      java.awt.Color initialPickerColor = new java.awt.Color(255, 0, 0);
      java.awt.Color newColor = booster.showColorPicker("Select Color", "Choose a brush color", initialPickerColor);
      if (newColor != null) {
        selectedColor = color(newColor.getRed(), newColor.getGreen(), newColor.getBlue());
      }
    }
    return; // 다른 release 로직이 실행되지 않도록 함
  }
  // 저장 버튼 클릭 처리
  if (mouseHober(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H)) {
    saveSticker();
    switchScreen(sticker_library);
    return;
  }
  // 도형 그리기가 활성화된 상태에서 마우스를 놓았을 때
  if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
    // 화면 좌표를 캔버스 좌표로 변환 
    float startX = pmousePos[0] - canvasX;
    float startY = pmousePos[1] - canvasY;
    float endX = mouseX - canvasX;
    float endY = mouseY - canvasY;
    stickerCanvas.beginDraw();
    stickerCanvas.stroke(selectedColor);
    stickerCanvas.strokeWeight(brushSize);
    stickerCanvas.noFill(); // 도형의 내부는 채우지 않음
    if (tool.equals("line")) {
      stickerCanvas.line(startX, startY, endX, endY);
    } else if (tool.equals("rect")) {
      stickerCanvas.rectMode(CORNERS);
      stickerCanvas.rect(startX, startY, endX, endY);
    } else if (tool.equals("circle")) {
      stickerCanvas.ellipseMode(CORNERS);
      stickerCanvas.ellipse(startX, startY, endX, endY);
    }
    stickerCanvas.endDraw();
  }
  else if (isBrushSizeChange) {
    cursor(ARROW);
    isBrushSizeChange = false;
  }
  isDrawingShape = false; // 그리기 상태 초기화
}
 
void saveSticker() {
  PImage newStickerImg = stickerCanvas.get(); // 캔버스를 PImage로 변환
  cursor(ARROW);
  if (stickerToEdit != null) {
    // 스티커 편집 시에는 비어있어도 저장 (삭제 효과)
    stickerToEdit.img = newStickerImg; // 편집된 이미지로 교체
    newStickerImg.save(dataPath("sticker/" + stickerToEdit.imageName));
    println("Sticker updated: " + stickerToEdit.imageName);
  } else {
    // 새 스티커 저장, 단 캔버스가 비어있지 않은 경우에만
    if (!isCanvasBlank(stickerCanvas)) {
      String sticker_name = "sticker_" + year() + month() + day() + "_" + hour() + minute() + second() + ".png";
      Sticker newSticker = new Sticker(0, 0, newStickerImg, defaultStickerSize, sticker_name);  // 스티커 객체 생성
      stickerLibrary.add(newSticker); // 라이브러리 ArrayList에 추가
      newStickerImg.save(dataPath("sticker/" + sticker_name));
      println("New sticker saved: " + sticker_name);
    } else {
      println("Canvas is blank. New sticker not saved.");
    }
  }
}
void paletteCenter(int i, int[] outXY) {
  int col = (i > 5) ? 1 : 0;          
  int row = (i > 5) ? (i - 6) : i;    
  outXY[0] = round(colorPos[0] + col * colorGab_palette);                
  outXY[1] = round(colorPos[1] + row * colorGab_palette);     
}
void clearUndoStack() {
  if (undoStack == null) {
    undoStack = new ArrayList<PImage>();
  }
  if (redoStack == null) {
    redoStack = new ArrayList<PImage>();
  }
  undoStack.clear();
  redoStack.clear();
}
void saveUndoState() {
  // 새로운 작업을 시작하면 Redo 스택은 비워져야 함
  redoStack.clear();
  undoStack.add(stickerCanvas.get()); 
  if (undoStack.size() > MAX_UNDO_STATES) {
    undoStack.remove(0);
  }
}
void performUndo() {
  if (!undoStack.isEmpty()) {
    // 현재 상태를 Redo 스택에 저장
    redoStack.add(stickerCanvas.get());
    if (redoStack.size() > MAX_UNDO_STATES) {
      redoStack.remove(0);
    }
    // 이전 상태를 Undo 스택에서 가져와 적용
    PImage lastState = undoStack.remove(undoStack.size() - 1);
    stickerCanvas.beginDraw();
    stickerCanvas.clear();
    stickerCanvas.image(lastState, 0, 0, canvasSize, canvasSize);
    stickerCanvas.endDraw();
  }
}
void performRedo() {
  if (!redoStack.isEmpty()) {
    // Redo를 수행하기 전의 현재 상태를 undo 스택에 저장합니다.
    // redo 스택을 비우지 않기 위해 saveUndoState()를 직접 호출하지 않습니다.
    undoStack.add(stickerCanvas.get());
    if (undoStack.size() > MAX_UNDO_STATES) {
      undoStack.remove(0);
    }
    // redo 스택에서 다음 상태를 가져와 캔버스에 적용합니다.
    PImage nextState = redoStack.remove(redoStack.size() - 1);
    stickerCanvas.beginDraw();
    stickerCanvas.clear();
    stickerCanvas.image(nextState, 0, 0, canvasSize, canvasSize);
    stickerCanvas.endDraw();
  }
}
void drawRainbowCircle(float x, float y, float diameter) {
  pushStyle();
  noStroke();
  float radius = diameter / 2;
  color[] rainbowColors = {
    color(255, 0, 0), 
    color(255, 127, 0), 
    color(255, 255, 0), 
    color(0, 255, 0), 
    color(0, 0, 255), 
    color(75, 0, 130)
  };
  float angleStep = TWO_PI / rainbowColors.length;
  for (int i = 0; i < rainbowColors.length; i++) {
    fill(rainbowColors[i]);
    arc(x, y, diameter, diameter, i * angleStep - HALF_PI, (i + 1) * angleStep - HALF_PI, PIE);
  }
  stroke(0);
  strokeWeight(1);
  noFill();
  circle(x, y, diameter);
  popStyle();
}
boolean isCanvasBlank(PGraphics pg) {
  pg.loadPixels();
  for (int i = 0; i < pg.pixels.length; i++) {
    // 픽셀이 완전히 투명하지 않은지 확인 (알파 > 0)
    if (alpha(pg.pixels[i]) > 0) {
      return false; // 투명하지 않은 픽셀 발견
    }
  }
  return true; // 모든 픽셀이 투명함
}