GUIController c;
IFButton b1;
IFLabel l;

boolean isButtonPressed;
boolean pressedOnNameBtn = false;

public void drawMenuScreen() {

    pushStyle();

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

    // 추가 버튼 만들고 싶으실 때
    // push-popMatrix에서 빼면 드래그 영향 안받아요! 고정됩니다.
    pushMatrix();
    
    translate(-menuScrollX, 0);

    dsButton.render();
    slButton.render();
    ddButton.render();
    dlButton.render();

    popMatrix();

    nameButton.render();

    boolean hoverScrollable =
      mouseHober(worldMouseX(), worldMouseY(),
                dsButton.position_x, dsButton.position_y, dsButton.width, dsButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                slButton.position_x, slButton.position_y, slButton.width, slButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                ddButton.position_x, ddButton.position_y, ddButton.width, ddButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                dlButton.position_x, dlButton.position_y, dlButton.width, dlButton.height);


    boolean hoverFixed =
      mouseHober(mouseX, mouseY,
                nameButton.position_x, nameButton.position_y, nameButton.width, nameButton.height);


    if (hoverScrollable || hoverFixed) {
      image(cursorImage, mouseX, mouseY, 50, 50);
    }

    if (isNameEntered) {
      
      pushStyle();
      fill(0);
      textAlign(CENTER, TOP);   
      textSize(16);             
      text("NAME : " + username,
          NAME_X + NAME_W/2,
          NAME_Y + NAME_H + 8);
      popStyle();
      
  }

    popStyle();

}

public void handleMenuMousePressed() {

  dsButton.onPress((int)worldMouseX(), (int)worldMouseY());
  slButton.onPress((int)worldMouseX(), (int)worldMouseY());
  ddButton.onPress((int)worldMouseX(), (int)worldMouseY());
  dlButton.onPress((int)worldMouseX(), (int)worldMouseY());
  nameButton.onPress(mouseX, mouseY);
  
  if (hitScreen(nameButton, mouseX, mouseY)) {

    pressedOnNameBtn = true;
    isMenuDragging = false;  
    totalDragDist = 0;
    return;

  }

  pressedOnNameBtn = false;
  isMenuDragging = true;
  dragStartX = mouseX;
  dragStartScroll = menuScrollX;
  totalDragDist = 0;

}

public void handleMenuDragged() {

  if (pressedOnNameBtn) return;  
  if (!isMenuDragging) return;
  float dx = mouseX - dragStartX;
  totalDragDist = max(totalDragDist, abs(dx));
  menuScrollX = constrain(dragStartScroll - dx, 0, PAGE_WIDTH);

  dsButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  slButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  ddButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  dlButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  nameButton.onDrag(mouseX, mouseY);

}

public void handleMenuReleased() {

  boolean clickDS = dsButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickSL = slButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDD = ddButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDL = dlButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickNAME = nameButton.onRelease(mouseX, mouseY);

  if (pressedOnNameBtn) {
    
    if (totalDragDist < 10) switchScreen(name_screen);
    pressedOnNameBtn = false;
    return;

  }

  if (!isMenuDragging) return;
  isMenuDragging = false;

  if (totalDragDist < 10) {

      if (clickDS) { switchScreen(making_sticker);  return; }
      if (clickSL) { switchScreen(sticker_library); return; }
      if (clickDD) { switchScreen(drawing_diary);   return; }
      if (clickDL) { switchScreen(diary_library);   return; }
      if (clickNAME) { switchScreen(name_screen);   return; }

  } else {
      menuTargetScrollX = (menuScrollX > PAGE_WIDTH * 0.5f) ? PAGE_WIDTH : 0;
  }

}

private boolean hitScreen(rectButton b, float sx, float sy) {
  return (sx > b.position_x && sx < b.position_x + b.width &&
          sy > b.position_y && sy < b.position_y + b.height);
}
