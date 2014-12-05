// tap 1x -> name horizontal scrolling across screen
// tap 2x -> record label

boolean isDebug = true;
boolean mockSerialPort = true;
boolean isLinux = false;
boolean isWinds = !isLinux;

boolean isFullScreen = true; // fullscreen toggle
//!!!!!!! set monitor: File -> Preferences: [Run sketches on display: ]
String serialPortOverride = "COM5"; // default: null; "COM5" -> override and use serial port on COM5
int minPlaybackSpeed = -2;// multiplier
int maxPlaybackSpeed = 4000;
int screenWidth = 600;
int screenHeight = 400;
int scrollingSpeed = 10;// 1:n
float scrollingBGy = 0.38;   // y pos  of scrolling text's background
float scrollingBGheight = 5; // height of scrolling text's background:  larger number -> smaller box

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
  background(0);
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
    image(movie, 100, -100);
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
  drawScrollingText();
  fill(0);
  rect(0,0, 100, height);    //added two rectangels to block the letters filling the black background
  rect(width-125,0, 125, height);
  waterMark();
}

void waterMark(){
  textSize(20);
   fill(40);
    text("StephenBontly.com", width - textWidth("StephenBontly.com"), height - 10);
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
    font = createFont("Orator Std", 400, true);
    x = width + 20;    // off screen
    y = height / 2; // halfway down canvas
  }
  
  public void draw(){
    //println("drawing: "+!isFinished);
    
    if(isFinished) return;
    
    textFont(font);
    // grey background
    //fill(153);
    //from x,1/3 screen
    //rect(x, height*scrollingBGy, width, height/scrollingBGheight);
      
    // leading iteration completely offscreen -> 
    if (x <= -textWidth(text)-20) {
      //fill(0);
      //rect(0, 0, width, height);
      isFinished = true;
      //println("drawing finished");
      return;
    }
   
    // draw text
    fill(255);
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

