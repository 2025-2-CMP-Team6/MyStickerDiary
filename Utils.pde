// 마우스 호버링
boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w)); }

public class rectButton {

  int position_x, position_y, width, height;
  color cl;

  String textLabel = "";
  int labelSize = 32;

  boolean isButtonPressing = false;

  rectButton(int x, int y, int w, int h, color c) {

    position_x = x;
    position_y = y;
    width = w;
    height = h;
    cl = c;

  }

  public void rectButtonText(String message, int textSize) {

    textLabel = message;
    labelSize = textSize;
    
  }

  public void render() {

    fill(cl);
    noStroke();
    rect(position_x, position_y, width, height);

    fill(0);
    textAlign(CENTER, CENTER);
    textSize(labelSize);
    text(textLabel, position_x + width/2, position_y + height/2);

  }

  public boolean isMouseOverButton() {

    return mouseX > position_x && mouseX < position_x + width 
          && mouseY > position_y && mouseY < position_y + height;

  }

}