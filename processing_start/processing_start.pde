boolean isDebug = true;
boolean isLinux = true;
boolean isWinds = !isLinux;

// imports library
import processing.serial.*;
import processing.video.*;

Movie movie;

Serial port;
float stickOne=1;
int buttonOne=0;
int buttonTwo=0;
int nInputs = 3;     // number of expected inputs

ArrayList<DJ> djs = new ArrayList<DJ>();  // list of DJs
DJ dj;                                    // current DJ

void setup(){
  port = validSerialPort();
  
  port.bufferUntil('\n');
  initMovie();
  
  // do this stuff AFTER serial port, movie 
  size (400,400);
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
  
  
//  for(int i=0; i< djs.size(); i++){
//     DJ dj = djs.get(i);
//     println(dj.name + dj.recordLabel);
//  }
  
  movieLooping();
}


void initMovie(){
  if(isWinds)
    movie = new Movie(this, "final_comp.mov");
}
void movieLooping(){
  if(isWinds)
    movie.loop();
}
void drawMovie(){
  if(isWinds)
    image(movie, 0, 0);
}

@Override void exit() {
   if (movie != null) movie.stop();
   super.exit();
}

Serial validSerialPort(){
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
     println("invalid port");
     return null;
  }
}


void movieEvent(Movie movie) {
   movie.read();  
}

void serialEvent(Serial thisPort) {
  String inputString = thisPort.readStringUntil('\n');

  if (inputString == null) return;

  inputString = trim(inputString); // trim carrige return and linefeed from input string
  // split input string at the commas;
  int inputs[] = int(split(inputString, ',')); 
  if (inputs.length != nInputs) { println("warn: {0} inputs; expected {1}", inputs.length, nInputs); return;} // UNexpected number of inputs
  
  processedInputs(inputs); // all inputs are processed
}

void processedInputs(int[] inputs){
  // process each input
  processedPot(inputs[0]);
  processedButton1(inputs[1]);
  processedButton2(inputs[2]);
}

void processedPot(input){
   stickOne = int(map(input, 0, 1023, -2, 2));// map 0:1023 -> -2:2
}
void processedButton1(input){
  button1= int(map(input, 0, 1, 0, 1));
}
void processedButton2(input){
  button2= int(map(input, 0, 1, 0, 1));
}

void draw(){
  drawMovie();
  //float newSpeed = map(mouseX, 0, width, 0, 2);  // change here!!!! figure out soon
  ///movie.speed(newSpeed);
}

void keyPressed(){
  if(key == 's'){
  //save("study6.jpeg");
  }
}

public class ScrollingText{
  PFont font;

  int x, y;   // current position of text

  public String text;
  public ScrollingText(String text){
    this.text = text;
  }
  
  public void start(){
    font = createFont("Orator Std", 64, true);
    x = width + 20;    // off screen
    y = height / 2; // halfway down canvas
  }
  public void draw(){
    textFont(font);
    // grey background
    fill(153);
    rect(0, 0, width, height);
      
    // text starts going offscreen -> draw another 50px behind
     if (x < 0){
      text(text, x + textWidth(text) + 50, y);
    }
   
    // leading iteration completely offscreen -> set x: location of next iteration
    if (x <= -textWidth(text)) {
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

// tap -> 1x, 100px/s: name horizontal scrolling across screen
// tap 2x -> record label
// tap 3x -> 100px/s; 6x/min; ; (proj.dim: 1600pxx1067px) blocky, straight in the middle
