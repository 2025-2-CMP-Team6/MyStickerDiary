// MakingSticker.pde

PGraphics stickerCanvas; // 캔버스 
int canvasSize = 680; // 정사각형 캔버스 크기
int canvasX, canvasY; // 캔버스가 그려질 화면상의 위치

// 기능 아이콘
PImage saveImg;  // 저장 이미지
PImage backImg;  // 뒤로가기 이미지

// 그리기 도구
String tool = ""; // 현재 선택된 도구
float toolGab = 72; // 도구 간격
int toolPos[] = {128,104};  // 도구 좌표
String posTool;  // 이전 도구

PImage brushImg;  // 브러쉬 이미지
PImage paintImg;  // 페인트 이미지
PImage eraserImg;  // 지우개 이미지

PImage brushCursor;  // 브러쉬 커서
PImage paintCursor;  // 페인트 커서
PImage eraserCursor; // 지우개 커서
PImage spoideCursor;  // 스포이드 커서


color selectedColor = color(0); // 현재 선택된 그리기 색상
// 브러쉬
float brushSize = 20; // 브러시 크기
boolean isBrushSizeChange = false; // 브러쉬 크기 변경 여부
int brushPos[] = {160,600};  // 브러쉬 사이즈 스크롤 좌표
PGraphics sizeCursor; // 브러쉬 크기 커서

// 도형
boolean isDrawingShape = false; // 도형을 그리고 있는지 여부
int[] pmousePos = new int[2];
PGraphics lineCursor;  // 직선 마우스 커서
PGraphics rectCursor;  // 사각형 마우스 커서
PGraphics circleCursor;  // 원 마우스 커서
// 아이콘 좌표
int[] linePos = new int[2];
int[] circlePos = new int[2];
int[] rectPos = new int[2];

// 컬러 팔레트
boolean isPalleteOpen = true;  //  팔레트 열림
int[] colorPos = {1128,104}; // 색의 좌표
int colorSize = 64; // 색의 크기
float colorGab = 72; // 색의 간격
color[] palleteColor = {color(255, 0, 0),color(0, 255, 0),color(0, 0, 255), color(255, 255, 0), color(255, 0, 255), color(0, 255, 255), color(128, 128, 128), color(0, 0, 0), color(255, 255, 255)}; // 팔레트 저장 색
boolean colorToggle = false;

// 뒤로 가기 버튼, 세이브 버튼 전역 변수로 설정해서 버튼 클릭 인식 최적화했습니다.
final int SAVE_W = 64, SAVE_H = 64;
final int BACK_W = 64, BACK_H = 64;
final int BACK_X = 24, BACK_Y = 24;

void setupCreator() {
  // 정사각형 크기의 그래픽 버퍼를 생성
  stickerCanvas = createGraphics(canvasSize, canvasSize);
  canvasX = (width - canvasSize) / 2; 
  canvasY = (height - canvasSize) / 2; 
  strokeJoin(ROUND); // 선이 만나는 부분을 둥글게
  strokeCap(ROUND);  // 선의 끝부분을 둥글게

  stickerCanvas.beginDraw();
  stickerCanvas.clear();
  stickerCanvas.endDraw();
  // 버튼 아이콘
saveImg = loadImage("data/images/saveIcon.png");
backImg = loadImage("data/images/backIcon.png");

  // 도구 아이콘
 brushImg = loadImage("data/images/brush.png");
 paintImg = loadImage("data/images/paint.png");
 eraserImg = loadImage("data/images/eraser.png");

 // 도구 커서
 brushCursor = loadImage("data/images/brush.png");
 paintCursor = loadImage("data/images/paint.png");
 eraserCursor = loadImage("data/images/eraser.png");
 spoideCursor = loadImage("data/images/spoide.png");
 lineCursor = createGraphics(32,32);
 lineCursor.noSmooth();
 lineCursor.beginDraw();
 lineCursor.stroke(0);
 lineCursor.strokeWeight(1);
 lineCursor.line(0,2,4,2);
 lineCursor.line(2,0,2,4);
 lineCursor.line(14,3,3,14);
 lineCursor.endDraw();

 rectCursor = createGraphics(32,32);
 rectCursor.noSmooth();
 rectCursor.beginDraw();
 rectCursor.stroke(0);
 rectCursor.strokeWeight(1);
 rectCursor.line(0,2,4,2);
 rectCursor.line(2,0,2,4);
 rectCursor.rect(4,4,12,12);
 rectCursor.endDraw();
 
 circleCursor = createGraphics(32,32);
 circleCursor.noSmooth();
 circleCursor.beginDraw();
 circleCursor.stroke(0);
 circleCursor.strokeWeight(1);
 circleCursor.line(0,2,4,2);
 circleCursor.line(2,0,2,4);
 circleCursor.circle(8,8,10);
 circleCursor.endDraw();

 sizeCursor = createGraphics(8,8);
 sizeCursor.noSmooth(); 
 sizeCursor.beginDraw();
 sizeCursor.noStroke(); 
 sizeCursor.fill(0);
 sizeCursor.triangle(3,0, 0,3, 3,7);
 sizeCursor.triangle(4,0, 7,3, 4,7);
 sizeCursor.endDraw();
}

