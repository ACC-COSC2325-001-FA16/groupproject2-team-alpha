; Range Finder for AVR
; Author: group alpha Cosc2325 HLC Fall 2016
; Date: Dec 6, 2016
; configuration for blink
//#include "c:\users\patrick\Documents\Atmel Studio\7.0\ultraLucas3\ultraLucas3\io.h"
#include "configRF.inc"
; delay.S

        .section .text
        //.global     long_delay
        //.global     micro_delay
        .global     main
		//.global		setup
		//.global		flashBlueRedOn
		//.global		flashBlueRedOff
        
        .org        0x0000


setup:
        ; set up the stack
        ldi         r28, (RAMEND & 0x00ff)
        ldi         r29, (RAMEND >> 8)
        out         _SPH , r29
        out         _SPL , r28

        ; initialize the devices and pins
        rcall        init  

main:
	;rcall	long_delay
	rcall	flashBlueRedOn
	rcall	long_delay
	rcall	micro_delay1
	rcall	micro_delay1
	rcall	flashBlueRedOff
	;rcall	long_delay
	rcall	triggerOnOff  //cycle trigger on and off. Delays are in the function.
	rcall	checkEchoIn   // check for Echo recieved
	rcall	checkEchoStop
	
	;rcall	long_delay
	rcall	long_delay

	;ldi		timerCount, 3	// test timerCount number
	;tst		timerCount
	ldi		temp, 13
	cp		timerCount, temp
	brge	CounterLightFeet
	cp		timerCount, ZERO   // compare timer to zero to skip zero inch case
	brge	CounterLightInches
	;rjmp	flashBlueRedOn
	;rcall	long_delay
	rcall	flashBlueRedOff

	rcall	init
	clr		timerCount

	EXIT:
	rjmp	main


//********************  FUNCTION START *******************************************//
CounterLightFeet:

		cbi			LED_PORT, LED_PIN
		sbi			LED_PORT, LED_PIN2
		rcall		long_delay

		cbi			LED_PORT, LED_PIN2
		;sbi			LED_PORT, LED_PIN
		rcall		long_delay
		rcall		flashBlueRedOff
		subi		timerCount, 12			//Decriment counter by 1 foot (12 inches)
		;dec		timerCount
		
		ldi		temp, 13
		cp		timerCount, temp
		brge	CounterLightFeet
		;cpse		timerCount, ZERO
		;rjmp		CounterLight
		ret

		CounterLightInches:

		sbi			LED_PORT, LED_PIN
		cbi			LED_PORT, LED_PIN2
		rcall		long_delay

		;sbi			LED_PORT, LED_PIN2
		cbi			LED_PORT, LED_PIN
		rcall		long_delay
		rcall		flashBlueRedOff
		dec			timerCount
		
		cp		timerCount, ZERO
		brne	CounterLightInches
		;cpse		timerCount, ZERO
		;rjmp		CounterLight
		ret
				
init:   ;eor         r1, r1                  ; zero out the r1 register
        ;out         SREG, r1               ; initialize the status reg
        ;ldi         r24, 0x80
        ;sts         CLKPR, r24              ; allow access to clock setup
        ;sts         CLKPR, r1               ; run at full speed
        
        ; set up the pins
        sbi         LED_DIR, LED_PIN        ; set LED pin to output
        cbi         LED_PORT, LED_PIN       ; start with the LED off
		sbi         LED_DIR, LED_PIN2        ; set LED pin to output
        cbi         LED_PORT, LED_PIN2       ; start with the LED off

       sbi         SONAR_DIR, TRIG_PIN     ; set TRIG pin to output
       cbi         SONAR_PORT, TRIG_PIN    ; start with the TRIG pin off
       cbi         SONAR_DIR, ECHO_PIN     ; set ECHO pin for input

		clr			timerCount				; clear timerCount (R20)
		ldi			temp, 0  //temp register (R16)
		ldi			maxCount, 250  //maximum counter value for reset (R18)
		ldi			timerCount, 0	//simple timer counter: 1 count = 1 microsecond (R20)
		eor			ZERO, ZERO		// zero register
       
		ret


triggerOnOff:

	rcall     micro_delay10
	rcall     micro_delay10
	
