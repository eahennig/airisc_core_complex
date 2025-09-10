// 7-segment display on Digilent Nexys4 DDR board

#include "airisc_nexys4_ddr_disp7seg.h"

void disp7seg_init(volatile DISP7SEG_t* const disp)
{
  disp->EN        = 0x000000;
  disp->DATA_L    = 0x000000;
  disp->DATA_R    = 0x000000;
  disp->BRIGHT_L  = 0x000000;
  disp->BRIGHT_R  = 0x000000;
}

void disp7seg_enable(volatile DISP7SEG_t* const disp)
{
  disp->EN        = 0x0000001;
}

void disp7seg_disable(volatile DISP7SEG_t* const disp)
{
  disp->EN        = 0x0000000;
}

void disp7seg_setChar(volatile DISP7SEG_t* const disp, uint8_t const c, uint8_t const pos)
{
  uint32_t mask;
  if (pos < 4) {
      mask = ~(0xff << pos*8);
      disp->DATA_R = (disp->DATA_R & mask) | (c << pos*8);
  } else if (pos < 8) {
      mask = ~(0xff << (pos-4)*8);
      disp->DATA_L = (disp->DATA_L & mask) | (c << (pos-4)*8);
  }
}

void disp7seg_shiftLeft(volatile DISP7SEG_t* const disp)
{
  disp->DATA_L = (disp->DATA_L << 8) | (disp->DATA_R >> 24);
  disp->DATA_R = disp->DATA_R << 8;
}

void disp7seg_shiftRight(volatile DISP7SEG_t* const disp)
{
  disp->DATA_R = (disp->DATA_R >> 8) | (disp->DATA_L << 24);
  disp->DATA_L = disp->DATA_L >> 8;
}

void disp7seg_rollLeft(volatile DISP7SEG_t* const disp)
{
  uint32_t hbyte = disp->DATA_L >> 24;
  disp->DATA_L = (disp->DATA_L << 8) | (disp->DATA_R >> 24);
  disp->DATA_R = (disp->DATA_R << 8) | hbyte;
}

void disp7seg_rollRight(volatile DISP7SEG_t* const disp)
{
  uint32_t lbyte = disp->DATA_R << 24;
  disp->DATA_R = (disp->DATA_R >> 8) | (disp->DATA_L << 24);
  disp->DATA_L = (disp->DATA_L >> 8) | lbyte;
}

void disp7seg_setBrightness(volatile DISP7SEG_t* const disp, uint8_t const bright)
{
  uint32_t regval = (bright << 24) | (bright << 16) | (bright << 8) | bright;
  disp->BRIGHT_R = regval;
  disp->BRIGHT_L = regval;
}

void disp7seg_setBrightnessChar(volatile DISP7SEG_t* const disp, uint8_t const bright, uint8_t const pos)
{
  uint32_t mask;
  if (pos < 4) {
      mask = ~(0xff << pos*8);
      disp->BRIGHT_R = (disp->BRIGHT_R & mask) | (bright << pos*8);
  } else if (pos < 8) {
      mask = ~(0xff << (pos-4)*8);
      disp->BRIGHT_L = (disp->BRIGHT_L & mask) | (bright << (pos-4)*8);
  }
}
