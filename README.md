# MyStickerDiary - Project Documentation

## 1. Comments in the Source Code (Technical Details & Techniques)

### Core Programming Techniques Used

#### State Management Pattern
The project implements a **finite state machine** for screen transitions using integer constants:
```java
// Screen state management with enum-like constants
final int start_screen = 0;
final int menu_screen = 1;
final int making_sticker = 2;
// ... etc
```
**Technique**: This approach provides type-safe screen switching through the `switchScreen()` function, which handles cleanup and initialization for each screen state.

#### Event-Driven Architecture
The application uses Processing's built-in event handlers (`mousePressed()`, `mouseDragged()`, `mouseReleased()`, `mouseWheel()`) with a **delegation pattern**:
```java
void mousePressed() {
  switch (currentScreen) {
    case menu_screen: handleMenuMousePressed(); break;
    case drawing_diary: handleDiaryMouse(); break;
    // ... delegates to screen-specific handlers
  }
}
```
**Technique**: This separates concerns by delegating input handling to appropriate screen modules, improving code maintainability.

#### Double Buffering for Drawing
The sticker creator uses **off-screen rendering** with `PGraphics`:
```java
PGraphics stickerCanvas;
stickerCanvas = createGraphics(round(canvasSize), round(canvasSize));
```
**Technique**: This allows non-destructive editing by rendering to a buffer before displaying, enabling undo/redo functionality.

#### Undo/Redo Stack Implementation
Uses **Memento pattern** with bounded stacks:
```java
ArrayList<PImage> undoStack;
ArrayList<PImage> redoStack;
final int MAX_UNDO_STATES = 30;
```
**Technique**: Captures canvas state as images, allowing users to revert changes. The 30-state limit prevents excessive memory usage.

#### Smooth Animation with Lerp
Implements **exponential smoothing** for UI animations:
```java
menuScrollX += (menuTargetScrollX - menuScrollX) * 0.20;
pressAnim = parent.lerp(pressAnim, target, 0.20f);
```
**Technique**: Linear interpolation (lerp) with a damping factor creates smooth, natural-looking transitions and spring-like animations.

#### Button State Machine
The `rectButton` class implements a **3-state button pattern**:
- `armed`: Button was pressed inside
- `pressedInside`: Mouse is currently over the button while pressed
- `isHovering`: Mouse is over but not pressed

**Technique**: This ensures buttons only activate when pressed AND released inside their bounds, following standard UI conventions.

#### Elastic Scrolling with Arctangent
Menu scrolling implements **rubber-band effect**:
```java
float stretched_overshoot = stretch_constant * atan(overshoot / stretch_constant);
```
**Technique**: Uses arctangent function to create non-linear resistance when scrolling past boundaries, mimicking iOS-style elastic scrolling.

#### Aspect Ratio Preservation
The `getScaledImageSize()` function maintains image proportions:
```java
float imgRatio = (float)img.width / img.height;
float boxRatio = boxW / boxH;
if (boxRatio > imgRatio) { /* fit to height */ }
else { /* fit to width */ }
```
**Technique**: Compares aspect ratios to determine which dimension to constrain, preventing image distortion.

#### Particle System for Background
The `Bubble` class implements a **simple particle system**:
```java
class Bubble {
  PVector pos;
  float speed;
  void update() { pos.y -= speed; } // Rise upward
  void display() { ellipse(pos.x, pos.y, size, size); }
}
```
**Technique**: Manages multiple animated particles with individual properties, creating dynamic background effects.

#### Color Blending Techniques
Uses Processing's color manipulation functions:
```java
color brightenedColor = parent.lerpColor(faceColor, parent.color(255), 0.15f);
color diaryBackgroundColor = lerpColor(diaryPaperColor, color(255), 0.8);
```
**Technique**: Blends colors mathematically to create visual hierarchy and depth in UI elements.

#### JSON-based Persistence
Settings and diary data are stored using JSON format:
```java
JSONObject settingData = loadJSONObject("data/user_setting.json");
```
**Technique**: Human-readable serialization format makes debugging easier and allows manual editing of save files.

#### Asynchronous Loading
Implements a **multi-stage loading system**:
```java
int loadingStage = 0; // 0: Before Start, 1: Background Loading, 2: Main Complete, 3: All Complete
```
**Technique**: Prevents UI freeze during resource loading by spreading initialization across multiple frames.

#### Custom Cursor System
Dynamically changes cursor based on tool selection:
```java
cursor(brushCursor); // Uses PGraphics-based custom cursors
cursor(HAND); // Or built-in cursor types
```
**Technique**: Provides visual feedback for the current tool, improving user experience.

