// tap 1x -> name horizontal scrolling across screen
// tap 2x -> record label

boolean isDebug = true;
boolean mockSerialPort = true;
boolean isLinux = true;
boolean isWinds = !isLinux;
String serialPortOverride = "COM5"; // default: null; "COM5" -> override and use serial port on COM5
int minPlaybackSpeed = -2;// multiplier
int maxPlaybackSpeed = 2000;

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
  size (1700,1250);
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
  print(queue.size());

  if(scrollingText != null && scrollingText.isFinished){
     
  }
  if(scrollingText == null && queue.size() >= 1){
    ScrollingText text = queue.remove();
    print(text.text);
    text.start();
  }
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
}

public class ScrollingText{
  PFont font;

  int x, y;   // current position of text
  
  public String text;
  public bool isFinished = true;
  
  public ScrollingText(String text){
    this.text = text;
  }
  
  public void start(){
    isFinished = false;
    font = createFont("Orator Std", 64, true);
    x = width + 20;    // off screen
    y = height / 2; // halfway down canvas
    draw();
  }
  public void draw(){
    if(isFinished) return;
    
    textFont(font);
    // grey background
    fill(153);
    rect(0, 0, width, height);
      
    // text starts going offscreen -> draw another 50px behind
     if (x < 0){
      text(text, x + textWidth(text) + 50, y);
    }
       
    // leading iteration completely offscreen -> 
    if (x <= -textWidth(text)) {
      isFinished = true;
      // set x: location of next iteration
      x = x + (int)textWidth(text) + 50;
    }
   
   
    // draw text
    text(text, x, y);
    
    // move position one to the left
    x--;
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

