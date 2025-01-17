// Lcd pinout settings
sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D7 at RB3_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D4 at RB0_bit;

// Pin direction
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D7_Direction at TRISB3_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D4_Direction at TRISB0_bit;

char txt1[] = "Speed:";
char txt2[] = "km/hr";

char txt[7];

// Global Variables
unsigned char tick;         // Timer0 interrupt counter, increments every 32ms
unsigned int tick1;        // Counter for right turn signal duration (~5 seconds)
unsigned int tick2;        // Counter for left turn signal duration (~5 seconds)
unsigned char tick3;        // Counter for hall sensor pulse detection (~224ms per increment)
unsigned int tick4;        // Counter for speed calculation interval (~7 seconds)
unsigned char tick5;        // Counter for ultrasonic sonar reading (~128ms interval)
unsigned char ticka;        // Counter for right turn signal blinking interval (~480ms)
unsigned char tickb;        // Counter for left turn signal blinking interval (~480ms)
unsigned char rturn;        // Right turn signal flag (1 = active, 0 = inactive)
unsigned char lturn;        // Left turn signal flag (1 = active, 0 = inactive)
unsigned int flexA0;        // Raw ADC value from channel AN0 (e.g., flex sensor)
unsigned int flexA1;        // Raw ADC value from channel AN1 (e.g., flex sensor)
unsigned int flexD0;        // Scaled ADC value from AN0 (percentage-like, 0-50)
unsigned int flexD1;        // Scaled ADC value from AN1 (percentage-like, 0-50)
unsigned int hallA2;        // Raw ADC value from channel AN3 (e.g., hall sensor)
unsigned int hallD2;        // Scaled ADC value from AN3 (percentage-like, 0-50)
unsigned int pulse;         // Count of hall sensor pulses (for speed/distance calculation)
unsigned int rpm;
unsigned int v;            // Speed in cm/s, scaled by 100 (actual speed = v / 100)
unsigned int T1overflow;    // Timer1 overflow count for ultrasonic sensor 1
unsigned long T1counts;     // Total Timer1 counts (32 bits) for ultrasonic sensor 1
unsigned long T1time;       // Echo time in microseconds for ultrasonic sensor 1
unsigned int T2overflow;    // Timer1 overflow count for ultrasonic sensor 2
unsigned long T2counts;     // Total Timer1 counts (32 bits) for ultrasonic sensor 2
unsigned long T2time;       // Echo time in microseconds for ultrasonic sensor 2
unsigned long D1;           // Calculated distance in cm for ultrasonic sensor 1
unsigned long D2;           // Calculated distance in cm for ultrasonic sensor 2
unsigned char mspeed1;      // Motor speed for motor 1
unsigned char mspeed2;      // Motor speed for motor 2
unsigned char D1read;       // Flag to indicate a new reading is available for sensor 1
unsigned char D2read;       // Flag to indicate a new reading is available for sensor 2
unsigned int period, duty;  // period in ms and duty cycle in ms
unsigned char HL;
unsigned int angle;
unsigned char sonar_e;
unsigned char servo_e;

char buffer[2];
unsigned int one;
unsigned int ten;
unsigned int tenth;

// Function Declarations
void port_init(void);
void ATD_init(void);            // Initialize ADC
unsigned int ATD_read0(void);   // Read ADC channel AN0
unsigned int ATD_read1(void);   // Read ADC channel AN1
unsigned int ATD_read2(void);   // Read ADC channel AN3
void usDelay(unsigned int);     // Microsecond delay function
void PWMusDelay(unsigned int);
void msDelay(unsigned int);     // Millisecond delay function
void sonar_init(void);          // Initialize ultrasonic sensors
void sonar_read1(void);         // Read ultrasonic sensor 1
void sonar_read2(void);         // Read ultrasonic sensor 2
void CCPPWM_init(void);         // Initialize CCP for PWM generation
void CCPcompare_init(void);
void motor1(void);              // Update motor 1 speed
void motor2(void);              // Update motor 2 speed