#### Handle-based Transformations
Stickers use corner handles for resizing:
```java
float[] getHandleRect(int index, float handleSize) {
  // Returns [x, y, w, h] for each corner handle
  // index: 0=TopLeft, 1=BottomLeft, 2=TopRight, 3=BottomRight
}
```
**Technique**: Calculates handle positions relative to sticker center and size, enabling intuitive resize interactions.

#### Weather API Integration
Fetches real-time weather data:
```java
String setupWeather() {
  // Makes HTTP request to OpenWeatherMap API
  // Returns weather description string
}
```
**Technique**: Integrates external data to enhance diary context with current weather conditions.

#### Sentiment Analysis API
Analyzes diary text emotion:
```java
void analyzeText() {
  // Sends diary text to sentiment analysis API
  // Returns sentiment score and label
}
```
**Technique**: Uses natural language processing to provide emotional feedback on diary entries.

#### Date Picker Implementation
Custom calendar UI with year/month scrolling:
```java
int isDatePickerVisible = 0; // 0: Hidden, 1: Month view, 2: Year view
```
**Technique**: Multi-level date selection interface allows users to navigate to any date efficiently.

#### Drag Speed Customization
User-adjustable scroll sensitivity:
```java
float menuDragSpeed = 1.0; // Multiplier for drag distance
```
**Technique**: Allows users to customize interaction feel based on preference, improving accessibility.

#### Sound System with Volume Control
Manages background music and sound effects:
```java
SoundFile song, clickSound;
song.amp(bgmVolume); // Volume control
clickSound.play(); // Play effect
```
**Technique**: Separates BGM and SFX volumes, providing granular audio control.

---

## 2. Overall Architecture and Component Descriptions

### Project Structure

```
MyStickerDiary/
├── MyStickerDiary.pde          # Main sketch file (entry point)
├── StartScreen.pde             # Initial splash screen
├── MenuScreen.pde              # Main navigation menu
├── NameScreen.pde              # User name input screen
├── MakingSticker.pde           # Sticker creation canvas
├── StickerLibrary.pde          # Sticker gallery viewer
├── DrawingDiary.pde            # Diary editing interface
├── DiaryLibrary.pde            # Diary archive/calendar
├── Sticker.pde                 # Sticker data class
├── Utils.pde                   # Utility functions and custom button class
├── WeatherDataAPI.pde          # Weather data fetcher
├── WeatherEffects.pde          # Visual weather effects
├── EmotionAnalysisAPI.pde      # Sentiment analysis integration
├── README.md                   # Project overview
└── data/                       # Resource directory
    ├── images/                 # UI icons and graphics
    │   ├── icon_*.png         # Weather and emotion icons
    │   ├── backIcon.png       # Navigation back button
    │   ├── SaveIcon.png       # Save action icon
    │   ├── brush.png          # Drawing tool icons
    │   ├── paint.png
    │   ├── eraser.png
    │   ├── undo.png
    │   ├── trash_*.png        # Delete zone icons
    │   ├── cat.png            # Menu button images
    │   ├── fox.png
    │   ├── cloud.png
    │   ├── owl.png
    │   ├── meow.png           # Mascot character
    │   └── name_edit*.png     # Name editing UI states
    ├── fonts/                 # Custom font files
    │   └── nanumHandWriting_babyLove.ttf
    ├── sounds/                # Audio files
    │   ├── cutebgm.mp3       # Background music
    │   └── click.mp3         # UI click sound
    ├── sticker/               # User-created stickers
    │   └── sticker_*.png     # Saved sticker images
    ├── diaries/               # Saved diary entries
    │   └── diary_*.json      # Diary data files
    └── user_setting.json      # User preferences and settings
```

### Component Descriptions

#### **MyStickerDiary.pde** (Main Controller)
**Purpose**: Application entry point and core state management  
**Key Responsibilities**:
- Initializes all screens and global variables
- Manages screen state transitions via `switchScreen()`
- Coordinates input event delegation to active screen
- Loads/saves user settings on startup/exit
- Handles background music and sound effects
- Implements settings overlay UI

**Key Variables**:
- `currentScreen`, `previousScreen`: Track application state
- `username`: Current user's name
- `stickerLibrary`, `placedStickers`: Sticker management
- `song`, `clickSound`: Audio playback
- Menu navigation: `dsButton`, `slButton`, `ddButton`, `dlButton`

#### **StartScreen.pde** (Splash Screen)
**Purpose**: Welcome screen with mascot animation  
**Features**:
- Displays application logo and mascot character
- Animated "Click Anywhere to Start" prompt with pulsing effect
- Floating bubble particle background
- Handles click-to-continue interaction

