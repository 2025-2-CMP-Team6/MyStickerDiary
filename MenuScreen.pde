GUIController c;
IFButton b1;
IFLabel l;

boolean isButtonPressed;

public void drawMenuScreen() {

    background(#FFCA1A);

    fill(#FFE880);
    noStroke();
    quad(0, 0, 0, 300, 1280, 400, 1280, 0);

    fill(0);
    textSize(50);
    text("Main Menu", 120, 40);

    dsButton.render();
    slButton.render();
    ddButton.render();
    dlButton.render();

}

public void handleMenuMouse() {

    if(dsButton.isMouseOverButton()) {
        dsButton.isButtonPressing = true;
    } else { 
        dsButton.isButtonPressing = false; 
    }

    if(slButton.isMouseOverButton()) {
        slButton.isButtonPressing = true;
    } else {
        slButton.isButtonPressing = false;
    }

    if(ddButton.isMouseOverButton()) {
        ddButton.isButtonPressing = true;
    } else {
        ddButton.isButtonPressing = false;
    }
    
    if(dlButton.isMouseOverButton()) {
        dlButton.isButtonPressing = true;
    } else {
        dlButton.isButtonPressing = false;
    }

}

public void handleMenuRelease() {

    if(dsButton.isMouseOverButton() && dsButton.isButtonPressing) {
        currentScreen = making_sticker;
    }

    if(slButton.isMouseOverButton()&& slButton.isButtonPressing) {
        currentScreen = sticker_library;
    }

    if(ddButton.isMouseOverButton() && ddButton.isButtonPressing) {
        currentScreen = drawing_diary;
    }

    if(dlButton.isMouseOverButton()&& dlButton.isButtonPressing) {
        currentScreen = diary_library;
    }

}
