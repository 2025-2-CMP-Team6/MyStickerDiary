public void drawMenuScreen() {
    // 임시 구현 (화면 잘 넘어가지는지 테스트용)
        background(100, 200, 100);
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(48);
        text("Menu Screen", width/2, height/2);
}
public void handleMenuRelease() {
    currentScreen = sticker_library;
}