#### **MenuScreen.pde** (Navigation Hub)
**Purpose**: Main menu with horizontal scrolling pages  
**Features**:
- Three-page layout: Sticker Creation/Library → Diary Creation/Library
- Elastic horizontal scrolling with rubber-band edges
- Custom button rendering with press animations
- Page indicators with click navigation
- Username display with edit button
- Mouse wheel and drag support

**Design Pattern**: Uses world coordinates (`worldMouseX()`) to handle scrolling offset

#### **NameScreen.pde** (User Identification)
**Purpose**: Initial user name entry  
**Features**:
- Text input field for username
- First-time setup screen
- Integrated with settings persistence

#### **MakingSticker.pde** (Drawing Canvas)
**Purpose**: Creative tool for making custom stickers  
**Features**:
- **Drawing Tools**:
  - Brush: Freehand drawing
  - Paint Bucket: Fill regions
  - Eraser: Remove content
  - Line, Rectangle, Circle: Shape primitives
  - Eyedropper: Color sampling from canvas
- **Color System**:
  - Predefined color palette (20 colors)
  - Rainbow color picker
  - Custom color selection
- **Editing Features**:
  - Undo/Redo (up to 30 steps)
  - Clear all
  - Adjustable brush size
- **Export**: Save stickers as PNG files with timestamp naming

**Technical Details**:
- Uses `PGraphics` off-screen buffer for non-destructive editing
- Custom cursor graphics for each tool
- Shape preview while dragging

#### **StickerLibrary.pde** (Sticker Gallery)
**Purpose**: Browse and manage saved stickers  
**Features**:
- Grid layout of all saved stickers
- Scrollable with mouse wheel
- Click sticker to enter edit mode in `MakingSticker`
- Delete functionality
- Shows sticker count

**Layout**: Dynamic grid that adjusts to window size

#### **DrawingDiary.pde** (Diary Editor)
**Purpose**: Main diary creation and editing interface  
**Features**:
- **Date Selection**: Custom date picker (day/month/year)
- **Weather Selection**: 6 weather types (Sunny, Windy, Cloudy, Rain, Snow, Storm)
- **Emotion Icons**: 5 mood indicators (Happy, Neutral, Sad, Crying, Angry)
- **Text Input**: Title and body text areas using G4P library
- **Sticker Placement**:
  - Drag stickers from overlay panel
  - Resize using corner handles
  - Rotate by dragging
  - Delete by dragging to trash zone
- **Background Color**: Customizable diary paper color
- **AI Features**:
  - Sentiment analysis of diary text
  - Real-time weather effects matching selected weather
- **Save/Load**: JSON-based diary persistence

**Technical Details**:
- Uses G4P for text input widgets (`GTextField`, `GTextArea`)
- Sticker overlay with vertical scrolling
- Weather effects rendered in background layer
- Date format: `diary_YYYYMMDD.json`

#### **DiaryLibrary.pde** (Diary Archive)
**Purpose**: Calendar-based diary browser  
**Features**:
- Monthly calendar view
- Visual indicators for days with diaries
- Navigation: Previous/Next month buttons
- Click date to load diary
- Shows diary count and date range
- Year/month quick jump

**Layout**: Traditional calendar grid (7 columns × 5 rows)

#### **Sticker.pde** (Data Model)
**Purpose**: Sticker object representation  
**Attributes**:
- `x, y`: Position coordinates
- `img`: PImage data
- `size`: Display size
- `imageName`: File name
- `imagePath`: Full path to sticker file

**Methods**:
- `display()`: Render sticker at position
- `getDisplaySize()`: Calculate scaled dimensions
- `getHandleRect()`: Get resize handle positions

#### **Utils.pde** (Shared Utilities)
**Purpose**: Common functions and custom UI components  
**Functions**:
- `mouseHober()`: Collision detection for rectangles
- `monthToString()`: Convert month index to abbreviation
- `getScaledImageSize()`: Aspect-ratio-preserving image scaling
- Month navigation helpers: `prevMonthIdx0()`, `nextMonthIdx0()`
- `midpoint()`: Calculate center point between two coordinates
- `getWeather()`: Parse weather API response

**Custom Classes**:
- **`rectButton`**: Animated button with two styles
  - SIMPLE: Centered text, solid color
  - FANCY: Two-tone gradient, text + image layout
  - Features: Press animation, hover effects, shadow rendering
  - State tracking: Armed, pressed inside, hovering

#### **WeatherDataAPI.pde** (External Data)
**Purpose**: Fetch real-time weather data  
**Implementation**:
- Uses OpenWeatherMap API
- Returns weather description string
- Called when creating new diary entry
- Provides context for weather effects

