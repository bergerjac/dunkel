// imports library
import processing.serial.*;
import processing.video.*;

Movie movie;

Serial port;
float stickOne=1;
int buttonOne=0;
int buttonTwo=0;
int nInputs = 3;     // number of expected inputs

ScrollingText trest = new ScrollingText("my man");

void setup(){
println(trest.text);
  size (400,400);
  smooth();
  println(Serial.list());
  
  port = validSerialPort();
  
  port.bufferUntil('\n');
  movie = new Movie(this, "final_comp.mov");
   movie.loop();
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
  println("error: failed to initialize serial port.");
  exit();
  throw new RuntimeException();
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

  if (inputString != null) {
    inputString = trim(inputString); // trim carrige return and linefeed from input string
    // split input string at the commas;
    int inputs[] = int(split(inputString, ',')); 
    // convert sections integers:
    if (inputs.length == nInputs) {                                                         
      stickOne = remapToInt(inputs[0], 0, 1023, -2, 2);  //might not work
      buttonOne= remapToInt(inputs[1], 0, 1, 0, 1);
      buttonTwo= remapToInt(inputs[2], 0, 1, 0, 1);
      // IamExtra= int(map(sensors[3], 0, 1023, 1,400));        
     }
  }
}

int remapToInt(int inValue, float minInValue, float maxInValue, float minOutValue, float maxOutValue){
 return int(map(inValue, minInValue, maxInValue, minOutValue, maxOutValue));
}

void draw(){  
  image(movie, 0, 0);
  //float newSpeed = map(mouseX, 0, width, 0, 2);  // change here!!!! figure out soon
  ///movie.speed(newSpeed);
}

void keyPressed(){
  if(key == 's'){
  save("study6.jpeg");
  }
}

public class ScrollingText{
  public String text;
  public ScrollingText(String text){
    this.text = text;
  }
}

void nameScrollingAcrossScreen(){

}

// tap -> name horizontal scrolling across screen
// tap 2x -> record label
// tap 3x -> 100px/s; 6x/min; ; (proj.dim: 1600pxx1067px) blocky, straight in the middle
