class Sticker { // 스티커 클래스
  float x, y;
  PImage img;
  float size; // 스티커의 크기 (가장 긴 쪽 기준)
  
  Sticker(float tempX, float tempY, PImage tempImg, float tempSize) {
    x = tempX;
    y = tempY;
    img = tempImg;
    size = tempSize;
  }
  
  void display() {
    imageMode(CENTER);
    PVector displaySize = getDisplaySize();
    image(img, x, y, displaySize.x, displaySize.y);
  }

  // 화면에 표시될 크기(displayW, displayH)를 계산하여 PVector로 반환
  PVector getDisplaySize() {
    float w = img.width;
    float h = img.height;
    float displayW, displayH;

    if (w > h) {
      displayW = size;
      displayH = h * (size / w);
    } else {
      displayH = size;
      displayW = w * (size / h);
    }
    return new PVector(displayW, displayH);
  }

  // 특정 인덱스의 조절 핸들 사각형 정보를 [x, y, w, h] 배열로 반환
  float[] getHandleRect(int index, int handleSize) {
      PVector s = getDisplaySize();
      float halfW = s.x / 2;
      float halfH = s.y / 2;
      
      if (index == 0) return new float[]{ x - halfW - handleSize/2, y - halfH - handleSize/2, handleSize, handleSize }; // 왼쪽 위
      if (index == 1) return new float[]{ x - halfW - handleSize/2, y + halfH - handleSize/2, handleSize, handleSize }; // 왼쪽 아래
      if (index == 2) return new float[]{ x + halfW - handleSize/2, y - halfH - handleSize/2, handleSize, handleSize }; // 오른쪽 위
      if (index == 3) return new float[]{ x + halfW - handleSize/2, y + halfH - handleSize/2, handleSize, handleSize }; // 오른쪽 아래
      
      return new float[]{0,0,0,0}; // 잘못된 인덱스
  }
}