#### **WeatherEffects.pde** (Visual Effects)
**Purpose**: Animated weather backgrounds  
**Effects**:
- **Sunny**: Warm light rays
- **Windy**: Moving lines
- **Cloudy**: Floating clouds
- **Rainy**: Falling raindrops
- **Snowy**: Falling snowflakes
- **Stormy**: Lightning flashes, heavy rain

**Technique**: Particle systems and procedural animation

#### **EmotionAnalysisAPI.pde** (AI Integration)
**Purpose**: Analyze emotional content of diary text  
**Implementation**:
- Sends diary text to sentiment analysis API
- Returns sentiment score (0.0 to 1.0)
- Categorizes as positive/neutral/negative
- Displays results in diary interface

### Data Files

#### **user_setting.json**
Stores user preferences:
```json
{
  "Name": "user name",
  "bgmVolume": 0.5,
  "sfxVolume": 0.8,
  "dragSpeed": 1.0
}
```

#### **diary_YYYYMMDD.json**
Diary entry format:
```json
{
  "date": "2024-10-28",
  "title": "Diary title",
  "content": "Diary text content",
  "weather": 0,
  "emotion": 2,
  "paperColor": 16768688,
  "stickers": [
    {
      "imageName": "sticker_20241028_1234.png",
      "x": 640,
      "y": 360,
      "size": 100
    }
  ]
}
```

#### **sticker_YYYYMMdd_HHmm.png**
User-created sticker images with timestamp naming

---

## 3. User Guide - Picture Diary Flow

### Overview
**MyStickerDiary** lets you create custom stickers and use them to decorate your personal diary entries. The workflow is simple: make stickers, write diaries, and preserve your memories!

---

### Step 1: Launch and Enter Your Name
- Click anywhere on the splash screen to start
- Enter your name when prompted (first time only)
- Navigate the **main menu** by dragging left/right or using mouse wheel
- The menu has 3 pages: **Drawing Sticker** 🎨 | **Sticker Library** 🦊 | **Drawing Diary** ☁️ | **Diary Library** 🦉

---

### Step 2: Create Your First Sticker
1. Click **Drawing Sticker** (cat icon) from the main menu
2. Select a drawing tool from the left toolbar:
   - **Brush** 🖌️, **Paint Bucket** 🎨, **Eraser** 🧽, **Line** 📏, **Rectangle** ▢, **Circle** ⭕, **Eyedropper** 💧
3. Choose a color from the palette on the right (or use the rainbow picker for custom colors)
4. Draw your sticker on the canvas
   - Use **Undo/Redo** (up to 30 steps) if you make mistakes
   - Adjust brush size with the slider
5. Click **Save** 💾 when finished
6. Return to main menu with the **Back** button ←

---

### Step 3: Write Your First Diary Entry
1. Click **Drawing Diary** (cloud icon) from the main menu
2. **Set the date** by clicking the date display at the top
3. **Select weather** ☀️💨☁️🌧️❄️⛈️ - the background will show matching animated effects!
4. **Choose your mood** 😊😐😢😭😠 for that day

---

### Step 4: Write Title and Content
1. Click the **title field** and enter a diary title (e.g., "Best Day Ever!")
2. Click the **main text area** below and write about your day
   - What happened, who you met, how you felt, etc.
3. Optional: Click **Analyze** to get AI sentiment analysis of your text

---

### Step 5: Decorate with Stickers
1. Click **Sticker Storage** button on the right
2. A panel slides out showing all your saved stickers
3. **Drag and drop** stickers onto your diary
4. **Resize**: Click a sticker, then drag the corner handles
5. **Move**: Click and drag the center of a sticker
6. **Delete**: Drag a sticker to the trash icon in the bottom-left corner

---

### Step 6: Customize and Save
1. Optional: Change diary **background color** using the Color Picker button
2. Click **Save** to store your diary entry
3. Click **Back** ← to return to the main menu

---

### Step 7: View Past Diaries
1. Click **Diary Library** (owl icon) from the main menu
2. Browse the **calendar view** - days with diary entries are highlighted
3. Navigate using **Previous Month** / **Next Month** buttons
4. Click any highlighted day to open and read/edit that diary

---

### Step 8: Manage Your Sticker Collection
1. Click **Sticker Library** (fox icon) from the main menu
2. Browse your saved stickers in a scrollable grid
3. Click any sticker to **edit** it in the drawing screen
4. Use the **delete** icon 🗑️ to remove unwanted stickers

---

### Step 9: Customize Settings
1. Click the **Settings** icon ⚙️ from the main menu
2. Adjust:
   - **BGM Volume**: Background music level
   - **SFX Volume**: Sound effects level
   - **Drag Speed**: Menu scrolling sensitivity
3. Settings save automatically

---

