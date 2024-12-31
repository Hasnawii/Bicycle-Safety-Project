
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;BicycleSafetySystem.c,42 :: 		void interrupt() {
;BicycleSafetySystem.c,44 :: 		if (INTCON & 0x01) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt0
;BicycleSafetySystem.c,45 :: 		if (!(PORTB & 0x10)) {   // Check if RB5 (right turn button) is pressed
	BTFSC      PORTB+0, 4
	GOTO       L_interrupt1
;BicycleSafetySystem.c,46 :: 		PORTB |= 0x04;      // Turn on RB2 (right turn signal)
	BSF        PORTB+0, 2
;BicycleSafetySystem.c,47 :: 		rturn = 1;          // Set right turn flag
	MOVLW      1
	MOVWF      _rturn+0
;BicycleSafetySystem.c,48 :: 		}
L_interrupt1:
;BicycleSafetySystem.c,49 :: 		if (!(PORTB & 0x20)) {   // Check if RB6 (left turn button) is pressed
	BTFSC      PORTB+0, 5
	GOTO       L_interrupt2
;BicycleSafetySystem.c,50 :: 		PORTB |= 0x08;      // Turn on RB3 (left turn signal)
	BSF        PORTB+0, 3
;BicycleSafetySystem.c,51 :: 		lturn = 1;          // Set left turn flag
	MOVLW      1
	MOVWF      _lturn+0
;BicycleSafetySystem.c,52 :: 		}
L_interrupt2:
;BicycleSafetySystem.c,53 :: 		INTCON &= 0xFE;          // Clear PORTB Change Interrupt flag
	MOVLW      254
	ANDWF      INTCON+0, 1
;BicycleSafetySystem.c,54 :: 		}
L_interrupt0:
;BicycleSafetySystem.c,57 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt3
;BicycleSafetySystem.c,58 :: 		tick++;                  // Increment Timer0 counter (~32ms per increment)
	INCF       _tick+0, 1
;BicycleSafetySystem.c,59 :: 		tick3++;                 // Increment hall sensor pulse counter
	INCF       _tick3+0, 1
;BicycleSafetySystem.c,60 :: 		tick4++;                 // Increment speed calculation counter
	INCF       _tick4+0, 1
;BicycleSafetySystem.c,61 :: 		tick5++;                 // Increment ultrasonic sensor counter
	INCF       _tick5+0, 1
;BicycleSafetySystem.c,64 :: 		if (tick == 2) {
	MOVF       _tick+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;BicycleSafetySystem.c,65 :: 		tick = 0;
	CLRF       _tick+0
;BicycleSafetySystem.c,68 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;BicycleSafetySystem.c,69 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
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
;BicycleSafetySystem.c,70 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;BicycleSafetySystem.c,71 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading
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
;BicycleSafetySystem.c,74 :: 		if ((flexD0 > 34) || (flexD1 > 34)) {
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt53
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt53:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt50
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt54
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt54:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt50
	GOTO       L_interrupt7
L__interrupt50:
;BicycleSafetySystem.c,75 :: 		PORTB |= 0x02;   // Turn on RB1
	BSF        PORTB+0, 1
;BicycleSafetySystem.c,76 :: 		} else {
	GOTO       L_interrupt8
L_interrupt7:
;BicycleSafetySystem.c,77 :: 		PORTB &= 0xFD;   // Turn off RB1
	MOVLW      253
	ANDWF      PORTB+0, 1
;BicycleSafetySystem.c,78 :: 		}
L_interrupt8:
;BicycleSafetySystem.c,79 :: 		}
L_interrupt4:
;BicycleSafetySystem.c,82 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;BicycleSafetySystem.c,83 :: 		tick1++;             // Increment right turn duration counter
	INCF       _tick1+0, 1
;BicycleSafetySystem.c,84 :: 		ticka++;             // Increment right turn blinking interval counter
	INCF       _ticka+0, 1
;BicycleSafetySystem.c,86 :: 		if (ticka == 15) {   // Toggle RB2 (right turn signal) every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;BicycleSafetySystem.c,87 :: 		ticka = 0;
	CLRF       _ticka+0
;BicycleSafetySystem.c,88 :: 		PORTB ^= 0x04;   // Toggle RB2
	MOVLW      4
	XORWF      PORTB+0, 1
;BicycleSafetySystem.c,89 :: 		}
L_interrupt10:
;BicycleSafetySystem.c,90 :: 		if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;BicycleSafetySystem.c,91 :: 		tick1 = 0;
	CLRF       _tick1+0
