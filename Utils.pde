/* Utils.pde
 * Owner: 신이철
 * SubOwner: 김동현, 최은영
 */


// Checks if the Mouse is Hovering Over a Rectangular Area.
boolean mouseHober(float x, float y, float w, float h) {
    return ((mouseY > y && mouseY < y+h) && (mouseX > x && mouseX < x+w));
}

// Overload to Check if a Specific Point (sx, sy) is Inside a Rectangular Area.
boolean mouseHober(float sx, float sy, int x, int y, int w, int h) {
  return (sx > x && sx < x + w && sy > y && sy < y + h);
}

/**
 * Converts a Month Index to its Abbreviated String Representation.
 * @param cal The month index (0-11).
 * @return The abbreviated month name (e.g., "Jan", "Feb"). Returns an empty string if invalid.
 */
String monthToString(int cal) {
  String[] monthStringList = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  if (cal >= 0 && cal < 12) {
    return monthStringList[cal];
  }
  return "";
}

// Clamps a Month Value to the Valid Range of 1-12.
int clampMonth1to12(int m) {
  return max(1, min(12, m));
}

// Converts a 1-Based Month (1-12) to a 0-Based Index (0-11).
int monthToIdx0(int month1to12) {
  return clampMonth1to12(month1to12) - 1;
}

// Gets the 0-Based Index for the Previous Month.
int prevMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 11) % 12;
}

// Gets the 0-Based Index for the Next Month.
int nextMonthIdx0(int month1to12) {
  return (monthToIdx0(month1to12) + 1) % 12;
}

/**
 * Calculates Scaled Image Dimensions to Fit a Rectangular Box While Maintaining Aspect Ratio.
 * @param img The PImage to scale.
 * @param boxW The width of the target box.
 * @param boxH The height of the target box.
 * @return A PVector containing the new calculated (width, height).
 */
static PVector getScaledImageSize(PImage img, float boxW, float boxH) {
  if (img == null || img.width <= 0 || img.height <= 0) {
    return new PVector(0, 0);
  }
  float imgRatio = (float)img.width / img.height;
  float boxRatio = boxW / boxH;
  float newW, newH;
  if (boxRatio > imgRatio) { // If Box is Wider, Fit to Height
    newH = boxH;
    newW = newH * imgRatio;
  } else { // If Box is Taller or Same Ratio, Fit to Width
    newW = boxW;
    newH = newW / imgRatio;
  }
  return new PVector(newW, newH);
}

/**
 * Overloaded Function to Calculate Scaled Image Size for a Square Box.
 * @param img The PImage to scale.
 * @param boxSize The side length of the square target box.
 * @return A PVector containing the new calculated (width, height).
 */
static PVector getScaledImageSize(PImage img, float boxSize) {
  return getScaledImageSize(img, boxSize, boxSize);
}


public static class rectButton {

  public enum ButtonStyle {
    SIMPLE,
    FANCY
  }

  PApplet parent;

  int position_x, position_y, width, height, position_x_r, position_y_r;
  int px;
  int py;
  color cl;

  String textLabel = "";
  int labelSize = 32;

  boolean isButtonPressing = false;
  PImage buttonImage = null;
  boolean useShadow = true;
  private ButtonStyle style = ButtonStyle.SIMPLE; // Default Style
  
  private boolean armed = false;
  private boolean pressedInside = false;
  private boolean isHovering = false;

  private float pressAnim = 0.0f;

  rectButton(PApplet p, int x, int y, int w, int h, color c) {
    parent = p;

    parent.pushStyle();
    parent.rectMode(CORNER);
    position_x = x;
    position_y = y;
    width = w;
    height = h;
    cl = c;
    px = position_x;
    py = position_y;
    position_x_r = position_x + width;
    position_y_r = position_y + height;
    parent.popStyle();

  }
  
  public void setStyle(ButtonStyle s) {
    this.style = s;
  }

  public void setImage(PImage img) {
    buttonImage = img;
  }

  public void setShadow(boolean on) { useShadow = on; }
  
  public void rectButtonText(String message, int textSize) {

    textLabel = message;
    labelSize = textSize;
    
  }

  public void onPress(int mx, int my) {
    armed = hit(mx, my);
    pressedInside = armed; 
  }
  
  public void onDrag(int mx, int my) {
    if (armed) pressedInside = hit(mx, my);
  }

  public boolean onRelease(int mx, int my) {
    boolean clicked = armed && hit(mx, my);
    armed = false;
    pressedInside = false;
    return clicked;
  }
  
  public void render() {
    render(parent.mouseX, parent.mouseY);
  }
  