void drawCreator() {
  pushStyle();

  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);

  background(225); // 배경
  stroke(0,1);
  fill(255,255,255);
  rect(canvasX, canvasY, canvasSize, canvasSize); // 캔버스 사각형 그리기
  // 중앙에 정사각형 캔버스 그리기
  image(stickerCanvas, canvasX, canvasY);
  
  // --- UI ---
  // 도구
  imageMode(CORNER);
  image(brushImg, toolPos[0], toolPos[1]);
  image(paintImg, toolPos[0], toolPos[1] + toolGab);
  image(eraserImg, toolPos[0], toolPos[1] + toolGab*2);
  fill(255);
  stroke(0);
  strokeWeight(3);
  rectMode(CENTER);
  line(toolPos[0]+8, toolPos[1]+toolGab*3+8,toolPos[0]+48,toolPos[1]+toolGab*3+48); // 선
  rect(toolPos[0]+32, toolPos[1]+toolGab*4+32, 48, 48); // 사각형
  circle(toolPos[0]+32, toolPos[1]+toolGab*5+32, 48); // 원
 // 브러쉬 크기 조절
  noFill();
  stroke(0);
  strokeWeight(1);
  float d = dist(brushPos[0],brushPos[1],mouseX,mouseY);
  if (d < 66) {circle(brushPos[0], brushPos[1], 132);}
  else {circle(brushPos[0], brushPos[1], 128);}
  fill(selectedColor);
  circle(brushPos[0], brushPos[1], brushSize);

  popStyle();

    // 도형 그리기 미리보기
  pushStyle();

    if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
      stroke(selectedColor);
      strokeWeight(brushSize);
      noFill();
      if (tool.equals("line")) {
        // 화면 좌표계에 직접 그리기
        line(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("rect")) {
        rectMode(CORNERS);
        rect(pmousePos[0], pmousePos[1], mouseX, mouseY);
      } else if (tool.equals("circle")) {
        ellipseMode(CORNERS);
        ellipse(pmousePos[0], pmousePos[1], mouseX, mouseY);
      }
    }
  
  popStyle();

  pushStyle();

  imageMode(CORNER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  // 팔레트
  if (isPalleteOpen) {

    int[] p = new int[2];

    for (int i = 0; i < palleteColor.length; i++) {

      paletteCenter(i, p);
      fill(palleteColor[i]);
      stroke(0, 1);
      circle(p[0], p[1], colorSize);  

    }

    if (mouseHober(colorPos[0]-(colorGab/2), colorPos[1]-(colorGab/2), 2*colorGab, colorGab*6)) {
      cursor(spoideCursor,0,30);
    }
    else {
      switch (tool) {
        case "brush":
          cursor(brushCursor,0,0);
          break;
        case "paint":
          cursor(paintCursor,0,0);
          break;
        case "eraser":
        cursor(eraserCursor,0,31);
          break;
        case "line":
          cursor(lineCursor.get(),2,2);
          break;
        case "rect":
          cursor(rectCursor.get(),2,2);
          break;
        case "circle":
          cursor(circleCursor.get(),2,2);
          break;
        default:
          cursor(ARROW);
      }
    }
  }
  // 저장
  image(saveImg, width - SAVE_W, height - SAVE_H, SAVE_W, SAVE_H);
  // 뒤로
  image(backImg, BACK_X, BACK_Y, BACK_W, BACK_H);

  popStyle();

}