// Interrupt Service Routine
void interrupt() {

    // Timer0 Overflow Interrupt (Handles Timing Events)
    if (INTCON & 0x04) {
        tick++;                  // Increment Timer0 counter (~32ms per increment)
        tick3++;                 // Increment hall sensor pulse counter
        tick4++;                 // Increment speed calculation counter

        // ADC Sampling Logic (~64ms interval)
        if (tick == 2) {
            tick = 0;

            // Read ADC values for flex sensors
            flexA0 = ATD_read0();
            flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
            flexA1 = ATD_read1();
            flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading

            // Control RB1 (LED or actuator) based on flex sensor thresholds
            if ((flexD0 > 23) || (flexD1 > 22 )){
                PORTD |= 0x03;
            } else {
                PORTD &= 0xFC;
            }
        }

       if (!(PORTE & 0x01)) {   // Check if right turn button is pressed
            PORTD |= 0x04;      // Turn on RD2 (right turn signal)
            rturn = 1;          // Set right turn flag
        }
        if (!(PORTE & 0x02)) {   // Check if left turn button is pressed
            PORTD |= 0x08;      // Turn on RD2 (left turn signal)
            lturn = 1;          // Set left turn flag
        }

        if (!(PORTE & 0x04)) {             // if button is pressed
         servo_e = 1;                 // enable servo flag
        }

        // Right Turn Signal Logic
        if (rturn == 1) {
            tick1++;             // Increment right turn duration counter
            ticka++;             // Increment right turn blinking interval counter

            if (ticka == 7) {   // Toggle(right turn signal) every ~240ms
                ticka = 0;
                PORTD ^= 0x04;   // Toggle RD1
            }
            if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
                tick1 = 0;
                rturn = 0;
                PORTD &= 0xFB;   // Turn off RD1
            }
        }

        // Left Turn Signal Logic
        if (lturn == 1) {
            tick2++;             // Increment left turn duration counter
            tickb++;             // Increment left turn blinking interval counter

            if (tickb == 7) {   // Toggle (left turn signal) every ~240ms
                tickb = 0;
                PORTD ^= 0x08;   // Toggle RD2
            }
            if (tick2 == 150) {  // Stop left turn signal after  seconds
                tick2 = 0;
                lturn = 0;
                PORTD &= 0xF7;   // Turn off RD2
            }
        }
        if (PORTD & 0x10) {
           pulse++;
        }
        // Speed and Distance Calculation (~20 seconds)
        if (tick4 == 312) {
            tick4 = 0;
            rpm = (pulse*6)/4;
            v = rpm * 0.13;
            pulse = 0;
        }
        // Ultrasonic Sensor Trigger (~128ms interval)
        if (sonar_e) {
           tick5++;
           PIE2 &= 0xFE;   //disable CCP2 interrupt
           T1CON = 0x18;

           if (tick5 == 4) {
              tick5 = 0;
             sonar_read1();        // Trigger ultrasonic sensor 1 reading
             sonar_read2();        // Trigger ultrasonic sensor 2 reading
           }
        }

        INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
    }

    if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
        T1overflow++;
        T2overflow++;
        PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
    }

    //CCP2 interrupt
    if (PIR2 & 0x01) {
       if(HL){ //high
           CCPR2H= angle >>8;
           CCPR2L= angle;
           HL = 0;//next time low
           CCP2CON=0x09;//next time Falling edge
           TMR1H=0;
           TMR1L=0;
    } else {  //low
           CCPR2H = (40000 - angle) >>8;
           CCPR2L = (40000 - angle);
           CCP2CON = 0x08; //next time rising edge
           HL = 1; //next time High
           TMR1H = 0;
           TMR1L = 0;
     }
     PIR2 &= 0xFE;
    }
}

