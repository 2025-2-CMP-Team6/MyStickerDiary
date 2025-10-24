boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w));
}
boolean mouseHober(float sx, float sy, int x, int y, int w, int h) {
  return (sx > x && sx < x + w && sy > y && sy < y + h);
}
String monthToString(int cal) {
  String[] monthStringList = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  if (cal >= 0 && cal < 12) {
    return monthStringList[cal];
  }
  return "";
}
int clampMonth1to12(int m) {
  return max(1, min(12, m));
}
int monthToIdx0(int month1to12) {
  return clampMonth1to12(month1to12) - 1;
}
int prevMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 11) % 12;
}
int nextMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 1) % 12;
}
// 이미지의 원본 비율을 유지하면서 주어진 사각형 박스에 맞게 크기를 조절한 PVector(너비, 높이)를 반환
static PVector getScaledImageSize(PImage img, float boxW, float boxH) {
  if (img == null || img.width <= 0 || img.height <= 0) {
    return new PVector(0, 0);
  }
  float imgRatio = (float)img.width / img.height;
  float boxRatio = boxW / boxH;
  float newW, newH;
  if (boxRatio > imgRatio) { // 박스가 이미지보다 넓은 경우, 높이를 기준으로 맞춤
    newH = boxH;
    newW = newH * imgRatio;
  } else { // 박스가 이미지보다 높거나 비율이 같은 경우, 너비를 기준으로 맞춤
    newW = boxW;
    newH = newW / imgRatio;
  }
  return new PVector(newW, newH);
}
// 이미지의 원본 비율을 유지하면서 주어진 정사각형 박스에 맞게 크기를 조절한 PVector(너비, 높이)를 반환
static PVector getScaledImageSize(PImage img, float boxSize) {
  return getScaledImageSize(img, boxSize, boxSize);
}
public static class rectButton {

  public enum ButtonStyle {
    SIMPLE,
    FANCY
  }

  PApplet parent;

  int position_x, position_y, width, height, position_x_r, position_y_r;
  int px;
  int py;
  color cl;

  String textLabel = "";
  int labelSize = 32;

  boolean isButtonPressing = false;
  PImage buttonImage = null;
  boolean useShadow = true;
  private ButtonStyle style = ButtonStyle.SIMPLE; // 기본 스타일은 SIMPLE
  
  private boolean armed = false;
  private boolean pressedInside = false;
  private boolean isHovering = false;

  private float pressAnim = 0.0f;

  rectButton(PApplet p, int x, int y, int w, int h, color c) {
    parent = p;

    parent.pushStyle();
    parent.rectMode(CORNER);
    position_x = x;
    position_y = y;
    width = w;
    height = h;
    cl = c;
    px = position_x;
    py = position_y;
    position_x_r = position_x + width;
    position_y_r = position_y + height;
    parent.popStyle();

  }
  
  public void setStyle(ButtonStyle s) {
    this.style = s;
  }

  public void setImage(PImage img) {
    buttonImage = img;
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
    render(parent.mouseX, parent.mouseY);
  }
  
