// MenuScreen.pde

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

    // nameButton.render(); // 기존 render 호출 제거, G4P 버튼은 자동 렌더링

    boolean hoverScrollable =
      mouseHober(worldMouseX(), worldMouseY(),
                 dsButton.position_x, dsButton.position_y, dsButton.width, dsButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 slButton.position_x, slButton.position_y, slButton.width, slButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 ddButton.position_x, ddButton.position_y, ddButton.width, ddButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 dlButton.position_x, dlButton.position_y, dlButton.width, dlButton.height);

    // 수정된 부분: GImageButton은 자체 호버 효과가 있으므로, 기존 호버 로직에서 제외.
    // boolean hoverFixed =
    //   mouseHober(mouseX, mouseY,
    //              nameButton.position_x, nameButton.position_y, nameButton.width, nameButton.height);
    
    // if (hoverScrollable || hoverFixed) {
    if (hoverScrollable) { // nameButton에 대한 hoverFixed 조건 제거
      image(cursorImage, mouseX, mouseY, 50, 50);
    }
    // 수정 끝

    if (isNameEntered) {
      pushStyle();
      fill(0);
      textAlign(CENTER, TOP);   
      textSize(16);           
      // 수정된 부분: GImageButton의 위치에 맞춰 텍스트 위치를 조정합니다.
      text("NAME : " + username,
           nameEditButton.getX() + nameEditButton.getWidth() / 2, // 버튼의 x 중앙
           nameEditButton.getY() + nameEditButton.getHeight() + 8); // 버튼의 y 하단 + 간격
      popStyle();
      // 수정 끝
  }

    popStyle();

}

public void handleMenuMousePressed() {

  dsButton.onPress((int)worldMouseX(), (int)worldMouseY());
  slButton.onPress((int)worldMouseX(), (int)worldMouseY());
  ddButton.onPress((int)worldMouseX(), (int)worldMouseY());
  dlButton.onPress((int)worldMouseX(), (int)worldMouseY());
  // nameButton.onPress(mouseX, mouseY); // G4P 버튼으로 대체되어 제거

  // 수정된 부분: G4P 버튼은 자체 이벤트 핸들러 사용, 관련 로직을 제거.
  // if (hitScreen(nameButton, mouseX, mouseY)) {
  // 
  //   pressedOnNameBtn = true;
  //   isMenuDragging = false;  
  //   totalDragDist = 0;
  //   return;
  // 
  // }
  
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
  // nameButton.onDrag(mouseX, mouseY); // G4P 버튼으로 대체되어 제거
}

public void handleMenuReleased() {

  boolean clickDS = dsButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickSL = slButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDD = ddButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDL = dlButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  // boolean clickNAME = nameButton.onRelease(mouseX, mouseY); // G4P 버튼으로 대체되어 제거

  // 수정된 부분: G4P 버튼 관련 로직 제거
  // if (pressedOnNameBtn) {
  //   
  //   if (totalDragDist < 10) switchScreen(name_screen);
  //   pressedOnNameBtn = false;
  //   return;
  // 
  // }

  if (!isMenuDragging) return;
  isMenuDragging = false;

  if (totalDragDist < 10) {

      if (clickDS) { switchScreen(making_sticker);  return; }
      if (clickSL) { switchScreen(sticker_library); return; }
      if (clickDD) { switchScreen(drawing_diary); resetDiary();  return; }
      if (clickDL) { switchScreen(diary_library);   return; }
      // if (clickNAME) { switchScreen(name_screen);   return; } // G4P 버튼으로 대체되어 제거

  } else {
      menuTargetScrollX = (menuScrollX > PAGE_WIDTH * 0.5f) ? PAGE_WIDTH : 0;
  }

}

boolean hitScreen(rectButton b, float sx, float sy) {
  return (sx > b.position_x && sx < b.position_x + b.width &&
          sy > b.position_y && sy < b.position_y + b.height);
}