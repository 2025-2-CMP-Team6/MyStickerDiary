// NameScreen.pde
// Owner:

UiBooster booster;
boolean isNameEntered = false;

void drawNameScreen() { // Using UiBooster, Ask User Name
    booster = new UiBooster();
    username = booster.showTextInputDialog("What's your name?");
    if(username != null && !username.trim().isEmpty()) { // When Input Not Blank or Null
        isNameEntered = true;
        switchScreen(menu_screen);
        return;
    } else { // When Input Blank or Null
        isNameEntered = false; 
        switchScreen(menu_screen);
        return;
    }
}