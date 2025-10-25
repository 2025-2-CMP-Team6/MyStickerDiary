// MenuScreen.pde

GUIController c;
IFButton b1;
IFLabel l;

boolean isButtonPressed;
boolean pressedOnNameBtn = false;

// 휠 스크롤 상태 관리를 위한 변수들
long lastWheelTime = 0;
final long WHEEL_SNAP_DELAY = 300; // 휠 스크롤 후 자동 정렬까지 대기 시간(ms)
boolean isWheeling = false;

public void drawMenuScreen() {

    pushStyle();
    background(#FFCA1A);
    drawBackgroundEffect();
    fill(0);
    textSize(50);
    text("Main Menu", 78, 86);

    // 휠 스크롤이 멈추면 자동 정렬 시작
    if (isWheeling && millis() - lastWheelTime > WHEEL_SNAP_DELAY) {
        isWheeling = false;
        snapToNearestPage();
    }

    // 사용자가 직접 조작(드래그, 휠)하지 않을 때만 목표 위치로 부드럽게 이동
    // 이 조건이 떨림 현상을 막는 핵심입니다.
    // 항상 목표 위치(menuTargetScrollX)를 향해 현재 보이는 위치(menuScrollX)를 부드럽게 이동시킵니다.
    // 이 방식은 여러 시스템이 충돌하여 떨리는 현상을 근본적으로 방지합니다.
    menuScrollX += (menuTargetScrollX - menuScrollX) * 0.20; 
    if (abs(menuTargetScrollX - menuScrollX) < 0.5) {
        menuScrollX = menuTargetScrollX;
    }

    // 추가 버튼 만들고 싶으실 때
    // push-popMatrix에서 빼면 드래그 영향 안받아요! 고정됩니다.
    pushMatrix();

    translate(-round(menuScrollX), 0); // menuScrollX 값을 반올림하여 정수 픽셀로 이동

    dsButton.render(round(worldMouseX()), round(worldMouseY()));
    slButton.render(round(worldMouseX()), round(worldMouseY()));
    ddButton.render(round(worldMouseX()), round(worldMouseY()));
    dlButton.render(round(worldMouseX()), round(worldMouseY()));

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
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
    // 수정 끝

    if (isNameEntered) {
      pushStyle();
      fill(0);
      textAlign(RIGHT, CENTER);   // 텍스트 정렬을 오른쪽으로 변경
      textSize(32);               // 폰트 크기 증가
      // 이름 텍스트를 버튼의 왼쪽에, 세로 중앙 정렬하여 표시합니다.
      text("NAME : " + username,
           nameEditButton.getX() - 24, // 버튼 왼쪽에서 24px 여백
           nameEditButton.getY() + nameEditButton.getHeight() / 2); // 버튼의 세로 중앙
           
      popStyle();
    }
    // Page indicators (toolbar-like) - 3개의 스냅 지점용
    float defaultIndicatorRadius = 8;
    float currentIndicatorRadius = 9; // 현재 페이지 인디케이터를 더 크게
    float indicatorSpacing = 20;
    float totalIndicatorWidth = 3 * (defaultIndicatorRadius * 2) + 2 * indicatorSpacing;
    float indicatorStartX = width / 2 - totalIndicatorWidth / 2;
    float indicatorY = height - 30; // 30 pixels from the bottom

    // 인디케이터 X 좌표 계산
    float indicator1X = indicatorStartX + defaultIndicatorRadius;
    float indicator2X = indicatorStartX + defaultIndicatorRadius + indicatorSpacing + defaultIndicatorRadius * 2;
    float indicator3X = indicatorStartX + defaultIndicatorRadius + 2 * (indicatorSpacing + defaultIndicatorRadius * 2);

    // 상태 확인
    boolean isCurrent1 = menuScrollX < width * 0.25f;
    boolean isCurrent2 = menuScrollX >= width * 0.25f && menuScrollX < width * 0.75f;
    boolean isCurrent3 = menuScrollX >= width * 0.75f;

    boolean isHover1 = dist(mouseX, mouseY, indicator1X, indicatorY) < defaultIndicatorRadius * 1.5;
    boolean isHover2 = dist(mouseX, mouseY, indicator2X, indicatorY) < defaultIndicatorRadius * 1.5;
    boolean isHover3 = dist(mouseX, mouseY, indicator3X, indicatorY) < defaultIndicatorRadius * 1.5;

    noStroke();

    // 첫 번째 지점 (0)
    fill(isCurrent1 ? 0 : (isHover1 ? 80 : 150));
    float r1 = isCurrent1 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator1X, indicatorY, r1 * 2, r1 * 2);

    // 두 번째 지점 (width/2)
    fill(isCurrent2 ? 0 : (isHover2 ? 80 : 150));
    float r2 = isCurrent2 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator2X, indicatorY, r2 * 2, r2 * 2);

    // 세 번째 지점 (width)
    fill(isCurrent3 ? 0 : (isHover3 ? 80 : 150));
    float r3 = isCurrent3 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator3X, indicatorY, r3 * 2, r3 * 2);

    popStyle();

}

