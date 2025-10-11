# MyStickerDiary

파일 디렉토리 구조 : 
```
MyStickerDiary/
├── MyStickerDiary.pde          // 메인 컨트롤 파일 (setup, draw 선언, 화면 전환 통제)
├── StartScreen.pde             // 시작 화면 -> 끝남
├── MenuScreen.pde              // 메뉴 화면
├── NameScreen.pde              // 메뉴 화면에서 이름 입력할 수 있는 화면 -> (삭제) 없애고 UIBooster로 팝업창 따로 구현하면 될듯?
├── MakingSticker.pde           // 스티커 만들기 화면 -> 거의 끝남
├── StickerLibrary.pde          // 스티커 라이브러리 화면 -> 거의 끝남
├── DrawingDiary.pde            // 일기 그리기 화면 -> 감정 분석 api, 날씨 api로 시각화하기
├── DiaryLibrary.pde            // 일기 라이브러리 화면
├── Utils.pde                   // 공통 유틸리티 함수들 (모든 파일에서 같이 사용 가능한 함수들 / drawButton, draw 같은 거)
└── data/
    ├── fonts/                  // 사용할 폰트 파일(ttf)
    ├── images/                 // 사용할 이미지 파일(processing 상에서 그리기 어렵거나 디자인 상 활용할 이미지)
    ├── stickers/               // 그린 스티커들 로드하여 저장
    └── diaries/                // DrawingLibrary 일기 텍스트 및 사용한 스티커 데이터 반영하여 저장
```
```
Plan
10/3(금)까지 : Menu screen 기능 구현 및 사용할 최종 api/라이브러리 정리
10/12(일)까지 : 핵심 기능 구현(Drawing Diary/Diary Library)
10/19(일)까지 : 코드 리팩토링(미흡한 부분 위주) 및 최종 빌드 테스트
```
```
남은 기능 구현들 10.11 ver
(생각나거나 더 좋은 기능 있으면 카톡이나 README에 추가 부탁드립니다)
stickerLibrary
- 만들어놓은 스티커 삭제 구현
- 만들어놓은 스티커 수정 구현

drawingLibrary
- 일기장에 있는 스티커 삭제(delete) 구현
- 날씨 아이콘 구현 및 선택에 따른 날씨 인포그래픽 구현

diaryLibrary
- 일기 텍스트(제목, 본문) 및 사용한 스티커 반영하여 특정한 파일로 저장되도록 구현
- 달력 구현 및 달력 클릭 시 해당 날짜에 쓴 일기 볼 수 있도록 구현
- 해당 날짜에 쓴 일기 텍스트 기반으로 감정 분석 결과 보여주도록 구현

그 외
- 메뉴 기능 구현 (BGM sound 조절, 메인으로 나가기 등) -> 아직 화면 전환이 완전히 자연스럽지 않은 것 같습니다. 
  흐름 같은 거를 다시 재정비할 필요가 있어보입니다
  (startScreen -> main Menu -> 주요 기능 4가지 -> 한 기능에서 다른 기능으로 어떻게 넘어가게 할지 등등 
  예를 들어 drawingDiary를 누르지 않은 상태에서 stickerLibrary의 '일기장으로'는 활성화하지 않는다던지 등등?)
- drawingDiary에서 추가로 그림을 그릴 수 있게 할건지 아니면 그렸던 스티커로만 그림을 그리게 할건지?
```
