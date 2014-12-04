// tap 1x -> name horizontal scrolling across screen
// tap 2x -> record label

boolean isDebug = true;
boolean mockSerialPort = true;
boolean isLinux = true;
boolean isWinds = !isLinux;

boolean isFullScreen = false; // fullscreen toggle
//!!!!!!! set monitor: File -> Preferences: [Run sketches on display: ]
String serialPortOverride = "COM5"; // default: null; "COM5" -> override and use serial port on COM5
int minPlaybackSpeed = -2;// multiplier
int maxPlaybackSpeed = 2000;
int screenWidth = 600;
int screenHeight = 400;
int scrollingSpeed = 4;// 1:n
float scrollingBGy = 0.38;   // y pos  of scrolling text's background
float scrollingBGheight = 5; // height of scrolling text's background:  larger number -> smaller box
float scrollingBGgreyscale = 155; // 0:255 (-> black:white)
float scrollingBGgreyStrength = 255;// 0:255 (-> transparent:full) -> anything other than 255 -> a bit of a trailing shadow/fuzzy

// imports library
import processing.serial.*;
import processing.video.*;
import java.util.*;

Movie movie;

Serial port;
KeyboardInputStream keyboard;
float stickOne=1;
int[] buttons=new int[6];
int nInputs = 3;     // number of expected inputs

ArrayList<DJ> djs = new ArrayList<DJ>();  // list of DJs
DJ dj;                                    // current DJ
ScrollingText scrollingText;              // current scrolling text
Queue<ScrollingText> queue = new LinkedList();

void setup(){
  initSerialPort();
  
  initMovie();
  
  // do this stuff AFTER serial port, movie 
  
  // fullscreen or not
  if(isFullScreen){
    size(displayWidth, displayHeight);
  }
  else{
    size (screenWidth,screenHeight);
  }
  
  smooth();
  
  // init DJs in list
  //   first DJ is 'current'
  dj = new DJ("UN", "UNNAMED ASSAULT SYSTEM");
  djs.add(dj);
  AddDJ("MICOL DANIELI", "030 RECORDINGS");
  AddDJ("ANNA BOLENA", "IDROSCALO DISCHI");
  AddDJ("SIRIO GRY J", "MONOLITH RECORDS");
  AddDJ("CIRCULA", "");
  AddDJ("RUFOX", "");
  
  keyboard = new KeyboardInputStream();
  
//  for(int i=0; i< djs.size(); i++){
//     DJ dj = djs.get(i);
//     println(dj.name + dj.recordLabel);
//  }
  
  movieLooping();
}

boolean sketchFullScreen() {
  return isFullScreen;
}


void initMovie(){
  if(isWinds)
    movie = new Movie(this, "test2.mp4");
}
void movieLooping(){
  if(isWinds)
    movie.loop();
}
void drawMovie(){
  if(isWinds){
    image(movie, 0, 0);
    movie.speed(stickOne);
    //println(stickOne);
  }
}

@Override void exit() {
   if (movie != null) movie.stop();
   super.exit();
}

void initSerialPort(){
  if(mockSerialPort){ return; }
  port = validSerialPort();
  port.bufferUntil('\n');
}

Serial validSerialPort(){
  if (serialPortOverride != null){
    Serial tempPort = trySerialPort(serialPortOverride);
    return tempPort;
  }
  String[] portNames = Serial.list();
  for(int i=0; i< portNames.length; i++){
     Serial tempPort = trySerialPort(portNames[i]);
     if(tempPort != null) {
       println("port: " + portNames[i]);
       return tempPort;
     }
  }
  exitThrow("failed to initialize valid serial port.");
  return null; // never reached
}

Serial trySerialPort(String portName){
  try{
     Serial testPort = new Serial(this, portName, 9600);
     return testPort;
   }
  catch(Exception ex){
     println("invalid port: "+ portName);
     return null;
  }
}