  public void render(int mx, int my) {
    isHovering = !armed && hit(mx, my);
    // 부드러운 보간
    float target = (armed && pressedInside) ? 1.0f : 0.0f; 
    // 선형 보간 사용
    pressAnim = parent.lerp(pressAnim, target, 0.20f);
    pressAnim = parent.constrain(pressAnim, 0, 1);
    // 시각 파라미터
    int baseShadow = 16;
    int minShadowOffset = 2;       // 완전 눌려도 최소한 남길 그림자 거리
    float cornerRadius = 15.0f;    // 버튼 모서리 둥글기 
    int maxFaceOffset   = baseShadow - minShadowOffset;
    // 면이 내려갈 거리(완전 눌려도 baseShadow에 딱 닿지 않게)
    float faceOffset   = parent.lerp(0, maxFaceOffset, pressAnim);
    // 그림자는 반대로 짧아지되, 최소 오프셋은 유지
    float shadowOffset = baseShadow - faceOffset; // 항상 >= minShadowOffset
    // 그림자 투명도도 살짝 줄여주기(깜빡임 대신 자연스러운 약화)
    int shadowAlpha = (int) parent.lerp(110, 40, pressAnim);
    // 버튼 면 색도 살짝 어둡게
    color baseColor = isHovering ? parent.lerpColor(cl, parent.color(255), 0.2) : cl;
    color faceColor = parent.lerpColor(baseColor, parent.color(0), 0.12f * pressAnim);
    
    parent.pushStyle();
    parent.rectMode(CORNER);
    parent.noStroke();
    // 그림자: 항상 그리되, 오프셋/알파만 눌림에 따라 변화
    if (useShadow) {
      parent.fill(0, shadowAlpha);
      if (style == ButtonStyle.FANCY) {
        parent.rect(position_x + shadowOffset, position_y + shadowOffset, width, height, cornerRadius);
      } else {
        parent.rect(position_x + shadowOffset, position_y + shadowOffset, width, height);
      }
    }
    if (style == ButtonStyle.FANCY) {
      // --- FANCY 스타일: 2분할 색상, 둥근 모서리, 이미지 ---
      parent.pushMatrix();
      parent.translate(position_x + faceOffset, position_y + faceOffset);
      color brightenedColor = parent.lerpColor(faceColor, parent.color(255), 0.15f);
      color topColor = parent.lerpColor(brightenedColor, parent.color(parent.brightness(brightenedColor)), 0.3f); // 채도를 30% 낮춤
      color bottomColor = faceColor;
      parent.noStroke();
      // 상단부 (위쪽 모서리만 둥글게)
      parent.fill(topColor);
      parent.beginShape();
      parent.vertex(0, height / 2);
      parent.vertex(0, cornerRadius);
      parent.quadraticVertex(0, 0, cornerRadius, 0);
      parent.vertex(width - cornerRadius, 0);
      parent.quadraticVertex(width, 0, width, cornerRadius);
      parent.vertex(width, height / 2);
      parent.endShape(CLOSE);
      // 하단부 (아래쪽 모서리만 둥글게)
      parent.fill(bottomColor);
      parent.beginShape();
      parent.vertex(0, height / 2);
      parent.vertex(width, height / 2);
      parent.vertex(width, height - cornerRadius);
      parent.quadraticVertex(width, height, width - cornerRadius, height);
      parent.vertex(cornerRadius, height);
      parent.quadraticVertex(0, height, 0, height - cornerRadius);
      parent.endShape(CLOSE);
      parent.popMatrix();
      
      // 텍스트 (왼쪽 위)
      float textPadding = width * 0.08f;
      parent.fill(0);
      parent.textAlign(LEFT, TOP);
      parent.textSize(labelSize);
      parent.text(textLabel, position_x + faceOffset + textPadding, position_y + faceOffset + textPadding);
      // 이미지 (오른쪽 아래)
      if (buttonImage != null) {
          parent.imageMode(CENTER);
          float imgPadding = width * 0.08f;
          float imgBoxSize = parent.min(width, height) * 0.8f;
          PVector newImgSize = getScaledImageSize(buttonImage, imgBoxSize);
          float imgX = position_x + width - (newImgSize.x / 2) - imgPadding + faceOffset;
          float imgY = position_y + height - (newImgSize.y / 2) - imgPadding/4 + faceOffset;
          parent.image(buttonImage, imgX, imgY, newImgSize.x, newImgSize.y);
      }
    } else {
      // --- SIMPLE 스타일: 단색, 중앙 텍스트 ---
      parent.fill(faceColor);
      parent.rect(position_x + faceOffset, position_y + faceOffset, width, height);
      parent.fill(0);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(labelSize);
      parent.text(textLabel, position_x + width/2 + faceOffset, position_y + height/2 + faceOffset);
    }
    parent.popStyle();
    // 우측/하단 좌표 갱신(외부 참조 호환)
    position_x_r = position_x + width;
    position_y_r = position_y + height;
  }
  public boolean isMouseOverButton() {
    return hit(parent.mouseX, parent.mouseY);
  }
  private boolean hit(int mx, int my) {
    return (mx > position_x && mx < position_x + width &&
            my > position_y && my < position_y + height);
  }
}
PVector midpoint(float x1, float y1, float x2, float y2) {
  return new PVector((x1 + x2) / 2, (y1 + y2) / 2);
}
int getWeather() {
  int weather = 0;
  // 0: 맑음, 1: 바람, 2: 흐림, 3: 비, 4: 눈, 5: 폭풍
  String des = setupWeather();
  switch(des) {
    case "clear sky":
    case "few clouds":
      weather = 0; // 맑음
      case "scattered clouds":
      case "broken clouds":
      case "overcast clouds":
        weather = 2; // 흐림
        break;
      case "shower rain":
      case "rain":
      case "light rain":
      case "moderate rain":
        weather = 3; // 비
        break;
      case "thunderstorm":
        weather = 5; // 폭풍
        break;
      case "snow":
      case "light snow":
        weather = 4; // 눈
        break;
    }
    return weather;
  }
  