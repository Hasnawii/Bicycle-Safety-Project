// Global Variables
unsigned char tick;         // Timer0 interrupt counter, increments every 32ms
unsigned char tick1;        // Counter for right turn signal duration (~5 seconds)
unsigned char tick2;        // Counter for left turn signal duration (~5 seconds)
unsigned char tick3;        // Counter for hall sensor pulse detection (~224ms per increment)
unsigned char tick4;        // Counter for speed calculation interval (~7 seconds)
unsigned char tick5;        // Counter for ultrasonic sonar reading (~128ms interval)
unsigned char ticka;        // Counter for right turn signal blinking interval (~480ms)
unsigned char tickb;        // Counter for left turn signal blinking interval (~480ms)
unsigned char rturn;        // Right turn signal flag (1 = active, 0 = inactive)
unsigned char lturn;        // Left turn signal flag (1 = active, 0 = inactive)
unsigned int flexA0;        // Raw ADC value from channel AN0 (e.g., flex sensor)
unsigned int flexA1;        // Raw ADC value from channel AN1 (e.g., flex sensor)
unsigned int flexD0;        // Scaled ADC value from AN0 (percentage-like, 0-50)
unsigned int flexD1;        // Scaled ADC value from AN1 (percentage-like, 0-50)
unsigned int hallA2;        // Raw ADC value from channel AN2 (e.g., hall sensor)
unsigned int hallD2;        // Scaled ADC value from AN2 (percentage-like, 0-50)
unsigned int pulse;         // Count of hall sensor pulses (for speed/distance calculation)
unsigned long dis;          // Distance traveled in cm, scaled by 100 for precision
unsigned long v;            // Speed in cm/s, scaled by 100 (actual speed = v / 100)
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

// Function Declarations
void ATD_init(void);            // Initialize ADC
unsigned int ATD_read0(void);   // Read ADC channel AN0
unsigned int ATD_read1(void);   // Read ADC channel AN1
unsigned int ATD_read2(void);   // Read ADC channel AN2
void usDelay(unsigned int);     // Microsecond delay function
void msDelay(unsigned int);     // Millisecond delay function
void sonar_init(void);          // Initialize ultrasonic sensors
void sonar_read1(void);         // Read ultrasonic sensor 1
void sonar_read2(void);         // Read ultrasonic sensor 2
void CCPPWM_init(void);         // Initialize CCP for PWM generation
void motor1(void);              // Update motor 1 speed
void motor2(void);              // Update motor 2 speed

// Interrupt Service Routine
void interrupt() {
    // PORTB Change Interrupt (Handles Button Presses)
    if (INTCON & 0x01) {
        if (!(PORTB & 0x10)) {   // Check if RB5 (right turn button) is pressed
            PORTB |= 0x04;      // Turn on RB2 (right turn signal)
            rturn = 1;          // Set right turn flag
        }
        if (!(PORTB & 0x20)) {   // Check if RB6 (left turn button) is pressed
            PORTB |= 0x08;      // Turn on RB3 (left turn signal)
            lturn = 1;          // Set left turn flag
        }
        INTCON &= 0xFE;          // Clear PORTB Change Interrupt flag
    }

    // Timer0 Overflow Interrupt (Handles Timing Events)
    if (INTCON & 0x04) {
        tick++;                  // Increment Timer0 counter (~32ms per increment)
        tick3++;                 // Increment hall sensor pulse counter
        tick4++;                 // Increment speed calculation counter
        tick5++;                 // Increment ultrasonic sensor counter

        // ADC Sampling Logic (~64ms interval)
        if (tick == 2) {
            tick = 0;

            // Read ADC values for flex sensors
            flexA0 = ATD_read0();
            flexD0 = (unsigned int)(flexA0 * 50) / 1023;  // Scale AN0 reading
            flexA1 = ATD_read1();
            flexD1 = (unsigned int)(flexA1 * 50) / 1023;  // Scale AN1 reading

            // Control RB1 (LED or actuator) based on flex sensor thresholds
            if ((flexD0 > 34) || (flexD1 > 34)) {
                PORTB |= 0x02;   // Turn on RB1
            } else {
                PORTB &= 0xFD;   // Turn off RB1
            }
        }

        // Right Turn Signal Logic
        if (rturn == 1) {
            tick1++;             // Increment right turn duration counter
            ticka++;             // Increment right turn blinking interval counter

            if (ticka == 15) {   // Toggle RB2 (right turn signal) every ~480ms
                ticka = 0;
                PORTB ^= 0x04;   // Toggle RB2
            }
            if (tick1 == 150) {  // Stop right turn signal after ~5 seconds
                tick1 = 0;
                rturn = 0;
                PORTB &= 0xFB;   // Turn off RB2
            }
        }

        // Left Turn Signal Logic
        if (lturn == 1) {
            tick2++;             // Increment left turn duration counter
            tickb++;             // Increment left turn blinking interval counter

            if (tickb == 15) {   // Toggle RB3 (left turn signal) every ~480ms
                tickb = 0;
                PORTB ^= 0x08;   // Toggle RB3
            }
            if (tick2 == 150) {  // Stop left turn signal after ~5 seconds
                tick2 = 0;
                lturn = 0;
                PORTB &= 0xF7;   // Turn off RB3
            }
        }

        // Hall Sensor Pulse Counting (~224ms interval)
        if (tick3 == 7) {
            tick3 = 0;

            // Read ADC value from hall sensor
            hallA2 = ATD_read2();
            hallD2 = (unsigned int)(hallA2 * 50) / 1023;

            // Increment pulse counter if hall sensor threshold is exceeded
            if (hallD2 > 10) {
                pulse++;
            }
        }

        // Speed and Distance Calculation (~7 seconds)
        if (tick4 == 219) {
            tick4 = 0;

            // Calculate distance in cm (scaled by 100)
            dis = (unsigned long)(314 * 35 * pulse) / 2;

            // Calculate speed in cm/s (scaled by 100)
            v = (unsigned long) dis / 700;

            // Reset pulse counter for next calculation interval
            pulse = 0;
        }

        // Ultrasonic Sensor Trigger (~128ms interval)
        if (tick5 == 4) {
            tick5 = 0;
            sonar_read1();        // Trigger ultrasonic sensor 1 reading
            sonar_read2();        // Trigger ultrasonic sensor 2 reading
        }

        INTCON &= 0xFB;           // Clear Timer0 Interrupt flag
    }

    if (PIR1 & 0x01) {            // Timer1 Overflow Interrupt
        T1overflow++;
        T2overflow++;
        PIR1 &= 0xFE;             // Clear Timer1 Overflow Interrupt flag
    }
}

