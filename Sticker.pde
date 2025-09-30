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
  }
  