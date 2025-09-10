// 7-segment display on Digilent Nexys4 DDR board

#ifndef AIRISC_DISP7SEG_H_
#define AIRISC_DISP7SEG_H_

#include "airisc_defines.h"

void disp7seg_init(volatile DISP7SEG_t* const disp);
void disp7seg_enable(volatile DISP7SEG_t* const disp);
void disp7seg_disable(volatile DISP7SEG_t* const disp);

void disp7seg_setChar(volatile DISP7SEG_t* const disp, uint8_t const c, uint8_t const pos);

void disp7seg_shiftLeft(volatile DISP7SEG_t* const disp);
void disp7seg_shiftRight(volatile DISP7SEG_t* const disp);
void disp7seg_rollLeft(volatile DISP7SEG_t* const disp);
void disp7seg_rollRight(volatile DISP7SEG_t* const disp);

void disp7seg_setBrightness(volatile DISP7SEG_t* const disp, uint8_t const bright);
void disp7seg_setBrightnessChar(volatile DISP7SEG_t* const disp, uint8_t const bright, uint8_t const pos);

#endif
