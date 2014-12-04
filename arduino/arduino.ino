// output to serial com port:
// output: "{POT=0:1023},{btn1:n=0,1}"
// output: "512,0,0,1,0,0,0"

int pot1 =0;
int btn1 = 0;
int btn2 = 0;
int btn3 = 0;
int btn4 = 0;
int btn5 = 0;
int btn6 = 0;

void setup(){
  
  pinMode(2, INPUT);  
  pinMode(3, INPUT); 
  Serial.begin(9600);
}

void loop () {
  pot1 = analogRead(A0);
  btn1 = digitalRead(2);
  btn2 = digitalRead(3);
  btn3 = digitalRead(4);
  btn4 = digitalRead(5);
  btn5 = digitalRead(6);
  btn6 = digitalRead(7);
  
  Serial.print(pot1);
  Serial.println(
    ","+String(btn1)+
    ","+String(btn2)+
    ","+String(btn3)+
    ","+String(btn4)+
    ","+String(btn5)+
    ","+String(btn6)
    );
 
  delay(100);
}