// Main Function
void main() {
    // Configure Ports
    TRISA = 0xCF;                 // Configure RA4 and RA5 as output
    PORTA = 0x00;                 // Initialize PORTA to LOW
    TRISB = 0x31;                 // Configure RB0, RB4, RB5, RB6 as inputs
    PORTB = 0x00;                 // Initialize PORTB to LOW
    TRISC = 0x50;                 // Configure RC6 and RC4 as input
    PORTC = 0x00;                 // Initialize PORTC to LOW

    ATD_init();                  // Initialize ADC
    sonar_init();                // Initialize ultrasonic sensors
    CCPPWM_init();               // Initialize PWM for motors

    // Configure Timer0
    OPTION_REG = 0x07;           // Oscillator clock/4, prescaler of 256
    INTCON = 0xF8;               // Enable all interrupts
    TMR0 = 0;                    // Reset Timer0

    // Initialize Variables
    tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;

    // Main Loop
    while (1) {
        // Update motor 1 speed based on ultrasonic sensor 1 reading
        if (D1read & 0x01) {
            if (D1 < 10) {
                PORTB |= 0x40;   // Turn on motor 1
                mspeed1 = 250;  // Set high speed
            } else if (D1 < 30) {
                PORTB |= 0x40;   // Maintain motor 1
                mspeed1 = 200;  // Set medium speed
            } else if (D1 < 50) {
                PORTB |= 0x40;   // Maintain motor 1
                mspeed1 = 175;  // Set low speed
            } else {
                PORTB &= 0xBF;   // Turn off motor 1
                mspeed1 = 0;     // Stop motor
            }
            D1read = 0x00;       // Clear read flag for sensor 1
        }

        // Update motor 2 speed based on ultrasonic sensor 2 reading
        if (D2read & 0x01) {
            if (D2 < 10) {
                mspeed2 = 250;  // Set high speed
                PORTA |= 0x20; // Turn on motor 2
            } else if (D2 < 50) {
                mspeed2 = 120;  // Set medium speed
                PORTA |= 0x20; // Maintain motor 2
            } else if (D2 < 100) {
                mspeed2 = 60;   // Set low speed
                PORTA |= 0x20; // Maintain motor 2
            } else {
                mspeed2 = 0;    // Stop motor
                PORTA &= 0xDF; // Turn off motor 2
            }
            D2read = 0x00;       // Clear read flag for sensor 2
        }

        motor1();               // Update motor 1
        motor2();               // Update motor 2
    }
}

// ADC Initialization
void ATD_init(void) {
    ADCON0 = 0x41;             // ADC ON, Don't GO, Channel 0, Fosc/16
    ADCON1 = 0xC4;             // AN0, AN1, AN3 analog channels; 500 KHz, right justified
    TRISE = 0x07;              // Configure PORTE as input
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

// Read ADC value from channel 2
unsigned int ATD_read2(void) {
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
    PIE1 = PIE1 | 0x01;               // Enable TMR1 Overflow interrupt
    T1CON = 0x18;                     // TMR1 OFF, Fosc/4 (1uS increments) with 1:2 prescaler
}

// Ultrasonic Sensor Reading for Sensor 1
void sonar_read1(void) {
    T1overflow = 0;
    TMR1H = 0;
    TMR1L = 0;

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
    CCP2CON = 0x0C;                  // Enable PWM for CCP2
    PR2 = 250;                       // Set Timer2 period
    CCPR1L = 125;                    // Initial duty cycle for CCP1 (50%)
    CCPR2L = 125;                    // Initial duty cycle for CCP2 (50%)
    mspeed1 = 0;
    mspeed2 = 0;
}

// Update Motor 1 Speed
void motor1(void) {
    CCPR1L = mspeed1;                // Set PWM duty cycle for motor 1
}

// Update Motor 2 Speed
void motor2(void) {
    CCPR2L = mspeed2;                // Set PWM duty cycle for motor 2
}

// Microsecond Delay
void usDelay(unsigned int usCnt) {
    unsigned int us;
    for (us = 0; us < usCnt; us++) {
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
