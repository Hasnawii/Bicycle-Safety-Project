#line 1 "C:/Users/Hasnawi/Desktop/Uni/Y4S1/Embedded Systems/Project/Final Design/Bicycle-Safety-Project/Source_code/MyProject.c"
unsigned char tick;
void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);
unsigned int flexA0;
unsigned int flexA1;
unsigned int flexD0;
unsigned int flexD1;

interrupt(){

if(INTCON & 0x04) {
 tick++;
 if(tick==2){
 tick=0;
 flexA0 = ATD_read0();
 flexD0 = (unsigned int)(flexA0*50)/1023;
 flexA1 = ATD_read1();
 flexD1 = (unsigned int)(flexA1*50)/1023;
 if((flexD0>34)||(flexD1>34)){
 PORTB = PORTB | 0x01;
 }
 else PORTB = PORTB & 0xFE;
 }
INTCON = INTCON & 0xFB;
}
}
void main() {
 TRISB = 0x00;
 PORTB = 0x00;
 ATD_init();
 OPTION_REG = 0x07;
 INTCON = 0xA0;
 TMR0 = 0;
 while(1){

 }
 }

void ATD_init(void){
 ADCON0 = 0x41;
 ADCON1 = 0xC0;
 TRISA = 0xFF;
 TRISE = 0x07;
 }

unsigned int ATD_read0(void){
 ADCON0 = ADCON0 & 0xC7;
 delay_us(10);
 ADCON0 = ADCON0 | 0x04;
 while(ADCON0 & 0x04);
 return((ADRESH<<8) | ADRESL);
 }

unsigned int ATD_read1(void){
 ADCON0 = (ADCON0 & 0xCF)|0x08;
 delay_us(10);
 ADCON0 = ADCON0 | 0x04;
 while(ADCON0 & 0x04);
 return((ADRESH<<8) | ADRESL);
 }
