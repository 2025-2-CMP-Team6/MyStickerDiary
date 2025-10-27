// MakingSticker.pde

// Sticker Canvas Setting
PGraphics stickerCanvas;
float canvasSize;
float canvasX, canvasY;
// Tool Setting
String tool = "";
float toolGab;
float toolPos[] = new float[2];
String posTool;

color selectedColor = color(0, 0, 0);
float brushSize = 20;

boolean isBrushSizeChange = false;
float brushPos[] = new float[2];
PGraphics sizeCursor;
// Shape Drawing Tool Setting
boolean isDrawingShape = false;
int[] pmousePos = new int[2];
int[] linePos = new int[2];
int[] circlePos = new int[2];
int[] rectPos = new int[2];
// Color Pallete Setting
boolean isPalleteOpen = true;
float[] colorPos = new float[2];
float colorSize;
float colorGab_palette;
boolean colorToggle = false;
boolean rainbowPickerClicked = false;
boolean clearAllPressed = false;
// Redo / Undo
boolean undoPressed = false;
boolean redoPressed = false;
ArrayList<PImage> undoStack;
ArrayList<PImage> redoStack;
final int MAX_UNDO_STATES = 30;
float SAVE_W, SAVE_H;

void setupCreator() {
  // Set Canvas Size
  canvasSize = height * (680.0f / 720.0f);
  // Create Graphic buffer for Stickers
  stickerCanvas = createGraphics(round(canvasSize), round(canvasSize));
  canvasX = (width - canvasSize) / 2; 
  canvasY = (height - canvasSize) / 2; 
  strokeJoin(ROUND);
  strokeCap(ROUND);
  stickerCanvas.beginDraw();
  stickerCanvas.clear();
  stickerCanvas.endDraw();
  // Initial Setting
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
// Tool Cursor Setting
// Line Cusor
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
 // Cricle Cursor
 circleCursor = createGraphics(32,32);
 circleCursor.noSmooth();
 circleCursor.beginDraw();
 circleCursor.stroke(0);
 circleCursor.strokeWeight(1);
 circleCursor.line(0,2,4,2);
 circleCursor.line(2,0,2,4);
 circleCursor.circle(8,8,10);
 circleCursor.endDraw();
// Brush Cursor
 sizeCursor = createGraphics(8,8);
 sizeCursor.noSmooth(); 
 sizeCursor.beginDraw();
 sizeCursor.noStroke(); 
 sizeCursor.fill(0);
 sizeCursor.triangle(3,0, 0,3, 3,7);
 sizeCursor.triangle(4,0, 7,3, 4,7);
 sizeCursor.endDraw();
}

