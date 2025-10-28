// Sticker.pde
// Owner:

class Sticker { // Sticker Class
  float x, y;
  PImage img;
  float size; // Size of Sticker
  String imageName;
  String imagePath;
  
  // Sticker Format to New Sticker
  Sticker(float tempX, float tempY, float tempSize, String imgName) {
    x = tempX;
    y = tempY;
    size = tempSize;
    imageName = imgName;
    this.imagePath = "sticker/" + imgName;
    this.img = loadImage(imagePath);
    if (this.img == null) {
      println("Warnning: Fail to Load Sticker Image:" + imagePath);
      PGraphics pg = createGraphics(100, 100);
      pg.beginDraw();
      pg.background(255, 0, 255);
      pg.stroke(0);
      pg.line(0, 0, 100, 100);
      pg.line(0, 100, 100, 0);
      pg.endDraw();
      this.img = pg;
    }
  }
  
  // Sticker Format to Exist Sticker
  Sticker(float tempX, float tempY, PImage tempImg, float tempSize, String imgName) {
    x = tempX;
    y = tempY;
    this.img = tempImg;
    size = tempSize;
    imageName = imgName;
    this.imagePath = "sticker/" + imgName;
  }
  
  void display() {
    imageMode(CENTER);
    PVector displaySize = getDisplaySize();
    image(img, x, y, displaySize.x, displaySize.y);
  }

  // Displayed Size of Sticker 
  PVector getDisplaySize() {
    return getScaledImageSize(img, size);
  }

  // Handle Index
  float[] getHandleRect(int index, float handleSize) {
      PVector s = getDisplaySize();
      float halfW = s.x / 2;
      float halfH = s.y / 2;
      
      if (index == 0) return new float[]{ x - halfW - handleSize/2, y - halfH - handleSize/2, handleSize, handleSize }; // LEFT TOP
      if (index == 1) return new float[]{ x - halfW - handleSize/2, y + halfH - handleSize/2, handleSize, handleSize }; // LEFT BOTTOM
      if (index == 2) return new float[]{ x + halfW - handleSize/2, y - halfH - handleSize/2, handleSize, handleSize }; // RIGHT TOP
      if (index == 3) return new float[]{ x + halfW - handleSize/2, y + halfH - handleSize/2, handleSize, handleSize }; // RIGHT BOTTOM
      
      return new float[]{0,0,0,0};
  }
}
