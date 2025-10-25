#define LEDS ((volatile unsigned char *)0x10000000)

int main() {
  unsigned char val = 1;
  *LEDS = val;
  return 0;
}
