class Sticker { // 스티커 클래스
  float x, y;
  PImage img;
  float size; // 스티커의 크기 (가장 긴 쪽 기준)
  String imageName;
  String imagePath; // 이미지 파일의 전체 경로
  
  // 파일 이름으로 지연 로딩하는 생성자
  Sticker(float tempX, float tempY, float tempSize, String imgName) {
    x = tempX;
    y = tempY;
    size = tempSize;
    imageName = imgName;
    this.imagePath = "sticker/" + imgName;
    this.img = loadImage(imagePath);
    if (this.img == null) {
      println("오류: 스티커 이미지 로드 실패: " + imagePath);
      PGraphics pg = createGraphics(100, 100);
      pg.beginDraw();
      pg.background(255, 0, 255); // 에러 표시용 밝은 분홍색
      pg.stroke(0);
      pg.line(0, 0, 100, 100);
      pg.line(0, 100, 100, 0);
      pg.endDraw();
      this.img = pg;
    }
  }
  
  // 이미 로드된 이미지용 생성자 (예: 스티커 제작기에서)
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

  // 화면에 표시될 크기(displayW, displayH)를 계산하여 PVector로 반환
  PVector getDisplaySize() {
    return getScaledImageSize(img, size);
  }

  // 특정 인덱스의 조절 핸들 사각형 정보를 [x, y, w, h] 배열로 반환
  float[] getHandleRect(int index, float handleSize) {
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
