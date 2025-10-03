GUIController c;
IFButton b1;
IFLabel l;

boolean isButtonPressed;

public void drawMenuScreen() {

    background(#FFCA1A);

    fill(#FFE880);
    noStroke();
    quad(0, 0, 0, 300, 1280, 400, 1280, 0);

    fill(0);
    textSize(50);
    text("Main Menu", 120, 40);

    if (!isMenuDragging) {

        menuScrollX += (menuTargetScrollX - menuScrollX) * 0.20; 

        if (abs(menuTargetScrollX - menuScrollX) < 0.5) {
            menuScrollX = menuTargetScrollX;
        }
        
  }

    pushMatrix();
    
    translate(-menuScrollX, 0);

    dsButton.render();
    slButton.render();
    ddButton.render();
    dlButton.render();

    popMatrix();

}

public void handleMenuMousePressed() {

  isMenuDragging = true;
  dragStartX = mouseX;
  dragStartScroll = menuScrollX;
  totalDragDist = 0;

}


public void handleMenuDragged() {

  if (!isMenuDragging) return;
  float dx = mouseX - dragStartX;            
  totalDragDist = max(totalDragDist, abs(dx));
  menuScrollX = constrain(dragStartScroll - dx, 0, PAGE_WIDTH);

}

public void handleMenuReleased() {

  if (!isMenuDragging) return;
  isMenuDragging = false;

  if (totalDragDist < 10) {

    handleMenuTap();
    return;

  }

  menuTargetScrollX = (menuScrollX > PAGE_WIDTH * 0.5f) ? PAGE_WIDTH : 0;

}


private void handleMenuTap() {

  float wx = worldMouseX();
  float wy = worldMouseY();

  if (hit(dsButton, wx, wy)) {

    currentScreen = making_sticker;
    return;
    
  }

  if (hit(slButton, wx, wy)) {

    currentScreen = sticker_library;
    return;

  }

  if (hit(ddButton, wx, wy)) {

    currentScreen = drawing_diary;
    return;

  }

  if (hit(dlButton, wx, wy)) {

    currentScreen = diary_library;
    return;

  }
}

private boolean hit(rectButton b, float wx, float wy) {

  return (wx > b.position_x && wx < b.position_x + b.width &&
          wy > b.position_y && wy < b.position_y + b.height);
          
}