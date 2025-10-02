GUIController c;
IFButton b1;
IFLabel l;

boolean isButtonPressed;

rectButton dsButton;
rectButton slButton;
rectButton ddButton;
rectButton dlButton;

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
    dsButton = new rectButton(100, 120, 200, 300, #FEFD48);
    dsButton.rectButtonText("Drawing\nSticker", 50);
}

public void stickerLibraryButton() {
    slButton = new rectButton(400, 120, 200, 300, #FEFD48);
    slButton.rectButtonText("Sticker\nLibrary", 50);
}

public void drawingDiaryButton() {
    ddButton = new rectButton(700, 120, 200, 300, #FEFD48);
    ddButton.rectButtonText("drawing\nDiary", 50);
}

public void diaryLibraryButton() {
    dlButton = new rectButton(1000, 120, 200, 300, #FEFD48);
    dlButton.rectButtonText("Diary\nLibrary", 50);
}

public void handleMenuMouse() {
    isButtonPressed = true;
}

public void handleMenuRelease() {
    if(isButtonPressed) {
        if(mouseX > dsButton.position_x && mouseX < dsButton.position_x + dsButton.width && mouseY > dsButton.position_y && mouseY < dsButton.position_y + height) {
            currentScreen = making_sticker;
        }

        if(mouseX > slButton.position_x && mouseX < slButton.position_x + slButton.width && mouseY > slButton.position_y && mouseY < slButton.position_y + height) {
            currentScreen = sticker_library;
        }

        if(mouseX > ddButton.position_x && mouseX < ddButton.position_x + ddButton.width && mouseY > ddButton.position_y && mouseY < ddButton.position_y + height) {
            currentScreen = drawing_diary;
        }

        if(mouseX > dlButton.position_x && mouseX < dlButton.position_x + dlButton.width && mouseY > dlButton.position_y && mouseY < dlButton.position_y + height) {
            currentScreen = diary_library;
        }
    }
}
