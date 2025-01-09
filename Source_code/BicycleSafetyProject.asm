
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;BicycleSafetyProject.c,56 :: 		void interrupt() {
;BicycleSafetyProject.c,59 :: 		if (INTCON&0x02){
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt0
;BicycleSafetyProject.c,60 :: 		if (!(PORTB & 0x01)) {
	BTFSC      PORTB+0, 0
	GOTO       L_interrupt1
;BicycleSafetyProject.c,61 :: 		sonar_e = 0;
	CLRF       _sonar_e+0
;BicycleSafetyProject.c,62 :: 		servo_e = 1;
	MOVLW      1
	MOVWF      _servo_e+0
;BicycleSafetyProject.c,64 :: 		}
L_interrupt1:
;BicycleSafetyProject.c,65 :: 		INTCON=INTCON&0xFD;
	MOVLW      253
	ANDWF      INTCON+0, 1
;BicycleSafetyProject.c,66 :: 		}
L_interrupt0:
;BicycleSafetyProject.c,70 :: 		if (INTCON & 0x01) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt2
;BicycleSafetyProject.c,71 :: 		if (!(PORTB & 0x10)) {   // Check if RB5 (right turn button) is pressed
	BTFSC      PORTB+0, 4
	GOTO       L_interrupt3
;BicycleSafetyProject.c,72 :: 		PORTB |= 0x04;      // Turn on RB2 (right turn signal)
	BSF        PORTB+0, 2
;BicycleSafetyProject.c,73 :: 		rturn = 1;          // Set right turn flag
	MOVLW      1
	MOVWF      _rturn+0
;BicycleSafetyProject.c,74 :: 		}
L_interrupt3:
;BicycleSafetyProject.c,75 :: 		if (!(PORTB & 0x20)) {   // Check if RB6 (left turn button) is pressed
	BTFSC      PORTB+0, 5
	GOTO       L_interrupt4
;BicycleSafetyProject.c,76 :: 		PORTB |= 0x08;      // Turn on RB3 (left turn signal)
	BSF        PORTB+0, 3
;BicycleSafetyProject.c,77 :: 		lturn = 1;          // Set left turn flag
	MOVLW      1
	MOVWF      _lturn+0
;BicycleSafetyProject.c,78 :: 		}
L_interrupt4:
;BicycleSafetyProject.c,79 :: 		INTCON &= 0xFE;          // Clear PORTB Change Interrupt flag
	MOVLW      254
	ANDWF      INTCON+0, 1
;BicycleSafetyProject.c,80 :: 		}
L_interrupt2:
;BicycleSafetyProject.c,83 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt5
;BicycleSafetyProject.c,84 :: 		tick++;                  // Increment Timer0 counter (~32ms per increment)
	INCF       _tick+0, 1
;BicycleSafetyProject.c,85 :: 		tick3++;                 // Increment hall sensor pulse counter
	INCF       _tick3+0, 1
;BicycleSafetyProject.c,86 :: 		tick4++;                 // Increment speed calculation counter
	INCF       _tick4+0, 1
;BicycleSafetyProject.c,87 :: 		tick5++;                 // Increment ultrasonic sensor counter
	INCF       _tick5+0, 1
;BicycleSafetyProject.c,91 :: 		if (tick == 2) {
	MOVF       _tick+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt6
;BicycleSafetyProject.c,92 :: 		tick = 0;
	CLRF       _tick+0
;BicycleSafetyProject.c,95 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;BicycleSafetyProject.c,96 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
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
;BicycleSafetyProject.c,97 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;BicycleSafetyProject.c,98 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading
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
;BicycleSafetyProject.c,101 :: 		if ((flexD0 > 34) || (flexD1 > 34)) {
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt71
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt71:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt68
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt72
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt72:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt68
	GOTO       L_interrupt9
L__interrupt68:
;BicycleSafetyProject.c,102 :: 		PORTB |= 0x02;   // Turn on RB1
	BSF        PORTB+0, 1
;BicycleSafetyProject.c,103 :: 		} else {
	GOTO       L_interrupt10
L_interrupt9:
;BicycleSafetyProject.c,104 :: 		PORTB &= 0xFD;   // Turn off RB1
	MOVLW      253
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,105 :: 		}
L_interrupt10:
;BicycleSafetyProject.c,106 :: 		}
L_interrupt6:
;BicycleSafetyProject.c,109 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;BicycleSafetyProject.c,110 :: 		tick1++;             // Increment right turn duration counter
	INCF       _tick1+0, 1
