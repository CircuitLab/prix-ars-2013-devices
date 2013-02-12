#include <SoftModem.h>
#include <ctype.h>
#include <ByteBuffer.h>
#include <Servo.h>

SoftModem modem;
Servo servo;
ByteBuffer buffer;
int BufferSize = 4;
int servoPin = 9;

void setup() {
   Serial.begin(57600);
   buffer.init(BufferSize);
   delay(1000);
   modem.begin();
   servo.attach(servoPin);
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
           int degX =  buffer.get();
           int degY =  buffer.get();
           Serial.println("A received");
           servo.write( map( degX, 0, 256, 0, 180 ) );
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
