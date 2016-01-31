/*
 *	code to configure the efm32gg board's OP Amps, so that we can make use of their
 *  rail-to-railiness.
 *
 *  Code based on Silicon Labs' App Note (#38 perhaps?)
 *  https://www.silabs.com/Support Documents/TechnicalDocs/AN0038.pdf
 */

#include <stdint.h>
#include <stdbool.h>
#include "em_device.h"
#include "em_chip.h"
#include "em_opamp.h"
#include "em_cmu.h"
#include "mbed.h"

/** Configuration of OPA2 in unity gain voltage follower mode.         */
#undef OPA_INIT_UNITY_GAIN_OPA2
#define OPA_INIT_UNITY_GAIN_OPA2                                                  \
  {                                                                               \
    opaNegSelUnityGain,             /* Unity gain.                             */ \
    opaPosSelPosPad,                /* Pos input from pad.                     */ \
    opaOutModeMain,                 /* Main output enabled.                    */ \
    opaResSelDefault,               /* Resistor ladder is not used.            */ \
    opaResInMuxDisable,             /* Resistor ladder disabled.               */ \
    DAC_OPA0MUX_OUTPEN_OUT0,        /* Alternate output 0 enabled.             */ \
    _DAC_BIASPROG_BIASPROG_DEFAULT, /* Default bias setting.             */       \
    _DAC_BIASPROG_HALFBIAS_DEFAULT, /* Default half-bias setting.        */       \
    false,                          /* No low pass filter on pos pad.          */ \
    false,                          /* No low pass filter on neg pad.          */ \
    false,                          /* No nextout output enabled.              */ \
    false,                          /* Neg pad disabled.                       */ \
    true,                           /* Pos pad enabled, used as signal input.  */ \
    false,                          /* No shorting of inputs.                  */ \
    false,                          /* Rail-to-rail input enabled.             */ \
    true,                           /* Use factory calibrated opamp offset.    */ \
    0                               /* Opamp offset value (not used).          */ \
  }

#undef OPA_INIT_NON_INVERTING_OPA2
#define OPA_INIT_NON_INVERTING_OPA2                                               \
  {                                                                               \
    opaNegSelResTap,                /* Neg input from resistor ladder tap.     */ \
    opaPosSelPosPad,                /* Pos input from pad.                     */ \
    opaOutModeMain,                 /* Main output enabled.                    */ \
    opaResSelR2eq2R1,            /* R2 = 2 R1                             */ \
    opaResInMuxNegPad,              /* Resistor ladder input from neg pad.     */ \
    DAC_OPA0MUX_OUTPEN_OUT0,        /* Alternate output 0 enabled.             */ \
    _DAC_BIASPROG_BIASPROG_DEFAULT, /* Default bias setting.             */       \
    _DAC_BIASPROG_HALFBIAS_DEFAULT, /* Default half-bias setting.        */       \
    false,                          /* No low pass filter on pos pad.          */ \
    false,                          /* No low pass filter on neg pad.          */ \
    false,                          /* No nextout output enabled.              */ \
    true,                           /* Neg pad enabled, used as signal ground. */ \
    true,                           /* Pos pad enabled, used as signal input.  */ \
    false,                          /* No shorting of inputs.                  */ \
    false,                          /* Rail-to-rail input enabled.             */ \
    true,                           /* Use factory calibrated opamp offset.    */ \
    0                               /* Opamp offset value (not used).          */ \
  }

#undef OPA_INIT_NON_INVERTING
/** Configuration of OPA0/1 in non-inverting amplifier mode.           */
#define OPA_INIT_NON_INVERTING                                                    \
  {                                                                               \
    opaNegSelResTap,                /* Neg input from resistor ladder tap.     */ \
    opaPosSelPosPad,                /* Pos input from pad.                     */ \
    opaOutModeMain,                 /* Main output enabled.                    */ \
    opaResSelR2eq2R1,            /* R2 = 2 R1                             */ \
    opaResInMuxNegPad,              /* Resistor ladder input from neg pad.     */ \
    0,                              /* No alternate outputs enabled.           */ \
    _DAC_BIASPROG_BIASPROG_DEFAULT, /* Default bias setting.             */       \
    _DAC_BIASPROG_HALFBIAS_DEFAULT, /* Default half-bias setting.        */       \
    false,                          /* No low pass filter on pos pad.          */ \
    false,                          /* No low pass filter on neg pad.          */ \
    false,                          /* No nextout output enabled.              */ \
    true,                           /* Neg pad enabled, used as signal ground. */ \
    true,                           /* Pos pad enabled, used as signal input.  */ \
    false,                          /* No shorting of inputs.                  */ \
    false,                          /* Rail-to-rail input enabled.             */ \
    true,                           /* Use factory calibrated opamp offset.    */ \
    0                               /* Opamp offset value (not used).          */ \
  }

DigitalOut led(LED0);

int main(void)
{ 
    CHIP_Init();

    CMU_ClockEnable(cmuClock_DAC0, true);
  
    /*Define the configuration for OPA2*/
    //OPAMP_Init_TypeDef configuration = OPA_INIT_UNITY_GAIN_OPA2;
    OPAMP_Init_TypeDef configuration1 = OPA_INIT_NON_INVERTING_OPA2;
    OPAMP_Init_TypeDef configuration2 = OPA_INIT_NON_INVERTING;
 
    OPAMP_Enable(DAC0, OPA2, &configuration1);
  	OPAMP_Enable(DAC0, OPA0, &configuration2);
  
    /*Never end*/
    while(1) {
    	led = !led;
    	wait(0.5);	
    };   
}
