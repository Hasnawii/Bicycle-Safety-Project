
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;BicycleSafetyProject.c,79 :: 		void interrupt() {
;BicycleSafetyProject.c,82 :: 		if (INTCON & 0x04) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;BicycleSafetyProject.c,83 :: 		tick++;                  // Increment Timer0 counter (~32ms per increment)
	INCF       _tick+0, 1
;BicycleSafetyProject.c,84 :: 		tick3++;                 // Increment hall sensor pulse counter
	INCF       _tick3+0, 1
;BicycleSafetyProject.c,85 :: 		tick4++;                 // Increment speed calculation counter
	INCF       _tick4+0, 1
;BicycleSafetyProject.c,88 :: 		if (tick == 2) {
	MOVF       _tick+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt1
;BicycleSafetyProject.c,89 :: 		tick = 0;
	CLRF       _tick+0
;BicycleSafetyProject.c,92 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;BicycleSafetyProject.c,93 :: 		flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
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
;BicycleSafetyProject.c,94 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;BicycleSafetyProject.c,95 :: 		flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading
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
;BicycleSafetyProject.c,98 :: 		if ((flexD0 > 23) || (flexD1 > 22 )){
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt74
	MOVF       _flexD0+0, 0
	SUBLW      23
L__interrupt74:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt71
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt75
	MOVF       _flexD1+0, 0
	SUBLW      22
L__interrupt75:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt71
	GOTO       L_interrupt4
L__interrupt71:
;BicycleSafetyProject.c,99 :: 		PORTD |= 0x03;
	MOVLW      3
	IORWF      PORTD+0, 1
;BicycleSafetyProject.c,100 :: 		} else {
	GOTO       L_interrupt5
L_interrupt4:
;BicycleSafetyProject.c,101 :: 		PORTD &= 0xFC;
	MOVLW      252
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,102 :: 		}
L_interrupt5:
;BicycleSafetyProject.c,103 :: 		}
L_interrupt1:
;BicycleSafetyProject.c,105 :: 		if (!(PORTE & 0x01)) {   // Check if right turn button is pressed
	BTFSC      PORTE+0, 0
	GOTO       L_interrupt6
;BicycleSafetyProject.c,106 :: 		PORTD |= 0x04;      // Turn on RD2 (right turn signal)
	BSF        PORTD+0, 2
;BicycleSafetyProject.c,107 :: 		rturn = 1;          // Set right turn flag
	MOVLW      1
	MOVWF      _rturn+0
;BicycleSafetyProject.c,108 :: 		}
L_interrupt6:
;BicycleSafetyProject.c,109 :: 		if (!(PORTE & 0x02)) {   // Check if left turn button is pressed
	BTFSC      PORTE+0, 1
	GOTO       L_interrupt7
;BicycleSafetyProject.c,110 :: 		PORTD |= 0x08;      // Turn on RD2 (left turn signal)
	BSF        PORTD+0, 3
;BicycleSafetyProject.c,111 :: 		lturn = 1;          // Set left turn flag
	MOVLW      1
	MOVWF      _lturn+0
;BicycleSafetyProject.c,112 :: 		}
L_interrupt7:
;BicycleSafetyProject.c,114 :: 		if (!(PORTE & 0x04)) {             // if button is pressed
	BTFSC      PORTE+0, 2
	GOTO       L_interrupt8
;BicycleSafetyProject.c,115 :: 		servo_flag = 1;                 // enable servo flag
	MOVLW      1
	MOVWF      _servo_flag+0
;BicycleSafetyProject.c,116 :: 		}
L_interrupt8:
;BicycleSafetyProject.c,119 :: 		if (rturn == 1) {
	MOVF       _rturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt9
;BicycleSafetyProject.c,120 :: 		tick1++;             // Increment right turn duration counter
	INCF       _tick1+0, 1
;BicycleSafetyProject.c,121 :: 		ticka++;             // Increment right turn blinking interval counter
	INCF       _ticka+0, 1
;BicycleSafetyProject.c,123 :: 		if (ticka == 15) {   // Toggle(right turn signal) every ~480ms
	MOVF       _ticka+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt10
;BicycleSafetyProject.c,124 :: 		ticka = 0;
	CLRF       _ticka+0
;BicycleSafetyProject.c,125 :: 		PORTD ^= 0x04;   // Toggle RD1
	MOVLW      4
	XORWF      PORTD+0, 1
;BicycleSafetyProject.c,126 :: 		}
L_interrupt10:
;BicycleSafetyProject.c,127 :: 		if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
	MOVF       _tick1+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt11
;BicycleSafetyProject.c,128 :: 		tick1 = 0;
	CLRF       _tick1+0
;BicycleSafetyProject.c,129 :: 		rturn = 0;
	CLRF       _rturn+0
;BicycleSafetyProject.c,130 :: 		PORTD &= 0xFB;   // Turn off RD1
	MOVLW      251
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,131 :: 		}
L_interrupt11:
;BicycleSafetyProject.c,132 :: 		}
L_interrupt9:
;BicycleSafetyProject.c,135 :: 		if (lturn == 1) {
	MOVF       _lturn+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;BicycleSafetyProject.c,136 :: 		tick2++;             // Increment left turn duration counter
	INCF       _tick2+0, 1
;BicycleSafetyProject.c,137 :: 		tickb++;             // Increment left turn blinking interval counter
	INCF       _tickb+0, 1
;BicycleSafetyProject.c,139 :: 		if (tickb == 15) {   // Toggle (left turn signal) every ~480ms
	MOVF       _tickb+0, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;BicycleSafetyProject.c,140 :: 		tickb = 0;
	CLRF       _tickb+0
;BicycleSafetyProject.c,141 :: 		PORTD ^= 0x08;   // Toggle RD2
	MOVLW      8
	XORWF      PORTD+0, 1
;BicycleSafetyProject.c,142 :: 		}
L_interrupt13:
;BicycleSafetyProject.c,143 :: 		if (tick2 == 150) {  // Stop left turn signal after ~5 seconds
	MOVF       _tick2+0, 0
	XORLW      150
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
;BicycleSafetyProject.c,144 :: 		tick2 = 0;
	CLRF       _tick2+0
;BicycleSafetyProject.c,145 :: 		lturn = 0;
	CLRF       _lturn+0
;BicycleSafetyProject.c,146 :: 		PORTD &= 0xF7;   // Turn off RD2
	MOVLW      247
	ANDWF      PORTD+0, 1
;BicycleSafetyProject.c,147 :: 		}
L_interrupt14:
;BicycleSafetyProject.c,148 :: 		}
L_interrupt12:
;BicycleSafetyProject.c,152 :: 		if (tick3 == 3) {
	MOVF       _tick3+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;BicycleSafetyProject.c,153 :: 		tick3 = 0;
	CLRF       _tick3+0
;BicycleSafetyProject.c,156 :: 		hallA2 = ATD_read2();
	CALL       _ATD_read2+0
	MOVF       R0+0, 0
	MOVWF      _hallA2+0
	MOVF       R0+1, 0
	MOVWF      _hallA2+1
;BicycleSafetyProject.c,157 :: 		hallD2 = (unsigned int)(hallA2 * 50) / 1023;
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
;BicycleSafetyProject.c,160 :: 		if (hallD2 > 10) {
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt76
	MOVF       R0+0, 0
	SUBLW      10
L__interrupt76:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt16
;BicycleSafetyProject.c,161 :: 		pulse++;
	INCF       _pulse+0, 1
	BTFSC      STATUS+0, 2
	INCF       _pulse+1, 1
;BicycleSafetyProject.c,162 :: 		}
L_interrupt16:
;BicycleSafetyProject.c,163 :: 		}
L_interrupt15:
;BicycleSafetyProject.c,166 :: 		if (tick4 == 219) {
	MOVF       _tick4+0, 0
	XORLW      219
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt17
;BicycleSafetyProject.c,167 :: 		tick4 = 0;
	CLRF       _tick4+0
;BicycleSafetyProject.c,170 :: 		dis = (unsigned long)(314 * 35 * pulse) / 2;
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
;BicycleSafetyProject.c,173 :: 		v = (unsigned long) dis / 700;
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
;BicycleSafetyProject.c,176 :: 		pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
;BicycleSafetyProject.c,177 :: 		}
L_interrupt17:
;BicycleSafetyProject.c,180 :: 		if (sonar_e) {
	MOVF       _sonar_e+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt18
;BicycleSafetyProject.c,181 :: 		tick5++;
	INCF       _tick5+0, 1
;BicycleSafetyProject.c,182 :: 		PIE2 &= 0xFE;   //disable CCP2 interrupt disable
	MOVLW      254
	ANDWF      PIE2+0, 1
;BicycleSafetyProject.c,183 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,185 :: 		if (tick5 == 4) {
	MOVF       _tick5+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt19
;BicycleSafetyProject.c,186 :: 		tick5 = 0;
	CLRF       _tick5+0
;BicycleSafetyProject.c,187 :: 		sonar_read1();        // Trigger ultrasonic sensor 1 reading
	CALL       _sonar_read1+0
;BicycleSafetyProject.c,188 :: 		sonar_read2();        // Trigger ultrasonic sensor 2 reading
	CALL       _sonar_read2+0
;BicycleSafetyProject.c,189 :: 		}
L_interrupt19:
;BicycleSafetyProject.c,190 :: 		}
L_interrupt18:
;BicycleSafetyProject.c,192 :: 		INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;BicycleSafetyProject.c,193 :: 		}
L_interrupt0:
;BicycleSafetyProject.c,195 :: 		if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt20
;BicycleSafetyProject.c,196 :: 		T1overflow++;
	INCF       _T1overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T1overflow+1, 1
;BicycleSafetyProject.c,197 :: 		T2overflow++;
	INCF       _T2overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T2overflow+1, 1
;BicycleSafetyProject.c,198 :: 		PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
	MOVLW      254
	ANDWF      PIR1+0, 1
;BicycleSafetyProject.c,199 :: 		}
L_interrupt20:
;BicycleSafetyProject.c,202 :: 		if (PIR2 & 0x01) {
	BTFSS      PIR2+0, 0
	GOTO       L_interrupt21
;BicycleSafetyProject.c,203 :: 		if(HL){ //high
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt22
;BicycleSafetyProject.c,204 :: 		CCPR2H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,205 :: 		CCPR2L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,206 :: 		HL = 0;//next time low
	CLRF       _HL+0
;BicycleSafetyProject.c,207 :: 		CCP2CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,208 :: 		TMR1H=0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,209 :: 		TMR1L=0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,210 :: 		} else {  //low
	GOTO       L_interrupt23
L_interrupt22:
;BicycleSafetyProject.c,211 :: 		CCPR2H = (40000 - angle) >>8;
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
;BicycleSafetyProject.c,212 :: 		CCPR2L = (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,213 :: 		CCP2CON = 0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,214 :: 		HL = 1; //next time High
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,215 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,216 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,217 :: 		}
L_interrupt23:
;BicycleSafetyProject.c,218 :: 		PIR2 &= 0xFE;
	MOVLW      254
	ANDWF      PIR2+0, 1
;BicycleSafetyProject.c,219 :: 		}
L_interrupt21:
;BicycleSafetyProject.c,220 :: 		}
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

;BicycleSafetyProject.c,223 :: 		void main() {
;BicycleSafetyProject.c,225 :: 		port_init();
	CALL       _port_init+0
;BicycleSafetyProject.c,226 :: 		ATD_init();                  // Initialize ADC
	CALL       _ATD_init+0
;BicycleSafetyProject.c,227 :: 		sonar_init();                // Initialize ultrasonic sensors
	CALL       _sonar_init+0
;BicycleSafetyProject.c,228 :: 		CCPPWM_init();               // Initialize PWM for motors
	CALL       _CCPPWM_init+0
;BicycleSafetyProject.c,229 :: 		CCPcompare_init();
	CALL       _CCPcompare_init+0
;BicycleSafetyProject.c,232 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;BicycleSafetyProject.c,233 :: 		Lcd_Cmd(_LCD_CLEAR);               // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;BicycleSafetyProject.c,234 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);          // Cursor off
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;BicycleSafetyProject.c,235 :: 		Lcd_Out(1, 6, "Hasnawi");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_BicycleSafetyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;BicycleSafetyProject.c,236 :: 		Lcd_Out(2, 1, txt1);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt1+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;BicycleSafetyProject.c,237 :: 		Lcd_Out(2, 14, txt2);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      14
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txt2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;BicycleSafetyProject.c,240 :: 		OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;BicycleSafetyProject.c,241 :: 		INTCON = 0xF0;               // Enable all interrupts
	MOVLW      240
	MOVWF      INTCON+0
;BicycleSafetyProject.c,242 :: 		TMR0 = 0;                    // Reset Timer0
	CLRF       TMR0+0
;BicycleSafetyProject.c,245 :: 		tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;
	CLRF       _pulse+0
	CLRF       _pulse+1
	CLRF       _tickb+0
	CLRF       _ticka+0
	CLRF       _tick4+0
	CLRF       _tick3+0
	CLRF       _tick2+0
	CLRF       _tick1+0
	CLRF       _tick+0
;BicycleSafetyProject.c,246 :: 		servo_flag = 0;
	CLRF       _servo_flag+0
;BicycleSafetyProject.c,247 :: 		sonar_e = 1;
	MOVLW      1
	MOVWF      _sonar_e+0
;BicycleSafetyProject.c,251 :: 		while (1) {
L_main24:
;BicycleSafetyProject.c,256 :: 		if(sonar_e) {
	MOVF       _sonar_e+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main26
;BicycleSafetyProject.c,257 :: 		if (D1read & 0x01) {
	BTFSS      _D1read+0, 0
	GOTO       L_main27
;BicycleSafetyProject.c,258 :: 		if (D1 < 10) {
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
;BicycleSafetyProject.c,259 :: 		PORTB |= 0x40;  // Turn on motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,260 :: 		mspeed1 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,261 :: 		} else if (D1 < 30) {
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
;BicycleSafetyProject.c,262 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,263 :: 		mspeed1 = 200;  // Set medium speed
	MOVLW      200
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,264 :: 		} else if (D1 < 50) {
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
;BicycleSafetyProject.c,265 :: 		PORTB |= 0x40;   // Maintain motor 1
	BSF        PORTB+0, 6
;BicycleSafetyProject.c,266 :: 		mspeed1 = 175;  // Set low speed
	MOVLW      175
	MOVWF      _mspeed1+0
;BicycleSafetyProject.c,267 :: 		} else {
	GOTO       L_main33
L_main32:
;BicycleSafetyProject.c,268 :: 		PORTB &= 0xBF;   // Turn off motor 1
	MOVLW      191
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,269 :: 		mspeed1 = 0;     // Stop motor
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,270 :: 		}
L_main33:
L_main31:
L_main29:
;BicycleSafetyProject.c,271 :: 		D1read = 0x00;       // Clear read flag for sensor 1
	CLRF       _D1read+0
;BicycleSafetyProject.c,272 :: 		}
L_main27:
;BicycleSafetyProject.c,275 :: 		if (D2read & 0x01) {
	BTFSS      _D2read+0, 0
	GOTO       L_main34
;BicycleSafetyProject.c,276 :: 		if (D2 < 10) {
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
;BicycleSafetyProject.c,277 :: 		mspeed2 = 250;  // Set high speed
	MOVLW      250
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,278 :: 		PORTC |= 0x08; // Turn on motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,279 :: 		} else if (D2 < 30) {
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
;BicycleSafetyProject.c,280 :: 		mspeed2 = 120;  // Set medium speed
	MOVLW      120
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,281 :: 		PORTC |= 0x08; // Maintain motor 2
	BSF        PORTC+0, 3
;BicycleSafetyProject.c,282 :: 		} else if (D2 < 50) {
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
;BicycleSafetyProject.c,283 :: 		mspeed2 = 60;   // Set low speed
	MOVLW      60
	MOVWF      _mspeed2+0
;BicycleSafetyProject.c,284 :: 		PORTC |= 0x808; // Maintain motor 2
	MOVLW      8
	IORWF      PORTC+0, 1
;BicycleSafetyProject.c,285 :: 		} else {
	GOTO       L_main40
L_main39:
;BicycleSafetyProject.c,286 :: 		mspeed2 = 0;    // Stop motor
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,287 :: 		PORTC &= ~0x08; // Turn off motor 2
	BCF        PORTC+0, 3
;BicycleSafetyProject.c,288 :: 		}
L_main40:
L_main38:
L_main36:
;BicycleSafetyProject.c,289 :: 		D2read = 0x00;       // Clear read flag for sensor 2
	CLRF       _D2read+0
;BicycleSafetyProject.c,290 :: 		}
L_main34:
;BicycleSafetyProject.c,291 :: 		motor1();               // Update motor 1
	CALL       _motor1+0
;BicycleSafetyProject.c,292 :: 		motor2();               // Update motor 2
	CALL       _motor2+0
;BicycleSafetyProject.c,293 :: 		}
L_main26:
;BicycleSafetyProject.c,295 :: 		if(servo_flag){
	MOVF       _servo_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main41
;BicycleSafetyProject.c,296 :: 		sonar_e = 0;         // disable sonar read
	CLRF       _sonar_e+0
;BicycleSafetyProject.c,297 :: 		mspeed1 = 0;
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,298 :: 		mspeed2 = 0;
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,299 :: 		if(angle == 4000){
	MOVF       _angle+1, 0
	XORLW      15
	BTFSS      STATUS+0, 2
	GOTO       L__main84
	MOVLW      160
	XORWF      _angle+0, 0
L__main84:
	BTFSS      STATUS+0, 2
	GOTO       L_main42
;BicycleSafetyProject.c,300 :: 		angle = 2000;
	MOVLW      208
	MOVWF      _angle+0
	MOVLW      7
	MOVWF      _angle+1
;BicycleSafetyProject.c,301 :: 		} else if(angle == 2000) {
	GOTO       L_main43
L_main42:
	MOVF       _angle+1, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L__main85
	MOVLW      208
	XORWF      _angle+0, 0
L__main85:
	BTFSS      STATUS+0, 2
	GOTO       L_main44
;BicycleSafetyProject.c,302 :: 		angle = 4000;
	MOVLW      160
	MOVWF      _angle+0
	MOVLW      15
	MOVWF      _angle+1
;BicycleSafetyProject.c,303 :: 		}
L_main44:
L_main43:
;BicycleSafetyProject.c,304 :: 		CCP2CON =0x08;
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,305 :: 		T1CON = 0x01;              //change tmr1 prescaler to 1:1
	MOVLW      1
	MOVWF      T1CON+0
;BicycleSafetyProject.c,306 :: 		PIE2 |= 0x01;
	BSF        PIE2+0, 0
;BicycleSafetyProject.c,308 :: 		msDelay(5000);             // delay 5 seconds
	MOVLW      136
	MOVWF      FARG_msDelay+0
	MOVLW      19
	MOVWF      FARG_msDelay+1
	CALL       _msDelay+0
;BicycleSafetyProject.c,309 :: 		servo_flag = 0;            //disable sonar flag
	CLRF       _servo_flag+0
;BicycleSafetyProject.c,310 :: 		sonar_e = 1;               // enable sonar read
	MOVLW      1
	MOVWF      _sonar_e+0
;BicycleSafetyProject.c,311 :: 		}
L_main41:
;BicycleSafetyProject.c,312 :: 		}
	GOTO       L_main24
;BicycleSafetyProject.c,313 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_port_init:

;BicycleSafetyProject.c,315 :: 		void port_init(void){
;BicycleSafetyProject.c,316 :: 		TRISA = 0x0F;                 // Configure RA4 RA5 RA6 RA7 as output
	MOVLW      15
	MOVWF      TRISA+0
;BicycleSafetyProject.c,317 :: 		PORTA = 0x00;                 // Initialize PORTA to LOW
	CLRF       PORTA+0
;BicycleSafetyProject.c,318 :: 		TRISB = 0x00;                 // Configure RB0, RB4, RB5, RB6 as inputs
	CLRF       TRISB+0
;BicycleSafetyProject.c,319 :: 		PORTB = 0x00;                 // Initialize PORTB to LOW
	CLRF       PORTB+0
;BicycleSafetyProject.c,320 :: 		TRISC = 0x50;                 // Configure RC6 and RC4 as input                                                         v
	MOVLW      80
	MOVWF      TRISC+0
;BicycleSafetyProject.c,321 :: 		PORTC = 0x00;                 // Initialize PORTC to LOW
	CLRF       PORTC+0
;BicycleSafetyProject.c,322 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;BicycleSafetyProject.c,323 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;BicycleSafetyProject.c,324 :: 		TRISE = 0x0F;
	MOVLW      15
	MOVWF      TRISE+0
;BicycleSafetyProject.c,325 :: 		PORTE = 0x00;
	CLRF       PORTE+0
;BicycleSafetyProject.c,326 :: 		}
L_end_port_init:
	RETURN
; end of _port_init

_ATD_init:

;BicycleSafetyProject.c,328 :: 		void ATD_init(void) {
;BicycleSafetyProject.c,329 :: 		ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,330 :: 		ADCON1 = 0xC4;             // AN0, AN1, AN3 analog channels; 500 KHz, right justified
	MOVLW      196
	MOVWF      ADCON1+0
;BicycleSafetyProject.c,331 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;BicycleSafetyProject.c,334 :: 		unsigned int ATD_read0(void) {
;BicycleSafetyProject.c,335 :: 		ADCON0 &= 0xC7;            // Select channel 0
	MOVLW      199
	ANDWF      ADCON0+0, 1
;BicycleSafetyProject.c,336 :: 		usDelay(10);               // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,337 :: 		ADCON0 |= 0x04;            // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,338 :: 		while (ADCON0 & 0x04);     // Wait for conversion to complete
L_ATD_read045:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read046
	GOTO       L_ATD_read045
L_ATD_read046:
;BicycleSafetyProject.c,339 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,340 :: 		}
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;BicycleSafetyProject.c,343 :: 		unsigned int ATD_read1(void) {
;BicycleSafetyProject.c,344 :: 		ADCON0 = (ADCON0 & 0xCF) | 0x08;  // Select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,345 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,346 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,347 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read147:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read148
	GOTO       L_ATD_read147
L_ATD_read148:
;BicycleSafetyProject.c,348 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,349 :: 		}
L_end_ATD_read1:
	RETURN
; end of _ATD_read1

_ATD_read2:

;BicycleSafetyProject.c,352 :: 		unsigned int ATD_read2(void) {
;BicycleSafetyProject.c,353 :: 		ADCON0 = (ADCON0 & 0xDF) | 0x18;  // Select channel 3
	MOVLW      223
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      24
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;BicycleSafetyProject.c,354 :: 		usDelay(10);                      // Stabilize ADC input
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,355 :: 		ADCON0 |= 0x04;                   // Start ADC conversion
	BSF        ADCON0+0, 2
;BicycleSafetyProject.c,356 :: 		while (ADCON0 & 0x04);            // Wait for conversion to complete
L_ATD_read249:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read250
	GOTO       L_ATD_read249
L_ATD_read250:
;BicycleSafetyProject.c,357 :: 		return ((ADRESH << 8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;BicycleSafetyProject.c,358 :: 		}
L_end_ATD_read2:
	RETURN
; end of _ATD_read2

_sonar_init:

;BicycleSafetyProject.c,361 :: 		void sonar_init(void) {
;BicycleSafetyProject.c,362 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,363 :: 		T1counts = 0;
	CLRF       _T1counts+0
	CLRF       _T1counts+1
	CLRF       _T1counts+2
	CLRF       _T1counts+3
;BicycleSafetyProject.c,364 :: 		T1time = 0;
	CLRF       _T1time+0
	CLRF       _T1time+1
	CLRF       _T1time+2
	CLRF       _T1time+3
;BicycleSafetyProject.c,365 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,366 :: 		T2counts = 0;
	CLRF       _T2counts+0
	CLRF       _T2counts+1
	CLRF       _T2counts+2
	CLRF       _T2counts+3
;BicycleSafetyProject.c,367 :: 		T2time = 0;
	CLRF       _T2time+0
	CLRF       _T2time+1
	CLRF       _T2time+2
	CLRF       _T2time+3
;BicycleSafetyProject.c,368 :: 		D1read = 0;
	CLRF       _D1read+0
;BicycleSafetyProject.c,369 :: 		D2read = 0;
	CLRF       _D2read+0
;BicycleSafetyProject.c,370 :: 		D1 = 0;
	CLRF       _D1+0
	CLRF       _D1+1
	CLRF       _D1+2
	CLRF       _D1+3
;BicycleSafetyProject.c,371 :: 		D2 = 0;
	CLRF       _D2+0
	CLRF       _D2+1
	CLRF       _D2+2
	CLRF       _D2+3
;BicycleSafetyProject.c,372 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,373 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,374 :: 		PIE1 |= 0x01;               // Enable TMR1 Overflow interrupt
	BSF        PIE1+0, 0
;BicycleSafetyProject.c,375 :: 		T1CON = 0x18;               // TMR1 OFF, Fosc/4 (1uS increments) with 1:2 prescaler
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,376 :: 		}
L_end_sonar_init:
	RETURN
; end of _sonar_init

_sonar_read1:

;BicycleSafetyProject.c,379 :: 		void sonar_read1(void) {
;BicycleSafetyProject.c,380 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;BicycleSafetyProject.c,381 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,382 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,383 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,385 :: 		PORTC |= 0x80;                    // Trigger ultrasonic sensor 1 (RC7 connected to trigger)
	BSF        PORTC+0, 7
;BicycleSafetyProject.c,386 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,387 :: 		PORTC &= 0x7F;                    // Remove trigger
	MOVLW      127
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,389 :: 		while (!(PORTC & 0x40));          // Wait for echo to start
L_sonar_read151:
	BTFSC      PORTC+0, 6
	GOTO       L_sonar_read152
	GOTO       L_sonar_read151
L_sonar_read152:
;BicycleSafetyProject.c,390 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,391 :: 		while (PORTC & 0x40);             // Wait for echo to end
L_sonar_read153:
	BTFSS      PORTC+0, 6
	GOTO       L_sonar_read154
	GOTO       L_sonar_read153
L_sonar_read154:
;BicycleSafetyProject.c,392 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,394 :: 		T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
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
;BicycleSafetyProject.c,395 :: 		T1time = T1counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T1time+0
	MOVF       R0+1, 0
	MOVWF      _T1time+1
	MOVF       R0+2, 0
	MOVWF      _T1time+2
	MOVF       R0+3, 0
	MOVWF      _T1time+3
;BicycleSafetyProject.c,396 :: 		D1 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,397 :: 		D1read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D1read+0
;BicycleSafetyProject.c,398 :: 		}
L_end_sonar_read1:
	RETURN
; end of _sonar_read1

_sonar_read2:

;BicycleSafetyProject.c,401 :: 		void sonar_read2(void) {
;BicycleSafetyProject.c,402 :: 		T2overflow = 0;
	CLRF       _T2overflow+0
	CLRF       _T2overflow+1
;BicycleSafetyProject.c,403 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;BicycleSafetyProject.c,404 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;BicycleSafetyProject.c,405 :: 		T1CON = 0x18;
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,407 :: 		PORTC |= 0x20;                    // Trigger ultrasonic sensor 2 (RC5 connected to trigger)
	BSF        PORTC+0, 5
;BicycleSafetyProject.c,408 :: 		usDelay(10);                      // Keep trigger for 10uS
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;BicycleSafetyProject.c,409 :: 		PORTC &= 0xDF;                    // Remove trigger
	MOVLW      223
	ANDWF      PORTC+0, 1
;BicycleSafetyProject.c,411 :: 		while (!(PORTC & 0x10));          // Wait for echo to start
L_sonar_read255:
	BTFSC      PORTC+0, 4
	GOTO       L_sonar_read256
	GOTO       L_sonar_read255
L_sonar_read256:
;BicycleSafetyProject.c,412 :: 		T1CON = 0x19;                     // TMR1 ON
	MOVLW      25
	MOVWF      T1CON+0
;BicycleSafetyProject.c,413 :: 		while (PORTC & 0x10);             // Wait for echo to end
L_sonar_read257:
	BTFSS      PORTC+0, 4
	GOTO       L_sonar_read258
	GOTO       L_sonar_read257
L_sonar_read258:
;BicycleSafetyProject.c,414 :: 		T1CON = 0x18;                     // TMR1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;BicycleSafetyProject.c,416 :: 		T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
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
;BicycleSafetyProject.c,417 :: 		T2time = T2counts;                // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T2time+0
	MOVF       R0+1, 0
	MOVWF      _T2time+1
	MOVF       R0+2, 0
	MOVWF      _T2time+2
	MOVF       R0+3, 0
	MOVWF      _T2time+3
;BicycleSafetyProject.c,418 :: 		D2 = ((T2time * 34) / 1000) / 2;  // Calculate distance in cm
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
;BicycleSafetyProject.c,419 :: 		D2read = 0x01;                    // Set read flag
	MOVLW      1
	MOVWF      _D2read+0
;BicycleSafetyProject.c,420 :: 		}
L_end_sonar_read2:
	RETURN
; end of _sonar_read2

_CCPPWM_init:

;BicycleSafetyProject.c,423 :: 		void CCPPWM_init(void) {
;BicycleSafetyProject.c,424 :: 		T2CON = 0x07;                    // Enable Timer2 with 1:16 prescaler
	MOVLW      7
	MOVWF      T2CON+0
;BicycleSafetyProject.c,425 :: 		CCP1CON = 0x0C;                  // Enable PWM for CCP1
	MOVLW      12
	MOVWF      CCP1CON+0
;BicycleSafetyProject.c,426 :: 		PR2 = 250;                       // Set Timer2 period
	MOVLW      250
	MOVWF      PR2+0
;BicycleSafetyProject.c,427 :: 		CCPR1L = 125;                    // Initial duty cycle for CCP1 (50%)
	MOVLW      125
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,429 :: 		mspeed1 = 0;
	CLRF       _mspeed1+0
;BicycleSafetyProject.c,430 :: 		mspeed2 = 0;
	CLRF       _mspeed2+0
;BicycleSafetyProject.c,431 :: 		period = 0;
	CLRF       _period+0
	CLRF       _period+1
;BicycleSafetyProject.c,432 :: 		duty = 0;
	CLRF       _duty+0
	CLRF       _duty+1
;BicycleSafetyProject.c,433 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_CCPcompare_init:

;BicycleSafetyProject.c,435 :: 		void CCPcompare_init(void){
;BicycleSafetyProject.c,436 :: 		HL = 1; //start high
	MOVLW      1
	MOVWF      _HL+0
;BicycleSafetyProject.c,437 :: 		CCP2CON = 0x08;//
	MOVLW      8
	MOVWF      CCP2CON+0
;BicycleSafetyProject.c,438 :: 		CCPR2H=2000>>8;
	MOVLW      7
	MOVWF      CCPR2H+0
;BicycleSafetyProject.c,439 :: 		CCPR2L=2000;
	MOVLW      208
	MOVWF      CCPR2L+0
;BicycleSafetyProject.c,440 :: 		}
L_end_CCPcompare_init:
	RETURN
; end of _CCPcompare_init

_motor1:

;BicycleSafetyProject.c,442 :: 		void motor1(void) {
;BicycleSafetyProject.c,443 :: 		CCPR1L = mspeed1;                // Set PWM duty cycle for motor 1
	MOVF       _mspeed1+0, 0
	MOVWF      CCPR1L+0
;BicycleSafetyProject.c,444 :: 		}
L_end_motor1:
	RETURN
; end of _motor1

_motor2:

;BicycleSafetyProject.c,447 :: 		void motor2(void) {
;BicycleSafetyProject.c,448 :: 		PORTB |= 0x80;                       //High
	BSF        PORTB+0, 7
;BicycleSafetyProject.c,449 :: 		PWMusDelay(mspeed2*2);
	MOVF       _mspeed2+0, 0
	MOVWF      FARG_PWMusDelay+0
	CLRF       FARG_PWMusDelay+1
	RLF        FARG_PWMusDelay+0, 1
	RLF        FARG_PWMusDelay+1, 1
	BCF        FARG_PWMusDelay+0, 0
	CALL       _PWMusDelay+0
;BicycleSafetyProject.c,450 :: 		PORTB &= 0x7F;                       //Low
	MOVLW      127
	ANDWF      PORTB+0, 1
;BicycleSafetyProject.c,451 :: 		PWMusDelay((250-mspeed2)*2);
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
;BicycleSafetyProject.c,452 :: 		}
L_end_motor2:
	RETURN
; end of _motor2

_usDelay:

;BicycleSafetyProject.c,455 :: 		void usDelay(unsigned int usCnt) {
;BicycleSafetyProject.c,457 :: 		for (us = 0; us < usCnt; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_usDelay59:
	MOVF       FARG_usDelay_usCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__usDelay99
	MOVF       FARG_usDelay_usCnt+0, 0
	SUBWF      R1+0, 0
L__usDelay99:
	BTFSC      STATUS+0, 0
	GOTO       L_usDelay60
;BicycleSafetyProject.c,458 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,459 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,457 :: 		for (us = 0; us < usCnt; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,460 :: 		}
	GOTO       L_usDelay59
L_usDelay60:
;BicycleSafetyProject.c,461 :: 		}
L_end_usDelay:
	RETURN
; end of _usDelay

_PWMusDelay:

;BicycleSafetyProject.c,463 :: 		void PWMusDelay(unsigned int PWMusCnt) {
;BicycleSafetyProject.c,465 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	CLRF       R1+0
	CLRF       R1+1
L_PWMusDelay62:
	MOVF       FARG_PWMusDelay_PWMusCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__PWMusDelay101
	MOVF       FARG_PWMusDelay_PWMusCnt+0, 0
	SUBWF      R1+0, 0
L__PWMusDelay101:
	BTFSC      STATUS+0, 0
	GOTO       L_PWMusDelay63
;BicycleSafetyProject.c,466 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,467 :: 		asm NOP;                     // 0.5 uS
	NOP
;BicycleSafetyProject.c,465 :: 		for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,468 :: 		}
	GOTO       L_PWMusDelay62
L_PWMusDelay63:
;BicycleSafetyProject.c,469 :: 		}
L_end_PWMusDelay:
	RETURN
; end of _PWMusDelay

_msDelay:

;BicycleSafetyProject.c,471 :: 		void msDelay(unsigned int msCnt) {
;BicycleSafetyProject.c,473 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R1+0
	CLRF       R1+1
L_msDelay65:
	MOVF       FARG_msDelay_msCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay103
	MOVF       FARG_msDelay_msCnt+0, 0
	SUBWF      R1+0, 0
L__msDelay103:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay66
;BicycleSafetyProject.c,474 :: 		for (cc = 0; cc < 155; cc++); // 1ms
	CLRF       R3+0
	CLRF       R3+1
L_msDelay68:
	MOVLW      0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay104
	MOVLW      155
	SUBWF      R3+0, 0
L__msDelay104:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay69
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
	GOTO       L_msDelay68
L_msDelay69:
;BicycleSafetyProject.c,473 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;BicycleSafetyProject.c,475 :: 		}
	GOTO       L_msDelay65
L_msDelay66:
;BicycleSafetyProject.c,476 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay

_display_speed:

;BicycleSafetyProject.c,479 :: 		void display_speed(unsigned int speed) {
;BicycleSafetyProject.c,483 :: 		unsigned long int integer_part = speed / 100;  // Integer part of speed
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FARG_display_speed_speed+0, 0
	MOVWF      R0+0
	MOVF       FARG_display_speed_speed+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      display_speed_integer_part_L0+0
	MOVF       R0+1, 0
	MOVWF      display_speed_integer_part_L0+1
	CLRF       display_speed_integer_part_L0+2
	CLRF       display_speed_integer_part_L0+3
;BicycleSafetyProject.c,484 :: 		unsigned long int decimal_part = speed % 100; // Decimal part of speed
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       FARG_display_speed_speed+0, 0
	MOVWF      R0+0
	MOVF       FARG_display_speed_speed+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      display_speed_decimal_part_L0+0
	MOVF       R0+1, 0
	MOVWF      display_speed_decimal_part_L0+1
	CLRF       display_speed_decimal_part_L0+2
	CLRF       display_speed_decimal_part_L0+3
;BicycleSafetyProject.c,487 :: 		buffer[0] = (integer_part) + '0'; // Units digit
	MOVLW      48
	ADDWF      display_speed_integer_part_L0+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      display_speed_buffer_L0+0
;BicycleSafetyProject.c,488 :: 		buffer[1] = '.';                  // Decimal point
	MOVLW      46
	MOVWF      display_speed_buffer_L0+1
;BicycleSafetyProject.c,491 :: 		buffer[2] = (decimal_part / 10) + '0'; // Tenths digit
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	MOVF       display_speed_decimal_part_L0+0, 0
	MOVWF      R0+0
	MOVF       display_speed_decimal_part_L0+1, 0
	MOVWF      R0+1
	MOVF       display_speed_decimal_part_L0+2, 0
	MOVWF      R0+2
	MOVF       display_speed_decimal_part_L0+3, 0
	MOVWF      R0+3
	CALL       _Div_32x32_U+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      display_speed_buffer_L0+2
;BicycleSafetyProject.c,492 :: 		buffer[3] = (decimal_part % 10) + '0'; // Hundredths digit
	MOVLW      10
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	MOVF       display_speed_decimal_part_L0+0, 0
	MOVWF      R0+0
	MOVF       display_speed_decimal_part_L0+1, 0
	MOVWF      R0+1
	MOVF       display_speed_decimal_part_L0+2, 0
	MOVWF      R0+2
	MOVF       display_speed_decimal_part_L0+3, 0
	MOVWF      R0+3
	CALL       _Div_32x32_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R8+2, 0
	MOVWF      R0+2
	MOVF       R8+3, 0
	MOVWF      R0+3
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      display_speed_buffer_L0+3
;BicycleSafetyProject.c,493 :: 		buffer[4] = '\0';                      // Null terminator for string
	CLRF       display_speed_buffer_L0+4
;BicycleSafetyProject.c,496 :: 		Lcd_Out(2, 8, buffer); // Display speed at row 2, column 8
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      display_speed_buffer_L0+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;BicycleSafetyProject.c,497 :: 		}
L_end_display_speed:
	RETURN
; end of _display_speed
