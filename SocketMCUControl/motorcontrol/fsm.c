//:set ts=2 sts=2 sw=2 expandtab
#include<stdio.h>

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

int validateInput() {
  if ((numbers[0]^numbers[1])==numbers[2]) {
    printf("%d %d %d\n", numbers[0], numbers[1], numbers[2]);
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

void test(char *c) {
  printf("testcase %s\n", c);
	char* ch = c;
	while(*ch) {
		nextChar(*ch);
    ++ch;
	}
}

void main() {
	test("_R100L100C200|");
	test("_R100L100C200|_R100L100C200|");
	test("_R100L_R110L120C200|");
	test("_R100L200C172|");
}

