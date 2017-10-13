#include <AFMotor.h>
#include <SoftwareSerial.h>
SoftwareSerial esp(9, 10);
AF_DCMotor ml(1);
AF_DCMotor mr(3);
void setup() {
  Serial.begin(9600);
  Serial.print("Hello");
  esp.begin(115200);
}
int readState = 0;
int readNumber = 0;
int numbers[3];
int sgn = 1;
int acc = 0;

int digit(char d) {
  d -= '0';
  if (d>=0&&d<=9) {
    return d;
  } else {
    return -1;
  }
}

int dir(int n) {
  if (n>0) return FORWARD;
  if (n<0) return BACKWARD;
  return RELEASE;
}

int validateInput() {
  if ((numbers[0]^numbers[1])==numbers[2]) {
   mr.run(dir(numbers[0]));
   ml.run(dir(numbers[1]));
   mr.setSpeed(abs(numbers[0]));
   ml.setSpeed(abs(numbers[1]));
  }
}

void tryPrefix(char d) {
  switch(d) {
    case 'R': readNumber = 0; readState = 2; sgn = 1; break;
    case 'L': readNumber = 1; readState = 2; sgn = 1; break;
    case 'C': readNumber = 2; readState = 2; sgn = 1; break;
    default: readState = 0;
  }
}

void tryControl(char d) {
  if (d == '_') {
    readState = 1;  
  }
  if (d == '|') {
    validateInput();
  }
}

void nextChar(char d) {
  int t;
  switch(readState) {
    case 0: tryControl(d);
            break;
    case 1: tryPrefix(d);
            break;
    case 2: switch(d) {
              case '+': sgn = 1;readState = 3; break;
              case '-': sgn = -1;readState = 3; break;
              default:
                        t = digit(d);
                        if (t<0) {
                          readState = 0; 
                          tryControl(d);
                        } else {
                          acc = t;
                          readState = 3;
                        }
                        break;
            }
            break;
    case 3: t = digit(d);
            if (t<0) {
              numbers[readNumber] = acc * sgn;
              tryPrefix(d);
              tryControl(d);
            } else {
              acc = acc * 10 + t;
            }
            break;

  }
}

void loop() {
  //Serial.println(digitalRead(9));
  if (esp.available()) {
    nextChar(esp.read());
  }
}