void movieEvent(Movie movie) {
   movie.read();  
}

void serialEvent(Serial thisPort) {
  println("serialEvent");
  String inputString = thisPort.readStringUntil('\n');

  if (inputString == null) return;

  inputString = trim(inputString); // trim carrige return and linefeed from input string
  // split input string at the commas;
  println(inputString);
  int inputs[] = int(split(inputString, ',')); 
  if (inputs.length != nInputs) { println("warn: {0} inputs; expected {1}", inputs.length, nInputs); return;} // UNexpected number of inputs
  
  processedInputs(inputs); // all inputs are processed
}

void keyPressed(){
  processedInputs(
    new int[]{
      keyboard.getPotValue(),
      keyboard.getValue(1),
      keyboard.getValue(2),
      keyboard.getValue(3),
      keyboard.getValue(4),
      keyboard.getValue(5),
      keyboard.getValue(6)
    }
  );
  println();
}

void processedInputs(int[] inputs){
  // process each input
  processedPot(inputs[0]);
  processedButtons(inputs);
  println(queue.size());
}

void processedPot(int potInput){
   stickOne = int(map(potInput, 0, 1023, minPlaybackSpeed, maxPlaybackSpeed));
   print(stickOne+",");
}

void processedButtons(int[] allInputs){
  for(int i=0, n=1; i< buttons.length; i++, n++){
     buttons[i]= int(map(allInputs[n], 0, 1, 0, 1));
     if(buttons[i] == 1){
        queue.add(new ScrollingText(djs.get(i).name));
     }
     print(buttons[i]);
  }
}

void draw(){
  drawMovie();
  //float newSpeed = map(mouseX, 0, width, 0, 2);  // change here!!!! figure out soon
  ///movie.speed(newSpeed);
  drawScrollingText();
}

// draws scrolling text, if necessary
void drawScrollingText(){
   // (NO text scrolling OR scrolling text finished) AND scrolling text in queue -> pop that mofo
   if(
   (scrollingText == null || (scrollingText != null && scrollingText.isFinished))
     &&
   (queue.size() >= 1)
     ){
    scrollingText = queue.remove();
    println(scrollingText.text);
  }
  
  // scrolling text (and not finished) -> draw that mofo
  if(scrollingText != null && !scrollingText.isFinished){
    scrollingText.draw();
  }
}

public class ScrollingText{
  PFont font;

  int x, y;   // current position of text
 // int boxHeight = scrollingBoxHeight;
  
  public String text;
  public boolean isFinished = true;
  
  public ScrollingText(String text){
    this.text = text;
    isFinished = false;
    font = createFont("Orator Std", 64, true);
    x = width + 20;    // off screen
    y = height / 2; // halfway down canvas
  }
  
  public void draw(){
    //println("drawing: "+!isFinished);
    
    if(isFinished) return;
    
    textFont(font);
    // grey background
    fill(scrollingBGgreyscale, scrollingBGgreyStrength);
    //from x,1/3 screen
    rect(x, height*scrollingBGy, width, height/scrollingBGheight);
      
    // leading iteration completely offscreen -> 
    if (x <= -textWidth(text)-20) {
      fill(255);
      rect(0, 0, width, height);
      isFinished = true;
      //println("drawing finished");
      return;
    }
   
    // draw text
    fill(0);
    text(text, x, y);
    
    // move next position
    x -= scrollingSpeed;
    //println("drawind: "+text);
  }
}

public class DJ{
  public String name;
  public String recordLabel;
  public DJ(String name, String recordLabel){
    this.name = name;
    this.recordLabel = recordLabel;
  }
} 
void AddDJ(String name, String recordLabel){
  djs.add(new DJ(name,recordLabel));
}

void nameScrollingAcrossScreen(){

}

// exits and throws a RuntimeException w/ msg
void exitThrow(String message){
  exit();
  throw new RuntimeException(message);
}


