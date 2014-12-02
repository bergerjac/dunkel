int switchState1 = 0;
int switchState2 = 0;
int pot1 =0;

void setup(){
  
  pinMode(2, INPUT);  
  pinMode(3, INPUT); 
  Serial.begin(9600);
}

void loop () {
  switchState1 = digitalRead(2);
  switchState2 = digitalRead(3);
  pot1 = analogRead(A0);
  
   Serial.print(pot1);
  
  if(switchState1 == LOW && switchState2 == LOW){
   Serial.println(",0,0");
  }
 if(switchState1 && switchState2 == LOW){
   Serial.println(",1,0");
  }
  if(switchState1 == LOW && switchState2){
   Serial.println(",0,1");
  }
  if(switchState1 && switchState2){
   Serial.println(",1,1");
  }
 
  delay(100);
}