  public void render(int mx, int my) {
    isHovering = !armed && hit(mx, my);
    // Smooth Interpolation for Press Animation
    float target = (armed && pressedInside) ? 1.0f : 0.0f; 
    pressAnim = parent.lerp(pressAnim, target, 0.20f);
    pressAnim = parent.constrain(pressAnim, 0, 1);
    
    // Visual Parameters
    int baseShadow = 16;
    int minShadowOffset = 2;       // Minimum Shadow Distance.
    float cornerRadius = 15.0f;    // Button Corner Roundness.
    int maxFaceOffset   = baseShadow - minShadowOffset;
    // Face Move Down Distance.
    float faceOffset   = parent.lerp(0, maxFaceOffset, pressAnim);
    // Shadow Shortens, Maintains Minimum Offset.
    float shadowOffset = baseShadow - faceOffset;
    // Reduce Shadow Transparency on Press.
    int shadowAlpha = (int) parent.lerp(110, 40, pressAnim);
    // Darken Button Face Color on Press.
    color baseColor = isHovering ? parent.lerpColor(cl, parent.color(255), 0.2) : cl;
    color faceColor = parent.lerpColor(baseColor, parent.color(0), 0.12f * pressAnim);
    
    parent.pushStyle();
    parent.rectMode(CORNER);
    parent.noStroke();
    // Shadow: Offset/Alpha Changes on Press.
    if (useShadow) {
      parent.fill(0, shadowAlpha);
      if (style == ButtonStyle.FANCY) {
        parent.rect(position_x + shadowOffset, position_y + shadowOffset, width, height, cornerRadius);
      } else {
        parent.rect(position_x + shadowOffset, position_y + shadowOffset, width, height);
      }
    }
    if (style == ButtonStyle.FANCY) {
      // FANCY Style: 2-Part Color, Rounded Corners, Image.
      parent.pushMatrix();
      parent.translate(position_x + faceOffset, position_y + faceOffset);
      color brightenedColor = parent.lerpColor(faceColor, parent.color(255), 0.15f);
      color topColor = parent.lerpColor(brightenedColor, parent.color(parent.brightness(brightenedColor)), 0.3f); // Reduce Saturation by 30%.
      color bottomColor = faceColor;
      parent.noStroke();
      // Top Part with Rounded Top Corners.
      parent.fill(topColor);
      parent.beginShape();
      parent.vertex(0, height / 2);
      parent.vertex(0, cornerRadius);
      parent.quadraticVertex(0, 0, cornerRadius, 0);
      parent.vertex(width - cornerRadius, 0);
      parent.quadraticVertex(width, 0, width, cornerRadius);
      parent.vertex(width, height / 2);
      parent.endShape(CLOSE);
      // Bottom Part with Rounded Bottom Corners.
      parent.fill(bottomColor);
      parent.beginShape();
      parent.vertex(0, height / 2);
      parent.vertex(width, height / 2);
      parent.vertex(width, height - cornerRadius);
      parent.quadraticVertex(width, height, width - cornerRadius, height);
      parent.vertex(cornerRadius, height);
      parent.quadraticVertex(0, height, 0, height - cornerRadius);
      parent.endShape(CLOSE);
      parent.popMatrix();
      
      // Text (Top Left).
      float textPadding = width * 0.08f;
      parent.fill(0);
      parent.textAlign(LEFT, TOP);
      parent.textSize(labelSize);
      parent.text(textLabel, position_x + faceOffset + textPadding, position_y + faceOffset + textPadding);
      // Image (Bottom Right).
      if (buttonImage != null) {
          parent.imageMode(CENTER);
          float imgPadding = width * 0.08f;
          float imgBoxSize = parent.min(width, height) * 0.8f;
          PVector newImgSize = getScaledImageSize(buttonImage, imgBoxSize);
          float imgX = position_x + width - (newImgSize.x / 2) - imgPadding + faceOffset;
          float imgY = position_y + height - (newImgSize.y / 2) - imgPadding/4 + faceOffset;
          parent.image(buttonImage, imgX, imgY, newImgSize.x, newImgSize.y);
      }
    } else {
      // SIMPLE Style: Solid Color, Centered Text.
      parent.fill(faceColor);
      parent.rect(position_x + faceOffset, position_y + faceOffset, width, height);
      parent.fill(0);
      parent.textAlign(CENTER, CENTER);
      parent.textSize(labelSize);
      parent.text(textLabel, position_x + width/2 + faceOffset, position_y + height/2 + faceOffset);
    }
    parent.popStyle();
    // Update Right/Bottom Coordinates.
    position_x_r = position_x + width;
    position_y_r = position_y + height;
  }
  public boolean isMouseOverButton() {
    return hit(parent.mouseX, parent.mouseY);
  }
  private boolean hit(int mx, int my) {
    return (mx > position_x && mx < position_x + width &&
            my > position_y && my < position_y + height);
  }
}

/**
 * Calculates the Midpoint Between Two Points.
 * @param x1 The x-coordinate of the first point.
 * @param y1 The y-coordinate of the first point.
 * @param x2 The x-coordinate of the second point.
 * @param y2 The y-coordinate of the second point.
 * @return A PVector representing the midpoint.
 */
PVector midpoint(float x1, float y1, float x2, float y2) {
  return new PVector((x1 + x2) / 2, (y1 + y2) / 2);
}

int getWeather() {
  int weather = 0;
  // 0: Sunny, 1: Windy, 2: Cloudy, 3: Rain, 4: Snow, 5: Storm.
  String des = setupWeather();
  switch(des) {
    case "clear sky":
    case "few clouds":
      weather = 0; // Sunny
      case "scattered clouds":
      case "broken clouds":
      case "overcast clouds":
        weather = 2; // Cloudy
        break;
      case "shower rain":
      case "rain":
      case "light rain":
      case "moderate rain":
        weather = 3; // Rain
        break;
      case "thunderstorm":
        weather = 5; // Storm
        break;
      case "snow":
      case "light snow":
        weather = 4; // Snow
        break;
    }
    return weather;
  }
  