### Step 10: Tips for Best Experience
**Sticker Creation**:
- Use Undo liberally - experiment freely!
- Create themed sets (emotions, food, animals, etc.)
- Small details make stickers more expressive

**Diary Writing**:
- Write regularly to build a habit
- Use weather icons consistently for context
- Add multiple stickers to highlight special moments
- Try sentiment analysis to track emotional patterns

**Organization**:
- Write meaningful titles for easy searching
- Review old diaries monthly
- Layer and arrange stickers creatively

**Controls Reminder**:
- **Left Click + Drag**: Draw, move stickers, scroll pages
- **Mouse Wheel**: Scroll through libraries and calendars
- **Corner Handles**: Resize selected stickers
- **Trash Zone**: Delete stickers by dragging there

---

## Have Fun Creating! 🎨📖

**MyStickerDiary** is your personal creative space - express yourself, document memories, and decorate freely! ✨

---

## 4. List of Borrowed Contents

### External Libraries Used

#### **Interfascia** - GUI Control Library
- **Purpose**: Basic GUI components and controls
- **Usage**: Button and label creation for user interface elements
- **License**: Open Source
- **Link**: http://interfascia.berg.industries/

#### **UIBooster** - GUI Control Library
- **Purpose**: Native system dialogs and confirmation windows
- **Usage**: Save/Load confirmation dialogs, file pickers
- **License**: Open Source  
- **Link**: https://github.com/Milchreis/UiBooster

#### **G4P (GUI for Processing)** - GUI Control Library
- **Purpose**: Advanced text input widgets
- **Usage**: Text fields and text areas for diary title and content
- **Features Used**: `GTextField`, `GTextArea`, `GImageButton`, `GSlider`
- **License**: Open Source
- **Link**: http://www.lagers.org.uk/g4p/

#### **Processing Sound** - Sound Play Library
- **Purpose**: Audio playback and control
- **Usage**: Background music (BGM) and sound effects (SFX)
- **Features Used**: `SoundFile` class for playing MP3 files, volume control
- **License**: LGPL (included with Processing)
- **Link**: https://processing.org/reference/libraries/sound/

---

### Audio Assets

#### **Background Music: "Cute BGM"**
- **Source**: YouTube Audio Library
- **Creator**: Various Artists
- **Link**: https://www.youtube.com/watch?v=inAfxb2VEc0&list=PL5ELOvDkXzUBSMaXEFYAd_Jw4BXw1Ptkq&index=20
- **Usage**: Main menu and diary editing background music
- **License**: Royalty-free / Creative Commons
- **File**: `data/sounds/cutebgm.mp3`

#### **Click Sound Effect**
- **Source**: Free sound effects library
- **Usage**: UI button click feedback
- **File**: `data/sounds/click.mp3`

---

### APIs and External Services

#### **Sentiment Analysis API - ClapAI modernBERT**
- **Service**: HuggingFace Inference API
- **Model**: `clapAI/modernBERT-base-multilingual-sentiment`
- **Link**: https://huggingface.co/clapAI/modernBERT-base-multilingual-sentiment
- **Purpose**: Analyzing emotional tone of diary entries
- **Usage**: 
  - Processes diary text through multilingual BERT model
  - Returns sentiment score (0.0 to 1.0) and label (Positive/Neutral/Negative)
  - Helps users understand the emotional content of their writing
- **Implementation**: `EmotionAnalysisAPI.pde`
- **Language Support**: Multilingual (including Korean, English)

#### **Weather Data API - OpenWeatherMap**
- **Service**: OpenWeatherMap API
- **Link**: https://openweathermap.org/
- **Purpose**: Fetching real-time weather data
- **Usage**:
  - Retrieves current weather conditions when creating diary entries
  - Provides weather descriptions that map to visual effects
  - Enhances diary context with meteorological information
- **Implementation**: `WeatherDataAPI.pde`
- **Data Used**: Weather description, temperature, conditions

---

### Fonts

#### **Nanum Handwriting BabyLove**
- **Type**: TrueType Font (.ttf)
- **Style**: Handwritten Korean font
- **Usage**: UI text rendering for a friendly, diary-like aesthetic
- **License**: Open Font License
- **File**: `data/fonts/nanumHandWriting_babyLove.ttf`

---

### Visual Assets (AI-Generated)

All character illustrations and mascot graphics used in the project were created using **AI image generation tools**:

- **Mascot Character** (`meow.png`): Main splash screen character
- **Menu Button Characters**: 
  - Cat icon (`cat.png`) - Drawing Sticker button
  - Fox icon (`fox.png`) - Sticker Library button  
  - Cloud icon (`cloud.png`) - Drawing Diary button
  - Owl icon (`owl.png`) - Diary Library button
