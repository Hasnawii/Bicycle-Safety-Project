#line 1 "C:/Users/Hasnawi/Desktop/Uni/Y4S1/Embedded Systems/Project/Final Design/Bicycle-Safety-Project/Source_code/BicycleSafety.c"

unsigned char tick;
unsigned char tick1;
unsigned char tick2;
unsigned char tick3;
unsigned char tick4;
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
unsigned long int dis;
unsigned int v;


void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);
unsigned int ATD_read2(void);


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


 dis = (unsigned long int)(314 * 35 * pulse) / 2;




 v = dis / 700;



 pulse = 0;
 }

 INTCON &= 0xFB;
 }
}

void main() {

 TRISB = 0xF1;
 PORTB = 0x00;


 ATD_init();


 OPTION_REG = 0x07;
 INTCON = 0xF8;
 TMR0 = 0;


 tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;


 while (1) {

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
 delay_us(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}


unsigned int ATD_read1(void) {
 ADCON0 = (ADCON0 & 0xCF) | 0x08;
 delay_us(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}


unsigned int ATD_read2(void) {
 ADCON0 = (ADCON0 & 0xD7) | 0x10;
 delay_us(10);
 ADCON0 |= 0x04;
 while (ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}
