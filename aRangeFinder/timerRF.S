;timerRF.S - timer for the range finder

#include "configRF.inc"

.equ	PRESET		,1

		.section	.text

		.global		timer_delay
		.global		timer_init
		.global		timer_start
		.global		timer_stop

timer_init:
		ldi		r16, (1<<CS02)|(1<<CS01)|(1<<CS00)		;divide by 1024
		out		_TCCR0B, r16					;set timer clock
		ldi		r16, 1 << TOV0				 	;clear interrupt flag
		out		_TIFR0, r16
		ldi		r16, PRESET
		out		 _TCNT0, r16
		ret


timer_delay:
        in      r16, _TIFR0                      ; check the flag 
        sbrs    r16, 0 << TOV0                       ; skip if overflow set
        rjmp    timer_delay                     ; wait for it
        ldi     r16, 1 << TOV0                  ; clear the interrupt flag
        out     _TIFR0, r16                      ; clear the interrupt flag
        ldi     r16, PRESET                     ; reload the counter
        out     _TCNT0, r16                      ; set preset in
        ret  

timer_start:
		ldi		r16, (1<<CS02)|(1<<CS01)|(1<<CS00)		;divide by 1024
		out		_TCCR0B, r16					;start timer clock
		ret

timer_stop:
		clr		r16							;clear r16
		out		_TCCR0B, r16				;stop timer

