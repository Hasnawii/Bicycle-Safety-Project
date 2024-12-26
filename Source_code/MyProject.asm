
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,21 :: 		void interrupt() {
;MyProject.c,23 :: 		if (INTCON & 0x01) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt0
;MyProject.c,24 :: 		if (!(PORTB & 0x10)) { // Check if RB5 button is pressed
	BTFSC      PORTB+0, 4
	GOTO       L_interrupt1
;MyProject.c,25 :: 		PORTB |= 0x04; // Turn on RB2
	BSF        PORTB+0, 2
;MyProject.c,26 :: 		rturn = 1;
	MOVLW      1
	MOVWF      _rturn+0
;MyProject.c,27 :: 		}
L_interrupt1:
;MyProject.c,28 :: 		if (!(PORTB & 0x20)) { // Check if RB6 button is pressed
	BTFSC      PORTB+0, 5
	GOTO       L_interrupt2
;MyProject.c,29 :: 		PORTB |= 0x08; // Turn on RB3
	BSF        PORTB+0, 3
;MyProject.c,30 :: 		lturn = 1;
	MOVLW      1
	MOVWF      _lturn+0
;MyProject.c,31 :: 		}
L_interrupt2:
;MyProject.c,32 :: 		INTCON &= 0xFE; // Clear PORTB Change Interrupt flag
	MOVLW      254
	ANDWF      INTCON+0, 1
;MyProject.c,33 :: 		}
L_interrupt0:
;MyProject.c,36 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt3
;MyProject.c,37 :: 		tick++; // Increment tick every 32ms
	INCF       _tick+0, 1
;MyProject.c,40 :: 		if (tick == 3) {
	MOVF       _tick+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;MyProject.c,41 :: 		tick = 0;
	CLRF       _tick+0
;MyProject.c,44 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;MyProject.c,45 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023;
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
;MyProject.c,46 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;MyProject.c,47 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023;
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
;MyProject.c,50 :: 		if ((flexD0 > 34) || (flexD1 > 34)) {
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt26
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt26:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt23
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt27
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt27:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt23
	GOTO       L_interrupt7
L__interrupt23:
;MyProject.c,51 :: 		PORTB |= 0x02; // Turn on RB1
	BSF        PORTB+0, 1
;MyProject.c,52 :: 		} else {
	GOTO       L_interrupt8
L_interrupt7:
;MyProject.c,53 :: 		PORTB &= 0xFD; // Turn off RB1
	MOVLW      253
	ANDWF      PORTB+0, 1
;MyProject.c,54 :: 		}
L_interrupt8:
;MyProject.c,55 :: 		}
L_interrupt4:
;MyProject.c,58 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;MyProject.c,59 :: 		tick1++;
	INCF       _tick1+0, 1
;MyProject.c,60 :: 		ticka++;
	INCF       _ticka+0, 1
;MyProject.c,61 :: 		if (ticka == 15) { // Toggle RB2 every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;MyProject.c,62 :: 		ticka = 0;
	CLRF       _ticka+0
;MyProject.c,63 :: 		PORTB ^= 0x04; // Toggle RB2
	MOVLW      4
	XORWF      PORTB+0, 1
;MyProject.c,64 :: 		}
L_interrupt10:
;MyProject.c,65 :: 		if (tick1 == 150) { // Stop after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;MyProject.c,66 :: 		tick1 = 0;
	CLRF       _tick1+0
;MyProject.c,67 :: 		rturn = 0;
	CLRF       _rturn+0
;MyProject.c,68 :: 		PORTB &= 0xFB; // Turn off RB2
	MOVLW      251
	ANDWF      PORTB+0, 1
;MyProject.c,69 :: 		}
L_interrupt11:
;MyProject.c,70 :: 		}
L_interrupt9:
;MyProject.c,73 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;MyProject.c,74 :: 		tick2++;
	INCF       _tick2+0, 1
;MyProject.c,75 :: 		tickb++;
	INCF       _tickb+0, 1
