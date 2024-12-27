
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;BicycleSafety.c,28 :: 		void interrupt() {
;BicycleSafety.c,30 :: 		if (INTCON & 0x01) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt0
;BicycleSafety.c,31 :: 		if (!(PORTB & 0x10)) { // Check if RB5 (right turn button) is pressed
	BTFSC      PORTB+0, 4
	GOTO       L_interrupt1
;BicycleSafety.c,32 :: 		PORTB |= 0x04;    // Turn on RB2 (right turn signal)
	BSF        PORTB+0, 2
;BicycleSafety.c,33 :: 		rturn = 1;        // Set right turn flag
	MOVLW      1
	MOVWF      _rturn+0
;BicycleSafety.c,34 :: 		}
L_interrupt1:
;BicycleSafety.c,35 :: 		if (!(PORTB & 0x20)) { // Check if RB6 (left turn button) is pressed
	BTFSC      PORTB+0, 5
	GOTO       L_interrupt2
;BicycleSafety.c,36 :: 		PORTB |= 0x08;    // Turn on RB3 (left turn signal)
	BSF        PORTB+0, 3
;BicycleSafety.c,37 :: 		lturn = 1;        // Set left turn flag
	MOVLW      1
	MOVWF      _lturn+0
;BicycleSafety.c,38 :: 		}
L_interrupt2:
;BicycleSafety.c,39 :: 		INTCON &= 0xFE; // Clear PORTB Change Interrupt flag
	MOVLW      254
	ANDWF      INTCON+0, 1
;BicycleSafety.c,40 :: 		}
L_interrupt0:
;BicycleSafety.c,43 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt3
;BicycleSafety.c,44 :: 		tick++;  // Increment general-purpose Timer0 counter (~32ms per increment)
	INCF       _tick+0, 1
;BicycleSafety.c,45 :: 		tick3++; // Increment hall sensor pulse counter
	INCF       _tick3+0, 1
;BicycleSafety.c,46 :: 		tick4++; // Increment speed calculation counter
	INCF       _tick4+0, 1
;BicycleSafety.c,49 :: 		if (tick == 2) {
	MOVF       _tick+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;BicycleSafety.c,50 :: 		tick = 0;
	CLRF       _tick+0
;BicycleSafety.c,53 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;BicycleSafety.c,54 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023; // Scale AN0 reading
	MOVLW      50
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _flexD0+0
	MOVF       R0+1, 0
	MOVWF      _flexD0+1
;BicycleSafety.c,55 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;BicycleSafety.c,56 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023; // Scale AN1 reading
	MOVLW      50
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _flexD1+0
	MOVF       R0+1, 0
	MOVWF      _flexD1+1
;BicycleSafety.c,59 :: 		if ((flexD0 > 34) || (flexD1 > 34)) {
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt32
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt32:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt29
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt33
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt33:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt29
	GOTO       L_interrupt7
L__interrupt29:
;BicycleSafety.c,60 :: 		PORTB |= 0x02; // Turn on RB1
	BSF        PORTB+0, 1
;BicycleSafety.c,61 :: 		} else {
	GOTO       L_interrupt8
L_interrupt7:
;BicycleSafety.c,62 :: 		PORTB &= 0xFD; // Turn off RB1
	MOVLW      253
	ANDWF      PORTB+0, 1
;BicycleSafety.c,63 :: 		}
L_interrupt8:
;BicycleSafety.c,64 :: 		}
L_interrupt4:
;BicycleSafety.c,67 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;BicycleSafety.c,68 :: 		tick1++; // Increment right turn duration counter
	INCF       _tick1+0, 1
;BicycleSafety.c,69 :: 		ticka++; // Increment right turn blinking interval counter
	INCF       _ticka+0, 1
;BicycleSafety.c,71 :: 		if (ticka == 15) { // Toggle RB2 (right turn signal) every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;BicycleSafety.c,72 :: 		ticka = 0;
	CLRF       _ticka+0
;BicycleSafety.c,73 :: 		PORTB ^= 0x04; // Toggle RB2
	MOVLW      4
	XORWF      PORTB+0, 1
;BicycleSafety.c,74 :: 		}
L_interrupt10:
;BicycleSafety.c,75 :: 		if (tick1 == 150) { // Stop right turn signal after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;BicycleSafety.c,76 :: 		tick1 = 0;
	CLRF       _tick1+0
;BicycleSafety.c,77 :: 		rturn = 0;
	CLRF       _rturn+0
;BicycleSafety.c,78 :: 		PORTB &= 0xFB; // Turn off RB2
	MOVLW      251
	ANDWF      PORTB+0, 1
;BicycleSafety.c,79 :: 		}
L_interrupt11:
;BicycleSafety.c,80 :: 		}
L_interrupt9:
;BicycleSafety.c,83 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;BicycleSafety.c,84 :: 		tick2++; // Increment left turn duration counter
	INCF       _tick2+0, 1
