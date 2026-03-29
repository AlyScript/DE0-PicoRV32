#define LEDS ((volatile unsigned int *)0x10000000)

int main() {
  unsigned int val = 1;
  *LEDS = val;
  return 0;
}
