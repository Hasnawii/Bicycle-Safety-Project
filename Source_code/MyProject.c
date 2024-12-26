// Global Variables
unsigned char tick;
unsigned char tick1;
unsigned char tick2;
unsigned char ticka;
unsigned char tickb;
unsigned char rturn;
unsigned char lturn;
unsigned int flexA0;
unsigned int flexA1;
unsigned int flexD0;
unsigned int flexD1;

// Function Declarations
void ATD_init(void);
unsigned int ATD_read0(void);
unsigned int ATD_read1(void);


// Interrupt Service Routine
void interrupt() {
    // PORTB Change Interrupt
    if (INTCON & 0x01) {
        if (!(PORTB & 0x10)) { // Check if RB5 button is pressed
            PORTB |= 0x04; // Turn on RB2
            rturn = 1;
        }
        if (!(PORTB & 0x20)) { // Check if RB6 button is pressed
            PORTB |= 0x08; // Turn on RB3
            lturn = 1;
        }
        INTCON &= 0xFE; // Clear PORTB Change Interrupt flag
    }

    // Timer0 Overflow Interrupt
    if (INTCON & 0x04) {
        tick++; // Increment tick every 32ms

        // ADC Sampling Logic (~64ms)
        if (tick == 2) {
            tick = 0;

            // Read ADC values
            flexA0 = ATD_read0();
            flexD0 = (unsigned int)(flexA0 * 50) / 1023;
            flexA1 = ATD_read1();
            flexD1 = (unsigned int)(flexA1 * 50) / 1023;

            // Control RB1 based on ADC conditions
            if ((flexD0 > 34) || (flexD1 > 34)) {
                PORTB |= 0x02; // Turn on RB1
            } else {
                PORTB &= 0xFD; // Turn off RB1
            }
        }

        // Right Turn Signal Logic
        if (rturn == 1) {
            tick1++;
            ticka++;
            if (ticka == 15) { // Toggle RB2 every ~480ms
                ticka = 0;
                PORTB ^= 0x04; // Toggle RB2
            }
            if (tick1 == 150) { // Stop after ~5 seconds
                tick1 = 0;
                rturn = 0;
                PORTB &= 0xFB; // Turn off RB2
            }
        }

        // Left Turn Signal Logic
        if (lturn == 1) {
            tick2++;
            tickb++;
            if (tickb == 15) { // Toggle RB3 every ~480ms
                tickb = 0;
                PORTB ^= 0x08; // Toggle RB3
            }
            if (tick2 == 150) { // Stop after ~5 seconds
                tick2 = 0;
                lturn = 0;
                PORTB &= 0xF7; // Turn off RB3
            }
        }

        INTCON &= 0xFB; // Clear Timer0 Interrupt flag
    }
}

void main() {
    // Configure Ports
    TRISB = 0xF1; // RB0, RB1, RB2, RB3 as outputs; RB4, RB5 as inputs
    PORTB = 0x00; // Initialize PORTB to LOW

    // Initialize ADC
    ATD_init();

    // Configure Timer0
    OPTION_REG = 0x07; // Osc clock/4, prescaler of 256
    INTCON = 0xF8;     // Enable all interrupts
    TMR0 = 0;          // Reset Timer0

    // Initialize Variables
    tick = 0;
    tick1 = 0;
    tick2 = 0;
    ticka = 0;
    tickb = 0;

    // Main Loop
    while (1) {
        // Intentionally left empty; logic handled in ISR
    }
}

// ADC Initialization
void ATD_init(void) {
    ADCON0 = 0x41; // ADC ON, Don't GO, Channel 0, Fosc/16
    ADCON1 = 0xC0; // All analog channels, 500 KHz, right justified
    TRISA = 0xFF;  // Configure PORTA as input
    TRISE = 0x07;  // Configure PORTE as input
}

// Read ADC value from channel 0
unsigned int ATD_read0(void) {
    ADCON0 &= 0xC7;   // Select channel 0
    delay_us(10);     // Stabilize ADC input
    ADCON0 |= 0x04;   // Start ADC conversion
    while (ADCON0 & 0x04); // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL); // Return ADC result
}

// Read ADC value from channel 1
unsigned int ATD_read1(void) {
    ADCON0 = (ADCON0 & 0xCF) | 0x08; // Select channel 1
    delay_us(10);      // Stabilize ADC input
    ADCON0 |= 0x04;    // Start ADC conversion
    while (ADCON0 & 0x04); // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL); // Return ADC result
}
