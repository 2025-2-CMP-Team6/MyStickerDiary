// 마우스 호버링
public boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w));
}
public float median(float a, float b, float c) {
  return max(a, min(b,c));
}





boolean mouseHober(float mx, float my, float x, float y, float w, float h) {
  return ((my > y && my < y+h) && (mx > x && mx < x+w));
}

public class rectButton {

  int position_x, position_y, width, height, position_x_r, position_y_r;
  int px;
  int py;
  color cl;

  String textLabel = "";
  int labelSize = 32;

  boolean isButtonPressing = false;
  boolean useShadow = true;

  private boolean armed = false;
  private boolean pressedInside = false;

  private float pressAnim = 0.0f;

  rectButton(int x, int y, int w, int h, color c) {

    pushStyle();
    rectMode(CORNER);
    position_x = x;
    position_y = y;
    width = w;
    height = h;
    cl = c;
    px = position_x;
    py = position_y;
    position_x_r = position_x + width;
    position_y_r = position_y + height;
    popStyle();

  }

  public void setShadow(boolean on) { useShadow = on; }

  public void rectButtonText(String message, int textSize) {

    textLabel = message;
    labelSize = textSize;
    
  }

  public void onPress(int mx, int my) {
    armed = hit(mx, my);
    pressedInside = armed; 
  }

  public void onDrag(int mx, int my) {
    if (armed) pressedInside = hit(mx, my);
  }

  public boolean onRelease(int mx, int my) {
    boolean clicked = armed && hit(mx, my);
    armed = false;
    pressedInside = false;
    return clicked;
  }

  public void render() {

    float target = (armed && pressedInside) ? 1.0f : 0.0f;
    pressAnim += (target - pressAnim) * 0.25f;   

    // 시각 효과 파라미터
    int baseShadow = 16;
    int faceOffset = round(baseShadow * pressAnim);       // 눌리면 아래/오른쪽 이동
    int shadowOffset = max(0, baseShadow - faceOffset);   // 그림자 길이 줄이기
    color faceColor = lerpColor(cl, color(0), 0.18f * pressAnim); // 약간 어둡게

    pushStyle();
    rectMode(CORNER);
    noStroke();

    // 그림자
    if (useShadow && shadowOffset > 0) {
      fill(0);
      rect(position_x + shadowOffset, position_y + shadowOffset, width, height);
    }

    // 버튼 면
    fill(faceColor);
    rect(position_x + faceOffset, position_y + faceOffset, width, height);

    // 텍스트
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(labelSize);
    text(textLabel, position_x + width/2 + faceOffset, position_y + height/2 + faceOffset);

    popStyle();

    // 우측/하단 좌표 업데이트(혹시 외부에서 쓰면 일관성 유지)
    position_x_r = position_x + width;
    position_y_r = position_y + height;
  }

  public boolean isMouseOverButton() {

    return hit(mouseX, mouseY);

  }

  private boolean hit(int mx, int my) {
    return (mx > position_x && mx < position_x + width &&
            my > position_y && my < position_y + height);
  }

  /*public boolean isMousePressed() {

  }

  public boolean isMouseReleased() {

  }*/
}


void paletteCenter(int i, int[] outXY) {

  int col = (i > 5) ? 1 : 0;          
  int row = (i > 5) ? (i - 6) : i;    

  outXY[0] = colorPos[0] + col * 72;                
  outXY[1] = colorPos[1] + row * (int)colorGab;     

}

PVector midpoint(float x1, float y1, float x2, float y2) {
  return new PVector((x1 + x2) / 2, (y1 + y2) / 2);
}