;BicycleSafetyProject.c,111 :: 		ticka++;             // Increment right turn blinking interval counter
	INCF       _ticka+0, 1
;BicycleSafetyProject.c,113 :: 		if (ticka == 15) {   // Toggle RB2 (right turn signal) every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;BicycleSafetyProject.c,114 :: 		ticka = 0;
	CLRF       _ticka+0
;BicycleSafetyProject.c,115 :: 		PORTB ^= 0x04;   // Toggle RB2
	MOVLW      4
	XORWF      PORTB+0, 1
;BicycleSafetyProject.c,116 :: 		}
L_interrupt12:
;BicycleSafetyProject.c,117 :: 		if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;BicycleSafetyProject.c,118 :: 		tick1 = 0;
	CLRF       _tick1+0
;BicycleSafetyProject.c,119 :: 		rturn = 0;
	CLRF       _rturn+0
;BicycleSafetyProject.c,120 :: 		PORTB &= 0xFB;   // Turn off RB2
	MOVLW      251
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,121 :: 		}
L_interrupt13:
;BicycleSafetyProject.c,122 :: 		}
L_interrupt11:
;BicycleSafetyProject.c,125 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;BicycleSafetyProject.c,126 :: 		tick2++;             // Increment left turn duration counter
	INCF       _tick2+0, 1
;BicycleSafetyProject.c,127 :: 		tickb++;             // Increment left turn blinking interval counter
	INCF       _tickb+0, 1
