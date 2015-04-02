
void setup(){
  Serial.begin(115200);
}

void loop(){
  int a0 = analogRead(0);
  int a1 = analogRead(1);
  int a2 = analogRead(2);
  int a3 = analogRead(3);
  int d0 = analogRead(4);
  int d1 = analogRead(5);
  
  
  Serial.print(a0);
  Serial.print(",");
  Serial.print(a1);
  Serial.print(",");
  Serial.print(a2);
  Serial.print(",");
  Serial.print(a3);
  Serial.print(",");
  Serial.print(d0);
  Serial.print(",");                                                                       
  Serial.print(d1);
  
  Serial.println();
  //delay(10);
}
