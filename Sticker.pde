// Sticker.pde


class Sticker { // 스티커 클래스
    float x, y;
    PImage img;
    
    Sticker(float tempX, float tempY, PImage tempImg) {
      x = tempX;
      y = tempY;
      img = tempImg;
    }
    
    void display() {
      imageMode(CENTER);
      image(img, x, y);
    }
    
    // 호버링
    boolean isMouseOver(float displayWidth, float displayHeight) {
      float halfW = displayWidth / 2;
      float halfH = displayHeight / 2;
      return (mouseX > x - halfW && mouseX < x + halfW &&
              mouseY > y - halfH&& mouseY < y + halfH);
    }
  }
  