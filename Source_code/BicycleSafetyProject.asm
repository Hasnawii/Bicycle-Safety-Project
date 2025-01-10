
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;BicycleSafetyProject.c,61 :: 		void interrupt() {
;BicycleSafetyProject.c,79 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;BicycleSafetyProject.c,80 :: 		tick++;                  // Increment Timer0 counter (~32ms per increment)
	INCF       _tick+0, 1
;BicycleSafetyProject.c,81 :: 		tick3++;                 // Increment hall sensor pulse counter
	INCF       _tick3+0, 1
;BicycleSafetyProject.c,82 :: 		tick4++;                 // Increment speed calculation counter
	INCF       _tick4+0, 1
;BicycleSafetyProject.c,85 :: 		if (tick == 2) {
	MOVF       _tick+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt1
;BicycleSafetyProject.c,86 :: 		tick = 0;
	CLRF       _tick+0
;BicycleSafetyProject.c,89 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;BicycleSafetyProject.c,90 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
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
;BicycleSafetyProject.c,91 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;BicycleSafetyProject.c,92 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading
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
;BicycleSafetyProject.c,95 :: 		if ((flexD0 > 34) || (flexD1 > 34)) {
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt74
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt74:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt71
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt75
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt75:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt71
	GOTO       L_interrupt4
L__interrupt71:
;BicycleSafetyProject.c,96 :: 		PORTD |= 0x03;
	MOVLW      3
	IORWF      PORTD+0, 1
;BicycleSafetyProject.c,97 :: 		} else {
	GOTO       L_interrupt5
L_interrupt4:
;BicycleSafetyProject.c,98 :: 		PORTD &= 0xFC;
	MOVLW      252
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,99 :: 		}
L_interrupt5:
;BicycleSafetyProject.c,100 :: 		}
L_interrupt1:
;BicycleSafetyProject.c,102 :: 		if (!(PORTE & 0x01)) {   // Check if right turn button is pressed
	BTFSC      PORTE+0, 0
	GOTO       L_interrupt6
;BicycleSafetyProject.c,103 :: 		PORTD |= 0x04;      // Turn on RD2 (right turn signal)
	BSF        PORTD+0, 2
;BicycleSafetyProject.c,104 :: 		rturn = 1;          // Set right turn flag
	MOVLW      1
	MOVWF      _rturn+0
;BicycleSafetyProject.c,105 :: 		}
L_interrupt6:
;BicycleSafetyProject.c,106 :: 		if (!(PORTE & 0x02)) {   // Check if left turn button is pressed
	BTFSC      PORTE+0, 1
	GOTO       L_interrupt7
;BicycleSafetyProject.c,107 :: 		PORTD |= 0x08;      // Turn on RD2 (left turn signal)
	BSF        PORTD+0, 3
;BicycleSafetyProject.c,108 :: 		lturn = 1;          // Set left turn flag
	MOVLW      1
	MOVWF      _lturn+0
;BicycleSafetyProject.c,109 :: 		}
L_interrupt7:
;BicycleSafetyProject.c,111 :: 		if (!(PORTE & 0x04)) {             // if button is pressed
	BTFSC      PORTE+0, 2
	GOTO       L_interrupt8
;BicycleSafetyProject.c,112 :: 		servo_flag = 1;                 // enable servo flag
	MOVLW      1
	MOVWF      _servo_flag+0
;BicycleSafetyProject.c,113 :: 		toggle_servo = !toggle_servo;    //opposite value of toggle
	MOVF       _toggle_servo+0, 0
	MOVLW      1
	BTFSS      STATUS+0, 2
	MOVLW      0
	MOVWF      _toggle_servo+0
;BicycleSafetyProject.c,114 :: 		}
L_interrupt8:
;BicycleSafetyProject.c,117 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;BicycleSafetyProject.c,118 :: 		tick1++;             // Increment right turn duration counter
	INCF       _tick1+0, 1
;BicycleSafetyProject.c,119 :: 		ticka++;             // Increment right turn blinking interval counter
	INCF       _ticka+0, 1
;BicycleSafetyProject.c,121 :: 		if (ticka == 15) {   // Toggle(right turn signal) every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;BicycleSafetyProject.c,122 :: 		ticka = 0;
	CLRF       _ticka+0
;BicycleSafetyProject.c,123 :: 		PORTD ^= 0x04;   // Toggle RD1
	MOVLW      4
	XORWF      PORTD+0, 1
;BicycleSafetyProject.c,124 :: 		}
L_interrupt10:
;BicycleSafetyProject.c,125 :: 		if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;BicycleSafetyProject.c,126 :: 		tick1 = 0;
	CLRF       _tick1+0
;BicycleSafetyProject.c,127 :: 		rturn = 0;
	CLRF       _rturn+0
;BicycleSafetyProject.c,128 :: 		PORTD &= 0xFB;   // Turn off RD1
	MOVLW      251
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,129 :: 		}
L_interrupt11:
;BicycleSafetyProject.c,130 :: 		}
L_interrupt9:
;BicycleSafetyProject.c,133 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;BicycleSafetyProject.c,134 :: 		tick2++;             // Increment left turn duration counter
	INCF       _tick2+0, 1
;BicycleSafetyProject.c,135 :: 		tickb++;             // Increment left turn blinking interval counter
	INCF       _tickb+0, 1
;BicycleSafetyProject.c,137 :: 		if (tickb == 15) {   // Toggle (left turn signal) every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;BicycleSafetyProject.c,138 :: 		tickb = 0;
	CLRF       _tickb+0
;BicycleSafetyProject.c,139 :: 		PORTD ^= 0x08;   // Toggle RD2
	MOVLW      8
	XORWF      PORTD+0, 1
;BicycleSafetyProject.c,140 :: 		}
L_interrupt13:
;BicycleSafetyProject.c,141 :: 		if (tick2 == 150) {  // Stop left turn signal after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;BicycleSafetyProject.c,142 :: 		tick2 = 0;
	CLRF       _tick2+0
;BicycleSafetyProject.c,143 :: 		lturn = 0;
	CLRF       _lturn+0
;BicycleSafetyProject.c,144 :: 		PORTD &= 0xF7;   // Turn off RD2
	MOVLW      247
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,145 :: 		}
L_interrupt14:
;BicycleSafetyProject.c,146 :: 		}
L_interrupt12:
;BicycleSafetyProject.c,150 :: 		if (tick3 == 3) {
	MOVF       _tick3+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;BicycleSafetyProject.c,151 :: 		tick3 = 0;
	CLRF       _tick3+0
;BicycleSafetyProject.c,154 :: 		hallA2 = ATD_read2();
	CALL       _ATD_read2+0
	MOVF       R0+0, 0
	MOVWF      _hallA2+0
	MOVF       R0+1, 0
	MOVWF      _hallA2+1
;BicycleSafetyProject.c,155 :: 		hallD2 = (unsigned int)(hallA2 * 50) / 1023;
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
;BicycleSafetyProject.c,158 :: 		if (hallD2 > 10) {
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt76
	MOVF       R0+0, 0
	SUBLW      10
L__interrupt76:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt16
;BicycleSafetyProject.c,159 :: 		pulse++;
	INCF       _pulse+0, 1
	BTFSC      STATUS+0, 2
	INCF       _pulse+1, 1
;BicycleSafetyProject.c,160 :: 		}
L_interrupt16:
;BicycleSafetyProject.c,161 :: 		}
L_interrupt15:
;BicycleSafetyProject.c,164 :: 		if (tick4 == 219) {
	MOVF       _tick4+0, 0
	XORLW      219
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
;BicycleSafetyProject.c,165 :: 		tick4 = 0;
	CLRF       _tick4+0
;BicycleSafetyProject.c,168 :: 		dis = (unsigned long)(314 * 35 * pulse) / 2;
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
;BicycleSafetyProject.c,171 :: 		v = (unsigned long) dis / 700;
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
;BicycleSafetyProject.c,174 :: 		pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
;BicycleSafetyProject.c,175 :: 		}
L_interrupt17:
;BicycleSafetyProject.c,178 :: 		if (sonar_e) {
	MOVF       _sonar_e+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt18
;BicycleSafetyProject.c,179 :: 		tick5++;
	INCF       _tick5+0, 1
;BicycleSafetyProject.c,180 :: 		PIE2 &= 0xFE;   //disable CCP2 interrupt disable
	MOVLW      254
	ANDWF      PIE2+0, 1
;BicycleSafetyProject.c,181 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,182 :: 		if (tick5 == 4) {
	MOVF       _tick5+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt19
;BicycleSafetyProject.c,183 :: 		tick5 = 0;
	CLRF       _tick5+0
;BicycleSafetyProject.c,184 :: 		sonar_read1();        // Trigger ultrasonic sensor 1 reading
	CALL       _sonar_read1+0
;BicycleSafetyProject.c,185 :: 		sonar_read2();        // Trigger ultrasonic sensor 2 reading
	CALL       _sonar_read2+0
;BicycleSafetyProject.c,186 :: 		}
L_interrupt19:
;BicycleSafetyProject.c,187 :: 		}
L_interrupt18:
;BicycleSafetyProject.c,189 :: 		INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;BicycleSafetyProject.c,190 :: 		}
L_interrupt0:
;BicycleSafetyProject.c,192 :: 		if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt20
;BicycleSafetyProject.c,193 :: 		T1overflow++;
	INCF       _T1overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T1overflow+1, 1
;BicycleSafetyProject.c,194 :: 		T2overflow++;
	INCF       _T2overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T2overflow+1, 1
;BicycleSafetyProject.c,195 :: 		PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
	MOVLW      254
	ANDWF      PIR1+0, 1
;BicycleSafetyProject.c,196 :: 		}
L_interrupt20:
;BicycleSafetyProject.c,199 :: 		if (PIR2 & 0x01) {
	BTFSS      PIR2+0, 0
	GOTO       L_interrupt21
;BicycleSafetyProject.c,200 :: 		if(HL){ //high
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt22
;BicycleSafetyProject.c,201 :: 		CCPR2H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,202 :: 		CCPR2L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,203 :: 		HL = 0;//next time low
	CLRF       _HL+0
;BicycleSafetyProject.c,204 :: 		CCP2CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,205 :: 		TMR1H=0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,206 :: 		TMR1L=0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,207 :: 		} else {  //low
	GOTO       L_interrupt23
L_interrupt22:
;BicycleSafetyProject.c,208 :: 		CCPR2H = (40000 - angle) >>8;
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
;BicycleSafetyProject.c,209 :: 		CCPR2L = (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,210 :: 		CCP2CON = 0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,211 :: 		HL = 1; //next time High
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,212 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,213 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,214 :: 		}
L_interrupt23:
;BicycleSafetyProject.c,215 :: 		PIR2 &= 0xFE;
	MOVLW      254
	ANDWF      PIR2+0, 1
;BicycleSafetyProject.c,216 :: 		}
L_interrupt21:
;BicycleSafetyProject.c,217 :: 		}
L_end_interrupt:
L__interrupt73:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;BicycleSafetyProject.c,220 :: 		void main() {
;BicycleSafetyProject.c,222 :: 		port_init();
	CALL       _port_init+0
;BicycleSafetyProject.c,223 :: 		ATD_init();                  // Initialize ADC
	CALL       _ATD_init+0
;BicycleSafetyProject.c,224 :: 		sonar_init();                // Initialize ultrasonic sensors
	CALL       _sonar_init+0
;BicycleSafetyProject.c,225 :: 		CCPPWM_init();               // Initialize PWM for motors
	CALL       _CCPPWM_init+0
;BicycleSafetyProject.c,226 :: 		CCPcompare_init();
	CALL       _CCPcompare_init+0
;BicycleSafetyProject.c,229 :: 		OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;BicycleSafetyProject.c,230 :: 		INTCON = 0xF0;               // Enable all interrupts
	MOVLW      240
	MOVWF      INTCON+0
;BicycleSafetyProject.c,231 :: 		TMR0 = 0;                    // Reset Timer0
	CLRF       TMR0+0
;BicycleSafetyProject.c,234 :: 		tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
	CLRF       _tickb+0
	CLRF       _ticka+0
	CLRF       _tick4+0
	CLRF       _tick3+0
	CLRF       _tick2+0
	CLRF       _tick1+0
	CLRF       _tick+0
;BicycleSafetyProject.c,236 :: 		servo_flag = 0;
	CLRF       _servo_flag+0
;BicycleSafetyProject.c,237 :: 		sonar_e = 1;
	MOVLW      1
	MOVWF      _sonar_e+0
;BicycleSafetyProject.c,238 :: 		toggle_servo = 0;
	CLRF       _toggle_servo+0
;BicycleSafetyProject.c,242 :: 		while (1) {
L_main24:
;BicycleSafetyProject.c,244 :: 		if(sonar_e) {
	MOVF       _sonar_e+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main26
;BicycleSafetyProject.c,245 :: 		if (D1read & 0x01) {
	BTFSS      _D1read+0, 0
	GOTO       L_main27
;BicycleSafetyProject.c,246 :: 		if (D1 < 10) {
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main78
	MOVLW      10
	SUBWF      _D1+0, 0
L__main78:
	BTFSC      STATUS+0, 0
	GOTO       L_main28
;BicycleSafetyProject.c,247 :: 		PORTB |= 0x40;  // Turn on motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,248 :: 		mspeed1 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,249 :: 		} else if (D1 < 30) {
	GOTO       L_main29
L_main28:
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main79
	MOVLW      30
	SUBWF      _D1+0, 0
L__main79:
	BTFSC      STATUS+0, 0
	GOTO       L_main30
;BicycleSafetyProject.c,250 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,251 :: 		mspeed1 = 200;  // Set medium speed
	MOVLW      200
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,252 :: 		} else if (D1 < 50) {
	GOTO       L_main31
L_main30:
	MOVLW      0
	SUBWF      _D1+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      0
	SUBWF      _D1+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      0
	SUBWF      _D1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main80
	MOVLW      50
	SUBWF      _D1+0, 0
L__main80:
	BTFSC      STATUS+0, 0
	GOTO       L_main32
;BicycleSafetyProject.c,253 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,254 :: 		mspeed1 = 175;  // Set low speed
	MOVLW      175
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,255 :: 		} else {
	GOTO       L_main33
L_main32:
;BicycleSafetyProject.c,256 :: 		PORTB &= 0xBF;   // Turn off motor 1
	MOVLW      191
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,257 :: 		mspeed1 = 0;     // Stop motor
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,258 :: 		}
L_main33:
L_main31:
L_main29:
;BicycleSafetyProject.c,259 :: 		D1read = 0x00;       // Clear read flag for sensor 1
	CLRF       _D1read+0
;BicycleSafetyProject.c,260 :: 		}
L_main27:
;BicycleSafetyProject.c,263 :: 		if (D2read & 0x01) {
	BTFSS      _D2read+0, 0
	GOTO       L_main34
;BicycleSafetyProject.c,264 :: 		if (D2 < 10) {
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main81
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main81
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main81
	MOVLW      10
	SUBWF      _D2+0, 0
L__main81:
	BTFSC      STATUS+0, 0
	GOTO       L_main35
;BicycleSafetyProject.c,265 :: 		mspeed2 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,266 :: 		PORTC |= 0x08; // Turn on motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,267 :: 		} else if (D2 < 30) {
	GOTO       L_main36
L_main35:
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main82
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main82
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main82
	MOVLW      30
	SUBWF      _D2+0, 0
L__main82:
	BTFSC      STATUS+0, 0
	GOTO       L_main37
;BicycleSafetyProject.c,268 :: 		mspeed2 = 120;  // Set medium speed
	MOVLW      120
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,269 :: 		PORTC |= 0x08; // Maintain motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,270 :: 		} else if (D2 < 50) {
	GOTO       L_main38
L_main37:
	MOVLW      0
	SUBWF      _D2+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main83
	MOVLW      0
	SUBWF      _D2+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main83
	MOVLW      0
	SUBWF      _D2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main83
	MOVLW      50
	SUBWF      _D2+0, 0
L__main83:
	BTFSC      STATUS+0, 0
	GOTO       L_main39
;BicycleSafetyProject.c,271 :: 		mspeed2 = 60;   // Set low speed
	MOVLW      60
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,272 :: 		PORTC |= 0x808; // Maintain motor 2
	MOVLW      8
	IORWF      PORTC+0, 1
;BicycleSafetyProject.c,273 :: 		} else {
	GOTO       L_main40
L_main39:
;BicycleSafetyProject.c,274 :: 		mspeed2 = 0;    // Stop motor
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,275 :: 		PORTC &= ~0x08; // Turn off motor 2
	BCF        PORTC+0, 3
;BicycleSafetyProject.c,276 :: 		}
L_main40:
L_main38:
L_main36:
;BicycleSafetyProject.c,277 :: 		D2read = 0x00;       // Clear read flag for sensor 2
	CLRF       _D2read+0
;BicycleSafetyProject.c,278 :: 		}
L_main34:
;BicycleSafetyProject.c,279 :: 		motor1();               // Update motor 1
	CALL       _motor1+0
;BicycleSafetyProject.c,280 :: 		motor2();               // Update motor 2
	CALL       _motor2+0
;BicycleSafetyProject.c,281 :: 		}
L_main26:
;BicycleSafetyProject.c,283 :: 		if(servo_flag){
	MOVF       _servo_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main41
;BicycleSafetyProject.c,284 :: 		sonar_e = 0;         // disable sonar read
	CLRF       _sonar_e+0
;BicycleSafetyProject.c,285 :: 		mspeed1 = 0;
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,286 :: 		mspeed2 = 0;
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,287 :: 		CCP2CON = 0x08;
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,288 :: 		T1CON = 0x01;              //change tmr1 prescaler to 1:1
	MOVLW      1
	MOVWF      T1CON+0
;BicycleSafetyProject.c,289 :: 		PIE2 |= 0x01;
	BSF        PIE2+0, 0
;BicycleSafetyProject.c,291 :: 		if(toggle_servo == 0){
	MOVF       _toggle_servo+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main42
;BicycleSafetyProject.c,292 :: 		angle = 1000;
	MOVLW      232
	MOVWF      _angle+0
	MOVLW      3
	MOVWF      _angle+1
;BicycleSafetyProject.c,293 :: 		} else if(toggle_servo == 1) {
	GOTO       L_main43
L_main42:
	MOVF       _toggle_servo+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main44
;BicycleSafetyProject.c,294 :: 		angle = 3000;
	MOVLW      184
	MOVWF      _angle+0
	MOVLW      11
	MOVWF      _angle+1
;BicycleSafetyProject.c,295 :: 		}
L_main44:
L_main43:
;BicycleSafetyProject.c,297 :: 		msDelay(5000);             // delay 5 seconds
	MOVLW      136
	MOVWF      FARG_msDelay+0
	MOVLW      19
	MOVWF      FARG_msDelay+1
	CALL       _msDelay+0
;BicycleSafetyProject.c,298 :: 		servo_flag = 0;            //disable sonar flag
	CLRF       _servo_flag+0
;BicycleSafetyProject.c,299 :: 		sonar_e = 1;               // enable sonar read
	MOVLW      1
	MOVWF      _sonar_e+0
;BicycleSafetyProject.c,300 :: 		}
L_main41:
;BicycleSafetyProject.c,301 :: 		}
	GOTO       L_main24
;BicycleSafetyProject.c,302 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_port_init:

;BicycleSafetyProject.c,304 :: 		void port_init(void){
;BicycleSafetyProject.c,305 :: 		TRISA = 0x0F;                 // Configure RA4 RA5 RA6 RA7 as output
	MOVLW      15
	MOVWF      TRISA+0
;BicycleSafetyProject.c,306 :: 		PORTA = 0x00;                 // Initialize PORTA to LOW
	CLRF       PORTA+0
;BicycleSafetyProject.c,307 :: 		TRISB = 0x00;                 // Configure RB0, RB4, RB5, RB6 as inputs
	CLRF       TRISB+0
;BicycleSafetyProject.c,308 :: 		PORTB = 0x00;                 // Initialize PORTB to LOW
	CLRF       PORTB+0
;BicycleSafetyProject.c,309 :: 		TRISC = 0x50;                 // Configure RC6 and RC4 as input                                                         v
	MOVLW      80
	MOVWF      TRISC+0
;BicycleSafetyProject.c,310 :: 		PORTC = 0x00;                 // Initialize PORTC to LOW
	CLRF       PORTC+0
;BicycleSafetyProject.c,311 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;BicycleSafetyProject.c,312 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;BicycleSafetyProject.c,313 :: 		TRISE = 0x0F;
	MOVLW      15
	MOVWF      TRISE+0
;BicycleSafetyProject.c,314 :: 		PORTE = 0x00;
	CLRF       PORTE+0
;BicycleSafetyProject.c,315 :: 		}
L_end_port_init:
	RETURN
; end of _port_init

_ATD_init:

;BicycleSafetyProject.c,317 :: 		void ATD_init(void) {
;BicycleSafetyProject.c,318 :: 		ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,319 :: 		ADCON1 = 0xC4;             // AN0, AN1, AN3 analog channels; 500 KHz, right justified
	MOVLW      196
	MOVWF      ADCON1+0
;BicycleSafetyProject.c,320 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;BicycleSafetyProject.c,323 :: 		unsigned int ATD_read0(void) {
;BicycleSafetyProject.c,324 :: 		ADCON0 &= 0xC7;            // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;BicycleSafetyProject.c,325 :: 		usDelay(10);               // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,326 :: 		ADCON0 |= 0x04;            // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,327 :: 		while (ADCON0 & 0x04);     // Wait for conversion to complete
L_ATD_read045:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read046
	GOTO       L_ATD_read045
L_ATD_read046:
;BicycleSafetyProject.c,328 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,329 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;BicycleSafetyProject.c,332 :: 		unsigned int ATD_read1(void) {
;BicycleSafetyProject.c,333 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08;  // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,334 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,335 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,336 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read147:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read148
	GOTO       L_ATD_read147
L_ATD_read148:
;BicycleSafetyProject.c,337 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,338 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1

_ATD_read2:

;BicycleSafetyProject.c,341 :: 		unsigned int ATD_read2(void) {
;BicycleSafetyProject.c,342 :: 		ADCON0 = (ADCON0 & 0xDF) | 0x18;  // Select channel 3
	MOVLW      223
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      24
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,343 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,344 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,345 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read249:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read250
	GOTO       L_ATD_read249
L_ATD_read250:
;BicycleSafetyProject.c,346 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,347 :: 		}
L_end_ATD_read2:
	RETURN
; end of _ATD_read2

_sonar_init:

;BicycleSafetyProject.c,350 :: 		void sonar_init(void) {
;BicycleSafetyProject.c,351 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,352 :: 		T1counts = 0;
	CLRF       _T1counts+0
	CLRF       _T1counts+1
	CLRF       _T1counts+2
	CLRF       _T1counts+3
;BicycleSafetyProject.c,353 :: 		T1time = 0;
	CLRF       _T1time+0
	CLRF       _T1time+1
	CLRF       _T1time+2
	CLRF       _T1time+3
;BicycleSafetyProject.c,354 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,355 :: 		T2counts = 0;
	CLRF       _T2counts+0
	CLRF       _T2counts+1
	CLRF       _T2counts+2
	CLRF       _T2counts+3
;BicycleSafetyProject.c,356 :: 		T2time = 0;
	CLRF       _T2time+0
	CLRF       _T2time+1
	CLRF       _T2time+2
	CLRF       _T2time+3
;BicycleSafetyProject.c,357 :: 		D1read = 0;
	CLRF       _D1read+0
;BicycleSafetyProject.c,358 :: 		D2read = 0;
	CLRF       _D2read+0
;BicycleSafetyProject.c,359 :: 		D1 = 0;
	CLRF       _D1+0
	CLRF       _D1+1
	CLRF       _D1+2
	CLRF       _D1+3
;BicycleSafetyProject.c,360 :: 		D2 = 0;
	CLRF       _D2+0
	CLRF       _D2+1
	CLRF       _D2+2
	CLRF       _D2+3
;BicycleSafetyProject.c,361 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,362 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,363 :: 		PIE1 |= 0x01;               // Enable TMR1 Overflow interrupt
	BSF        PIE1+0, 0
;BicycleSafetyProject.c,364 :: 		T1CON = 0x18;               // TMR1 OFF, Fosc/4 (1uS increments) with 1:2 prescaler
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,365 :: 		}
L_end_sonar_init:
	RETURN
; end of _sonar_init

_sonar_read1:

;BicycleSafetyProject.c,368 :: 		void sonar_read1(void) {
;BicycleSafetyProject.c,369 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,370 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,371 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,372 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,374 :: 		PORTC |= 0x80;                    // Trigger ultrasonic sensor 1 (RC7 connected to trigger)
	BSF        PORTC+0, 7
;BicycleSafetyProject.c,375 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,376 :: 		PORTC &= 0x7F;                    // Remove trigger
	MOVLW      127
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,378 :: 		while (!(PORTC & 0x40));          // Wait for echo to start
L_sonar_read151:
	BTFSC      PORTC+0, 6
	GOTO       L_sonar_read152
	GOTO       L_sonar_read151
L_sonar_read152:
;BicycleSafetyProject.c,379 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,380 :: 		while (PORTC & 0x40);             // Wait for echo to end
L_sonar_read153:
	BTFSS      PORTC+0, 6
	GOTO       L_sonar_read154
	GOTO       L_sonar_read153
L_sonar_read154:
;BicycleSafetyProject.c,381 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,383 :: 		T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
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
;BicycleSafetyProject.c,384 :: 		T1time = T1counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T1time+0
	MOVF       R0+1, 0
	MOVWF      _T1time+1
	MOVF       R0+2, 0
	MOVWF      _T1time+2
	MOVF       R0+3, 0
	MOVWF      _T1time+3
;BicycleSafetyProject.c,385 :: 		D1 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,386 :: 		D1read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D1read+0
;BicycleSafetyProject.c,387 :: 		}
L_end_sonar_read1:
	RETURN
; end of _sonar_read1

_sonar_read2:

;BicycleSafetyProject.c,390 :: 		void sonar_read2(void) {
;BicycleSafetyProject.c,391 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,392 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,393 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,394 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,396 :: 		PORTC |= 0x20;                    // Trigger ultrasonic sensor 2 (RC5 connected to trigger)
	BSF        PORTC+0, 5
;BicycleSafetyProject.c,397 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,398 :: 		PORTC &= 0xDF;                    // Remove trigger
	MOVLW      223
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,400 :: 		while (!(PORTC & 0x10));          // Wait for echo to start
L_sonar_read255:
	BTFSC      PORTC+0, 4
	GOTO       L_sonar_read256
	GOTO       L_sonar_read255
L_sonar_read256:
;BicycleSafetyProject.c,401 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,402 :: 		while (PORTC & 0x10);             // Wait for echo to end
L_sonar_read257:
	BTFSS      PORTC+0, 4
	GOTO       L_sonar_read258
	GOTO       L_sonar_read257
L_sonar_read258:
;BicycleSafetyProject.c,403 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,405 :: 		T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
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
;BicycleSafetyProject.c,406 :: 		T2time = T2counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T2time+0
	MOVF       R0+1, 0
	MOVWF      _T2time+1
	MOVF       R0+2, 0
	MOVWF      _T2time+2
	MOVF       R0+3, 0
	MOVWF      _T2time+3
;BicycleSafetyProject.c,407 :: 		D2 = ((T2time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,408 :: 		D2read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D2read+0
;BicycleSafetyProject.c,409 :: 		}
L_end_sonar_read2:
	RETURN
; end of _sonar_read2

_CCPPWM_init:

;BicycleSafetyProject.c,412 :: 		void CCPPWM_init(void) {
;BicycleSafetyProject.c,413 :: 		T2CON = 0x07;                    // Enable Timer2 with 1:16 prescaler
	MOVLW      7
	MOVWF      T2CON+0
;BicycleSafetyProject.c,414 :: 		CCP1CON = 0x0C;                  // Enable PWM for CCP1
	MOVLW      12
	MOVWF      CCP1CON+0
;BicycleSafetyProject.c,415 :: 		PR2 = 250;                       // Set Timer2 period
	MOVLW      250
	MOVWF      PR2+0
;BicycleSafetyProject.c,416 :: 		CCPR1L = 125;                    // Initial duty cycle for CCP1 (50%)
	MOVLW      125
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,418 :: 		mspeed1 = 0;
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,419 :: 		mspeed2 = 0;
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,420 :: 		period = 0;
	CLRF       _period+0
	CLRF       _period+1
;BicycleSafetyProject.c,421 :: 		duty = 0;
	CLRF       _duty+0
	CLRF       _duty+1
;BicycleSafetyProject.c,422 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_CCPcompare_init:

;BicycleSafetyProject.c,424 :: 		void CCPcompare_init(void){
;BicycleSafetyProject.c,425 :: 		HL = 1; //start high
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,426 :: 		CCP2CON = 0x08;//
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,427 :: 		CCPR2H=2000>>8;
	MOVLW      7
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,428 :: 		CCPR2L=2000;
	MOVLW      208
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,429 :: 		}
L_end_CCPcompare_init:
	RETURN
; end of _CCPcompare_init

_motor1:

;BicycleSafetyProject.c,431 :: 		void motor1(void) {
;BicycleSafetyProject.c,432 :: 		CCPR1L = mspeed1;                // Set PWM duty cycle for motor 1
	MOVF       _mspeed1+0, 0
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,433 :: 		}
L_end_motor1:
	RETURN
; end of _motor1

_motor2:

;BicycleSafetyProject.c,436 :: 		void motor2(void) {
;BicycleSafetyProject.c,437 :: 		PORTB |= 0x80;                       //High
	BSF        PORTB+0, 7
;BicycleSafetyProject.c,438 :: 		PWMusDelay(mspeed2*2);
	MOVF       _mspeed2+0, 0
	MOVWF      FARG_PWMusDelay+0
	CLRF       FARG_PWMusDelay+1
	RLF        FARG_PWMusDelay+0, 1
	RLF        FARG_PWMusDelay+1, 1
	BCF        FARG_PWMusDelay+0, 0
	CALL       _PWMusDelay+0
;BicycleSafetyProject.c,439 :: 		PORTB &= 0x7F;                       //Low
	MOVLW      127
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,440 :: 		PWMusDelay((250-mspeed2)*2);
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
;BicycleSafetyProject.c,441 :: 		}
L_end_motor2:
	RETURN
; end of _motor2

_usDelay:

;BicycleSafetyProject.c,444 :: 		void usDelay(unsigned int usCnt) {
;BicycleSafetyProject.c,446 :: 		for (us = 0; us < usCnt; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_usDelay59:
	MOVF       FARG_usDelay_usCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__usDelay97
	MOVF       FARG_usDelay_usCnt+0, 0
	SUBWF      R1+0, 0
L__usDelay97:
	BTFSC      STATUS+0, 0
	GOTO       L_usDelay60
;BicycleSafetyProject.c,447 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,448 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,446 :: 		for (us = 0; us < usCnt; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,449 :: 		}
	GOTO       L_usDelay59
L_usDelay60:
;BicycleSafetyProject.c,450 :: 		}
L_end_usDelay:
	RETURN
; end of _usDelay

_PWMusDelay:

;BicycleSafetyProject.c,452 :: 		void PWMusDelay(unsigned int PWMusCnt) {
;BicycleSafetyProject.c,454 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	CLRF       R1+0
	CLRF       R1+1
L_PWMusDelay62:
	MOVF       FARG_PWMusDelay_PWMusCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PWMusDelay99
	MOVF       FARG_PWMusDelay_PWMusCnt+0, 0
	SUBWF      R1+0, 0
L__PWMusDelay99:
	BTFSC      STATUS+0, 0
	GOTO       L_PWMusDelay63
;BicycleSafetyProject.c,455 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,456 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,454 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,457 :: 		}
	GOTO       L_PWMusDelay62
L_PWMusDelay63:
;BicycleSafetyProject.c,458 :: 		}
L_end_PWMusDelay:
	RETURN
; end of _PWMusDelay

_msDelay:

;BicycleSafetyProject.c,460 :: 		void msDelay(unsigned int msCnt) {
;BicycleSafetyProject.c,462 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R1+0
	CLRF       R1+1
L_msDelay65:
	MOVF       FARG_msDelay_msCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay101
	MOVF       FARG_msDelay_msCnt+0, 0
	SUBWF      R1+0, 0
L__msDelay101:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay66
;BicycleSafetyProject.c,463 :: 		for (cc = 0; cc < 155; cc++); // 1ms
	CLRF       R3+0
	CLRF       R3+1
L_msDelay68:
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay102
	MOVLW      155
	SUBWF      R3+0, 0
L__msDelay102:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay69
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
	GOTO       L_msDelay68
L_msDelay69:
;BicycleSafetyProject.c,462 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,464 :: 		}
	GOTO       L_msDelay65
L_msDelay66:
;BicycleSafetyProject.c,465 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay
