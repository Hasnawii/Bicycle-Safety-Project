#line 1 "C:/Users/Hasnawi/Desktop/Uni/Y4S1/Embedded Systems/Project/Final Design/Bicycle-Safety-Project/Source_code/BicycleSafetySystem.c"

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


void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);
unsigned int ATD_read2(void);
void usDelay(unsigned int);
void msDelay(unsigned int);
void sonar_init(void);
void sonar_read1(void);
void sonar_read2(void);


void interrupt() {

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


 if (tick5 == 7) {
 tick5 = 0;
 sonar_read1();
 sonar_read2();
 }

 INTCON &= 0xFB;
 }

 if (PIR1 & 0x01) {
 T1overflow++;
 T2overflow++;
 PIR1 &= 0xFE;
 }
}


void main() {

 TRISB = 0x71;
 PORTB = 0x00;
 TRISC = 0x40;
 PORTC = 0x00;


 ATD_init();
 sonar_init();


 OPTION_REG = 0x07;
 INTCON = 0xF8;
 TMR0 = 0;


 tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;


 while (1) {
 if (D1 < 20) {
 PORTC |= 0x0C;
 } else {
 PORTC &= 0xF3;
 }

 if (D2 < 20) {
 PORTC |= 0x30;
 } else {
 PORTC &= 0xCF;
 }
 }
}


void ATD_init(void) {
 ADCON0 = 0x41;
 ADCON1 = 0xC0;
 TRISA = 0xFF;
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
 ADCON0 = (ADCON0 & 0xD7) | 0x10;
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
 D1 = 0;
 D2 = 0;
 TMR1H = 0;
 TMR1L = 0;
 PIE1 = PIE1 | 0x01;
 T1CON = 0x18;
}


void sonar_read1(void) {
 T1overflow = 0;
 TMR1H = 0;
 TMR1L = 0;

 PORTB |= 0x80;
 usDelay(10);
 PORTB &= 0x7F;

 while (!(PORTB & 0x40));
 T1CON = 0x19;
 while (PORTB & 0x40);
 T1CON = 0x18;

 T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
 T1time = T1counts;
 D1 = ((T1time * 34) / 1000) / 2;
}

void sonar_read2(void) {
 T2overflow = 0;
 TMR1H = 0;
 TMR1L = 0;

 PORTC |= 0x80;
 usDelay(10);
 PORTC &= 0x7F;

 while (!(PORTC & 0x40));
 T1CON = 0x19;
 while (PORTC & 0x40);
 T1CON = 0x18;

 T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
 T2time = T2counts;
 D2 = ((T2time * 34) / 1000) / 2;
}


void usDelay(unsigned int usCnt) {
 unsigned int us;
 for (us = 0; us < usCnt; us++) {
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