interface IPotInputStream{
  int getPotValue();
}
interface IButtonInputStream{
  int getValue(int buttonNumber);
}
interface IInputStream {
 // int getNumberOfButtonInputs();
}

class KeyboardInputStream implements IInputStream, IButtonInputStream,  IPotInputStream {
   int potValue = 512;
   
   int getPotValue(){
     // up/down -> inc/decrement
     if (key == CODED){
         if (keyCode == UP) {// inc
           potValue++;
         }
         else if (keyCode == DOWN) {// dec
           potValue--;
         } 
     }
     // keep between 0:1023
     if(potValue < 0) potValue = 0;
     if(potValue > 1023) potValue = 1023;
     
     return potValue;
   }
   int getValue(int buttonNumber) {
     int intKey = Character.getNumericValue(key);
     if(intKey >= 1 && intKey <= 9 && intKey == buttonNumber){
        return 1;
     }
     return 0;
   }
}

/*
MULTI-CLICK: One Button, Multiple Events

Oct 12, 2009
Run checkButton() to retrieve a button event:
Click
Double-Click
Hold
Long Hold
*/

// Button timing variables
int debounce = 20; // ms debounce period to prevent flickering when pressing or releasing the button
int DCgap = 250; // max ms between clicks for a double click event
int holdTime = 2000; // ms hold period: how long to wait for press+hold event
int longHoldTime = 5000; // ms long hold period: how long to wait for press+hold event

// Other button variables
boolean buttonVal = true; // value read from button
boolean buttonLast = true; // buffered value of the button's previous state
boolean DCwaiting = false; // whether we're waiting for a double click (down)
boolean DConUp = false; // whether to register a double click on next release, or whether to wait and click
boolean singleOK = true; // whether it's OK to do a single click
long downTime = -1; // time the button was pressed down
long upTime = -1; // time the button was released
boolean ignoreUp = false; // whether to ignore the button release because the click+hold was triggered
boolean waitForUp = false; // when held, whether to wait for the up event
boolean holdEventPast = false; // whether or not the hold event happened already
boolean longHoldEventPast = false;// whether or not the long hold event happened already

int checkButton()
{ 
  int event = 0;
  // Read the state of the button
  buttonVal = digitalRead(buttonPin);
  // Button pressed down
  if (buttonVal == false && buttonLast == true && (millis() - upTime) > debounce) {
    downTime = millis();
    ignoreUp = false;
    waitForUp = false;
    singleOK = true;
    holdEventPast = false;
    longHoldEventPast = false;
    if ((millis()-upTime) < DCgap && DConUp == false && DCwaiting == true) DConUp = true;
    else DConUp = false;
    DCwaiting = false;
  }
  // Button released
  else if (buttonVal == HIGH && buttonLast == LOW && (millis() - downTime) > debounce) { 
    if (not ignoreUp) {
      upTime = millis();
      if (DConUp == false) DCwaiting = true;
      else {
        event = 2;
        DConUp = false;
        DCwaiting = false;
        singleOK = false;
      }
    }
  }
  // Test for normal click event: DCgap expired
  if ( buttonVal == HIGH && (millis()-upTime) >= DCgap && DCwaiting == true && DConUp == false && singleOK == true) {
    event = 1;
    DCwaiting = false;
  }
  // Test for hold
  if (buttonVal == LOW && (millis() - downTime) >= holdTime) {
    // Trigger "normal" hold
    if (not holdEventPast) {
      event = 3;
      waitForUp = true;
      ignoreUp = true;
      DConUp = false;
      DCwaiting = false;
      //downTime = millis();
      holdEventPast = true;
    }
    // Trigger "long" hold
    if ((millis() - downTime) >= longHoldTime) {
      if (not longHoldEventPast) {
        event = 4;
        longHoldEventPast = true;
      }
    }
  }
  buttonLast = buttonVal;
  return event;
}