;BicycleSafetySystem.c,92 :: 		rturn = 0;
	CLRF       _rturn+0
;BicycleSafetySystem.c,93 :: 		PORTB &= 0xFB;   // Turn off RB2
	MOVLW      251
	ANDWF      PORTB+0, 1
;BicycleSafetySystem.c,94 :: 		}
L_interrupt11:
;BicycleSafetySystem.c,95 :: 		}
L_interrupt9:
;BicycleSafetySystem.c,98 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;BicycleSafetySystem.c,99 :: 		tick2++;             // Increment left turn duration counter
	INCF       _tick2+0, 1
;BicycleSafetySystem.c,100 :: 		tickb++;             // Increment left turn blinking interval counter
	INCF       _tickb+0, 1
;BicycleSafetySystem.c,102 :: 		if (tickb == 15) {   // Toggle RB3 (left turn signal) every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;BicycleSafetySystem.c,103 :: 		tickb = 0;
	CLRF       _tickb+0
;BicycleSafetySystem.c,104 :: 		PORTB ^= 0x08;   // Toggle RB3
	MOVLW      8
	XORWF      PORTB+0, 1
;BicycleSafetySystem.c,105 :: 		}
L_interrupt13:
;BicycleSafetySystem.c,106 :: 		if (tick2 == 150) {  // Stop left turn signal after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;BicycleSafetySystem.c,107 :: 		tick2 = 0;
	CLRF       _tick2+0
;BicycleSafetySystem.c,108 :: 		lturn = 0;
	CLRF       _lturn+0
;BicycleSafetySystem.c,109 :: 		PORTB &= 0xF7;   // Turn off RB3
	MOVLW      247
	ANDWF      PORTB+0, 1
;BicycleSafetySystem.c,110 :: 		}
L_interrupt14:
;BicycleSafetySystem.c,111 :: 		}
L_interrupt12:
;BicycleSafetySystem.c,114 :: 		if (tick3 == 7) {
	MOVF       _tick3+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;BicycleSafetySystem.c,115 :: 		tick3 = 0;
	CLRF       _tick3+0
;BicycleSafetySystem.c,118 :: 		hallA2 = ATD_read2();
	CALL       _ATD_read2+0
	MOVF       R0+0, 0
	MOVWF      _hallA2+0
	MOVF       R0+1, 0
	MOVWF      _hallA2+1
;BicycleSafetySystem.c,119 :: 		hallD2 = (unsigned int)(hallA2 * 50) / 1023;
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
;BicycleSafetySystem.c,122 :: 		if (hallD2 > 10) {
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt55
	MOVF       R0+0, 0
	SUBLW      10
L__interrupt55:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt16
;BicycleSafetySystem.c,123 :: 		pulse++;
	INCF       _pulse+0, 1
	BTFSC      STATUS+0, 2
	INCF       _pulse+1, 1
;BicycleSafetySystem.c,124 :: 		}
L_interrupt16:
;BicycleSafetySystem.c,125 :: 		}
L_interrupt15:
;BicycleSafetySystem.c,128 :: 		if (tick4 == 219) {
	MOVF       _tick4+0, 0
	XORLW      219
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
;BicycleSafetySystem.c,129 :: 		tick4 = 0;
	CLRF       _tick4+0
;BicycleSafetySystem.c,132 :: 		dis = (unsigned long)(314 * 35 * pulse) / 2;
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
;BicycleSafetySystem.c,135 :: 		v = (unsigned long) dis / 700;
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
	MOVF       R0+2, 0
	MOVWF      _v+2
	MOVF       R0+3, 0
	MOVWF      _v+3
;BicycleSafetySystem.c,138 :: 		pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
;BicycleSafetySystem.c,139 :: 		}
L_interrupt17:
;BicycleSafetySystem.c,142 :: 		if (tick5 == 30) {
	MOVF       _tick5+0, 0
	XORLW      30
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt18
;BicycleSafetySystem.c,143 :: 		tick5 = 0;
	CLRF       _tick5+0
;BicycleSafetySystem.c,144 :: 		sonar_read1();        // Trigger ultrasonic sensor 1 reading
	CALL       _sonar_read1+0
;BicycleSafetySystem.c,146 :: 		}
L_interrupt18:
;BicycleSafetySystem.c,148 :: 		INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;BicycleSafetySystem.c,149 :: 		}
L_interrupt3:
;BicycleSafetySystem.c,151 :: 		if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt19
;BicycleSafetySystem.c,152 :: 		T1overflow++;
	INCF       _T1overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T1overflow+1, 1
