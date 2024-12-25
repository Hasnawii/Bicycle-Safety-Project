unsigned char tick;
void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);
unsigned int flexA0;
unsigned int flexA1;
unsigned int flexD0;
unsigned int flexD1;

interrupt(){ // TMR0 overflow interrupt occurs every 32ms
tick++; //increment tick evey 32ms
if(tick==8){ // this condition is true every almost 256 ms
  tick=0;
  flexA0 = ATD_read0();
  flexD0 = (unsigned int)(flexA0*50)/1023;
  delay_ms(100);
  flexA1 = ATD_read1();
  flexD1 = (unsigned int)(flexA1*50)/1023;
  if((flexD0>34)||(flexD1>34)){
   PORTB = PORTB | 0x01;
  } else PORTB = PORTB & 0xFE;
   }
INTCON = INTCON & 0xFB; // clear the interrupt flag
}
void main() {
  TRISB = 0x00;
  PORTB = 0x00;
  ATD_init();
  OPTION_REG = 0x07; // Osc clock/4, prescale of 256
  INTCON = 0xA0; // Global Interrupt Enable and Local Enable the TMR0 Overflow Interrupt
  TMR0 = 0;
  while(1){

  }
 }
void ATD_init(void){
 ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
 ADCON1 = 0xC0;// all analog channels, 500 KHz, right justified
 TRISA = 0xFF; }
unsigned int ATD_read0(void){
  ADCON0 = ADCON0 &  0xC7;
  delay_us(10);
  ADCON0 = ADCON0 | 0x04;// GO
  while(ADCON0 & 0x04);
  return((ADRESH<<8) | ADRESL); }
unsigned int ATD_read1(void){
  ADCON0 = (ADCON0 &  0xCF)|0x08; // select channel 1
  delay_us(10);
  ADCON0 = ADCON0 | 0x04;// GO
  while(ADCON0 & 0x04);
  return((ADRESH<<8) | ADRESL); }