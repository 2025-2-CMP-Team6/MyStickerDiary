UiBooster booster;
boolean isNameEntered = false;

void drawNameScreen() {
    booster = new UiBooster();
    username = booster.showTextInputDialog("What's your name?");
    if(username != null && !username.trim().isEmpty()) {
        isNameEntered = true;
        switchScreen(menu_screen);
        return;
    } else { // 사용자가 취소하거나 아무것도 입력하지 않은 경우
        isNameEntered = false; 
        switchScreen(menu_screen);
        return;
    }
}