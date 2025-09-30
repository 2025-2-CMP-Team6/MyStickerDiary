UiBooster booster;
String username;

void drawNameScreen() {
    booster = new UiBooster();
    username = booster.showTextInputDialog("What's your name?");
  
    textAlign(CENTER, CENTER);
    textSize(32);
    text(username, width/2, height/2);
}