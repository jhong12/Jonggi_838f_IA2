int buttonPin_d = 2;
int buttonPin2_d = 3;
int photoPin_a = 0;
int potPin_a = 1;
int presPin_a = 2;

void setup(){
  pinMode(buttonPin_d, INPUT);
  pinMode(buttonPin2_d, INPUT);
  
  Serial.begin(9600);
}

void loop(){
  int photoState = analogRead(photoPin_a);
  int potState = analogRead(potPin_a);
  int presState = analogRead(presPin_a);
  int buttonState = digitalRead(buttonPin_d);
  int buttonState2 = digitalRead(buttonPin2_d);
  
  
  Serial.print(photoState);
  Serial.print(",");
  Serial.print(potState);
  Serial.print(",");
  Serial.print(presState);
  Serial.print(",");
  Serial.print(buttonState);
  Serial.print(",");
  Serial.print(buttonState2);                                                                         
  
  Serial.println();
  //delay(10);
}
