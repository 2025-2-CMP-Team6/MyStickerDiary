// Library.pde

float libraryScrollY = 0;
float minLibraryScrollY = 0;

// 스크롤바 관련 변수
boolean isDraggingLibScrollbar = false;
float libScrollbarDragStartY;
float libScrollbarDragStartScrollY;
float libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH;
float libThumbY, libThumbH;

void drawLibrary() {
    background(220, 240, 220);
    imageMode(CENTER);
    rectMode(CENTER);
    // 타이틀 (뒤로가기 버튼과 겹치지 않도록 위치 조정)
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("Sticker Library", width/2, height*(60.0f/720.0f));
  
    // '새 스티커 만들기' 버튼
    if (mouseHober(width/2 - width*(140.0f/1280.0f), height - height*(110.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f))) {
      fill(230, 230, 160);
    } else {
      fill(220, 220, 150);
    }
    rect(width/2, height - height*(80.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f));
    fill(0);
    textSize(30);
    text("+ Making new Sticker!", width/2, height - height*(80.0f/720.0f));
  
    // 스티커 목록 그리기

    pushStyle();
    rectMode(CORNER);
    float boxSize = width * (150.0f/1280.0f);   // 스티커가 들어갈 칸의 최대 크기
    float spacing = width * (180.0f/1280.0f);  // 스티커 간격
    float startX = width * (200.0f/1280.0f); // X좌표
    float startY = height * (200.0f/720.0f); // Y좌표
    int cols = 6; // 한 줄당 개수

    // 보이는 영역과 전체 콘텐츠 영역의 높이를 일관되게 계산합니다.
    float viewHeight = height - startY - height*(120.0f/720.0f); // 스티커가 보이는 영역의 높이
    float contentHeight = 0;

    // 스크롤 범위
    if (stickerLibrary.size() > 0) {
      int numRows = (stickerLibrary.size() - 1) / cols + 1;
      contentHeight = (numRows - 1) * spacing + boxSize;
      minLibraryScrollY = max(0, contentHeight - viewHeight);
    } else {
      minLibraryScrollY = 0;
    }
    clip(0, startY + spacing, width*2, height - boxSize - 128); 
  
    for (int i = 0; i < stickerLibrary.size(); i++) {
      Sticker s = stickerLibrary.get(i);
      int c = i % cols;
      int r = i / cols;
      
      s.x = startX + c * spacing;
      s.y = startY + r * spacing - libraryScrollY;
      
      PImage img = s.img;
      PVector newSize = getScaledImageSize(img, boxSize);
  
      // 계산된 새 크기로 이미지 그리기
      image(img, s.x, s.y, newSize.x, newSize.y);
      
      // 마우스 영역 확인
      if (mouseHober(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y)) {
        rectMode(CORNER);
        stroke(0);
        strokeWeight(3);
        noFill();
        rect(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y);
        strokeWeight(1);

        // 삭제 버튼 그리기
        float deleteBtnRadius = max(10, width * (8.0f / 1280.0f)); // 최소 10px
        float deleteBtnX = s.x + newSize.x/2;
        float deleteBtnY = s.y - newSize.y/2;

        pushStyle();
        if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
            fill(255, 50, 50); // Hover color
        } else {
            fill(200, 0, 0);
        }
        stroke(255);
        strokeWeight(1.5);
        circle(deleteBtnX, deleteBtnY, deleteBtnRadius * 2);
        line(deleteBtnX - deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX + deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
        line(deleteBtnX + deleteBtnRadius/2, deleteBtnY - deleteBtnRadius/2, deleteBtnX - deleteBtnRadius/2, deleteBtnY + deleteBtnRadius/2);
        popStyle();

        fill(0);
      }
      
    }
    noClip();
    // 스크롤바 그리기
    if (minLibraryScrollY > 0) {
      libScrollbarW = width * (12.0f/1280.0f);
      float scrollbarMargin = width * (20.0f/1280.0f);
      libScrollbarX = width - scrollbarMargin - libScrollbarW;
      libScrollbarY = height * (80.0f/720.0f);
      libScrollbarH = height - height * (200.0f/720.0f); // 상단(80) 및 하단(120) 여백을 제외한 높이
  
      // 스크롤바 트랙
      fill(200, 180);
      noStroke();
      rect(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH, 6);
  
      // 스크롤바 섬
      thumbH = libScrollbarH * (viewHeight / contentHeight);
      thumbH = max(thumbH, 25); // 최소 높이
      float scrollableDist = libScrollbarH - thumbH;
      float scrollRatio = libraryScrollY / minLibraryScrollY;
      thumbY = libScrollbarY + scrollableDist * scrollRatio;
      // 마우스가 섬 위에 있거나 드래그 중이면 색상 변경
      if (isDraggingLibScrollbar || mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
        fill(120);
      } else {
        fill(170);
      }
      rect(libScrollbarX, thumbY, libScrollbarW, thumbH, 6);
    }
    
    drawBackButton(); // 공통 뒤로가기 버튼 호출
    popStyle();
  }
  
  void handleLibraryMouse() {
    // 스크롤바 드래그 확인
    if (minLibraryScrollY > 0 && mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      isDraggingLibScrollbar = true;
      libScrollbarDragStartY = mouseY;
      libScrollbarDragStartScrollY = libraryScrollY;
    }
  } 
  void handleLibraryDrag() {
    // 스크롤바 드래그 처리
    if (isDraggingLibScrollbar) {
      float dy = mouseY - libScrollbarDragStartY;
      float scrollablePixelRange = libScrollbarH - thumbH;
      if (scrollablePixelRange > 0) {
        float scrollAmount = dy * (minLibraryScrollY / scrollablePixelRange);
        libraryScrollY = constrain(libScrollbarDragStartScrollY + scrollAmount, 0, minLibraryScrollY);
      }
    }
  }

  void handleLibraryMouseReleased() {
    if (isDraggingLibScrollbar) {
      isDraggingLibScrollbar = false;
      return;
    }

    // '새 스티커 만들기' 버튼 클릭 확인 (우선순위 높임)
    if (mouseHober(width/2 - width*(140.0f/1280.0f), height - height*(110.0f/720.0f), width*(280.0f/1280.0f), height*(60.0f/720.0f))) {
      switchScreen(making_sticker);
      return;
    }

    // 스티커 클릭/삭제 확인
    float boxSize = width * (150.0f/1280.0f);

    // Iterate backwards to safely remove items
    for (int i = stickerLibrary.size() - 1; i >= 0; i--) {
        Sticker s = stickerLibrary.get(i);
        PImage img = s.img; // 이미지 가져오기
        PVector newSize = getScaledImageSize(img, boxSize);
        if (mouseHober(s.x-newSize.x/2, s.y-newSize.y/2, newSize.x, newSize.y)) {
            // 삭제 버튼 클릭 확인
            float deleteBtnRadius = max(10, width * (8.0f / 1280.0f));
            float deleteBtnX = s.x + newSize.x/2;
            float deleteBtnY = s.y - newSize.y/2;

            if (dist(mouseX, mouseY, deleteBtnX, deleteBtnY) < deleteBtnRadius) {
                UiBooster booster = new UiBooster();
                boolean confirmed = booster.showConfirmDialog("Are you sure you want to delete this sticker?", "Delete Sticker");
                if (confirmed) {
                    // 파일 삭제
                    File stickerFile = new File(dataPath("sticker/" + s.imageName));
                    if (stickerFile.exists()) {
                        if (!stickerFile.delete()) {
                            println("Failed to delete sticker file: " + s.imageName);
                        }
                    }
                    // 라이브러리에서 스티커 제거
                    stickerLibrary.remove(i);
                }
                return; // 한 번에 하나의 동작만 처리 (삭제 시도 또는 취소)
            }

            // 스티커를 클릭하면 편집 화면으로 이동 (삭제가 아닐 경우)
            stickerToEdit = s;
            stickerCanvas.beginDraw();
            stickerCanvas.clear();
            stickerCanvas.image(stickerToEdit.img, 0, 0, canvasSize, canvasSize);
            stickerCanvas.endDraw();
            switchScreen(making_sticker);
            return;
        }
    }

    // 스크롤바 트랙 클릭
    if ((minLibraryScrollY > 0) && mouseHober(libScrollbarX, libScrollbarY, libScrollbarW, libScrollbarH) && !mouseHober(libScrollbarX, thumbY, libScrollbarW, thumbH)) {
      // 스크롤 이동
      float clickRatio = (mouseY - libScrollbarY - thumbH / 2) / (libScrollbarH - thumbH);
      clickRatio = constrain(clickRatio, 0, 1);
      libraryScrollY = clickRatio * minLibraryScrollY;
    }
}

void handleLibraryMouseWheel(MouseEvent ev) {
  if (mouseHober(width*(130.0f/1280.0f), height*(164.0f/720.0f), width - width*(270.0f/1280.0f), height - height*(280.0f/720.0f))) {
    float scrollAmount = ev.getCount() * 10; // 스크롤 속도
    libraryScrollY = constrain(libraryScrollY + scrollAmount, 0, minLibraryScrollY);
  }
}
