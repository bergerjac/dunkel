// imports library
import processing.serial.*;
import processing.video.*;

Movie mov;

Serial myPort;
float stickOne=1;
int buttonOne=0;
int buttonTwo=0;

void setup(){
  size (800,800);
  smooth();
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.bufferUntil('\n');
  mov = new Movie(this, "final_comp.mov");
  mov.loop();
}

void movieEvent(Movie movie) {
  mov.read();  
}

void serialEvent(Serial thisPort) {
  String inputString = thisPort.readStringUntil('\n');

  if (inputString != null){
    inputString = trim(inputString);                                                              // trim the carrige return and linefeed from the input string:
   int sensors[] = int(split(inputString, ',')); 
                                                                                      // split the input string at the commas
                                                                                      // and convert the sections into integers:
     if (sensors.length == 3) {                                                         
      stickOne = int(map(sensors[0], 0, 1023, -2, 2));                  //might not work
      buttonOne= int(map(sensors[1], 0, 1, 0, 1));                                // make sure to comment on what each stick does
      buttonTwo= int(map(sensors[2], 0, 1, 0, 1));   
      // IamExtra= int(map(sensors[3], 0, 1023, 1,400));        
     }
  }
}


void draw(){  
  image(mov, 12, 12);
    
  float newSpeed = map(mouseX, 0, width, 0, 2);  // change here!!!! figure out soon
  mov.speed(newSpeed);  
                                                                
  
}

void keyPressed(){
  if(key == 's'){
  save("study6.jpeg");
  }
}