public void handleMenuMousePressed() {

  // Page indicator click handling
  float indicatorRadius = 8;
  float indicatorSpacing = 20;
  float totalIndicatorWidth = 3 * (indicatorRadius * 2) + 2 * indicatorSpacing;
  float indicatorStartX = width / 2 - totalIndicatorWidth / 2;
  float indicatorY = height - 30;

  float indicator1X = indicatorStartX + indicatorRadius;
  float indicator2X = indicatorStartX + indicatorRadius + indicatorSpacing + indicatorRadius * 2;
  float indicator3X = indicatorStartX + indicatorRadius + 2 * (indicatorSpacing + indicatorRadius * 2);

  // 클릭 영역을 조금 더 넓게 설정 (반지름의 1.5배)
  if (dist(mouseX, mouseY, indicator1X, indicatorY) < indicatorRadius * 1.5) {
    menuTargetScrollX = 0;
    return;
  }
  if (dist(mouseX, mouseY, indicator2X, indicatorY) < indicatorRadius * 1.5) {
    menuTargetScrollX = width / 2;
    return;
  }
  if (dist(mouseX, mouseY, indicator3X, indicatorY) < indicatorRadius * 1.5) {
    menuTargetScrollX = width;
    return;
  }

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

  float potentialScrollX = dragStartScroll - (dx * menuDragSpeed);
  // 드래그 시에는 시각적 위치(menuScrollX)가 아닌 목표 위치(menuTargetScrollX)를 업데이트합니다.
  menuTargetScrollX = applyInertia(potentialScrollX);
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
      if (clickDS) { 
        playClickSound();
        switchScreen(making_sticker);  
        return; 
      }
      if (clickSL) { 
        playClickSound();
        switchScreen(sticker_library); 
        return; 
      }
      if (clickDD) { 
        playClickSound();
        switchScreen(drawing_diary); resetDiary();  
        return; 
      }
      if (clickDL) { 
        playClickSound();
        switchScreen(diary_library);   
        return; 
      }
      // if (clickNAME) { switchScreen(name_screen);   return; } // G4P 버튼으로 대체되어 제거

  } else {
      snapToNearestPage();
  }

}

boolean hitScreen(rectButton b, float sx, float sy) {
  return (sx > b.position_x && sx < b.position_x + b.width &&
          sy > b.position_y && sy < b.position_y + b.height);
}

void nameForced() {
  if (username == null) {
    switchScreen(name_screen);
  }
}

public void handleMenuMouseWheel(MouseEvent ev) {
    if (isMenuDragging) return; // 드래그 중에는 휠 스크롤 비활성화

    isWheeling = true;
    lastWheelTime = millis();

    float scrollAmount = ev.getCount() * 15; // 휠 감도. 숫자를 줄이면 느려집니다.
    
    // 휠 스크롤 시에도 목표 위치(menuTargetScrollX)를 업데이트합니다.
    float potentialScrollX = menuTargetScrollX - scrollAmount; // 현재 목표 위치에서 계산
    menuTargetScrollX = applyInertia(potentialScrollX);
}

/**
 * 현재 스크롤 위치(`menuScrollX`)를 기반으로 가장 가까운 페이지(0, width/2, width)를 찾아
 * 목표 스크롤 위치(`menuTargetScrollX`)를 설정합니다.
 */
void snapToNearestPage() {
    if (menuScrollX < width * 0.25f) {
        menuTargetScrollX = 0;
    } else if (menuScrollX < width * 0.75f) {
        menuTargetScrollX = width / 2;
    } else {
        menuTargetScrollX = width;
    }
}
/**
 * 이상적인 스크롤 위치에 관성/저항 효과를 적용하여 실제 시각적 위치를 반환합니다.
 * @param idealPos 저항이 없는 이상적인 스크롤 위치
 * @return 저항 효과가 적용된 시각적 스크롤 위치
 */
float applyInertia(float idealPos) {
    float stretch_constant = width / 2.0f; // 값이 클수록 더 많이 늘어납니다.

    if (idealPos >= 0 && idealPos <= width) {
        return idealPos; // 유효 범위 내에서는 그대로 반환
    } else if (idealPos < 0) {
        float overshoot = -idealPos;
        float stretched_overshoot = stretch_constant * atan(overshoot / stretch_constant);
        return -stretched_overshoot;
    } else { // idealPos > width
        float overshoot = idealPos - width;
        float stretched_overshoot = stretch_constant * atan(overshoot / stretch_constant);
        return width + stretched_overshoot;
    }
}