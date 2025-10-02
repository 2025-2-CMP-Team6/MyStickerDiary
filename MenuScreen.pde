GUIController c;
IFButton b1;
IFLabel l;

public void drawMenuScreen() {
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
}
