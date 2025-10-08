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

    if(isNameEntered) {
      text("NAME : " + username, NAME_X + NAME_W / 2, NAME_Y + NAME_H + 20);
    }

    popStyle();

}

public void handleMenuMousePressed() {
  
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

}

public void handleMenuReleased() {

  if (pressedOnNameBtn) {
    
    if (totalDragDist < 10) switchScreen(name_screen);
    pressedOnNameBtn = false;
    return;

  }

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

  if (hit(dsButton, wx, wy)) { switchScreen(making_sticker); return; }
  if (hit(slButton, wx, wy)) { switchScreen(sticker_library); return; }
  if (hit(ddButton, wx, wy)) { switchScreen(drawing_diary);   return; }
  if (hit(dlButton, wx, wy)) { switchScreen(diary_library);   return; }

  if (hitScreen(nameButton, mouseX, mouseY)) {
    switchScreen(name_screen);
    return;
  }

}

private boolean hit(rectButton b, float wx, float wy) {

  return (wx > b.position_x && wx < b.position_x + b.width &&
          wy > b.position_y && wy < b.position_y + b.height);
          
}

private boolean hitScreen(rectButton b, float sx, float sy) {
  return (sx > b.position_x && sx < b.position_x + b.width &&
          sy > b.position_y && sy < b.position_y + b.height);
}