;BicycleSafetyProject.c,129 :: 		if (tickb == 15) {   // Toggle RB3 (left turn signal) every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;BicycleSafetyProject.c,130 :: 		tickb = 0;
	CLRF       _tickb+0
;BicycleSafetyProject.c,131 :: 		PORTB ^= 0x08;   // Toggle RB3
	MOVLW      8
	XORWF      PORTB+0, 1
;BicycleSafetyProject.c,132 :: 		}
L_interrupt15:
;BicycleSafetyProject.c,133 :: 		if (tick2 == 150) {  // Stop left turn signal after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt16
;BicycleSafetyProject.c,134 :: 		tick2 = 0;
	CLRF       _tick2+0
;BicycleSafetyProject.c,135 :: 		lturn = 0;
	CLRF       _lturn+0
;BicycleSafetyProject.c,136 :: 		PORTB &= 0xF7;   // Turn off RB3
	MOVLW      247
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,137 :: 		}
L_interrupt16:
;BicycleSafetyProject.c,138 :: 		}
L_interrupt14:
;BicycleSafetyProject.c,141 :: 		if (tick3 == 7) {
	MOVF       _tick3+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
;BicycleSafetyProject.c,142 :: 		tick3 = 0;
	CLRF       _tick3+0
;BicycleSafetyProject.c,145 :: 		hallA2 = ATD_read2();
	CALL       _ATD_read2+0
	MOVF       R0+0, 0
	MOVWF      _hallA2+0
	MOVF       R0+1, 0
	MOVWF      _hallA2+1
;BicycleSafetyProject.c,146 :: 		hallD2 = (unsigned int)(hallA2 * 50) / 1023;
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
;BicycleSafetyProject.c,149 :: 		if (hallD2 > 10) {
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt73
	MOVF       R0+0, 0
	SUBLW      10
L__interrupt73:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt18
;BicycleSafetyProject.c,150 :: 		pulse++;
	INCF       _pulse+0, 1
	BTFSC      STATUS+0, 2
	INCF       _pulse+1, 1
;BicycleSafetyProject.c,151 :: 		}
L_interrupt18:
;BicycleSafetyProject.c,152 :: 		}
L_interrupt17:
;BicycleSafetyProject.c,155 :: 		if (tick4 == 219) {
	MOVF       _tick4+0, 0
	XORLW      219
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt19
;BicycleSafetyProject.c,156 :: 		tick4 = 0;
	CLRF       _tick4+0
;BicycleSafetyProject.c,159 :: 		dis = (unsigned long)(314 * 35 * pulse) / 2;
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
;BicycleSafetyProject.c,162 :: 		v = (unsigned long) dis / 700;
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
;BicycleSafetyProject.c,165 :: 		pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
;BicycleSafetyProject.c,166 :: 		}
L_interrupt19:
;BicycleSafetyProject.c,169 :: 		if (sonar_e) {
	MOVF       _sonar_e+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt20
;BicycleSafetyProject.c,170 :: 		if (tick5 == 4) {
	MOVF       _tick5+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt21
;BicycleSafetyProject.c,171 :: 		tick5 = 0;
	CLRF       _tick5+0
;BicycleSafetyProject.c,172 :: 		sonar_read1();        // Trigger ultrasonic sensor 1 reading
	CALL       _sonar_read1+0
;BicycleSafetyProject.c,173 :: 		sonar_read2();        // Trigger ultrasonic sensor 2 reading
	CALL       _sonar_read2+0
;BicycleSafetyProject.c,174 :: 		}
L_interrupt21:
;BicycleSafetyProject.c,175 :: 		}
L_interrupt20:
;BicycleSafetyProject.c,177 :: 		INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;BicycleSafetyProject.c,178 :: 		}
L_interrupt5:
;BicycleSafetyProject.c,180 :: 		if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt22
;BicycleSafetyProject.c,181 :: 		T1overflow++;
	INCF       _T1overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T1overflow+1, 1
;BicycleSafetyProject.c,182 :: 		T2overflow++;
	INCF       _T2overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T2overflow+1, 1
;BicycleSafetyProject.c,183 :: 		PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
	MOVLW      254
	ANDWF      PIR1+0, 1
