#include <SoftwareSerial.h>
SoftwareSerial mySerial(2,3);

const int FSR_PIN0 = A0; // Pin connected to FSR/resistor divider
const int FSR_PIN1 = A1;
const int FSR_PIN2 = A2;
const int FSR_PIN3 = A3;
const int FSR_PIN4 = A4;
const int FSR_PIN5 = A5;

const float VCC = 4.98; // Measured voltage of Ardunio 5V line
const float R_DIV = 3230.0; // Measured resistance of 3.3k resistor

void setup() 
{
  Serial.begin(9600);
  mySerial.begin(9600);
  pinMode(FSR_PIN0, INPUT);
  pinMode(FSR_PIN1, INPUT);
  pinMode(FSR_PIN2, INPUT);
  pinMode(FSR_PIN3, INPUT);
  pinMode(FSR_PIN4, INPUT);
  pinMode(FSR_PIN5, INPUT);
  Serial.println();
}

float forceConv(float fsrADC)
{
  if(fsrADC != 0){
    float fsrV = fsrADC * VCC / 1023.0;
    // Use voltage and static resistor value to 
    // calculate FSR resistance:
    float fsrR = R_DIV * (VCC / fsrV - 1.0);
    // Serial.println("Resistance: " + String(fsrR) + " ohms");
    // // Guesstimate force based on slopes in figure 3 of
    // FSR datasheet:
    float force;
    float fsrG = 1.0 / fsrR; // Calculate conductance
    // Break parabolic curve down into two linear slopes:
    if (fsrR <= 600) 
      force = (fsrG - 0.00075) / 0.00000032639;
    else
      force =  fsrG / 0.000000642857;
    return force;
  }
  else{
    return 0.0;
  }
  
}

void loop() 
{
  int fsrADC0 = analogRead(FSR_PIN0);
  int fsrADC1 = analogRead(FSR_PIN1);
  int fsrADC2 = analogRead(FSR_PIN2);
  int fsrADC3 = analogRead(FSR_PIN3);
  int fsrADC4 = analogRead(FSR_PIN4);
  int fsrADC5 = analogRead(FSR_PIN5);
  // If the FSR has no pressure, the resistance will be
  // near infinite. So the voltage should be near 0.

  float weight[6];
  weight[0] = forceConv(fsrADC0);
  weight[1] = forceConv(fsrADC1);
  weight[2] = forceConv(fsrADC2);
  weight[3] = forceConv(fsrADC3);
  weight[4] = forceConv(fsrADC4);
  weight[5] = forceConv(fsrADC5);
  

  
  if(mySerial.available()){
    String result = String(weight[0])
      + "," + String(weight[1])
      + "," + String(weight[2])
      + "," + String(weight[3])
      + "," + String(weight[4])
      + "," + String(weight[5]) + "|";
    Serial.println(result);
    mySerial.print(result);
  }
  
  delay(2000);

  
}