void drawCreator() {  // Draw in Making Sticker
  pushStyle();
  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  background(#FBDAB0);
  stroke(0,1);
  fill(255,255,255);
  rect(canvasX, canvasY, canvasSize, canvasSize); // Canvas Rectangle
  image(stickerCanvas, canvasX, canvasY);
  
  // --- UI ---
  rectMode(CORNER);
  float toolIconSize = width * (56.0f / 1280.0f);
  float toolGabX = toolIconSize + width * (16.0f/1280.0f);
  float toolGabY = toolGab;
  // Tool Hover effect
  for (int i = 0; i < 9; i++) {
    int c = i % 2;
    int r = i / 2;
    float x = toolPos[0] + c * toolGabX;
    float y = toolPos[1] + r * toolGabY;
    if (mouseHober(x, y, toolIconSize, toolIconSize)) {
      fill(255, 50);
      noStroke();
      rect(x, y, toolIconSize, toolIconSize);
    }

    String currentToolName = "";  // Currently Selected Tool
    switch(i) {
      case 0: currentToolName = "brush"; break;
      case 1: currentToolName = "paint"; break;
      case 2: currentToolName = "eraser"; break;
      case 3: currentToolName = "line"; break;
      case 4: currentToolName = "rect"; break;
      case 5: currentToolName = "circle"; break;
    }
    if (!currentToolName.isEmpty() && tool.equals(currentToolName)) {
      pushStyle();
      noFill();
      stroke(#96DA4A);
      strokeWeight(3);
      rectMode(CORNER);
      rect(x - 4, y - 4, toolIconSize + 6, toolIconSize + 6, 4);
      popStyle();
    }
  }
  // Tool Icon drawing
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
 // ReSizing Brush Size
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

    // Draw Shape When Mouse Dragging
  pushStyle();
    if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
      stroke(selectedColor);
      strokeWeight(brushSize);
      noFill();
      if (tool.equals("line")) {  // Line
        line(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("rect")) { // Rectangle
        rectMode(CORNERS);
        rect(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("circle")) { // cricle
        ellipseMode(CORNERS);
        ellipse(pmousePos[0], pmousePos[1], mouseX, mouseY);
      }
    }
  popStyle();
  pushStyle();
  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  // Draw Color Pallete
  if (isPalleteOpen) { 
    fill(255);
    noStroke();
    rect(colorPos[0] - colorSize/2 - 8, colorPos[1] - colorSize/2 - 8, colorGab_palette*2,colorGab_palette*6 + colorSize/2, 16);
    int[] p = new int[2];
    for (int i = 0; i < palleteColor.length; i++) {
      paletteCenter(i, p);
      if (i == palleteColor.length - 1) { // Color Picker Icon
        drawRainbowCircle(p[0], p[1], colorSize);
      } else {
        fill(palleteColor[i]);
        stroke(0);
        strokeWeight(1);
        circle(p[0], p[1], colorSize);
      }
    }

    boolean onCanvas = mouseHober(canvasX, canvasY, canvasSize, canvasSize);
    if (onCanvas && (tool.equals("brush") || tool.equals("eraser"))) {  // Brush or Eraser Cursor on Canvas
        noCursor(); 
        pushStyle();
        
        int canvasMouseX = round(mouseX - canvasX);
        int canvasMouseY = round(mouseY - canvasY);
        color underCursorColor = stickerCanvas.get(canvasMouseX, canvasMouseY);

        // Setting Cursor Color in Canvas
        color cursorColor;
        if (alpha(underCursorColor) < 128) { 
            cursorColor = color(0);
        } else if (brightness(underCursorColor) < 128) {
            cursorColor = color(255);
        } else {
            cursorColor = color(0);
        }

        noFill();
        stroke(cursorColor);
        strokeWeight(1);
        ellipseMode(CENTER);
        ellipse(mouseX, mouseY, brushSize, brushSize);
        popStyle();
    } else {  // Setting Cursor in other Tool
      if (isBrushSizeChange) {
        cursor(sizeCursor.get());
      } else if (mouseHober(colorPos[0]-(colorGab_palette/2), colorPos[1]-(colorGab_palette/2), 2*colorGab_palette, colorGab_palette*6)) {
        cursor(spoideCursor,0,30);
      } else {
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
  }
  // Save Button
  if (mouseHober(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H)) {
    fill(255, 50);
    noStroke();
    rect(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H);
  }
  PVector newSize = getScaledImageSize(saveImg, SAVE_W, SAVE_H);
  image(saveImg, width - SAVE_W - BACK_X + (SAVE_W - newSize.x) / 2, height - SAVE_H - BACK_Y + (SAVE_H - newSize.y) / 2, newSize.x, newSize.y);
  drawBackButton();
  popStyle();
}
void handleCreatorMouse() { // Mouse Click in Making Sticker
  // Select Tools
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    for (int i = 0; i < 9; i++) {
      int c = i % 2;
      int r = i / 2;
      float x = toolPos[0] + c * toolGabX;
      float y = toolPos[1] + r * toolGabY;
      if (mouseHober(x, y, toolIconSize, toolIconSize)) {
        switch (i) {
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
          case 6:
            undoPressed = true;
            break;
          case 7:
            redoPressed = true;
            break;
          case 8:
            clearAllPressed = true;
            break;
        }
        return;
      }
    }
    
    // Resizing Brush Size
    float d_brush = dist(brushPos[0], brushPos[1], mouseX, mouseY);
    float brushAreaRadius = width * (66.0f/1280.0f);
    if (d_brush < brushAreaRadius) {
      isBrushSizeChange = true;
      return;
    }

    // Select Color
    for (int i = 0; i < palleteColor.length; i++) {
      int[] p = new int[2];
      paletteCenter(i, p);
      float d2 = dist(mouseX, mouseY, p[0], p[1]);
      if (d2 < colorSize / 2.0f) {
        if (i == palleteColor.length - 1) { // Select ColorPicker
          rainbowPickerClicked = true;
        } else {
          selectedColor = palleteColor[i];
        }
        return;
      }
    }
    // Start Drawing When Mouse Click in Canvas
    if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
        if (tool.equals("brush") || tool.equals("eraser") || tool.equals("paint") || tool.equals("line") || tool.equals("rect") || tool.equals("circle")) { // Update Undo State
            saveUndoState();
        }
        if (tool.equals("paint")) { // Paint Tool
            int canvasMouseX = round(mouseX - canvasX);
            int canvasMouseY = round(mouseY - canvasY);
            
            floodFill(canvasMouseX, canvasMouseY, selectedColor);

            return;
        }
    }
    if (tool.equals("line") || tool.equals("rect") || tool.equals("circle")) {  // Shape Drawing Tools
      if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
        isDrawingShape = true;
        pmousePos[0] = mouseX;
        pmousePos[1] = mouseY;
      }
    }
}
// Mouse Drag in Making Sticker
void handleCreatorDrag() {
  if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
     if (tool.equals("brush")) {  // Brush Tool
      // Convert mouse position to canvas coordinates
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();
      stickerCanvas.stroke(selectedColor);
      stickerCanvas.strokeWeight(brushSize);
      stickerCanvas.strokeJoin(ROUND);
      stickerCanvas.strokeCap(ROUND);
      stickerCanvas.noFill();
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY);
      stickerCanvas.endDraw();
    }
    if (tool.equals("eraser")) {  // Eraser Tool
      // Convert mouse position to canvas coordinates
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();
      stickerCanvas.blendMode(REPLACE);
      stickerCanvas.stroke(0, 0);
      stickerCanvas.strokeWeight(brushSize);
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY);
      stickerCanvas.blendMode(BLEND);
      stickerCanvas.endDraw();
    }
  }
  
  if (isBrushSizeChange) {  // When Brush Size Changing
    brushSize += mouseX - pmouseX;
    float maxBrushSize = width * (128.0f/1280.0f);
    if (brushSize > maxBrushSize) {
      brushSize = maxBrushSize;
    }
    if (brushSize < 1) {
      brushSize = 1;
    }
  }

}
// Mouse Release in Making Sticker
void handleCreatorRelease() {
  // Clear All Tool
  if (clearAllPressed) {
    clearAllPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    if (mouseHober(toolPos[0] + 0 * toolGabX, toolPos[1] + 4 * toolGabY, toolIconSize, toolIconSize)) {
      UiBooster booster = new UiBooster();
      boolean confirmed = booster.showConfirmDialog("Do you want to erase everything?", "Clear Canvas");  // Asking User
      if (confirmed) {
        saveUndoState();
        stickerCanvas.beginDraw();
        stickerCanvas.clear();
        stickerCanvas.endDraw();
      }
    }
    return;
  }
  // Undo Tool
  if (undoPressed) {
    undoPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    if (mouseHober(toolPos[0] + 0 * toolGabX, toolPos[1] + 3 * toolGabY, toolIconSize, toolIconSize)) {
      performUndo();
    }
    return;
  }
  // Redo Tool
  if (redoPressed) {
    redoPressed = false;
    float toolIconSize = width * (56.0f / 1280.0f);
    float toolGabX = toolIconSize + width * (16.0f/1280.0f);
    float toolGabY = toolGab;
    if (mouseHober(toolPos[0] + 1 * toolGabX, toolPos[1] + 3 * toolGabY, toolIconSize, toolIconSize)) {
      performRedo();
    }
    return;
  }
  // Color Picker Tool
  if (rainbowPickerClicked) {
    rainbowPickerClicked = false;
    int[] p = new int[2];
    paletteCenter(palleteColor.length - 1, p);
    if (dist(mouseX, mouseY, p[0], p[1]) < colorSize / 2.0f) {
      UiBooster booster = new UiBooster();
      // Setting Default Color to Red
      java.awt.Color initialPickerColor = new java.awt.Color(255, 0, 0);
      java.awt.Color newColor = booster.showColorPicker("Select Color", "Choose a brush color", initialPickerColor);
      if (newColor != null) {
        selectedColor = color(newColor.getRed(), newColor.getGreen(), newColor.getBlue());
      }
    }
    return;
  }
  // Save Button Click
  if (mouseHober(width - SAVE_W - BACK_X, height - SAVE_H - BACK_Y, SAVE_W, SAVE_H)) {
    saveSticker();
    if (returnToDiaryAfterEdit) { switchScreen(drawing_diary); returnToDiaryAfterEdit = false; overlayWasVisibleBeforeEdit = false; } else { switchScreen(sticker_library); }
    return;
  }
  // Shape Drawing Tools
  if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
    // Convert mouse position to canvas coordinates
    float startX = pmousePos[0] - canvasX;
    float startY = pmousePos[1] - canvasY;
    float endX = mouseX - canvasX;
    float endY = mouseY - canvasY;
    stickerCanvas.beginDraw();  // Fix Shape in Canvas
    stickerCanvas.stroke(selectedColor);
    stickerCanvas.strokeWeight(brushSize);
    stickerCanvas.noFill();
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
    isBrushSizeChange = false;
  }

  isDrawingShape = false; // Initialize Drawing State
}

// Save Created Sticker
void saveSticker() {
  PImage newStickerImg = stickerCanvas.get(); // Convert Canvas to PImage
  cursor(ARROW);
  if (stickerToEdit != null) {  // Edit Sticker
    stickerToEdit.img = newStickerImg; // Update Sticker Image
    newStickerImg.save(dataPath("sticker/" + stickerToEdit.imageName));
    println("Sticker updated: " + stickerToEdit.imageName);
  } else {  // Making New Sticker
    if (!isCanvasBlank(stickerCanvas)) {  // When Canvas not Blank
      String sticker_name = "sticker_" + year() + month() + day() + "_" + hour() + minute() + second() + ".png";
      Sticker newSticker = new Sticker(0, 0, newStickerImg, defaultStickerSize, sticker_name);  // Create Sticker Class
      stickerLibrary.add(newSticker); // add Sticker to ArrayList 
      newStickerImg.save(dataPath("sticker/" + sticker_name));
      println("New sticker saved: " + sticker_name);
    } else {
      println("Canvas is blank. New sticker not saved.");
    }
  }
}
// @return Center of Circle
void paletteCenter(int i, int[] outXY) {
  int col = (i > 5) ? 1 : 0;          
  int row = (i > 5) ? (i - 6) : i;    
  outXY[0] = round(colorPos[0] + col * colorGab_palette);                
  outXY[1] = round(colorPos[1] + row * colorGab_palette);     
}
// Reset Undo/Redo
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
// Save Undo/Redo
void saveUndoState() {
  isStickerModified = true;
  redoStack.clear();
  undoStack.add(stickerCanvas.get()); 
  if (undoStack.size() > MAX_UNDO_STATES) {
    undoStack.remove(0);
  }
}

void performUndo() {
  if (!undoStack.isEmpty()) {
    isStickerModified = true;
    redoStack.add(stickerCanvas.get());
    if (redoStack.size() > MAX_UNDO_STATES) {
      redoStack.remove(0);
    }
    // Get Previous State from Undo Stack
    PImage lastState = undoStack.remove(undoStack.size() - 1);
    stickerCanvas.beginDraw();
    stickerCanvas.clear();
    stickerCanvas.image(lastState, 0, 0, canvasSize, canvasSize);
    stickerCanvas.endDraw();
  }
}

void performRedo() {
  if (!redoStack.isEmpty()) {
    isStickerModified = true;
    undoStack.add(stickerCanvas.get());
    if (undoStack.size() > MAX_UNDO_STATES) {
      undoStack.remove(0);
    }
    // Get Next State from Redo Stack
    PImage nextState = redoStack.remove(redoStack.size() - 1);
    stickerCanvas.beginDraw();
    stickerCanvas.clear();
    stickerCanvas.image(nextState, 0, 0, canvasSize, canvasSize);
    stickerCanvas.endDraw();
  }
}
/**
 * FloodFill Algorithm using in Paint Tool
 * @param x input x
 * @param y input y
 * @param color input color
 */
void floodFill(int x, int y, color replacementColor) {
  int canvasW = stickerCanvas.width;
  int canvasH = stickerCanvas.height;

  if (x < 0 || x >= canvasW || y < 0 || y >= canvasH) return;

  stickerCanvas.loadPixels();

  color targetColor = stickerCanvas.get(x, y);
  if (targetColor == replacementColor) {
    // No need to updatePixels() if nothing changed
    return;
  }
// Fill Translucent Pixels made due to Anti-aliasing
  final int ALPHA_BOUNDARY_THRESHOLD = 250;
  if (alpha(targetColor) >= ALPHA_BOUNDARY_THRESHOLD) {
    return;
  }
  // Flood fill algorithm
  ArrayList<PVector> queue = new ArrayList<PVector>();
  queue.add(new PVector(x,y));
  while (!queue.isEmpty()) {
    PVector p = queue.remove(0);
    int px = int(p.x);
    int py = int(p.y);

    if (px < 0 || px >= canvasW || py < 0 || py >= canvasH) {
      continue;
    }

    int loc = px + py * canvasW;
    // Fill new Color
    if (alpha(stickerCanvas.pixels[loc]) < ALPHA_BOUNDARY_THRESHOLD && stickerCanvas.pixels[loc] != replacementColor) {
      stickerCanvas.pixels[loc] = replacementColor;
      // Add neighboring pixels to the queue
      if (px + 1 < canvasW) queue.add(new PVector(px + 1, py));
      if (px - 1 >= 0)      queue.add(new PVector(px - 1, py));
      if (py + 1 < canvasH) queue.add(new PVector(px, py + 1));
      if (py - 1 >= 0)      queue.add(new PVector(px, py - 1));
    }
  }
  stickerCanvas.updatePixels();
}
// Color Picker Drawing
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
/**
 * Check Whether Canvas Blank or not
 * @param pg input PGraphics
 * @return boolean If Canvas Blank return true
 */
boolean isCanvasBlank(PGraphics pg) {
  pg.loadPixels();
  for (int i = 0; i < pg.pixels.length; i++) {
    if (alpha(pg.pixels[i]) > 0) {
      return false;
    }
  }
  return true;
}

void resetCreator() {
  // Reset Canvas
  stickerCanvas.beginDraw();
  stickerCanvas.clear();
  stickerCanvas.endDraw();

  // Reset Tools
  tool = "";
  selectedColor = color(0, 0, 0);
  brushSize = 20;

  // Reset Undo/Redo
  clearUndoStack();

  // Reset Tool Setting
  isDrawingShape = false;
  isBrushSizeChange = false;
  clearAllPressed = false;
  undoPressed = false;
  redoPressed = false;
  rainbowPickerClicked = false;
}