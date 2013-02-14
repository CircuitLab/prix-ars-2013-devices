#include <AccelStepper.h>
#include <Servo.h>
#include <SoftModem.h>
#include <ctype.h>

// Define a stepper and the pins it will use
AccelStepper stepper(1, 9, 8);
Servo servo;
SoftModem modem;
int stepperPos = 500;
int servoPos = 90;

char command;
String msg = "";
boolean isCompleteReading = false;

void setup()
{
  modem.begin();
  
  Serial.begin(57600);
  while (!Serial) {
    ;
  }
  
  msg.reserve(200);
  
  stepper.setMaxSpeed(2000);
  stepper.setAcceleration(500);
  
  servo.attach(10);
  servo.write(90);
}

void loop()
{
  if (isCompleteReading) {
    Serial.print("msg: ");
    Serial.println(msg);
    
    String stepperPosStr = msg.substring(0, msg.indexOf('_'));
    String servoPosStr = msg.substring(msg.indexOf('_') + 1, msg.length() - 1);
    Serial.print("stepperPosStr: ");
    Serial.println(stepperPosStr.toInt());
    Serial.print("servoPosStr: ");
    Serial.println(servoPosStr.toInt());
    
    if (!stepper.distanceToGo()) {
      delay(500);
//      stepper.moveTo(stepperPosStr.toInt());
    }
    
    if (servoPosStr) {
      servoPos = servoPosStr.toInt();
      servo.write(max(70, min(servoPos, 120)));
    }
    
    msg = "";
    isCompleteReading = false;
  }
  stepper.run();
}

void serialEvent() {
  command = (char)modem.read();
  if ('p' == command) {
    msg = "";
    
    Serial.println("set position");
    
    while (modem.available()) {
      char val = (char)modem.read();      
      msg += val;

      if ('\n' == val || !modem.available()) {
        isCompleteReading = true;
      }
    }
  }
}
