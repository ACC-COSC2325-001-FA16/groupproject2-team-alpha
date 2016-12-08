; Range Finder for AVR
; Author: group alpha Cosc2325 HLC Fall 2016
; Date: Dec 6, 2016

#include "configRF.inc"

        .section .text
        .global     main
        .extern     long_delay
		.extern		micro_delay    
		.extern 	timer_init 
		.extern		timer_delay    
        .org        0x0000

main:
        ; set up the stack
        ldi         r28, (RAMEND & 0x00ff)
        ldi         r29, (RAMEND >> 8)
        out         _SPH, r29
        out         _SPL, r28

        ; initialize the devices and pins
        call        init      

        ; enter the RangeFinder loop
1:		
		;call		pulseOut		; Trig pin sends a pulse
		call		timer_start				; start the timer
		;call		pulseIn			; Echo pin captures pulse return
        call        toggle
        call        timer_delay
        rjmp        1b

init:   eor         r1, r1                  ; zero out the r1 register
        out         _SREG, r1               ; initialize the status reg
        ldi         r24, 0x80
        sts         CLKPR, r24              ; allow access to clock setup
        sts         CLKPR, r1               ; run at full speed

		call		timer_init				;set up timer
        
        ; set up the pins
        sbi         LED_DIR, LED_PIN        ; set LED pin to output
        cbi         LED_PORT, LED_PIN       ; start with the LED off
		sbi			SONAR_DIR, TRIG_PIN		; set TRIG pin to output
		cbi			SONAR_PORT, TRIG_PIN	; start with the TRIG pin off
		cbi			SONAR_DIR, ECHO_PIN		; set ECHO pin for input
        ret

toggle:
        in          r24, LED_PORT           ; get current bits
        ldi         r25, (1 << LED_PIN)     ; LED is pin 5
        eor         r24, r25                ; flip the bit
        out         LED_PORT, r24           ; write the bits back
        ret

pulseOut:
		eor		r26, r26					; clear r26
   		in		r26, SONAR_PORT				; copy portB to r24
  		ldi 	r26, (1 << TRIG_PIN)		; turn TRIG bit on
		out		SONAR_PORT, r26				; write bits back to portB
		call 	micro_delay
 		in		r26, SONAR_PORT				; copy portB to r24
  		ldi 	r26, (0 << TRIG_PIN)		; turn TRIG bit off
		out		SONAR_PORT, r26				; write back to portB
		ret


pulseIn:
		eor		r27, r27
pulse_clear:								;wait for previous pulse to clear
		in 		r27, SONAR_PORT				;copy portB to r27
		sbrc	r27, ECHO_PIN				;wait for ECHO pin to be LOW
		rjmp 	pulse_clear

		eor 	r27, r27					;clear r27 before next loop
pulse_start:								;start of last pulse
		in 		r27, SONAR_PORT				;copy portB to r27
		sbi 	0x05, 4
		sbrs	r27, ECHO_PIN				;wait for ECHO pin to be HIGH
		rjmp 	pulse_start
		eor 	r27, r27					;clear r27 before next loop
pulse_stop:									;end of last pulse
		in		r27, SONAR_PORT
		sbrc	r27, ECHO_PIN
		rjmp 	pulse_stop		
		ret



