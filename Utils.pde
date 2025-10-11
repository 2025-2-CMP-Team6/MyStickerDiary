// 마우스 호버링
boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w));
}
boolean mouseHober(float sx, float sy, int x, int y, int w, int h) {
  return (sx > x && sx < x + w && sy > y && sy < y + h);
}

// 중간값
float median(float a, float b, float c) {
  return max(a, min(b,c));
}

// 달 영어로
String monthToString(int cal) {
  String[] monthStringList = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  if (cal >= 0 && cal < 12) {
    return monthStringList[cal];
  }
  return "";
}

// 최소/최댓값 제한
int clampMonth1to12(int m) {
  return max(1, min(12, m));
}

int monthToIdx0(int month1to12) {
  return clampMonth1to12(month1to12) - 1; // 0~11
}

int prevMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 11) % 12; // 0~11
}

int nextMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 1) % 12; // 0~11
}

// 버튼
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
    // 부드러운 보간 (가볍게, 과도한 진동 방지)
    float target = (armed && pressedInside) ? 1.0f : 0.0f;
    // 선형 보간 사용 — overshoot 줄이고 깜빡임 완화
    pressAnim = pressAnim + (target - pressAnim) * 0.20f;
    pressAnim = constrain(pressAnim, 0, 1);

    // 시각 파라미터
    int baseShadow = 16;
    int minShadowOffset = 2;       // 완전 눌려도 최소한 남길 그림자 거리
    int maxFaceOffset   = baseShadow - minShadowOffset;

    // 면이 내려갈 거리(완전 눌려도 baseShadow에 딱 닿지 않게)
    float faceOffset   = lerp(0, maxFaceOffset, pressAnim);
    // 그림자는 반대로 짧아지되, 최소 오프셋은 유지
    float shadowOffset = baseShadow - faceOffset; // 항상 >= minShadowOffset

    // 그림자 투명도도 살짝 줄여주기(깜빡임 대신 자연스러운 약화)
    int shadowAlpha = (int) lerp(110, 40, pressAnim);

    // 버튼 면 색도 살짝 어둡게
    color faceColor = lerpColor(cl, color(0), 0.12f * pressAnim);

    pushStyle();
    rectMode(CORNER);
    noStroke();

    // 그림자: 항상 그리되, 오프셋/알파만 눌림에 따라 변화
    if (useShadow) {
      fill(0, shadowAlpha);
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

    // 우측/하단 좌표 갱신(외부 참조 호환)
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

}

// 색 팔래트 정렬
void paletteCenter(int i, int[] outXY) {

  int col = (i > 5) ? 1 : 0;          
  int row = (i > 5) ? (i - 6) : i;    

  outXY[0] = colorPos[0] + col * 72;                
  outXY[1] = colorPos[1] + row * (int)colorGab;     

}
// 중점
PVector midpoint(float x1, float y1, float x2, float y2) {
  return new PVector((x1 + x2) / 2, (y1 + y2) / 2);
}