// 마우스 호버링
boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w)); }

public class rectButton {
  int position_x;
  int position_y;
  color cl;

  rectButton(int x, int y, int w, int h, color c) {
    position_x = x;
    position_y = y;
    cl = c;
    fill(c);
    noStroke();
    rect(x, y, w, h);
  }

  public void isRectButtonClicked() {

  }

  public void rectButtonText(String message, int textSize) {
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(textSize);
    text(message, position_x + 150, position_y + 250);
  }
}
