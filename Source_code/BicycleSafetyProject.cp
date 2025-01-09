#line 1 "C:/Users/Hasnawi/Desktop/Uni/Y4S1/Embedded Systems/Project/Final Design/Bicycle-Safety-Project/Source_code/BicycleSafetyProject.c"

unsigned char tick;
unsigned char tick1;
unsigned char tick2;
unsigned char tick3;
unsigned char tick4;
unsigned char tick5;
unsigned char ticka;
unsigned char tickb;
unsigned char rturn;
unsigned char lturn;
unsigned int flexA0;
unsigned int flexA1;
unsigned int flexD0;
unsigned int flexD1;
unsigned int hallA2;
unsigned int hallD2;
unsigned int pulse;
unsigned long dis;
unsigned long v;
unsigned int T1overflow;
unsigned long T1counts;
unsigned long T1time;
unsigned int T2overflow;
unsigned long T2counts;
unsigned long T2time;
unsigned long D1;
unsigned long D2;
unsigned char mspeed1;
unsigned char mspeed2;
unsigned char D1read;
unsigned char D2read;
unsigned int period, duty;
unsigned char HL;
unsigned int angle;
unsigned char sonar_e;
unsigned char servo_e;


void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);
unsigned int ATD_read2(void);
void usDelay(unsigned int);
void msDelay(unsigned int);
void sonar_init(void);
void sonar_read1(void);
void sonar_read2(void);
void CCPPWM_init(void);
void CCPcompare_init(void);
void motor1(void);
void motor2(void);
void PWMusDelay(unsigned int);


void interrupt() {


 if (INTCON&0x02){
 if (!(PORTB & 0x01)) {
 sonar_e = 0;
 servo_e = 1;

 }
 INTCON=INTCON&0xFD;
 }



 if (INTCON & 0x01) {
 if (!(PORTB & 0x10)) {
 PORTB |= 0x04;
 rturn = 1;
 }
 if (!(PORTB & 0x20)) {
 PORTB |= 0x08;
 lturn = 1;
 }
 INTCON &= 0xFE;
 }


 if (INTCON & 0x04) {
 tick++;
 tick3++;
 tick4++;
 tick5++;



 if (tick == 2) {
 tick = 0;


 flexA0 = ATD_read0();
 flexD0 = (unsigned int)(flexA0 * 50) / 1023;
 flexA1 = ATD_read1();
 flexD1 = (unsigned int)(flexA1 * 50) / 1023;


 if ((flexD0 > 34) || (flexD1 > 34)) {
 PORTB |= 0x02;
 } else {
 PORTB &= 0xFD;
 }
 }


 if (rturn == 1) {
 tick1++;
 ticka++;

 if (ticka == 15) {
 ticka = 0;
 PORTB ^= 0x04;
 }
 if (tick1 == 150) {
 tick1 = 0;
 rturn = 0;
 PORTB &= 0xFB;
 }
 }


 if (lturn == 1) {
 tick2++;
 tickb++;

 if (tickb == 15) {
 tickb = 0;
 PORTB ^= 0x08;
 }
 if (tick2 == 150) {
 tick2 = 0;
 lturn = 0;
 PORTB &= 0xF7;
 }
 }


 if (tick3 == 7) {
 tick3 = 0;


 hallA2 = ATD_read2();
 hallD2 = (unsigned int)(hallA2 * 50) / 1023;


 if (hallD2 > 10) {
 pulse++;
 }
 }


 if (tick4 == 219) {
 tick4 = 0;


 dis = (unsigned long)(314 * 35 * pulse) / 2;


 v = (unsigned long) dis / 700;


 pulse = 0;
 }


 if (sonar_e) {
 if (tick5 == 4) {
 tick5 = 0;
 sonar_read1();
 sonar_read2();
 }
 }

 INTCON &= 0xFB;
 }

 if (PIR1 & 0x01) {
 T1overflow++;
 T2overflow++;
 PIR1 &= 0xFE;
 }


 if (PIR2 & 0x01) {
 if(HL){
 CCPR2H= angle >>8;
 CCPR2L= angle;
 HL = 0;
 CCP2CON=0x09;
 TMR1H=0;
 TMR1L=0;
 } else {
 CCPR2H = (40000 - angle) >>8;
 CCPR2L = (40000 - angle);
 CCP2CON = 0x08;
 HL = 1;
 TMR1H = 0;
 TMR1L = 0;
 }

 PIR2 &= 0xFE;
 }
}


