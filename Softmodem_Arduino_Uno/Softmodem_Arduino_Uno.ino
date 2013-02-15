#include <AccelStepper.h>
#include <SoftModem.h>
#include <ctype.h>
#include <ByteBuffer.h>
#include <Servo.h>

AccelStepper stepper(1, 9, 8);
SoftModem modem;
Servo servo;
ByteBuffer buffer;
int BufferSize = 7;
int servoPin = 10;

void setup() {
   Serial.begin(57600);
   buffer.init(BufferSize);
   delay(1000);
   modem.begin();
   servo.attach(servoPin);
   servo.write(90);
   
   stepper.setMaxSpeed(2000);
   stepper.setAcceleration(500);
}

void loop() {

  while(modem.available()){
    int c = modem.read();
    if((buffer.getSize() == BufferSize || buffer.getSize() == 0) && c == 0xFF) {
      buffer.clear();
    } else {
      buffer.put(c);
    }
  };

  if( buffer.getSize() == BufferSize ) {

     while( buffer.getSize() > 0 ) {

       int check_byte_0 = buffer.get();
       int check_byte_1 = buffer.get();
       if( 88 == check_byte_0 && 88 == check_byte_1 ) {
         int commandByte = buffer.get();
         if( 65 == commandByte ) { //65 = 'A' in asscii
           int degX_h =  buffer.get();
           int degX_l =  buffer.get();
           int degY_h =  buffer.get();
           int degY_l=  buffer.get();
           
           int degX = ( degX_h<<8 ) + degX_l;
           int degY = ( degY_h<<8 ) + degY_l;
           
           Serial.println("A received");
           servo.write( map( degX, 0, 1024, 0, 180 ) );
           Serial.println(degX);
           Serial.println(degY);
           buffer.clear();
         } else if ( 66 == commandByte ) {//66 = 'B' in ascii
           Serial.println("B received");
           buffer.clear();
           
         }
       } else {
         buffer.clear();
       }
      }
    
    delay(100);
  }

}