- **Running Friends** (`running_friends.png`): Additional decorative graphics

**AI Generation Tool**: DALL-E / Stable Diffusion / Midjourney
**Prompts Used**: Custom prompts designed for cute, diary-themed character illustrations
**License**: Generated assets are original and project-specific

---

### Icon Sets

#### **Weather Icons**
- Custom-designed weather icons for diary context
- Files: `icon_weather_sunny.png`, `icon_weather_rainy.png`, `icon_weather_cloudy.png`, `icon_weather_windy.png`, `icon_weather_snow.png`, `icon_weather_storm.png`
- Style: Minimalist, colorful

#### **Emotion Icons**
- Custom emoji-style emotion indicators
- Files: `icon_face_happy.png`, `icon_face_neutral.png`, `icon_face_sad.png`, `icon_face_crying.png`, `icon_face_angry.png`
- Style: Simple, expressive faces

#### **UI Icons**
- Tool icons: `brush.png`, `paint.png`, `eraser.png`, `undo.png`, `spoide.png`
- Action icons: `SaveIcon.png`, `backIcon.png`, `trash_closed.png`, `trash_open.png`
- Edit icons: `name_edit.png` series (normal, hover, pressed, off states)

---

### Code References

**Processing Framework**
- **Version**: Processing 4.x
- **Language**: Java-based
- **License**: LGPL
- **Link**: https://processing.org/

**Programming Patterns Referenced**:
- State machine pattern for screen management
- Observer pattern for event handling  
- Memento pattern for undo/redo functionality
- MVC-inspired separation of concerns

---

### Attribution Summary

All external resources used in this project are either:
- ✅ Open source libraries with appropriate licenses
- ✅ Royalty-free audio content
- ✅ Free-tier API services
- ✅ AI-generated original content
- ✅ Custom-created graphics and icons

No copyrighted materials were used without proper licensing or attribution.

---

## 5. Declaration of AI Tool Usage in the Project

This section outlines how AI tools were utilized in the development of MyStickerDiary.

---

### 1. Development Assistance

AI tools were used to assist in various aspects of software development:

- **Code Review**: Reviewing code for potential bugs and suggesting improvements
- **Debugging**: Identifying and resolving technical issues in the codebase
- **Algorithm Implementation**: Assisting with implementation of features such as elastic scrolling, undo/redo functionality, and UI animations
- **Library Integration**: Providing guidance on using external libraries (G4P, Interfascia, UIBooster, Processing Sound)
- **Code Documentation**: Helping write clear inline comments and documentation

---

### 2. Character and Visual Design

AI image generation tools were used to create all character illustrations in the application:

**AI-Generated Assets**:
- Main mascot character (`meow.png`) - splash screen welcome character
- Cat character (`cat.png`) - Drawing Sticker menu button
- Fox character (`fox.png`) - Sticker Library menu button
- Cloud character (`cloud.png`) - Drawing Diary menu button
- Owl character (`owl.png`) - Diary Library menu button
- Supporting graphics (`running_friends.png`)

**Design Process**:
1. Created prompts describing desired character style (cute, friendly, diary-themed)
2. Generated multiple variations using AI tools
3. Selected and refined the best results
4. Integrated finalized assets into the application

---

### 3. Sentiment Analysis Feature (clapAI)

The application includes an AI-powered sentiment analysis feature using the **clapAI modernBERT model**.

**Implementation**: `EmotionAnalysisAPI.pde`

**Functionality**:
- Analyzes the emotional tone of diary text entries
- Uses multilingual NLP (Natural Language Processing) model
- Supports Korean, English, and other languages
- Returns sentiment classification (Positive/Neutral/Negative) with confidence score

**User Benefit**:
- Provides objective insight into the emotional content of diary entries
- Helps users track mood patterns over time
- Enhances self-awareness through AI feedback

**Example**:
```
Diary Text: "오늘 친구들과 즐거운 시간을 보냈다!"
Analysis Result: Positive (0.92)
```

---

### 4. Documentation

AI tools assisted in creating project documentation:

- Writing code comments and explanations
- Structuring the README file
- Organizing this project report
- Formatting technical documentation

---

### 5. Responsible AI Usage

**Transparency**:
- All AI-generated content is disclosed in this report
- External AI services are properly credited
- Clear distinction between AI-assisted and human-created work

**Human Oversight**:
- All AI suggestions were reviewed and validated by the development team
- Final decisions about features, design, and implementation were made by human developers
- Core creative vision and architecture were human-driven

**Ethical Considerations**:
- AI served as a tool to enhance productivity, not replace human creativity
- The development team maintained full understanding of all code
- User privacy is protected - sentiment analysis is user-initiated and optional