void main() {

 TRISA = 0x0F;
 PORTA = 0x00;
 TRISB = 0x31;
 PORTB = 0x00;
 TRISC = 0x50;
 PORTC = 0x00;

 ATD_init();
 sonar_init();
 CCPPWM_init();
 CCPcompare_init();


 OPTION_REG = 0x07;
 INTCON = 0xF8;
 TMR0 = 0;


 tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;


 while (1) {

 if (D1read & 0x01) {
 if (D1 < 10) {
 PORTB |= 0x40;
 mspeed1 = 250;
 } else if (D1 < 30) {
 PORTB |= 0x40;
 mspeed1 = 200;
 } else if (D1 < 50) {
 PORTB |= 0x40;
 mspeed1 = 175;
 } else {
 PORTB &= 0xBF;
 mspeed1 = 0;
 }
 D1read = 0x00;
 }


 if (D2read & 0x01) {
 if (D2 < 10) {
 mspeed2 = 250;
 PORTC |= 0x08;
 } else if (D2 < 30) {
 mspeed2 = 120;
 PORTC |= 0x08;
 } else if (D2 < 50) {
 mspeed2 = 60;
 PORTC |= 0x808;
 } else {
 mspeed2 = 0;
 PORTC &= ~0x08;
 }
 D2read = 0x00;
 }
 motor1();
 motor2();
 }
}


void ATD_init(void) {
 ADCON0 = 0x41;
 ADCON1 = 0xC4;
 TRISE = 0x07;
}


unsigned int ATD_read0(void) {
 ADCON0 &= 0xC7;
 usDelay(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}


unsigned int ATD_read1(void) {
 ADCON0 = (ADCON0 & 0xCF) | 0x08;
 usDelay(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}


unsigned int ATD_read2(void) {
 ADCON0 = (ADCON0 & 0xDF) | 0x18;
 usDelay(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}


void sonar_init(void) {
 T1overflow = 0;
 T1counts = 0;
 T1time = 0;
 T2overflow = 0;
 T2counts = 0;
 T2time = 0;
 D1read = 0;
 D2read = 0;
 D1 = 0;
 D2 = 0;
 TMR1H = 0;
 TMR1L = 0;
 PIE1 |= 0x01;
 T1CON = 0x18;
}


void sonar_read1(void) {
 T1overflow = 0;
 TMR1H = 0;
 TMR1L = 0;
 T1CON = 0x18;

 PORTC |= 0x80;
 usDelay(10);
 PORTC &= 0x7F;

 while (!(PORTC & 0x40));
 T1CON = 0x19;
 while (PORTC & 0x40);
 T1CON = 0x18;

 T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
 T1time = T1counts;
 D1 = ((T1time * 34) / 1000) / 2;
 D1read = 0x01;
}


void sonar_read2(void) {
 T2overflow = 0;
 TMR1H = 0;
 TMR1L = 0;
 T1CON = 0x18;

 PORTC |= 0x20;
 usDelay(10);
 PORTC &= 0xDF;

 while (!(PORTC & 0x10));
 T1CON = 0x19;
 while (PORTC & 0x10);
 T1CON = 0x18;

 T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
 T2time = T2counts;
 D2 = ((T2time * 34) / 1000) / 2;
 D2read = 0x01;
}


void CCPPWM_init(void) {
 T2CON = 0x07;
 CCP1CON = 0x0C;
 PR2 = 250;
 CCPR1L = 125;
 mspeed1 = 0;
 mspeed2 = 0;
 period = 0;
 duty = 0;
}

void CCPcompare_init(void){
 HL = 1;
 CCP2CON = 0x08;
 CCPR2H=2000>>8;
 CCPR2L=2000;
}

void motor1(void) {
 CCPR1L = mspeed1;
}


void motor2(void) {
 PORTB |= 0x80;
 PWMusDelay(mspeed2*2);
 PORTB &= 0x7F;
 PWMusDelay((250-mspeed2)*2);
}


void usDelay(unsigned int usCnt) {
 unsigned int us;
 for (us = 0; us < usCnt; us++) {
 asm NOP;
 asm NOP;
 }
}

void PWMusDelay(unsigned int PWMusCnt) {
 unsigned int PWMus;
 for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
 asm NOP;
 asm NOP;
 }
}

void msDelay(unsigned int msCnt) {
 unsigned int ms, cc;
 for (ms = 0; ms < msCnt; ms++) {
 for (cc = 0; cc < 155; cc++);
 }
}
