; configuration for blink
#include <avr/io.h>
#include "../include/AVRSpecialRegs.inc"

#define LED_PIN     5
#define TRIG_PIN	2
#define ECHO_PIN	4
#define LED_DIR     _DDRB
#define SONAR_DIR	_DDRB
#define LED_PORT    _PORTB
#define SONAR_PORT	_PORTB
