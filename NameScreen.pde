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

    if(username != null && !username.trim().isEmpty()) { // 사용자가 취소하거나 아무것도 입력하지 않은 경우를 처리
        isNameEntered = true;
        switchScreen(menu_screen);
        return;
    } else {
        // 이름이 입력되지 않았을 경우 isNameEntered를 false로 유지
        isNameEntered = false; 
        switchScreen(menu_screen);
        return;
    }
}