/*
;Turn trigger on routine
eor      r26, r26                    ; clear r26
in       r26, SONAR_PORT             ; copy portB to r24
ldi      r26, (1 << TRIG_PIN)        ; turn TRIG bit on
out      SONAR_PORT, r26             ; write bits back to portB
*/

	sbi	_PORTB, TRIG_PIN			; Sets the trigger pin bit for port b on (high)

	rcall		micro_delay150			; Wait 50 microseconds
	rcall		micro_delay10			; Wait 10 microseconds

	cbi	_PORTB, TRIG_PIN			; Sets the trigger pin bit for port b off (LOW)
	

	ret					; 1 trigger cycle is complete. Return
//****END triggerOnOff****//


checkEchoIn:
	;rcall	micro_delay10
	;dec		maxCount
	;cp		temp, maxCount
	;breq	echoTimeOut
	sbis	PINB4, ECHO_PIN		;Checking Echo PIN
	rjmp	checkEchoIn
	
	;Reset timer counter to ready next start
	;clr	timerCount		;clear counter to zero
	;ldi	maxCount, 250
	;rcall	flash5
	ret				; Pulse detected by ECHO so return
/*****END checkPulseIn****/


//****** ECHO timeout ******* //
/*
echoTimeOut:
	sbi		LED_PORT, LED_PIN
	rcall	long_delay
	rcall	long_delay
	rcall	long_delay
	rcall	long_delay
	jmp		0x0000
	ret
*/

checkEchoStop:
	rcall	micro_delay150		; count 1 microsecond
	inc		timerCount		; add one to the timer counter
	sbic	PINB4, ECHO_PIN		; Check ECHO pin for low (Echo stop)
	rjmp	checkEchoStop

	rcall	flash5
	;mov		R30, timerCount		; save timer current count before return
	
	ret
/***END checkEchoStop *************/

//******* TIMERS start ***********************//

long_delay:
; Delay 8 000 000 cycles  (1/2 second)
; 500ms at 16 MHz

    ldi  r18, 41
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	ret


mili_delay:			// Delay 1 milisecond
    ldi  r18, 21
    ldi  r19, 199
mili: dec  r19
    brne mili
    dec  r18
    brne mili
	ret

micro_delay1:   // Delay 1 microsecond

    ldi  r18, 5  //5 is 1 usecond  50 is 10 microsecond
micro: dec  r18
    brne micro
    nop
	ret


micro_delay10:   // Delay 10 microsecond

    ldi  r18, 50  //5 is 1 usecond  50 is 10 microsecond
micro10: dec  r18
    brne micro10
    nop
	ret

micro_delay30:   // Delay 30 microsecond

    ldi  r18, 150  //5 is 1 usecond  50 is 10 microsecond
micro30: dec  r18
    brne micro30
    nop
	ret


micro_delay50:   // Delay 50 microsecond

    ldi  r18, 250  //5 is 1 usecond  50 is 10 microsecond
micro50: dec  r18
    brne micro50
    nop
	ret


micro_delay150:		// Delay 148 microseconds (1 inch travel)

    ldi  r18, 4
    ldi  r19, 18
micro150: dec  r19
    brne micro150
    dec  r18
    brne micro150
    nop
	ret

/**************************  LED 13 tests Start *********************************/

flashBlueRedOn:
		sbi			LED_PORT, LED_PIN
		sbi			LED_PORT, LED_PIN2
		ret	

flashBlueRedOff:
		cbi			LED_PORT, LED_PIN
		cbi			LED_PORT, LED_PIN2
		ret

flash5:
		cbi         LED_PORT, LED_PIN       ; start with the LED off
		sbi         LED_PORT, LED_PIN       ; start with the LED off
		rcall		micro_delay1
		cbi         LED_PORT, LED_PIN       ; start with the LED off
		rcall		micro_delay1
		sbi         LED_PORT, LED_PIN       ; start with the LED off
		rcall		micro_delay1
		cbi         LED_PORT, LED_PIN       ; start with the LED off
		rcall		micro_delay1
		sbi         LED_PORT, LED_PIN2       ; start with the LED off
		rcall		micro_delay1
		cbi			LED_PORT, LED_PIN2
		rcall		micro_delay1
		sbi         LED_PORT, LED_PIN2       ; start with the LED off
		rcall		micro_delay1
		cbi			LED_PORT, LED_PIN2
		rcall		micro_delay1
		sbi         LED_PORT, LED_PIN       ; start with the LED off
		rcall		micro_delay1
		cbi			LED_PORT, LED_PIN
		ret