void handleCreatorMouse() {

  if (mouseHober(width - SAVE_W, height - SAVE_H, SAVE_W, SAVE_H)) { // 저장
    PImage newStickerImg = stickerCanvas.get(); // 캔버스를 PImage로 변환
    cursor(ARROW);
    String sticker_name = "sticker_" + year() + month() + day() + "_" + hour() + minute() + second() + ".png";
    Sticker newSticker = new Sticker(0, 0, newStickerImg, defaultStickerSize, sticker_name);  // 스티커 객체 생성
    stickerLibrary.add(newSticker); // 라이브러리 ArrayList에 추가
    newStickerImg.save(dataPath("sticker/" + sticker_name));

    switchScreen(sticker_library);
    return;

  }
  if (mouseHober(BACK_X, BACK_Y, BACK_W, BACK_H)) { // 뒤로가기
    switchScreen(menu_screen);
    return;
  }
  // 도구 선택
    for (int i = 0; i < 6; i++) {
      if (mouseHober(toolPos[0], toolPos[1] + i * toolGab, 64, 64)) {
        switch (i) {
          case 0:
            tool = "brush";
            cursor(brushCursor,0,0);
            break;
            case 1:
              tool = "paint";
              cursor(paintCursor,0,0);
              break;
            case 2:
                tool = "eraser";
                cursor(eraserCursor,0,31);
                break;
            case 3:
                tool = "line";
                cursor(lineCursor.get(),2,2);
                break;
            case 4:
                tool = "rect";
                cursor(rectCursor.get(),2,2);
                break;
            case 5:
          tool = "circle";
          cursor(circleCursor.get(),2,2);
          break;
        }
        return; // 도구가 선택되었으면 함수 종료
        }
    }
  // 색상 선택
    // 색상 선택 (클릭 시에만 동작)
    for (int i = 0; i < palleteColor.length; i++) {
      int[] p = new int[2];
      paletteCenter(i, p);                         // ✅ 그릴 때와 동일 좌표
      float d2 = dist(mouseX, mouseY, p[0], p[1]); // 중심 거리
      if (d2 < colorSize / 2.0f) {
        selectedColor = palleteColor[i];
        return;
      }
    }
    // 캔버스 내에서 도형 그리기를 시작하는지 확인
    if (tool.equals("line") || tool.equals("rect") || tool.equals("circle")) {
      if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
        isDrawingShape = true;
        pmousePos[0] = mouseX;
        pmousePos[1] = mouseY;
      }
    }
}

void handleCreatorDrag() {
  if (mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
     if (tool.equals("brush")) {
    // 마우스가 캔버스 안쪽에 있을 때만 그리도록 제한
      // 화면 좌표를 캔버스 내부 좌표로 변환
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();  // 그림을 그릴 캔버스
      stickerCanvas.stroke(selectedColor);    // 선 색상  = 선택한 색
      stickerCanvas.strokeWeight(brushSize);  // 선 굵기
      stickerCanvas.strokeJoin(ROUND); // 선 연결부 둥글게
      stickerCanvas.strokeCap(ROUND);  // 선 끝 둥글게
      stickerCanvas.noFill();
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY); // 선 그리기
      stickerCanvas.endDraw();
    }
    if (tool.equals("paint")) {}
    if (tool.equals("eraser")) {
      // 화면 좌표를 캔버스 내부 좌표로 변환
      float canvasMouseX = mouseX - canvasX;
      float canvasMouseY = mouseY - canvasY;
      float pcanvasMouseX = pmouseX - canvasX;
      float pcanvasMouseY = pmouseY - canvasY;
      stickerCanvas.beginDraw();
      stickerCanvas.blendMode(REPLACE); // 픽셀을 직접 교체하는 모드로 변경
      stickerCanvas.stroke(0, 0); // 완전히 투명한 색으로 설정
      stickerCanvas.strokeWeight(brushSize);
      stickerCanvas.line(pcanvasMouseX, pcanvasMouseY, canvasMouseX, canvasMouseY);
      stickerCanvas.blendMode(BLEND); // 기본 블렌딩 모드로 
      stickerCanvas.endDraw();
    }
  }
  
  float d = dist(brushPos[0],brushPos[1],mouseX,mouseY);
  if (d<132) {
    brushSize += mouseX - pmouseX;
    cursor(sizeCursor.get());
    isBrushSizeChange = true;
    if (brushSize > 128) {
      brushSize = 128;
    }
    if (brushSize < 1) {
      brushSize = 1;
    }
  }
}

void handleCreatorRelease() {
  // 도형 그리기가 활성화된 상태에서 마우스를 놓았을 때
  if (isDrawingShape && mouseHober(canvasX, canvasY, canvasSize, canvasSize)) {
    // 화면 좌표를 캔버스 좌표로 변환
    float startX = pmousePos[0] - canvasX;
    float startY = pmousePos[1] - canvasY;
    float endX = mouseX - canvasX;
    float endY = mouseY - canvasY;

    stickerCanvas.beginDraw();
    stickerCanvas.stroke(selectedColor);
    stickerCanvas.strokeWeight(brushSize);
    stickerCanvas.noFill(); // 도형의 내부는 채우지 않음
    if (tool.equals("line")) {
      stickerCanvas.line(startX, startY, endX, endY);
    } else if (tool.equals("rect")) {
      stickerCanvas.rectMode(CORNERS);
      stickerCanvas.rect(startX, startY, endX, endY);
    } else if (tool.equals("circle")) {
      stickerCanvas.ellipseMode(CORNERS);
      stickerCanvas.ellipse(startX, startY, endX, endY);
    }
    stickerCanvas.endDraw();
  }
  else if (isBrushSizeChange) {
    cursor(ARROW);
    isBrushSizeChange = false;
  }
  isDrawingShape = false; // 그리기 상태 초기화
}