;BicycleSafetySystem.c,153 :: 		T2overflow++;
	INCF       _T2overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T2overflow+1, 1
;BicycleSafetySystem.c,154 :: 		PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
	MOVLW      254
	ANDWF      PIR1+0, 1
;BicycleSafetySystem.c,155 :: 		}
L_interrupt19:
;BicycleSafetySystem.c,156 :: 		}
L_end_interrupt:
L__interrupt52:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;BicycleSafetySystem.c,159 :: 		void main() {
;BicycleSafetySystem.c,161 :: 		TRISB = 0x71;                // RB1, RB2, RB3, RB7 as outputs; RB0, RB4, RB5, RB6 as inputs
	MOVLW      113
	MOVWF      TRISB+0
;BicycleSafetySystem.c,162 :: 		PORTB = 0x00;                // Initialize PORTB to LOW
	CLRF       PORTB+0
;BicycleSafetySystem.c,163 :: 		TRISC = 0x40;                // Configure RC6 as input
	MOVLW      64
	MOVWF      TRISC+0
;BicycleSafetySystem.c,164 :: 		PORTC = 0x00;                // Initialize PORTC to LOW
	CLRF       PORTC+0
;BicycleSafetySystem.c,167 :: 		ATD_init();
	CALL       _ATD_init+0
;BicycleSafetySystem.c,168 :: 		sonar_init();                // Initialize ultrasonic sensor
	CALL       _sonar_init+0
;BicycleSafetySystem.c,171 :: 		OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;BicycleSafetySystem.c,172 :: 		INTCON = 0xF8;               // Enable all interrupts
	MOVLW      248
	MOVWF      INTCON+0
;BicycleSafetySystem.c,173 :: 		TMR0 = 0;                    // Reset Timer0
	CLRF       TMR0+0
;BicycleSafetySystem.c,176 :: 		tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
	CLRF       _tickb+0
	CLRF       _ticka+0
	CLRF       _tick4+0
	CLRF       _tick3+0
	CLRF       _tick2+0
	CLRF       _tick1+0
	CLRF       _tick+0
;BicycleSafetySystem.c,179 :: 		while (1) {
L_main20:
;BicycleSafetySystem.c,180 :: 		if (D1 < 10) {
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main57
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main57
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main57
	MOVLW      10
	SUBWF      _D1+0, 0
L__main57:
	BTFSC      STATUS+0, 0
	GOTO       L_main22
;BicycleSafetySystem.c,181 :: 		PORTC |= 0x0C;        // Turn on RC2 and RC3
	MOVLW      12
	IORWF      PORTC+0, 1
;BicycleSafetySystem.c,182 :: 		} else {
	GOTO       L_main23
L_main22:
;BicycleSafetySystem.c,183 :: 		PORTC &= 0xF3;        // Turn off RC2 and RC3
	MOVLW      243
	ANDWF      PORTC+0, 1
;BicycleSafetySystem.c,184 :: 		}
L_main23:
;BicycleSafetySystem.c,186 :: 		if (D2 < 10) {
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main58
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main58
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main58
	MOVLW      10
	SUBWF      _D2+0, 0
L__main58:
	BTFSC      STATUS+0, 0
	GOTO       L_main24
;BicycleSafetySystem.c,187 :: 		PORTC |= 0x30;
	MOVLW      48
	IORWF      PORTC+0, 1
;BicycleSafetySystem.c,188 :: 		} else {
	GOTO       L_main25
L_main24:
;BicycleSafetySystem.c,189 :: 		PORTC &= 0xCF;
	MOVLW      207
	ANDWF      PORTC+0, 1
;BicycleSafetySystem.c,190 :: 		}
L_main25:
;BicycleSafetySystem.c,191 :: 		}
	GOTO       L_main20
;BicycleSafetySystem.c,192 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;BicycleSafetySystem.c,195 :: 		void ATD_init(void) {
;BicycleSafetySystem.c,196 :: 		ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;BicycleSafetySystem.c,197 :: 		ADCON1 = 0xC0;             // All analog channels, 500 KHz, right justified
	MOVLW      192
	MOVWF      ADCON1+0
;BicycleSafetySystem.c,198 :: 		TRISA = 0xFF;              // Configure PORTA as input
	MOVLW      255
	MOVWF      TRISA+0
;BicycleSafetySystem.c,199 :: 		TRISE = 0x07;              // Configure PORTE as input
	MOVLW      7
	MOVWF      TRISE+0
;BicycleSafetySystem.c,200 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;BicycleSafetySystem.c,203 :: 		unsigned int ATD_read0(void) {
;BicycleSafetySystem.c,204 :: 		ADCON0 &= 0xC7;            // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;BicycleSafetySystem.c,205 :: 		delay_us(10);              // Stabilize ADC input
	MOVLW      6
	MOVWF      R13+0
L_ATD_read026:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read026
	NOP
;BicycleSafetySystem.c,206 :: 		ADCON0 |= 0x04;            // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetySystem.c,207 :: 		while (ADCON0 & 0x04);     // Wait for conversion to complete
L_ATD_read027:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read028
	GOTO       L_ATD_read027
L_ATD_read028:
;BicycleSafetySystem.c,208 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetySystem.c,209 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;BicycleSafetySystem.c,212 :: 		unsigned int ATD_read1(void) {
;BicycleSafetySystem.c,213 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08;  // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetySystem.c,214 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetySystem.c,215 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetySystem.c,216 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read129:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read130
	GOTO       L_ATD_read129
L_ATD_read130:
;BicycleSafetySystem.c,217 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetySystem.c,218 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1

_ATD_read2:

;BicycleSafetySystem.c,221 :: 		unsigned int ATD_read2(void) {
;BicycleSafetySystem.c,222 :: 		ADCON0 = (ADCON0 & 0xD7) | 0x10;  // Select channel 2
	MOVLW      215
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      16
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetySystem.c,223 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetySystem.c,224 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetySystem.c,225 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read231:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read232
	GOTO       L_ATD_read231
L_ATD_read232:
;BicycleSafetySystem.c,226 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetySystem.c,227 :: 		}
L_end_ATD_read2:
	RETURN
; end of _ATD_read2

_sonar_init:

;BicycleSafetySystem.c,230 :: 		void sonar_init(void) {
;BicycleSafetySystem.c,231 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetySystem.c,232 :: 		T1counts = 0;
	CLRF       _T1counts+0
	CLRF       _T1counts+1
	CLRF       _T1counts+2
	CLRF       _T1counts+3
;BicycleSafetySystem.c,233 :: 		T1time = 0;
	CLRF       _T1time+0
	CLRF       _T1time+1
	CLRF       _T1time+2
	CLRF       _T1time+3
;BicycleSafetySystem.c,234 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetySystem.c,235 :: 		T2counts = 0;
	CLRF       _T2counts+0
	CLRF       _T2counts+1
	CLRF       _T2counts+2
	CLRF       _T2counts+3
;BicycleSafetySystem.c,236 :: 		T2time = 0;
	CLRF       _T2time+0
	CLRF       _T2time+1
	CLRF       _T2time+2
	CLRF       _T2time+3
;BicycleSafetySystem.c,237 :: 		D1 = 0;
	CLRF       _D1+0
	CLRF       _D1+1
	CLRF       _D1+2
	CLRF       _D1+3
;BicycleSafetySystem.c,238 :: 		D2 = 0;
	CLRF       _D2+0
	CLRF       _D2+1
	CLRF       _D2+2
	CLRF       _D2+3
;BicycleSafetySystem.c,239 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetySystem.c,240 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetySystem.c,241 :: 		PIE1 = PIE1 | 0x01;               // Enable TMR1 Overflow interrupt
	BSF        PIE1+0, 0
;BicycleSafetySystem.c,242 :: 		T1CON = 0x18;                     // TMR1 OFF, Fosc/4 (inc 1uS) with 1:2 prescaler
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetySystem.c,243 :: 		}
L_end_sonar_init:
	RETURN
; end of _sonar_init

_sonar_read1:

;BicycleSafetySystem.c,246 :: 		void sonar_read1(void) {
;BicycleSafetySystem.c,247 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetySystem.c,248 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetySystem.c,249 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetySystem.c,251 :: 		PORTB |= 0x80;                    // Trigger the ultrasonic sensor (RB7 connected to trigger)
	BSF        PORTB+0, 7
;BicycleSafetySystem.c,252 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetySystem.c,253 :: 		PORTB &= 0x7F;                    // Remove trigger
	MOVLW      127
	ANDWF      PORTB+0, 1
;BicycleSafetySystem.c,255 :: 		while (!(PORTB & 0x40));          // Wait until you start receiving the echo
L_sonar_read133:
	BTFSC      PORTB+0, 6
	GOTO       L_sonar_read134
	GOTO       L_sonar_read133
L_sonar_read134:
;BicycleSafetySystem.c,256 :: 		T1CON = 0x19;                     // TMR1 ON, Fosc/4 (inc 1uS) with 1:2 prescaler
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetySystem.c,257 :: 		while (PORTB & 0x40);             // Wait until the pulse is received
L_sonar_read135:
	BTFSS      PORTB+0, 6
	GOTO       L_sonar_read136
	GOTO       L_sonar_read135
L_sonar_read136:
;BicycleSafetySystem.c,258 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetySystem.c,260 :: 		T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
	MOVF       TMR1H+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 0
	MOVWF      R8+0
	MOVF       R0+1, 0
	MOVWF      R8+1
	MOVLW      0
	IORWF      R8+1, 1
	MOVF       _T1overflow+1, 0
	MOVWF      R4+3
	MOVF       _T1overflow+0, 0
	MOVWF      R4+2
	CLRF       R4+0
	CLRF       R4+1
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVF       R4+0, 0
	ADDWF      R0+0, 1
	MOVF       R4+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+1, 0
	ADDWF      R0+1, 1
	MOVF       R4+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+2, 0
	ADDWF      R0+2, 1
	MOVF       R4+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+3, 0
	ADDWF      R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _T1counts+0
	MOVF       R0+1, 0
	MOVWF      _T1counts+1
	MOVF       R0+2, 0
	MOVWF      _T1counts+2
	MOVF       R0+3, 0
	MOVWF      _T1counts+3
;BicycleSafetySystem.c,261 :: 		T1time = T1counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T1time+0
	MOVF       R0+1, 0
	MOVWF      _T1time+1
	MOVF       R0+2, 0
	MOVWF      _T1time+2
	MOVF       R0+3, 0
	MOVWF      _T1time+3
;BicycleSafetySystem.c,262 :: 		D1 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
	MOVLW      34
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _D1+0
	MOVF       R0+1, 0
	MOVWF      _D1+1
	MOVF       R0+2, 0
	MOVWF      _D1+2
	MOVF       R0+3, 0
	MOVWF      _D1+3
	RRF        _D1+3, 1
	RRF        _D1+2, 1
	RRF        _D1+1, 1
	RRF        _D1+0, 1
	BCF        _D1+3, 7
;BicycleSafetySystem.c,263 :: 		}
L_end_sonar_read1:
	RETURN
; end of _sonar_read1

_sonar_read2:

;BicycleSafetySystem.c,265 :: 		void sonar_read2(void) {
;BicycleSafetySystem.c,266 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetySystem.c,267 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetySystem.c,268 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetySystem.c,270 :: 		PORTC |= 0x80;                    // Trigger the ultrasonic sensor (RC7 connected to trigger)
	BSF        PORTC+0, 7
;BicycleSafetySystem.c,271 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetySystem.c,272 :: 		PORTC &= 0x7F;                    // Remove trigger
	MOVLW      127
	ANDWF      PORTC+0, 1
;BicycleSafetySystem.c,274 :: 		while (!(PORTC & 0x40));          // Wait until you start receiving the echo
L_sonar_read237:
	BTFSC      PORTC+0, 6
	GOTO       L_sonar_read238
	GOTO       L_sonar_read237
L_sonar_read238:
;BicycleSafetySystem.c,275 :: 		T1CON = 0x19;                     // TMR1 ON, Fosc/4 (inc 1uS) with 1:2 prescaler
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetySystem.c,276 :: 		while (PORTC & 0x40);             // Wait until the pulse is received
L_sonar_read239:
	BTFSS      PORTC+0, 6
	GOTO       L_sonar_read240
	GOTO       L_sonar_read239
L_sonar_read240:
;BicycleSafetySystem.c,277 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetySystem.c,279 :: 		T2counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
	MOVF       TMR1H+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 0
	MOVWF      R8+0
	MOVF       R0+1, 0
	MOVWF      R8+1
	MOVLW      0
	IORWF      R8+1, 1
	MOVF       _T1overflow+1, 0
	MOVWF      R4+3
	MOVF       _T1overflow+0, 0
	MOVWF      R4+2
	CLRF       R4+0
	CLRF       R4+1
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVF       R4+0, 0
	ADDWF      R0+0, 1
	MOVF       R4+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+1, 0
	ADDWF      R0+1, 1
	MOVF       R4+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+2, 0
	ADDWF      R0+2, 1
	MOVF       R4+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+3, 0
	ADDWF      R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _T2counts+0
	MOVF       R0+1, 0
	MOVWF      _T2counts+1
	MOVF       R0+2, 0
	MOVWF      _T2counts+2
	MOVF       R0+3, 0
	MOVWF      _T2counts+3
;BicycleSafetySystem.c,280 :: 		T2time = T2counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T2time+0
	MOVF       R0+1, 0
	MOVWF      _T2time+1
	MOVF       R0+2, 0
	MOVWF      _T2time+2
	MOVF       R0+3, 0
	MOVWF      _T2time+3
;BicycleSafetySystem.c,281 :: 		D2 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
	MOVF       _T1time+0, 0
	MOVWF      R0+0
	MOVF       _T1time+1, 0
	MOVWF      R0+1
	MOVF       _T1time+2, 0
	MOVWF      R0+2
	MOVF       _T1time+3, 0
	MOVWF      R0+3
	MOVLW      34
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _D2+0
	MOVF       R0+1, 0
	MOVWF      _D2+1
	MOVF       R0+2, 0
	MOVWF      _D2+2
	MOVF       R0+3, 0
	MOVWF      _D2+3
	RRF        _D2+3, 1
	RRF        _D2+2, 1
	RRF        _D2+1, 1
	RRF        _D2+0, 1
	BCF        _D2+3, 7
;BicycleSafetySystem.c,282 :: 		}
L_end_sonar_read2:
	RETURN
; end of _sonar_read2

_usDelay:

;BicycleSafetySystem.c,285 :: 		void usDelay(unsigned int usCnt) {
;BicycleSafetySystem.c,287 :: 		for (us = 0; us < usCnt; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_usDelay41:
	MOVF       FARG_usDelay_usCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__usDelay67
	MOVF       FARG_usDelay_usCnt+0, 0
	SUBWF      R1+0, 0
L__usDelay67:
	BTFSC      STATUS+0, 0
	GOTO       L_usDelay42
;BicycleSafetySystem.c,288 :: 		asm NOP; // 0.5 uS
	NOP
;BicycleSafetySystem.c,289 :: 		asm NOP; // 0.5 uS
	NOP
;BicycleSafetySystem.c,287 :: 		for (us = 0; us < usCnt; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetySystem.c,290 :: 		}
	GOTO       L_usDelay41
L_usDelay42:
;BicycleSafetySystem.c,291 :: 		}
L_end_usDelay:
	RETURN
; end of _usDelay

_msDelay:

;BicycleSafetySystem.c,294 :: 		void msDelay(unsigned int msCnt) {
;BicycleSafetySystem.c,296 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R1+0
	CLRF       R1+1
L_msDelay44:
	MOVF       FARG_msDelay_msCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay69
	MOVF       FARG_msDelay_msCnt+0, 0
	SUBWF      R1+0, 0
L__msDelay69:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay45
;BicycleSafetySystem.c,297 :: 		for (cc = 0; cc < 155; cc++);  // 1ms
	CLRF       R3+0
	CLRF       R3+1
L_msDelay47:
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay70
	MOVLW      155
	SUBWF      R3+0, 0
L__msDelay70:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay48
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
	GOTO       L_msDelay47
L_msDelay48:
;BicycleSafetySystem.c,296 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetySystem.c,298 :: 		}
	GOTO       L_msDelay44
L_msDelay45:
;BicycleSafetySystem.c,299 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay
