# MyStickerDiary

파일 디렉토리 구조 : 
```
MyStickerDiary/
├── MyStickerDiary.pde          // 메인 컨트롤 파일 (setup, draw 선언, 화면 전환 통제)
├── StartScreen.pde             // 시작 화면
├── MenuScreen.pde              // 메뉴 화면
├── NameScreen.pde              // 메뉴 화면에서 이름 입력할 수 있는 화면
├── MakingSticker.pde           // 스티커 만들기 화면
├── StickerLibrary.pde          // 스티커 라이브러리 화면
├── DrawingDiary.pde            // 일기 그리기 화면
├── DiaryLibrary.pde            // 일기 라이브러리 화면
├── Utils.pde                   // 공통 유틸리티 함수들 (모든 파일에서 같이 사용 가능한 함수들 / drawButton, draw 같은 거)
└── data/
    ├── fonts/                  // 사용할 폰트 파일(ttf)
    ├── images/                 // 사용할 이미지 파일(processing 상에서 그리기 어렵거나 디자인 상 활용할 이미지)
    └── stickers/               // 그린 스티커들 로드하여 저장
```
```
(2025.09.22 17:47)
시작화면 구현
시작화면 버튼 Pressed 시 이펙트 추가
시작화면 -> 메뉴화면 화면 전환 구현
```
```
(2025.09.23 00:21)
시작화면 수정 : 아무 곳이나 클릭하여 시작으로 구현
```
