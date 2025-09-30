GUIController c;
IFButton b1;
IFLabel l;

public void drawMenuScreen() {
<<<<<<< HEAD
    // 임시 구현 (화면 잘 넘어가지는지 테스트용)
        background(100, 200, 100);
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(48);
        text("Menu Screen", width/2, height/2);

        c = new GUIController (this); // test용 임시 버튼
        b1 = new IFButton ("Green", 30, 35, 60, 30);
        b1.addActionListener(this);
        c.add (b1);


=======
    background(#FFCA1A);

    fill(#FFE880);
    noStroke();
    quad(0, 0, 0, 300, 1280, 400, 1280, 0);

    fill(0);
    textSize(50);
    text("Main Menu", 120, 40);

    drawingStickerButton();
    stickerLibraryButton();
    drawingDiaryButton();
    diaryLibraryButton();
>>>>>>> c8b8c314ad88a5350cf5711068efb67090606fbf
}

public void drawingStickerButton() {
    rectButton dsButton = new rectButton(100, 120, 300, 500, #FEFD48);
    dsButton.rectButtonText("Drawing\nSticker", 50);
}

public void stickerLibraryButton() {
    rectButton slButton = new rectButton(600, 120, 300, 500, #FEFD48);
    slButton.rectButtonText("Sticker\nLibrary", 50);
}

public void drawingDiaryButton() {
    rectButton ddButton = new rectButton(1100, 120, 300, 500, #FEFD48);
    ddButton.rectButtonText("drawing\nDiary", 50);
}

public void diaryLibraryButton() {
    rectButton dlButton = new rectButton(1600, 120, 300, 500, #FEFD48);
    dlButton.rectButtonText("Diary\nLibrary", 50);
}

public void handleMenuRelease() {
<<<<<<< HEAD
    currentScreen = sticker_library;
}
void actionPerformed (GUIEvent e) {
  if (e.getSource() == b1) {
    drawNameScreen();

  } 
=======

>>>>>>> c8b8c314ad88a5350cf5711068efb67090606fbf
}
