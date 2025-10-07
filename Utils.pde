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

  int position_x, position_y, width, height;
  int px;
  int py;
  color cl;

  String textLabel = "";
  int labelSize = 32;

  boolean isButtonPressing = false;
  boolean useShadow = true;

  rectButton(int x, int y, int w, int h, color c) {

    position_x = x;
    position_y = y;
    width = w;
    height = h;
    cl = c;
    px = position_x;
    py = position_y;

  }

  public void setShadow(boolean on) { useShadow = on; }

  public void rectButtonText(String message, int textSize) {

    textLabel = message;
    labelSize = textSize;
    
  }

  public void render() {
    int shadow = 16;
    if (useShadow) {
      fill(0);
      noStroke();
      rect(position_x + shadow, position_y + shadow, width, height);
    }

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


void paletteCenter(int i, int[] outXY) {

  int col = (i > 5) ? 1 : 0;          
  int row = (i > 5) ? (i - 6) : i;    

  outXY[0] = colorPos[0] + col * 72;                
  outXY[1] = colorPos[1] + row * (int)colorGab;     

}