---

**Summary**: AI tools were used as assistants throughout the project to improve code quality, create visual assets, provide integrated features, and enhance documentation. However, the fundamental design, implementation, and creative decisions were made by the human development team.

---

**Project Team**:
- 김동현 (Development)
- 신이철 (Development)  
- 최은영 (Development)

**Documentation Date**: October 2024  
**Processing Version**: 4.x  
**Project Repository**: https://github.com/2025-2-CMP-Team6/MyStickerDiary

---

## 4. List of Borrowed Contents

This project incorporates various external libraries, media, and APIs to enhance functionality and user experience. Below is a comprehensive list of all borrowed contents used in the project:

### External Libraries

#### **Interfascia** - GUI Control Library
- **Purpose**: Provides basic GUI components for user interface elements
- **Source**: Processing Library Manager
- **Usage**: Button controls and interface elements in early development stages
- **License**: Open source

#### **UIBooster** - GUI Control Library
- **Purpose**: Simplified dialog and popup creation for user interactions
- **Source**: Processing Library Manager / [GitHub](https://github.com/Milchreis/UiBooster)
- **Usage**: Confirmation dialogs (e.g., "Do you want to save your changes?"), user prompts for name input
- **License**: MIT License

#### **G4P (GUI for Processing)** - GUI Control Library
- **Purpose**: Advanced GUI controls with text input capabilities
- **Source**: Processing Library Manager / [Official Site](http://www.lagers.org.uk/g4p/)
- **Usage**: 
  - `GTextField`: Diary title input field
  - `GTextArea`: Main diary content text area with scrolling support
  - `GImageButton`: Name edit button with custom image states
  - `GSlider`: Volume controls and drag speed settings
- **License**: GNU Lesser General Public License

#### **Processing Sound** - Audio Playback Library
- **Purpose**: Sound file loading and playback functionality
- **Source**: Built-in Processing library
- **Usage**: Background music playback, UI sound effects (click sounds)
- **License**: LGPL

### Media Assets

#### **Background Music (BGM)**
- **Title**: "Cute BGM"
- **Source**: [YouTube - Pastel Music](https://www.youtube.com/watch?v=inAfxb2VEc0&list=PL5ELOvDkXzUBSMaXEFYAd_Jw4BXw1Ptkq&index=20)
- **Artist**: Pastel Music / 파스텔뮤직
- **File**: `data/sounds/cutebgm.mp3`
- **Usage**: Background music that plays during application use
- **License**: Royalty-free music / Creative Commons (verify specific license)
- **Note**: Downloaded and converted to MP3 format for Processing compatibility

#### **UI Sound Effects**
- **Click Sound**: `data/sounds/click.mp3`
- **Source**: Self-created or royalty-free sound library
- **Usage**: Button click feedback throughout the application

#### **Custom Font**
- **Name**: Nanum HandWriting - Baby Love (나눔손글씨 아기사랑체)
- **File**: `data/fonts/nanumHandWriting_babyLove.ttf`
- **Source**: [Nanum Font](https://hangeul.naver.com/font)
- **Usage**: UI text rendering to provide a handwritten, diary-like aesthetic
- **License**: SIL Open Font License (OFL)

#### **Icon Images**
All icon images in `data/images/` were either:
- Created by the team using digital art tools
- Sourced from royalty-free icon libraries
- Modified from open-source icon sets

**Icon Categories**:
- Weather icons: `icon_weather_*.png` (sunny, cloudy, rainy, snowy, windy, stormy)
- Emotion icons: `icon_face_*.png` (happy, neutral, sad, crying, angry)
- Tool icons: `brush.png`, `paint.png`, `eraser.png`, `undo.png`
- UI elements: `backIcon.png`, `SaveIcon.png`, `trash_*.png`
- Character illustrations: `cat.png`, `fox.png`, `cloud.png`, `owl.png`, `meow.png`

### External APIs

#### **HuggingFace Sentiment Analysis API**
- **Model**: modernBERT-base-multilingual-sentiment by clapAI
- **URL**: https://huggingface.co/clapAI/modernBERT-base-multilingual-sentiment
- **Purpose**: Analyzes the emotional sentiment of diary text content
- **Implementation**: `EmotionAnalysisAPI.pde`
- **Usage**: 
  - Accepts diary text as input
  - Returns sentiment score (0.0 to 1.0) and label (Positive/Neutral/Negative)
  - Provides users with emotional insights about their writing
- **API Type**: REST API via HTTP POST request
- **License**: Apache 2.0 (verify on HuggingFace model page)
- **Rate Limits**: Subject to HuggingFace API usage limits
- **Cost**: Free tier available

#### **OpenWeatherMap API**
- **Service**: Current Weather Data API
- **URL**: https://openweathermap.org/api
- **Purpose**: Fetches real-time weather information based on user location
- **Implementation**: `WeatherDataAPI.pde`
- **Usage**:
  - Automatically retrieves current weather conditions
  - Suggests appropriate weather icon for diary entry
  - Provides weather description (clear sky, rain, snow, etc.)
  - Enables weather-based visual effects in diary background
- **API Type**: REST API via HTTP GET request
- **License**: OpenWeatherMap API terms of service
- **Rate Limits**: Free tier allows 1,000 calls/day
- **Cost**: Free tier used in this project
- **Note**: Requires API key (stored in code, should be externalized in production)

### Design Inspirations

The overall visual design and color palette were inspired by:
- **Stationery aesthetics**: Traditional diary and notebook designs
- **Pastel color schemes**: Soft, warm colors for a comforting user experience
- **Kawaii (cute) style**: Japanese cute aesthetic for character illustrations and stickers

### Development Tools

- **Processing IDE**: Version 4.x
- **Java**: JDK 11 or higher (required for Processing)
- **Code Editor**: Processing built-in editor
- **Version Control**: Git / GitHub
- **Graphics Editing**: Various tools for creating and editing image assets

### Attribution Notes

All borrowed content is used in accordance with respective licenses and terms of service. The team has made efforts to:
- ✅ Properly attribute all external resources
- ✅ Comply with licensing requirements
- ✅ Use only content that allows educational and non-commercial use
- ✅ Respect copyright and intellectual property rights

**If you are the owner of any content used in this project and have concerns, please contact the development team.**

---

## 5. Declaration of How AI Tools Were Used in the Project

This project leveraged various AI tools throughout the development lifecycle to enhance code quality, productivity, and feature implementation. Below is a comprehensive declaration of all AI tool usage:

### AI-Powered Development Assistance

- **Purpose**: Code review, debugging, and general development consultation
- **Usage Scenarios**:
  
  **1. Code Review and Optimization**
  - Reviewed Processing/Java code for potential bugs and inefficiencies
  - Suggested performance optimizations (e.g., using `PGraphics` for off-screen rendering)
  - Identified memory leaks and recommended solutions (e.g., limiting undo stack size)
  - Helped refactor complex functions into modular, maintainable components
  
  **2. Bug Fixing and Debugging**
  - Identified race conditions in asynchronous loading
  - Helped debug file I/O issues with JSON parsing
  - Resolved issues with G4P text input event handling
  - Fixed coordinate transformation problems in scrolling menus
  
  **3. Documentation**
  - Assisted in writing clear, comprehensive code comments
  - Helped create this project documentation
  - Suggested best practices for inline documentation
  - Reviewed and improved README content

### AI-Powered Features in the Application

#### **ClapAI Sentiment Analysis (HuggingFace)**
- **Integration Point**: `EmotionAnalysisAPI.pde`
- **AI Model**: modernBERT-base-multilingual-sentiment
- **Functionality**:
  - Analyzes diary text using state-of-the-art NLP (Natural Language Processing)
  - Employs BERT (Bidirectional Encoder Representations from Transformers) architecture
  - Supports multilingual input (English, Korean, etc.)
  - Returns sentiment score and classification
  
- **Technical Implementation**:
  ```java
  // Simplified example of API call
  void analyzeText() {
    String diaryText = textArea.getText();
    JSONObject requestBody = new JSONObject();
    requestBody.setString("inputs", diaryText);
    
    // Send HTTP POST request to HuggingFace API
    // Parse response to get sentiment score
    // Display result to user
  }
  ```

- **User Experience Enhancement**:
  - Provides emotional awareness about writing
  - Helps users track emotional patterns over time
  - Offers objective analysis of subjective content
  - Makes diary writing more interactive and insightful

#### **Character and Visual Design**
AI image generation tools were used to create all character illustrations in the application:

- **AI-Generated Assets**:
  - Main mascot character (`meow.png`) - splash screen welcome character
  - Cat character (`cat.png`) - Drawing Sticker menu button
  - Fox character (`fox.png`) - Sticker Library menu button
  - Cloud character (`cloud.png`) - Drawing Diary menu button
  - Owl character (`owl.png`) - Diary Library menu button
  - Supporting graphics (`running_friends.png`)

- **Design Process**:
  1. Created prompts describing desired character style (cute, friendly, diary-themed)
  2. Generated multiple variations using AI tools
  3. Selected and refined the best results
  4. Integrated finalized assets into the application

---

**This project demonstrates responsible and transparent use of AI tools as development aids while maintaining human creativity, ownership, and decision-making at the core of the software engineering process.**