// Main Function
void main() {

    port_init();
    ATD_init();                  // Initialize ADC
    sonar_init();                // Initialize ultrasonic sensors
    CCPPWM_init();               // Initialize PWM for motors
    CCPcompare_init();

    // Initialize LCD
    Lcd_Init();
    Lcd_Cmd(_LCD_CLEAR);               // Clear display
    Lcd_Cmd(_LCD_CURSOR_OFF);          // Cursor off
    Lcd_Out(1, 5, "PSUT BSS");
    Lcd_Out(2, 1, txt1);
    Lcd_Out(2, 12, txt2);

    // Configure Timer0
    OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
    INTCON = 0xE0;               // Enable all interrupts
    TMR0 = 0;                    // Reset Timer0

    // Initialize Variables
    v = tick = tick1 = tick2 = tick3 = tick4 = tick5 = ticka = tickb = pulse = rpm = 0;
    servo_e = 0;
    sonar_e = 1;


    // Main Loop
    while (1) {
    // Update motor 1 speed based on ultrasonic sensor 1 reading
      if(sonar_e) {
        if (D1read & 0x01) {
            if (D1 < 10) {
                PORTD |= 0x40;  // Turn on motor 1
                mspeed1 = 250;  // Set high speed
            } else if (D1 < 30) {
                PORTD |= 0x40;   // Maintain motor 1
                mspeed1 = 200;  // Set medium speed
            } else if (D1 < 50) {
                PORTD |= 0x40;   // Maintain motor 1
                mspeed1 = 175;  // Set low speed
            } else {
                PORTD &= 0xBF;   // Turn off motor 1
                mspeed1 = 0;     // Stop motor
            }
            D1read = 0x00;       // Clear read flag for sensor 1
        }

        // Update motor 2 speed based on ultrasonic sensor 2 reading
        if (D2read & 0x01) {
            if (D2 < 10) {
                mspeed2 = 250;  // Set high speed
                PORTC |= 0x08; // Turn on motor 2
            } else if (D2 < 30) {
                mspeed2 = 120;  // Set medium speed
                PORTC |= 0x08; // Maintain motor 2
            } else if (D2 < 50) {
                mspeed2 = 60;   // Set low speed
                PORTC |= 0x808; // Maintain motor 2
            } else {
                mspeed2 = 0;    // Stop motor
                PORTC &= ~0x08; // Turn off motor 2
            }
            D2read = 0x00;       // Clear read flag for sensor 2
        }
        motor1();               // Update motor 1
        motor2();               // Update motor 2
    }
    if(servo_e){
            sonar_e = 0;         // disable sonar read
            mspeed1 = 0;
            mspeed2 = 0;
            if(angle == 2000){
                angle = 4000;
            } else if(angle == 4000) {
                angle = 2000;
            }
            CCP2CON =0x08;
            T1CON = 0x01;              //change tmr1 prescaler to 1:1
            PIE2 |= 0x01;

            msDelay(2000);             // delay 5 seconds
            servo_e = 0;            //disable sonar flag
            sonar_e = 1;               // enable sonar read
        }
    //ten = v/10;
    //one = v%10;
    sprintl(&buffer, "%d", v);
    Lcd_Out(2, 8, buffer);

    }
}

void port_init(void){
    TRISA = 0x0F;                 // Configure RA4 RA5 RA6 RA7 as output
    PORTA = 0x00;                 // Initialize PORTA to LOW
    TRISB = 0x00;                 // Configure RB0, RB4, RB5, RB6 as inputs
    PORTB = 0x00;                 // Initialize PORTB to LOW
    TRISC = 0x50;                 // Configure RC6 and RC4 as input                                                         v
    PORTC = 0x00;                 // Initialize PORTC to LOW
    TRISD = 0x10;
    PORTD = 0x00;
    TRISE = 0x0F;
    PORTE = 0x00;
}
// ADC Initialization
void ATD_init(void) {
    ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
    ADCON1 = 0xC4;             // AN0, AN1, AN3 analog channels; 500 KHz, right justified
}

// Read ADC value from channel 0
unsigned int ATD_read0(void) {
    ADCON0 &= 0xC7;            // Select channel 0
    usDelay(10);               // Stabilize ADC input
    ADCON0 |= 0x04;            // Start ADC conversion
    while (ADCON0 & 0x04);     // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL);
}

// Read ADC value from channel 1
unsigned int ATD_read1(void) {
    ADCON0 = (ADCON0 & 0xCF) | 0x08;  // Select channel 1
    usDelay(10);                      // Stabilize ADC input
    ADCON0 |= 0x04;                   // Start ADC conversion
    while (ADCON0 & 0x04);            // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL);
}

