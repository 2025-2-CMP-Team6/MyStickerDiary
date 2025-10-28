// WeatherEffects.pde
// Owner: 김동현

ArrayList<RainDrop> rainDrops;
ArrayList<Snowflake> snowflakes;
ArrayList<Cloud> clouds;
int lightningFrame = -1;

// Initialze Weather Effects
void initWeatherEffects() {
  // If there no ArrayList, Create new Ones
  if (rainDrops == null) rainDrops = new ArrayList<RainDrop>();
  if (snowflakes == null) snowflakes = new ArrayList<Snowflake>();
  if (clouds == null) clouds = new ArrayList<Cloud>();

  // Clear All Particles
  rainDrops.clear();
  snowflakes.clear();
  clouds.clear();
  lightningFrame = -1;

  // Making Weather Efect
  switch(todayWeather) {
    case 1: // Windy
    case 2: // Cloudy
      for (int i = 0; i < 15; i++) {
        clouds.add(new Cloud(todayWeather == 1)); // isWindy
      }
      break;
    case 3: // Rainy
      for (int i = 0; i < 150; i++) {
        rainDrops.add(new RainDrop(false)); // isStorm
      }
      break;
    case 4: // Snowy
      for (int i = 0; i < 100; i++) {
        snowflakes.add(new Snowflake());
      }
      break;
    case 5: // Stromy
      for (int i = 0; i < 250; i++) { // more Rain
        rainDrops.add(new RainDrop(true)); // isStorm
      }
      for (int i = 0; i < 5; i++) { // Black Cloud
        clouds.add(new Cloud(true));
      }
      break;
  }
}
//========== Draw Function ===========
void drawWeatherEffect() {
  switch(todayWeather) {
    case 0: drawSunnyEffect(); break;
    case 1: // Windy
    case 2: // Cloudy
      drawCloudyEffect();
      break;
    case 3: drawRainyEffect(); break; // Rainy
    case 4: drawSnowyEffect(); break; // Snowy
    case 5: drawStormyEffect(); break; // Stormy
  }
}

// Wheather Effects
void drawSunnyEffect() {
  pushStyle();
  float sunX = 80;
  float sunY = 80;
  float sunRadius = 60;
  noStroke();
  for (int i = 20; i > 0; i--) {
    fill(255, 255, 0, 150 / i);
    ellipse(sunX, sunY, sunRadius * i * 0.2, sunRadius * i * 0.2);
  }
  // Sun
  fill(255, 255, 150);
  ellipse(sunX, sunY, sunRadius * 2, sunRadius * 2);
  // Parhelion   
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
  // Dark Background
  fill(0, 50);
  rect(0, 0, width, height);

  drawCloudyEffect();
  drawRainyEffect();
  // Lightning
  if (lightningFrame > 0 && frameCount == lightningFrame) {
    fill(255, 255, 200, 200);
    rect(0, 0, width, height);
    lightningFrame = -1;
  }
  if (lightningFrame == -1 && random(1) < 0.01) { // 1% by Frame
    lightningFrame = frameCount + 1;
  }
}

// ======= Particle Class =======

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