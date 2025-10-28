// MenuScreen.pde
// Owner: 

GUIController c;
IFButton b1;
IFLabel l;
// G4P Button
boolean isButtonPressed;
boolean pressedOnNameBtn = false;
// Mouse Wheel Setting
long lastWheelTime = 0;
final long WHEEL_SNAP_DELAY = 300;
boolean isWheeling = false;
// Drawing in Menu Screen
public void drawMenuScreen() {
    pushStyle();
    background(#FFCA1A);
    drawBackgroundEffect();
    fill(0);
    textSize(50);
    text("Main Menu", 78, 86);

    // When Mouse Wheel Stop, Snap to Nearest Page
    if (isWheeling && millis() - lastWheelTime > WHEEL_SNAP_DELAY) {
        isWheeling = false;
        snapToNearestPage();
    }
    // Move Menu Scroll
    menuScrollX += (menuTargetScrollX - menuScrollX) * 0.20; 
    if (abs(menuTargetScrollX - menuScrollX) < 0.5) {
        menuScrollX = menuTargetScrollX;
    }
    pushMatrix();
    translate(-round(menuScrollX), 0);
    // Draw Menu Buttons
    dsButton.render(round(worldMouseX()), round(worldMouseY()));
    slButton.render(round(worldMouseX()), round(worldMouseY()));
    ddButton.render(round(worldMouseX()), round(worldMouseY()));
    dlButton.render(round(worldMouseX()), round(worldMouseY()));
    popMatrix();
    // Hober Menu Button
    boolean hoverScrollable =
      mouseHober(worldMouseX(), worldMouseY(),
                 dsButton.position_x, dsButton.position_y, dsButton.width, dsButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 slButton.position_x, slButton.position_y, slButton.width, slButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 ddButton.position_x, ddButton.position_y, ddButton.width, ddButton.height) ||
      mouseHober(worldMouseX(), worldMouseY(),
                 dlButton.position_x, dlButton.position_y, dlButton.width, dlButton.height);
    // Name Button
    if (hoverScrollable) {
      cursor(HAND);
    } else {
      cursor(ARROW);
    }
    // Draw Name
    if (isNameEntered) {
      pushStyle();
      fill(0);
      textAlign(RIGHT, CENTER);
      textSize(32);
      text("NAME : " + username,
           nameEditButton.getX() - 24,
           nameEditButton.getY() + nameEditButton.getHeight() / 2);
           
      popStyle();
    }
    // Page Indicators
    float defaultIndicatorRadius = 8;
    float currentIndicatorRadius = 9;
    float indicatorSpacing = 20;
    float totalIndicatorWidth = 3 * (defaultIndicatorRadius * 2) + 2 * indicatorSpacing;
    float indicatorStartX = width / 2 - totalIndicatorWidth / 2;
    float indicatorY = height - 30;
    // Set Value of Indicator
    float indicator1X = indicatorStartX + defaultIndicatorRadius;
    float indicator2X = indicatorStartX + defaultIndicatorRadius + indicatorSpacing + defaultIndicatorRadius * 2;
    float indicator3X = indicatorStartX + defaultIndicatorRadius + 2 * (indicatorSpacing + defaultIndicatorRadius * 2);

    boolean isCurrent1 = menuScrollX < width * 0.25f;
    boolean isCurrent2 = menuScrollX >= width * 0.25f && menuScrollX < width * 0.75f;
    boolean isCurrent3 = menuScrollX >= width * 0.75f;

    boolean isHover1 = dist(mouseX, mouseY, indicator1X, indicatorY) < defaultIndicatorRadius * 1.5;
    boolean isHover2 = dist(mouseX, mouseY, indicator2X, indicatorY) < defaultIndicatorRadius * 1.5;
    boolean isHover3 = dist(mouseX, mouseY, indicator3X, indicatorY) < defaultIndicatorRadius * 1.5;
    // Draw Indicators
    noStroke();
    // First Indicator
    fill(isCurrent1 ? 0 : (isHover1 ? 80 : 150));
    float r1 = isCurrent1 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator1X, indicatorY, r1 * 2, r1 * 2);

    // Second Indicator
    fill(isCurrent2 ? 0 : (isHover2 ? 80 : 150));
    float r2 = isCurrent2 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator2X, indicatorY, r2 * 2, r2 * 2);

    // Third Indicator
    fill(isCurrent3 ? 0 : (isHover3 ? 80 : 150));
    float r3 = isCurrent3 ? currentIndicatorRadius : defaultIndicatorRadius;
    ellipse(indicator3X, indicatorY, r3 * 2, r3 * 2);

    popStyle();
}

public void handleMenuMousePressed() { // Mouse Pressed in Menu Screen

  // Page indicator click handling
  float indicatorRadius = 8;
  float indicatorSpacing = 20;
  float totalIndicatorWidth = 3 * (indicatorRadius * 2) + 2 * indicatorSpacing;
  float indicatorStartX = width / 2 - totalIndicatorWidth / 2;
  float indicatorY = height - 30;

  float indicator1X = indicatorStartX + indicatorRadius;
  float indicator2X = indicatorStartX + indicatorRadius + indicatorSpacing + indicatorRadius * 2;
  float indicator3X = indicatorStartX + indicatorRadius + 2 * (indicatorSpacing + indicatorRadius * 2);

  // Click Indicators
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
  pressedOnNameBtn = false;
  isMenuDragging = true;
  dragStartX = mouseX;
  dragStartScroll = menuScrollX;
  totalDragDist = 0;

}

public void handleMenuDragged() { // Mouse Dragging in Menu Screen
  if (pressedOnNameBtn) return;  
  if (!isMenuDragging) return;
  float dx = mouseX - dragStartX;
  totalDragDist = max(totalDragDist, abs(dx));

  float potentialScrollX = dragStartScroll - (dx * menuDragSpeed);
  menuTargetScrollX = applyInertia(potentialScrollX);
  dsButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  slButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  ddButton.onDrag((int)worldMouseX(), (int)worldMouseY());
  dlButton.onDrag((int)worldMouseX(), (int)worldMouseY());
}

public void handleMenuReleased() {  // Mouse Released in Menu Screen
  // Menu Button Release Check
  boolean clickDS = dsButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickSL = slButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDD = ddButton.onRelease((int)worldMouseX(), (int)worldMouseY());
  boolean clickDL = dlButton.onRelease((int)worldMouseX(), (int)worldMouseY());

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
  } else {
      snapToNearestPage();
  }

}

boolean hitScreen(rectButton b, float sx, float sy) {
  return (sx > b.position_x && sx < b.position_x + b.width &&
          sy > b.position_y && sy < b.position_y + b.height);
}

void nameForced() { // Check User Name When First Start Program
  if (username == null) {
    switchScreen(name_screen);
  }
}

public void handleMenuMouseWheel(MouseEvent ev) { // Mouse Wheel in Menu Screen
    if (isMenuDragging) return;

    isWheeling = true;
    lastWheelTime = millis();

    float scrollAmount = ev.getCount() * 15;
    
    float potentialScrollX = menuTargetScrollX - scrollAmount;
    menuTargetScrollX = applyInertia(potentialScrollX);
}
// Snapping to Nearest Page
void snapToNearestPage() {
    if (menuScrollX < width * 0.25f) {
        menuTargetScrollX = 0;
    } else if (menuScrollX < width * 0.75f) {
        menuTargetScrollX = width / 2;
    } else {
        menuTargetScrollX = width;
    }
}
// Inertia Effect
float applyInertia(float idealPos) {
    float stretch_constant = width / 2.0f;

    if (idealPos >= 0 && idealPos <= width) {
        return idealPos;
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