unsigned int ATD_read2 (void) {
    ADCON0 = (ADCON0 & 0xDF) | 0x18;  // Select channel 3
    usDelay(10);                      // Stabilize ADC input
    ADCON0 |= 0x04;                   // Start ADC conversion
    while (ADCON0 & 0x04);            // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL);
}

// Ultrasonic Sensor Initialization
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
    PIE1 |= 0x01;               // Enable TMR1 Overflow interrupt
    T1CON = 0x18;               // TMR1 OFF, Fosc/4 (1uS increments) with 1:2 prescaler
}

// Ultrasonic Sensor Reading for Sensor 1
void sonar_read1(void) {
    T1overflow = 0;
    TMR1H = 0;
    TMR1L = 0;
    T1CON = 0x18;

    PORTC |= 0x80;                    // Trigger ultrasonic sensor 1 (RC7 connected to trigger)
    usDelay(10);                      // Keep trigger for 10uS
    PORTC &= 0x7F;                    // Remove trigger

    while (!(PORTC & 0x40));          // Wait for echo to start
    T1CON = 0x19;                     // TMR1 ON
    while (PORTC & 0x40);             // Wait for echo to end
    T1CON = 0x18;                     // TMR1 OFF

    T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
    T1time = T1counts;                // Time in microseconds
    D1 = ((T1time * 34) / 1000) / 2;  // Calculate distance in cm
    D1read = 0x01;                    // Set read flag
}

// Ultrasonic Sensor Reading for Sensor 2
void sonar_read2(void) {
    T2overflow = 0;
    TMR1H = 0;
    TMR1L = 0;
    T1CON = 0x18;

    PORTC |= 0x20;                    // Trigger ultrasonic sensor 2 (RC5 connected to trigger)
    usDelay(10);                      // Keep trigger for 10uS
    PORTC &= 0xDF;                    // Remove trigger

    while (!(PORTC & 0x10));          // Wait for echo to start
    T1CON = 0x19;                     // TMR1 ON
    while (PORTC & 0x10);             // Wait for echo to end
    T1CON = 0x18;                     // TMR1 OFF

    T2counts = ((TMR1H << 8) | TMR1L) + (T2overflow * 65536);
    T2time = T2counts;                // Time in microseconds
    D2 = ((T2time * 34) / 1000) / 2;  // Calculate distance in cm
    D2read = 0x01;                    // Set read flag
}

// PWM Initialization
void CCPPWM_init(void) {
    T2CON = 0x07;                    // Enable Timer2 with 1:16 prescaler
    CCP1CON = 0x0C;                  // Enable PWM for CCP1
    PR2 = 250;                       // Set Timer2 period
    CCPR1L = 125;                    // Initial duty cycle for CCP1 (50%)

    mspeed1 = 0;
    mspeed2 = 0;
    period = 0;
    duty = 0;
}

void CCPcompare_init(void){
    HL = 1; //start high
    CCP2CON = 0x08;//
    CCPR2H=2000>>8;
    CCPR2L=2000;
    angle = 2000;
}
// Update Motor 1 Speed
void motor1(void) {
    CCPR1L = mspeed1;                // Set PWM duty cycle for motor 1
}

// Update Motor 2 Speed
void motor2(void) {
     PORTD |= 0x80;                       //High
     PWMusDelay(mspeed2*2);
     PORTD &= 0x7F;                       //Low
     PWMusDelay((250-mspeed2)*2);
}

// Microsecond Delay
void usDelay(unsigned int usCnt) {
    unsigned int us;
    for (us = 0; us < usCnt; us++) {
        asm NOP;                     // 0.5 uS
        asm NOP;                     // 0.5 uS
    }
}

void PWMusDelay(unsigned int PWMusCnt) {
    unsigned int PWMus;
    for (PWMus = 0; PWMus < PWMusCnt; PWMus++) {
        asm NOP;                     // 0.5 uS
        asm NOP;                     // 0.5 uS
    }
}

// Millisecond Delay
void msDelay(unsigned int msCnt) {
    unsigned int ms, cc;
    for (ms = 0; ms < msCnt; ms++) {
        for (cc = 0; cc < 155; cc++); // 1ms
    }
}