;BicycleSafetyProject.c,184 :: 		}
L_interrupt22:
;BicycleSafetyProject.c,187 :: 		if (PIR2 & 0x01) {
	BTFSS      PIR2+0, 0
	GOTO       L_interrupt23
;BicycleSafetyProject.c,188 :: 		if(HL){ //high
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt24
;BicycleSafetyProject.c,189 :: 		CCPR2H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,190 :: 		CCPR2L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,191 :: 		HL = 0;//next time low
	CLRF       _HL+0
;BicycleSafetyProject.c,192 :: 		CCP2CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,193 :: 		TMR1H=0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,194 :: 		TMR1L=0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,195 :: 		} else {  //low
	GOTO       L_interrupt25
L_interrupt24:
;BicycleSafetyProject.c,196 :: 		CCPR2H = (40000 - angle) >>8;
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,197 :: 		CCPR2L = (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,198 :: 		CCP2CON = 0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,199 :: 		HL = 1; //next time High
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,200 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,201 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,202 :: 		}
L_interrupt25:
;BicycleSafetyProject.c,204 :: 		PIR2 &= 0xFE;
	MOVLW      254
	ANDWF      PIR2+0, 1
;BicycleSafetyProject.c,205 :: 		}
L_interrupt23:
;BicycleSafetyProject.c,206 :: 		}
L_end_interrupt:
L__interrupt70:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;BicycleSafetyProject.c,209 :: 		void main() {
;BicycleSafetyProject.c,211 :: 		TRISA = 0x0F;                 // Configure RA4 RA5 RA6 RA7 as output
	MOVLW      15
	MOVWF      TRISA+0
;BicycleSafetyProject.c,212 :: 		PORTA = 0x00;                 // Initialize PORTA to LOW
	CLRF       PORTA+0
;BicycleSafetyProject.c,213 :: 		TRISB = 0x31;                 // Configure RB0, RB4, RB5, RB6 as inputs
	MOVLW      49
	MOVWF      TRISB+0
;BicycleSafetyProject.c,214 :: 		PORTB = 0x00;                 // Initialize PORTB to LOW
	CLRF       PORTB+0
;BicycleSafetyProject.c,215 :: 		TRISC = 0x50;                 // Configure RC6 and RC4 as input
	MOVLW      80
	MOVWF      TRISC+0
;BicycleSafetyProject.c,216 :: 		PORTC = 0x00;                 // Initialize PORTC to LOW
	CLRF       PORTC+0
;BicycleSafetyProject.c,218 :: 		ATD_init();                  // Initialize ADC
	CALL       _ATD_init+0
;BicycleSafetyProject.c,219 :: 		sonar_init();                // Initialize ultrasonic sensors
	CALL       _sonar_init+0
;BicycleSafetyProject.c,220 :: 		CCPPWM_init();               // Initialize PWM for motors
	CALL       _CCPPWM_init+0
;BicycleSafetyProject.c,221 :: 		CCPcompare_init();
	CALL       _CCPcompare_init+0
;BicycleSafetyProject.c,224 :: 		OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;BicycleSafetyProject.c,225 :: 		INTCON = 0xF8;               // Enable all interrupts
	MOVLW      248
	MOVWF      INTCON+0
;BicycleSafetyProject.c,226 :: 		TMR0 = 0;                    // Reset Timer0
	CLRF       TMR0+0
;BicycleSafetyProject.c,229 :: 		tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
	CLRF       _tickb+0
	CLRF       _ticka+0
	CLRF       _tick4+0
	CLRF       _tick3+0
	CLRF       _tick2+0
	CLRF       _tick1+0
	CLRF       _tick+0
;BicycleSafetyProject.c,232 :: 		while (1) {
L_main26:
;BicycleSafetyProject.c,234 :: 		if (D1read & 0x01) {
	BTFSS      _D1read+0, 0
	GOTO       L_main28
;BicycleSafetyProject.c,235 :: 		if (D1 < 10) {
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main75
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main75
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main75
	MOVLW      10
	SUBWF      _D1+0, 0
L__main75:
	BTFSC      STATUS+0, 0
	GOTO       L_main29
;BicycleSafetyProject.c,236 :: 		PORTB |= 0x40;  // Turn on motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,237 :: 		mspeed1 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,238 :: 		} else if (D1 < 30) {
	GOTO       L_main30
L_main29:
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main76
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main76
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main76
	MOVLW      30
	SUBWF      _D1+0, 0
L__main76:
	BTFSC      STATUS+0, 0
	GOTO       L_main31
;BicycleSafetyProject.c,239 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,240 :: 		mspeed1 = 200;  // Set medium speed
	MOVLW      200
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,241 :: 		} else if (D1 < 50) {
	GOTO       L_main32
L_main31:
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main77
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main77
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main77
	MOVLW      50
	SUBWF      _D1+0, 0
L__main77:
	BTFSC      STATUS+0, 0
	GOTO       L_main33
;BicycleSafetyProject.c,242 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,243 :: 		mspeed1 = 175;  // Set low speed
	MOVLW      175
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,244 :: 		} else {
	GOTO       L_main34
L_main33:
;BicycleSafetyProject.c,245 :: 		PORTB &= 0xBF;   // Turn off motor 1
	MOVLW      191
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,246 :: 		mspeed1 = 0;     // Stop motor
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,247 :: 		}
L_main34:
L_main32:
L_main30:
;BicycleSafetyProject.c,248 :: 		D1read = 0x00;       // Clear read flag for sensor 1
	CLRF       _D1read+0
;BicycleSafetyProject.c,249 :: 		}
L_main28:
;BicycleSafetyProject.c,252 :: 		if (D2read & 0x01) {
	BTFSS      _D2read+0, 0
	GOTO       L_main35
;BicycleSafetyProject.c,253 :: 		if (D2 < 10) {
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      10
	SUBWF      _D2+0, 0
L__main78:
	BTFSC      STATUS+0, 0
	GOTO       L_main36
;BicycleSafetyProject.c,254 :: 		mspeed2 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,255 :: 		PORTC |= 0x08; // Turn on motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,256 :: 		} else if (D2 < 30) {
	GOTO       L_main37
L_main36:
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      30
	SUBWF      _D2+0, 0
L__main79:
	BTFSC      STATUS+0, 0
	GOTO       L_main38
;BicycleSafetyProject.c,257 :: 		mspeed2 = 120;  // Set medium speed
	MOVLW      120
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,258 :: 		PORTC |= 0x08; // Maintain motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,259 :: 		} else if (D2 < 50) {
	GOTO       L_main39
L_main38:
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      50
	SUBWF      _D2+0, 0
L__main80:
	BTFSC      STATUS+0, 0
	GOTO       L_main40
;BicycleSafetyProject.c,260 :: 		mspeed2 = 60;   // Set low speed
	MOVLW      60
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,261 :: 		PORTC |= 0x808; // Maintain motor 2
	MOVLW      8
	IORWF      PORTC+0, 1
;BicycleSafetyProject.c,262 :: 		} else {
	GOTO       L_main41
L_main40:
;BicycleSafetyProject.c,263 :: 		mspeed2 = 0;    // Stop motor
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,264 :: 		PORTC &= ~0x08; // Turn off motor 2
	BCF        PORTC+0, 3
;BicycleSafetyProject.c,265 :: 		}
L_main41:
L_main39:
L_main37:
;BicycleSafetyProject.c,266 :: 		D2read = 0x00;       // Clear read flag for sensor 2
	CLRF       _D2read+0
;BicycleSafetyProject.c,267 :: 		}
L_main35:
;BicycleSafetyProject.c,268 :: 		motor1();               // Update motor 1
	CALL       _motor1+0
;BicycleSafetyProject.c,269 :: 		motor2();               // Update motor 2
	CALL       _motor2+0
;BicycleSafetyProject.c,270 :: 		}
	GOTO       L_main26
;BicycleSafetyProject.c,271 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;BicycleSafetyProject.c,274 :: 		void ATD_init(void) {
;BicycleSafetyProject.c,275 :: 		ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,276 :: 		ADCON1 = 0xC4;             // AN0, AN1, AN3 analog channels; 500 KHz, right justified
	MOVLW      196
	MOVWF      ADCON1+0
;BicycleSafetyProject.c,277 :: 		TRISE = 0x07;              // Configure PORTE as input
	MOVLW      7
	MOVWF      TRISE+0
;BicycleSafetyProject.c,278 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;BicycleSafetyProject.c,281 :: 		unsigned int ATD_read0(void) {
;BicycleSafetyProject.c,282 :: 		ADCON0 &= 0xC7;            // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;BicycleSafetyProject.c,283 :: 		usDelay(10);               // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,284 :: 		ADCON0 |= 0x04;            // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,285 :: 		while (ADCON0 & 0x04);     // Wait for conversion to complete
L_ATD_read042:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read043
	GOTO       L_ATD_read042
L_ATD_read043:
;BicycleSafetyProject.c,286 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,287 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;BicycleSafetyProject.c,290 :: 		unsigned int ATD_read1(void) {
;BicycleSafetyProject.c,291 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08;  // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,292 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,293 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,294 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read144:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read145
	GOTO       L_ATD_read144
L_ATD_read145:
;BicycleSafetyProject.c,295 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,296 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1

_ATD_read2:

;BicycleSafetyProject.c,299 :: 		unsigned int ATD_read2(void) {
;BicycleSafetyProject.c,300 :: 		ADCON0 = (ADCON0 & 0xDF) | 0x18;  // Select channel 3
	MOVLW      223
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      24
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,301 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,302 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,303 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read246:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read247
	GOTO       L_ATD_read246
L_ATD_read247:
;BicycleSafetyProject.c,304 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,305 :: 		}
L_end_ATD_read2:
	RETURN
; end of _ATD_read2

_sonar_init:

;BicycleSafetyProject.c,308 :: 		void sonar_init(void) {
;BicycleSafetyProject.c,309 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,310 :: 		T1counts = 0;
	CLRF       _T1counts+0
	CLRF       _T1counts+1
	CLRF       _T1counts+2
	CLRF       _T1counts+3
;BicycleSafetyProject.c,311 :: 		T1time = 0;
	CLRF       _T1time+0
	CLRF       _T1time+1
	CLRF       _T1time+2
	CLRF       _T1time+3
;BicycleSafetyProject.c,312 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,313 :: 		T2counts = 0;
	CLRF       _T2counts+0
	CLRF       _T2counts+1
	CLRF       _T2counts+2
	CLRF       _T2counts+3
;BicycleSafetyProject.c,314 :: 		T2time = 0;
	CLRF       _T2time+0
	CLRF       _T2time+1
	CLRF       _T2time+2
	CLRF       _T2time+3
;BicycleSafetyProject.c,315 :: 		D1read = 0;
	CLRF       _D1read+0
;BicycleSafetyProject.c,316 :: 		D2read = 0;
	CLRF       _D2read+0
;BicycleSafetyProject.c,317 :: 		D1 = 0;
	CLRF       _D1+0
	CLRF       _D1+1
	CLRF       _D1+2
	CLRF       _D1+3
;BicycleSafetyProject.c,318 :: 		D2 = 0;
	CLRF       _D2+0
	CLRF       _D2+1
	CLRF       _D2+2
	CLRF       _D2+3
;BicycleSafetyProject.c,319 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,320 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,321 :: 		PIE1 |= 0x01;               // Enable TMR1 Overflow interrupt
	BSF        PIE1+0, 0
;BicycleSafetyProject.c,322 :: 		T1CON = 0x18;               // TMR1 OFF, Fosc/4 (1uS increments) with 1:2 prescaler
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,323 :: 		}
L_end_sonar_init:
	RETURN
; end of _sonar_init

_sonar_read1:

;BicycleSafetyProject.c,326 :: 		void sonar_read1(void) {
;BicycleSafetyProject.c,327 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,328 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,329 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,330 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,332 :: 		PORTC |= 0x80;                    // Trigger ultrasonic sensor 1 (RC7 connected to trigger)
	BSF        PORTC+0, 7
;BicycleSafetyProject.c,333 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,334 :: 		PORTC &= 0x7F;                    // Remove trigger
	MOVLW      127
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,336 :: 		while (!(PORTC & 0x40));          // Wait for echo to start
L_sonar_read148:
	BTFSC      PORTC+0, 6
	GOTO       L_sonar_read149
	GOTO       L_sonar_read148
L_sonar_read149:
;BicycleSafetyProject.c,337 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,338 :: 		while (PORTC & 0x40);             // Wait for echo to end
L_sonar_read150:
	BTFSS      PORTC+0, 6
	GOTO       L_sonar_read151
	GOTO       L_sonar_read150
L_sonar_read151:
;BicycleSafetyProject.c,339 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,341 :: 		T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
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
;BicycleSafetyProject.c,342 :: 		T1time = T1counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T1time+0
	MOVF       R0+1, 0
	MOVWF      _T1time+1
	MOVF       R0+2, 0
	MOVWF      _T1time+2
	MOVF       R0+3, 0
	MOVWF      _T1time+3
;BicycleSafetyProject.c,343 :: 		D1 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,344 :: 		D1read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D1read+0
;BicycleSafetyProject.c,345 :: 		}
L_end_sonar_read1:
	RETURN
; end of _sonar_read1

_sonar_read2:

;BicycleSafetyProject.c,348 :: 		void sonar_read2(void) {
;BicycleSafetyProject.c,349 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,350 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,351 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,352 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,354 :: 		PORTC |= 0x20;                    // Trigger ultrasonic sensor 2 (RC5 connected to trigger)
	BSF        PORTC+0, 5
;BicycleSafetyProject.c,355 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,356 :: 		PORTC &= 0xDF;                    // Remove trigger
	MOVLW      223
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,358 :: 		while (!(PORTC & 0x10));          // Wait for echo to start
L_sonar_read252:
	BTFSC      PORTC+0, 4
	GOTO       L_sonar_read253
	GOTO       L_sonar_read252
L_sonar_read253:
;BicycleSafetyProject.c,359 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,360 :: 		while (PORTC & 0x10);             // Wait for echo to end
L_sonar_read254:
	BTFSS      PORTC+0, 4
	GOTO       L_sonar_read255
	GOTO       L_sonar_read254
L_sonar_read255:
;BicycleSafetyProject.c,361 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,363 :: 		T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
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
	MOVF       _T2overflow+1, 0
	MOVWF      R4+3
	MOVF       _T2overflow+0, 0
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
;BicycleSafetyProject.c,364 :: 		T2time = T2counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T2time+0
	MOVF       R0+1, 0
	MOVWF      _T2time+1
	MOVF       R0+2, 0
	MOVWF      _T2time+2
	MOVF       R0+3, 0
	MOVWF      _T2time+3
;BicycleSafetyProject.c,365 :: 		D2 = ((T2time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,366 :: 		D2read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D2read+0
;BicycleSafetyProject.c,367 :: 		}
L_end_sonar_read2:
	RETURN
; end of _sonar_read2

_CCPPWM_init:

;BicycleSafetyProject.c,370 :: 		void CCPPWM_init(void) {
;BicycleSafetyProject.c,371 :: 		T2CON = 0x07;                    // Enable Timer2 with 1:16 prescaler
	MOVLW      7
	MOVWF      T2CON+0
;BicycleSafetyProject.c,372 :: 		CCP1CON = 0x0C;                  // Enable PWM for CCP1
	MOVLW      12
	MOVWF      CCP1CON+0
;BicycleSafetyProject.c,373 :: 		PR2 = 250;                       // Set Timer2 period
	MOVLW      250
	MOVWF      PR2+0
;BicycleSafetyProject.c,374 :: 		CCPR1L = 125;                    // Initial duty cycle for CCP1 (50%)
	MOVLW      125
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,375 :: 		mspeed1 = 0;
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,376 :: 		mspeed2 = 0;
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,377 :: 		period = 0;
	CLRF       _period+0
	CLRF       _period+1
;BicycleSafetyProject.c,378 :: 		duty = 0;
	CLRF       _duty+0
	CLRF       _duty+1
;BicycleSafetyProject.c,379 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_CCPcompare_init:

;BicycleSafetyProject.c,381 :: 		void CCPcompare_init(void){
;BicycleSafetyProject.c,382 :: 		HL = 1; //start high
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,383 :: 		CCP2CON = 0x08;//
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,384 :: 		CCPR2H=2000>>8;
	MOVLW      7
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,385 :: 		CCPR2L=2000;
	MOVLW      208
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,386 :: 		}
L_end_CCPcompare_init:
	RETURN
; end of _CCPcompare_init

_motor1:

;BicycleSafetyProject.c,388 :: 		void motor1(void) {
;BicycleSafetyProject.c,389 :: 		CCPR1L = mspeed1;                // Set PWM duty cycle for motor 1
	MOVF       _mspeed1+0, 0
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,390 :: 		}
L_end_motor1:
	RETURN
; end of _motor1

_motor2:

;BicycleSafetyProject.c,393 :: 		void motor2(void) {
;BicycleSafetyProject.c,394 :: 		PORTB |= 0x80;                       //High
	BSF        PORTB+0, 7
;BicycleSafetyProject.c,395 :: 		PWMusDelay(mspeed2*2);
	MOVF       _mspeed2+0, 0
	MOVWF      FARG_PWMusDelay+0
	CLRF       FARG_PWMusDelay+1
	RLF        FARG_PWMusDelay+0, 1
	RLF        FARG_PWMusDelay+1, 1
	BCF        FARG_PWMusDelay+0, 0
	CALL       _PWMusDelay+0
;BicycleSafetyProject.c,396 :: 		PORTB &= 0x7F;                       //Low
	MOVLW      127
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,397 :: 		PWMusDelay((250-mspeed2)*2);
	MOVF       _mspeed2+0, 0
	SUBLW      250
	MOVWF      FARG_PWMusDelay+0
	CLRF       FARG_PWMusDelay+1
	BTFSS      STATUS+0, 0
	DECF       FARG_PWMusDelay+1, 1
	RLF        FARG_PWMusDelay+0, 1
	RLF        FARG_PWMusDelay+1, 1
	BCF        FARG_PWMusDelay+0, 0
	CALL       _PWMusDelay+0
;BicycleSafetyProject.c,398 :: 		}
L_end_motor2:
	RETURN
; end of _motor2

_usDelay:

;BicycleSafetyProject.c,401 :: 		void usDelay(unsigned int usCnt) {
;BicycleSafetyProject.c,403 :: 		for (us = 0; us < usCnt; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_usDelay56:
	MOVF       FARG_usDelay_usCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__usDelay93
	MOVF       FARG_usDelay_usCnt+0, 0
	SUBWF      R1+0, 0
L__usDelay93:
	BTFSC      STATUS+0, 0
	GOTO       L_usDelay57
;BicycleSafetyProject.c,404 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,405 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,403 :: 		for (us = 0; us < usCnt; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,406 :: 		}
	GOTO       L_usDelay56
L_usDelay57:
;BicycleSafetyProject.c,407 :: 		}
L_end_usDelay:
	RETURN
; end of _usDelay

_PWMusDelay:

;BicycleSafetyProject.c,409 :: 		void PWMusDelay(unsigned int PWMusCnt) {
;BicycleSafetyProject.c,411 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	CLRF       R1+0
	CLRF       R1+1
L_PWMusDelay59:
	MOVF       FARG_PWMusDelay_PWMusCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PWMusDelay95
	MOVF       FARG_PWMusDelay_PWMusCnt+0, 0
	SUBWF      R1+0, 0
L__PWMusDelay95:
	BTFSC      STATUS+0, 0
	GOTO       L_PWMusDelay60
;BicycleSafetyProject.c,412 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,413 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,411 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,414 :: 		}
	GOTO       L_PWMusDelay59
L_PWMusDelay60:
;BicycleSafetyProject.c,415 :: 		}
L_end_PWMusDelay:
	RETURN
; end of _PWMusDelay

_msDelay:

;BicycleSafetyProject.c,417 :: 		void msDelay(unsigned int msCnt) {
;BicycleSafetyProject.c,419 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R1+0
	CLRF       R1+1
L_msDelay62:
	MOVF       FARG_msDelay_msCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay97
	MOVF       FARG_msDelay_msCnt+0, 0
	SUBWF      R1+0, 0
L__msDelay97:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay63
;BicycleSafetyProject.c,420 :: 		for (cc = 0; cc < 155; cc++); // 1ms
	CLRF       R3+0
	CLRF       R3+1
L_msDelay65:
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay98
	MOVLW      155
	SUBWF      R3+0, 0
L__msDelay98:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay66
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
	GOTO       L_msDelay65
L_msDelay66:
;BicycleSafetyProject.c,419 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,421 :: 		}
	GOTO       L_msDelay62
L_msDelay63:
;BicycleSafetyProject.c,422 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay
