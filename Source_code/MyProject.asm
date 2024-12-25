
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,9 :: 		interrupt(){ // TMR0 overflow interrupt occurs every 32ms
;MyProject.c,10 :: 		tick++; //increment tick evey 32ms
	INCF       _tick+0, 1
;MyProject.c,11 :: 		if(tick==8){ // this condition is true every almost 256 ms
	MOVF       _tick+0, 0
	XORLW      8
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt0
;MyProject.c,12 :: 		tick=0;
	CLRF       _tick+0
;MyProject.c,13 :: 		flexA0 = ATD_read0();
	CALL       _ATD_read0+0
	MOVF       R0+0, 0
	MOVWF      _flexA0+0
	MOVF       R0+1, 0
	MOVWF      _flexA0+1
;MyProject.c,14 :: 		flexD0 = (unsigned int)(flexA0*50)/1023;
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
;MyProject.c,15 :: 		delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_interrupt1:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt1
	DECFSZ     R12+0, 1
	GOTO       L_interrupt1
	DECFSZ     R11+0, 1
	GOTO       L_interrupt1
	NOP
;MyProject.c,16 :: 		flexA1 = ATD_read1();
	CALL       _ATD_read1+0
	MOVF       R0+0, 0
	MOVWF      _flexA1+0
	MOVF       R0+1, 0
	MOVWF      _flexA1+1
;MyProject.c,17 :: 		flexD1 = (unsigned int)(flexA1*50)/1023;
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
;MyProject.c,18 :: 		if((flexD0>34)||(flexD1>34)){
	MOVF       _flexD0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt17
	MOVF       _flexD0+0, 0
	SUBLW      34
L__interrupt17:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt14
	MOVF       _flexD1+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt18
	MOVF       _flexD1+0, 0
	SUBLW      34
L__interrupt18:
	BTFSS      STATUS+0, 0
	GOTO       L__interrupt14
	GOTO       L_interrupt4
L__interrupt14:
;MyProject.c,19 :: 		PORTB = PORTB | 0x01;
	BSF        PORTB+0, 0
;MyProject.c,20 :: 		} else PORTB = PORTB & 0xFE;
	GOTO       L_interrupt5
L_interrupt4:
	MOVLW      254
	ANDWF      PORTB+0, 1
L_interrupt5:
;MyProject.c,21 :: 		}
L_interrupt0:
;MyProject.c,22 :: 		INTCON = INTCON & 0xFB; // clear the interrupt flag
	MOVLW      251
	ANDWF      INTCON+0, 1
;MyProject.c,23 :: 		}
L_end_interrupt:
L__interrupt16:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;MyProject.c,24 :: 		void main() {
;MyProject.c,25 :: 		TRISB = 0x00;
	CLRF       TRISB+0
;MyProject.c,26 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;MyProject.c,27 :: 		ATD_init();
	CALL       _ATD_init+0
;MyProject.c,28 :: 		OPTION_REG = 0x07; // Osc clock/4, prescale of 256
	MOVLW      7
	MOVWF      OPTION_REG+0
;MyProject.c,29 :: 		INTCON = 0xA0; // Global Interrupt Enable and Local Enable the TMR0 Overflow Interrupt
	MOVLW      160
	MOVWF      INTCON+0
;MyProject.c,30 :: 		TMR0 = 0;
	CLRF       TMR0+0
;MyProject.c,31 :: 		while(1){
L_main6:
;MyProject.c,33 :: 		}
	GOTO       L_main6
;MyProject.c,34 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_ATD_init:

;MyProject.c,35 :: 		void ATD_init(void){
;MyProject.c,36 :: 		ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;MyProject.c,37 :: 		ADCON1 = 0xC0;// all analog channels, 500 KHz, right justified
	MOVLW      192
	MOVWF      ADCON1+0
;MyProject.c,38 :: 		TRISA = 0xFF; }
	MOVLW      255
	MOVWF      TRISA+0
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read0:

;MyProject.c,39 :: 		unsigned int ATD_read0(void){
;MyProject.c,40 :: 		ADCON0 = ADCON0 &  0xC7;
	MOVLW      199
	ANDWF      ADCON0+0, 1
;MyProject.c,41 :: 		delay_us(10);
	MOVLW      6
	MOVWF      R13+0
L_ATD_read08:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read08
	NOP
;MyProject.c,42 :: 		ADCON0 = ADCON0 | 0x04;// GO
	BSF        ADCON0+0, 2
;MyProject.c,43 :: 		while(ADCON0 & 0x04);
L_ATD_read09:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read010
	GOTO       L_ATD_read09
L_ATD_read010:
;MyProject.c,44 :: 		return((ADRESH<<8) | ADRESL); }
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
L_end_ATD_read0:
	RETURN
; end of _ATD_read0

_ATD_read1:

;MyProject.c,45 :: 		unsigned int ATD_read1(void){
;MyProject.c,46 :: 		ADCON0 = (ADCON0 &  0xCF)|0x08; // select channel 1
	MOVLW      207
	ANDWF      ADCON0+0, 0
	MOVWF      R0+0
	MOVLW      8
	IORWF      R0+0, 0
	MOVWF      ADCON0+0
;MyProject.c,47 :: 		delay_us(10);
	MOVLW      6
	MOVWF      R13+0
L_ATD_read111:
	DECFSZ     R13+0, 1
	GOTO       L_ATD_read111
	NOP
;MyProject.c,48 :: 		ADCON0 = ADCON0 | 0x04;// GO
	BSF        ADCON0+0, 2
;MyProject.c,49 :: 		while(ADCON0 & 0x04);
L_ATD_read112:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read113
	GOTO       L_ATD_read112
L_ATD_read113:
;MyProject.c,50 :: 		return((ADRESH<<8) | ADRESL); }
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
L_end_ATD_read1:
	RETURN
; end of _ATD_read1
