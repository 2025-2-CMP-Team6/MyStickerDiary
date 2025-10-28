// StickerLibrary.pde
// Owner: 

float libraryScrollY = 0;
float minLibraryScrollY = 0;

// Scrollbar Variables
boolean isDraggingLibScrollbar = false;
float libScrollbarDragStartY;
float libScrollbarDragStartScrollY;
float libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH;
float libThumbY, libThumbH;

void drawLibrary() {
    background(220, 240, 220);
    imageMode(CENTER);
    rectMode(CENTER);
    // Title
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("Sticker Library", width/2, height*(60.0f/720.0f));
  
    // New Sticker Button
    if (mouseHober(width/2 - width*(140.0f/1280.0f), height - height*(110.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f))) {
      fill(230, 230, 160);
    } else {
      fill(220, 220, 150);
    }
    rect(width/2, height - height*(80.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f));
    fill(0);
    textSize(30);
    text("+ Making new Sticker!", width/2, height - height*(80.0f/720.0f));
  
    // Draw Sticker List

    pushStyle();
    rectMode(CORNER);
    float boxSize = width * (150.0f/1280.0f);
    float spacing = width * (180.0f/1280.0f);
    float startX = width * (200.0f/1280.0f);
    float startY = height * (200.0f/720.0f);
    int cols = 6;

    // Calculate View & Content Height
    float viewHeight = height - startY - height*(120.0f/720.0f); // Visible Area Height
    float contentHeight = 0;

    // Scroll Range
    if (stickerLibrary.size() > 0) {
      int numRows = (stickerLibrary.size() - 1) / cols + 1;
      contentHeight = (numRows - 1) * spacing + boxSize;
      minLibraryScrollY = max(0, contentHeight - viewHeight);
    } else {
      minLibraryScrollY = 0;
    }
    clip(0, startY + spacing, width*2, height - boxSize - 128); 
  
    for (int i = 0; i < stickerLibrary.size(); i++) {
      Sticker s = stickerLibrary.get(i);
      int c = i % cols;
      int r = i / cols;
      
      s.x = startX + c * spacing;
      s.y = startY + r * spacing - libraryScrollY;
      
      PImage img = s.img;
      PVector newSize = getScaledImageSize(img, boxSize);
  
      // Draw Image with New Size
      image(img, s.x, s.y, newSize.x, newSize.y);
      
      // Check Mouse Area
      if (mouseHober(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y)) {
        rectMode(CORNER);
        stroke(0);
        strokeWeight(3);
        noFill();
        rect(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y);
        strokeWeight(1);

        // Draw Delete Button
        float deleteBtnRadius = max(10, width * (8.0f / 1280.0f)); // Min 10px
        float deleteBtnX = s.x + newSize.x/2;
        float deleteBtnY = s.y - newSize.y/2;

        pushStyle();
        if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
            fill(255, 50, 50); // Hover color
        } else {
            fill(200, 0, 0);
        }
        stroke(255);
        strokeWeight(1.5);
        circle(deleteBtnX, deleteBtnY, deleteBtnRadius * 2);
        line(deleteBtnX - deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX + deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
        line(deleteBtnX + deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX - deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
        popStyle();

        fill(0);
      }
      
    }
    noClip();
    // Draw Scrollbar
    if (minLibraryScrollY > 0) {
      libScrollbarW = width * (12.0f/1280.0f);
      float scrollbarMargin = width * (20.0f/1280.0f);
      libScrollbarX = width - scrollbarMargin - libScrollbarW;
      libScrollbarY = height * (80.0f/720.0f);
      libScrollbarH = height - height * (200.0f/720.0f);
  
      // Scrollbar Track
      fill(200, 180);
      noStroke();
      rect(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH, 6);
  
      // Scrollbar Thumb
      thumbH = libScrollbarH * (viewHeight / contentHeight);
      thumbH = max(thumbH, 25);
      float scrollableDist = libScrollbarH - thumbH;
      float scrollRatio = libraryScrollY / minLibraryScrollY;
      thumbY = libScrollbarY + scrollableDist * scrollRatio;
      if (isDraggingLibScrollbar || mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
        fill(120);
      } else {
        fill(170);
      }
      rect(libScrollbarX, thumbY, libScrollbarW, thumbH, 6);
    }
    
    drawBackButton(); // Call Common Back Button
    popStyle();
  }
  
  void handleLibraryMouse() {
    // Check Scrollbar Drag
    if (minLibraryScrollY > 0 && mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      isDraggingLibScrollbar = true;
      libScrollbarDragStartY = mouseY;
      libScrollbarDragStartScrollY = libraryScrollY;
    }
  } 
  void handleLibraryDrag() {
    // Handle Scrollbar Drag
    if (isDraggingLibScrollbar) {
      float dy = mouseY - libScrollbarDragStartY;
      float scrollablePixelRange = libScrollbarH - thumbH;
      if (scrollablePixelRange > 0) {
        float scrollAmount = dy * (minLibraryScrollY / scrollablePixelRange);
        libraryScrollY = constrain(libScrollbarDragStartScrollY + scrollAmount, 0, minLibraryScrollY);
      }
    }
  }

  void handleLibraryMouseReleased() {
    if (isDraggingLibScrollbar) {
      isDraggingLibScrollbar = false;
      return;
    }

    // Check New Sticker Button Click (High Priority)
    if (mouseHober(width/2 - width*(140.0f/1280.0f), height - height*(110.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f))) {
      switchScreen(making_sticker);
      return;
    }

    // Check Sticker Click/Delete
    float boxSize = width * (150.0f/1280.0f);

    // Iterate backwards to safely remove items
    for (int i = stickerLibrary.size() - 1; i >= 0; i--) {
        Sticker s = stickerLibrary.get(i);
        PImage img = s.img;
        PVector newSize = getScaledImageSize(img, boxSize);
        if (mouseHober(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y)) {
            // Check Delete Button Click
            float deleteBtnRadius = max(10, width * (8.0f / 1280.0f));
            float deleteBtnX = s.x + newSize.x/2;
            float deleteBtnY = s.y - newSize.y/2;

            if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
                UiBooster booster = new UiBooster();
                boolean confirmed = booster.showConfirmDialog("Are you sure you want to delete this sticker?", "Delete Sticker");
                if (confirmed) {
                    // Delete File
                    File stickerFile = new File(dataPath("sticker/" + s.imageName));
                    if (stickerFile.exists()) {
                        if (!stickerFile.delete()) {
                            println("Failed to delete sticker file: " + s.imageName);
                        }
                    }
                    // Remove Sticker from Library
                    stickerLibrary.remove(i);
                }
                return; // Process One Action at a Time
            }

            // If Not Delete, Go to Edit Screen
            stickerToEdit = s;
            stickerCanvas.beginDraw();
            stickerCanvas.clear();
            stickerCanvas.image(stickerToEdit.img, 0, 0, canvasSize, canvasSize);
            stickerCanvas.endDraw();
            switchScreen(making_sticker);
            return;
        }
    }

    // Scrollbar Track Click
    if ((minLibraryScrollY > 0) && mouseHober(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH) && !mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      // Move Scroll
      float clickRatio = (mouseY - libScrollbarY - thumbH / 2) / (libScrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      libraryScrollY = clickRatio * minLibraryScrollY;
    }
}

void handleLibraryMouseWheel(MouseEvent ev) {
  if (mouseHober(width*(130.0f/1280.0f), height*(164.0f/720.0f), width - width*(270.0f/1280.0f), height - height*(280.0f/720.0f))) {
    float scrollAmount = ev.getCount() * 10; // Scroll Speed
    libraryScrollY = constrain(libraryScrollY + scrollAmount, 0, minLibraryScrollY);
  }
}
