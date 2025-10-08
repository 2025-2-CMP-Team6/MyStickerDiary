UiBooster booster;
String username;
boolean isNameEntered = false;

void drawNameScreen() {
    booster = new UiBooster();
    username = booster.showTextInputDialog("What's your name?");
  
    // 테스트용으로 쓰신 거 같아서 일단 주석 처리하고 menu_Screen에서 처리했습니다.
    // textAlign(CENTER, CENTER);
    // textSize(32);
    // text(username, width/2, height/2);

    if(username != null) {
        isNameEntered = true;
        switchScreen(menu_screen);
        return;
    } else {
        switchScreen(menu_screen);
        return;
    }
}