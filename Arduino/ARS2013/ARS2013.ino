#include <AccelStepper.h>
#include <Servo.h>

// Define a stepper and the pins it will use
AccelStepper stepper(1, 9, 8);
Servo servo;

int stepperPos = 500;
int servoPos = 90;

char command;
String msg = "";
boolean isCompleteReading = false;

void setup()
{
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
  command = (char)Serial.read();
  if ('p' == command) {
    msg = "";
    
    Serial.println("set position");
    
    while (Serial.available()) {
      char val = (char)Serial.read();      
      msg += val;

      if ('\n' == val || !Serial.available()) {
        isCompleteReading = true;
      }
    }
  }
}