;BicycleSafety.c,85 :: 		tickb++; // Increment left turn blinking interval counter
	INCF       _tickb+0, 1
;BicycleSafety.c,87 :: 		if (tickb == 15) { // Toggle RB3 (left turn signal) every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;BicycleSafety.c,88 :: 		tickb = 0;
	CLRF       _tickb+0
;BicycleSafety.c,89 :: 		PORTB ^= 0x08; // Toggle RB3
	MOVLW      8
	XORWF      PORTB+0, 1
;BicycleSafety.c,90 :: 		}
L_interrupt13:
;BicycleSafety.c,91 :: 		if (tick2 == 150) { // Stop left turn signal after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;BicycleSafety.c,92 :: 		tick2 = 0;
	CLRF       _tick2+0
;BicycleSafety.c,93 :: 		lturn = 0;
	CLRF       _lturn+0
;BicycleSafety.c,94 :: 		PORTB &= 0xF7; // Turn off RB3
	MOVLW      247
	ANDWF      PORTB+0, 1
;BicycleSafety.c,95 :: 		}
L_interrupt14:
;BicycleSafety.c,96 :: 		}
L_interrupt12:
;BicycleSafety.c,99 :: 		if (tick3 == 7) {
	MOVF       _tick3+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;BicycleSafety.c,100 :: 		tick3 = 0;
	CLRF       _tick3+0
;BicycleSafety.c,103 :: 		hallA2 = ATD_read2();
	CALL       _ATD_read2+0
	MOVF       R0+0, 0
	MOVWF      _hallA2+0
	MOVF       R0+1, 0
	MOVWF      _hallA2+1
;BicycleSafety.c,104 :: 		hallD2 = (unsigned int)(hallA2 * 50) / 1023;
	MOVLW      50
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _hallD2+0
	MOVF       R0+1, 0
	MOVWF      _hallD2+1
;BicycleSafety.c,107 :: 		if (hallD2 > 10) {
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt34
	MOVF       R0+0, 0
	SUBLW      10
L__interrupt34:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt16
;BicycleSafety.c,108 :: 		pulse++;
	INCF       _pulse+0, 1
	BTFSC      STATUS+0, 2
	INCF       _pulse+1, 1
;BicycleSafety.c,109 :: 		}
L_interrupt16:
;BicycleSafety.c,110 :: 		}
L_interrupt15:
;BicycleSafety.c,113 :: 		if (tick4 == 219) {
	MOVF       _tick4+0, 0
	XORLW      219
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
;BicycleSafety.c,114 :: 		tick4 = 0;
	CLRF       _tick4+0
;BicycleSafety.c,117 :: 		dis = (unsigned long int)(314 * 35 * pulse) / 2;
	MOVLW      238
	MOVWF      R0+0
	MOVLW      42
	MOVWF      R0+1
	MOVF       _pulse+0, 0
	MOVWF      R4+0
	MOVF       _pulse+1, 0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      R5+0
	MOVF       R0+1, 0
	MOVWF      R5+1
	CLRF       R5+2
	CLRF       R5+3
	MOVF       R5+0, 0
	MOVWF      R0+0
	MOVF       R5+1, 0
	MOVWF      R0+1
	MOVF       R5+2, 0
	MOVWF      R0+2
	MOVF       R5+3, 0
	MOVWF      R0+3
	RRF        R0+3, 1
	RRF        R0+2, 1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+3, 7
	MOVF       R0+0, 0
	MOVWF      _dis+0
	MOVF       R0+1, 0
	MOVWF      _dis+1
	MOVF       R0+2, 0
	MOVWF      _dis+2
	MOVF       R0+3, 0
	MOVWF      _dis+3
;BicycleSafety.c,122 :: 		v = dis / 700;
	MOVLW      188
	MOVWF      R4+0
	MOVLW      2
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _v+0
	MOVF       R0+1, 0
	MOVWF      _v+1
;BicycleSafety.c,126 :: 		pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
;BicycleSafety.c,127 :: 		}
L_interrupt17:
;BicycleSafety.c,129 :: 		INTCON &= 0xFB; // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;BicycleSafety.c,130 :: 		}
L_interrupt3:
;BicycleSafety.c,131 :: 		}
L_end_interrupt:
L__interrupt31:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;BicycleSafety.c,133 :: 		void main() {
;BicycleSafety.c,135 :: 		TRISB = 0xF1; // RB0, RB1, RB2, RB3 as outputs; RB4, RB5 as inputs
	MOVLW      241
	MOVWF      TRISB+0
;BicycleSafety.c,136 :: 		PORTB = 0x00; // Initialize PORTB to LOW
	CLRF       PORTB+0
;BicycleSafety.c,139 :: 		ATD_init();
	CALL       _ATD_init+0
;BicycleSafety.c,142 :: 		OPTION_REG = 0x07; // Oscillator clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;BicycleSafety.c,143 :: 		INTCON = 0xF8;     // Enable all interrupts
	MOVLW      248
	MOVWF      INTCON+0
;BicycleSafety.c,144 :: 		TMR0 = 0;          // Reset Timer0
	CLRF       TMR0+0
;BicycleSafety.c,147 :: 		tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
	CLRF       _tickb+0
	CLRF       _ticka+0
	CLRF       _tick4+0
	CLRF       _tick3+0
	CLRF       _tick2+0
	CLRF       _tick1+0
	CLRF       _tick+0
;BicycleSafety.c,150 :: 		while (1) {
L_main18:
;BicycleSafety.c,152 :: 		}
	GOTO       L_main18
;BicycleSafety.c,153 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;BicycleSafety.c,156 :: 		void ATD_init(void) {
;BicycleSafety.c,157 :: 		ADCON0 = 0x41; // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;BicycleSafety.c,158 :: 		ADCON1 = 0xC0; // All analog channels, 500 KHz, right justified
	MOVLW      192
	MOVWF      ADCON1+0
;BicycleSafety.c,159 :: 		TRISA = 0xFF;  // Configure PORTA as input
	MOVLW      255
	MOVWF      TRISA+0
;BicycleSafety.c,160 :: 		TRISE = 0x07;  // Configure PORTE as input
	MOVLW      7
	MOVWF      TRISE+0
;BicycleSafety.c,161 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;BicycleSafety.c,164 :: 		unsigned int ATD_read0(void) {
;BicycleSafety.c,165 :: 		ADCON0 &= 0xC7;   // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;BicycleSafety.c,166 :: 		delay_us(10);     // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read020:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read020
	NOP
;BicycleSafety.c,167 :: 		ADCON0 |= 0x04;   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafety.c,168 :: 		while (ADCON0 & 0x04); // Wait for conversion to complete
L_ATD_read021:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read022
	GOTO       L_ATD_read021
L_ATD_read022:
;BicycleSafety.c,169 :: 		return ((ADRESH << 8) | ADRESL); // Return ADC result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafety.c,170 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;BicycleSafety.c,173 :: 		unsigned int ATD_read1(void) {
;BicycleSafety.c,174 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08; // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafety.c,175 :: 		delay_us(10);      // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read123:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read123
	NOP
;BicycleSafety.c,176 :: 		ADCON0 |= 0x04;    // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafety.c,177 :: 		while (ADCON0 & 0x04); // Wait for conversion to complete
L_ATD_read124:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read125
	GOTO       L_ATD_read124
L_ATD_read125:
;BicycleSafety.c,178 :: 		return ((ADRESH << 8) | ADRESL); // Return ADC result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafety.c,179 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1

_ATD_read2:

;BicycleSafety.c,182 :: 		unsigned int ATD_read2(void) {
;BicycleSafety.c,183 :: 		ADCON0 = (ADCON0 & 0xD7) | 0x10; // Select channel 2
	MOVLW      215
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      16
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafety.c,184 :: 		delay_us(10);      // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read226:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read226
	NOP
;BicycleSafety.c,185 :: 		ADCON0 |= 0x04;    // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafety.c,186 :: 		while (ADCON0 & 0x04); // Wait for conversion to complete
L_ATD_read227:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read228
	GOTO       L_ATD_read227
L_ATD_read228:
;BicycleSafety.c,187 :: 		return ((ADRESH << 8) | ADRESL); // Return ADC result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafety.c,188 :: 		}
L_end_ATD_read2:
	RETURN
; end of _ATD_read2