;MyProject.c,76 :: 		if (tickb == 15) { // Toggle RB3 every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;MyProject.c,77 :: 		tickb = 0;
	CLRF       _tickb+0
;MyProject.c,78 :: 		PORTB ^= 0x08; // Toggle RB3
	MOVLW      8
	XORWF      PORTB+0, 1
;MyProject.c,79 :: 		}
L_interrupt13:
;MyProject.c,80 :: 		if (tick2 == 150) { // Stop after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;MyProject.c,81 :: 		tick2 = 0;
	CLRF       _tick2+0
;MyProject.c,82 :: 		lturn = 0;
	CLRF       _lturn+0
;MyProject.c,83 :: 		PORTB &= 0xF7; // Turn off RB3
	MOVLW      247
	ANDWF      PORTB+0, 1
;MyProject.c,84 :: 		}
L_interrupt14:
;MyProject.c,85 :: 		}
L_interrupt12:
;MyProject.c,87 :: 		INTCON &= 0xFB; // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;MyProject.c,88 :: 		}
L_interrupt3:
;MyProject.c,89 :: 		}
L_end_interrupt:
L__interrupt25:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;MyProject.c,91 :: 		void main() {
;MyProject.c,93 :: 		TRISB = 0xF1; // RB0, RB1, RB2, RB3 as outputs; RB4, RB5 as inputs
	MOVLW      241
	MOVWF      TRISB+0
;MyProject.c,94 :: 		PORTB = 0x00; // Initialize PORTB to LOW
	CLRF       PORTB+0
;MyProject.c,97 :: 		ATD_init();
	CALL       _ATD_init+0
;MyProject.c,100 :: 		OPTION_REG = 0x07; // Osc clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;MyProject.c,101 :: 		INTCON = 0xF8;     // Enable all interrupts
	MOVLW      248
	MOVWF      INTCON+0
;MyProject.c,102 :: 		TMR0 = 0;          // Reset Timer0
	CLRF       TMR0+0
;MyProject.c,105 :: 		tick = 0;
	CLRF       _tick+0
;MyProject.c,106 :: 		tick1 = 0;
	CLRF       _tick1+0
;MyProject.c,107 :: 		tick2 = 0;
	CLRF       _tick2+0
;MyProject.c,108 :: 		ticka = 0;
	CLRF       _ticka+0
;MyProject.c,109 :: 		tickb = 0;
	CLRF       _tickb+0
;MyProject.c,112 :: 		while (1) {
L_main15:
;MyProject.c,114 :: 		}
	GOTO       L_main15
;MyProject.c,115 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;MyProject.c,118 :: 		void ATD_init(void) {
;MyProject.c,119 :: 		ADCON0 = 0x41; // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;MyProject.c,120 :: 		ADCON1 = 0xC0; // All analog channels, 500 KHz, right justified
	MOVLW      192
	MOVWF      ADCON1+0
;MyProject.c,121 :: 		TRISA = 0xFF;  // Configure PORTA as input
	MOVLW      255
	MOVWF      TRISA+0
;MyProject.c,122 :: 		TRISE = 0x07;  // Configure PORTE as input
	MOVLW      7
	MOVWF      TRISE+0
;MyProject.c,123 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;MyProject.c,126 :: 		unsigned int ATD_read0(void) {
;MyProject.c,127 :: 		ADCON0 &= 0xC7;   // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;MyProject.c,128 :: 		delay_us(10);     // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read017:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read017
	NOP
;MyProject.c,129 :: 		ADCON0 |= 0x04;   // Start ADC conversion
	BSF        ADCON0+0, 2
;MyProject.c,130 :: 		while (ADCON0 & 0x04); // Wait for conversion to complete
L_ATD_read018:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read019
	GOTO       L_ATD_read018
L_ATD_read019:
;MyProject.c,131 :: 		return ((ADRESH << 8) | ADRESL); // Return ADC result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProject.c,132 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;MyProject.c,135 :: 		unsigned int ATD_read1(void) {
;MyProject.c,136 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08; // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;MyProject.c,137 :: 		delay_us(10);      // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read120:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read120
	NOP
;MyProject.c,138 :: 		ADCON0 |= 0x04;    // Start ADC conversion
	BSF        ADCON0+0, 2
;MyProject.c,139 :: 		while (ADCON0 & 0x04); // Wait for conversion to complete
L_ATD_read121:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read122
	GOTO       L_ATD_read121
L_ATD_read122:
;MyProject.c,140 :: 		return ((ADRESH << 8) | ADRESL); // Return ADC result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProject.c,141 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1
