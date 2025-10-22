// WeatherEffects.pde
// 날씨에 따른 배경 효과를 관리하는 파일입니다.

// === 전역 변수 ===
ArrayList<RainDrop> rainDrops;
ArrayList<Snowflake> snowflakes;
ArrayList<Cloud> clouds;
int lightningFrame = -1; // 폭풍 효과용

// === 초기화 함수 ===
void initWeatherEffects() {
  // 리스트가 없으면 새로 생성
  if (rainDrops == null) rainDrops = new ArrayList<RainDrop>();
  if (snowflakes == null) snowflakes = new ArrayList<Snowflake>();
  if (clouds == null) clouds = new ArrayList<Cloud>();

  // 기존 파티클 모두 제거
  rainDrops.clear();
  snowflakes.clear();
  clouds.clear();
  lightningFrame = -1;

  // 현재 날씨(todayWeather)에 따라 파티클 생성
  // 0: 맑음, 1: 바람, 2: 흐림, 3: 비, 4: 눈, 5: 폭풍
  switch(todayWeather) {
    case 1: // 바람
    case 2: // 흐림
      for (int i = 0; i < 15; i++) {
        clouds.add(new Cloud(todayWeather == 1)); // isWindy
      }
      break;
    case 3: // 비
      for (int i = 0; i < 150; i++) {
        rainDrops.add(new RainDrop(false)); // isStorm
      }
      break;
    case 4: // 눈
      for (int i = 0; i < 100; i++) {
        snowflakes.add(new Snowflake());
      }
      break;
    case 5: // 폭풍
      for (int i = 0; i < 250; i++) { // 더 많은 비
        rainDrops.add(new RainDrop(true)); // isStorm
      }
      for (int i = 0; i < 5; i++) { // 폭풍 구름
        clouds.add(new Cloud(true));
      }
      break;
  }
}

// === 메인 그리기 함수 ===
void drawWeatherEffect() {
  // 현재 날씨에 맞는 효과 그리기 함수 호출
  switch(todayWeather) {
    case 0: drawSunnyEffect(); break;
    case 1: // 바람
    case 2: // 흐림
      drawCloudyEffect();
      break;
    case 3: drawRainyEffect(); break;
    case 4: drawSnowyEffect(); break;
    case 5: drawStormyEffect(); break;
  }
}

// === 날씨별 효과 그리기 함수들 ===

void drawSunnyEffect() {
  pushStyle();
  float sunX = width - 80;
  float sunY = 80;
  float sunRadius = 60;

  // 해 주변의 빛 번짐 효과
  noStroke();
  for (int i = 20; i > 0; i--) {
    fill(255, 255, 0, 150 / i);
    ellipse(sunX, sunY, sunRadius * i * 0.2, sunRadius * i * 0.2);
  }

  // 해 본체
  fill(255, 255, 150);
  ellipse(sunX, sunY, sunRadius * 2, sunRadius * 2);

  // 회전하는 햇살
  stroke(255, 255, 0, 100);
  strokeWeight(3);
  pushMatrix();
  translate(sunX, sunY);
  rotate(frameCount * 0.005);
  for (int i = 0; i < 12; i++) {
    rotate(radians(360.0 / 12));
    float angle = frameCount * 0.01 + i * (TWO_PI / 12);
    float len = 80 + sin(angle * 2) * 10;
    line(sunRadius, 0, sunRadius + len, 0);
  }
  popMatrix();
  popStyle();
}

void drawCloudyEffect() {
  for (Cloud c : clouds) {
    c.update();
    c.display();
  }
}

void drawRainyEffect() {
  for (RainDrop r : rainDrops) {
    r.update();
    r.display();
  }
}

void drawSnowyEffect() {
  for (Snowflake s : snowflakes) {
    s.update();
    s.display();
  }
}

void drawStormyEffect() {
  // 폭풍일 때 배경을 어둡게
  fill(0, 50);
  rect(0, 0, width, height);

  drawCloudyEffect();
  drawRainyEffect();

  // 번개 효과
  if (lightningFrame > 0 && frameCount == lightningFrame) {
    fill(255, 255, 200, 200);
    rect(0, 0, width, height);
    lightningFrame = -1; // 번쩍인 후 리셋
  }
  if (lightningFrame == -1 && random(1) < 0.01) { // 매 프레임 1% 확률로 번개
    lightningFrame = frameCount + 1; // 다음 프레임에 번쩍이도록 설정
  }
}

// === 파티클 클래스들 ===

class Cloud {
  PVector pos;
  float speed;
  float w, h;
  color c;
  ArrayList<PVector> parts = new ArrayList<PVector>();

  Cloud(boolean isWindy) {
    pos = new PVector(random(-width, width), random(height * 0.1, height * 0.4));
    speed = isWindy ? random(1.5, 3.0) : random(0.5, 1.5);
    w = random(150, 300);
    h = random(40, 80);
    c = isWindy ? color(100, 100, 120, 150) : color(255, 255, 255, 120);

    for (int i = 0; i < 5; i++) {
      parts.add(new PVector(random(-w/2, w/2), random(-h/2, h/2), random(w*0.4, w*0.8)));
    }
  }

  void update() {
    pos.x += speed;
    if (pos.x - w > width) {
      pos.x = -w;
      pos.y = random(height * 0.1, height * 0.4);
    }
  }

  void display() {
    pushStyle();
    noStroke();
    fill(c);
    for (PVector p : parts) {
      ellipse(pos.x + p.x, pos.y + p.y, p.z, p.z * 0.6);
    }
    popStyle();
  }
}

class RainDrop {
  PVector pos;
  float speed;
  float len;
  color c;

  RainDrop(boolean isStorm) {
    pos = new PVector(random(width), random(-height, 0));
    speed = isStorm ? random(15, 25) : random(5, 15);
    len = random(10, 20);
    c = isStorm ? color(180, 180, 220, 200) : color(100, 120, 200, 150);
  }

  void update() {
    pos.y += speed;
    if (pos.y > height) {
      pos.y = random(-200, 0);
      pos.x = random(width);
    }
  }

  void display() {
    stroke(c);
    strokeWeight(random(1, 2));
    line(pos.x, pos.y, pos.x, pos.y + len);
  }
}

class Snowflake {
  PVector pos;
  float speedY;
  float speedX;
  float size;
  float angle = 0;
  float angleSpeed;

  Snowflake() {
    pos = new PVector(random(width), random(-height, 0));
    speedY = random(1, 3);
    speedX = random(-0.5, 0.5);
    size = random(3, 8);
    angleSpeed = random(-0.05, 0.05);
  }

  void update() {
    pos.y += speedY;
    pos.x += speedX + sin(angle) * 0.5;
    angle += angleSpeed;

    if (pos.y > height) {
      pos.y = 0;
      pos.x = random(width);
    }
  }

  void display() {
    noStroke();
    fill(255, 200);
    ellipse(pos.x, pos.y, size, size);
  }
}