// Global Variables
unsigned char tick;    // Timer0 interrupt counter, increments every 32ms
unsigned char tick1;   // Counter for right turn signal duration (~5 seconds)
unsigned char tick2;   // Counter for left turn signal duration (~5 seconds)
unsigned char tick3;   // Counter for hall sensor pulse detection (~224ms per increment)
unsigned char tick4;   // Counter for speed calculation interval (~7 seconds)
unsigned char ticka;   // Counter for right turn signal blinking interval (~480ms)
unsigned char tickb;   // Counter for left turn signal blinking interval (~480ms)
unsigned char rturn;   // Right turn signal flag (1 = active, 0 = inactive)
unsigned char lturn;   // Left turn signal flag (1 = active, 0 = inactive)
unsigned int flexA0;   // Raw ADC value from channel AN0 (e.g., flex sensor)
unsigned int flexA1;   // Raw ADC value from channel AN1 (e.g., flex sensor)
unsigned int flexD0;   // Scaled ADC value from AN0 (percentage-like, 0-50)
unsigned int flexD1;   // Scaled ADC value from AN1 (percentage-like, 0-50)
unsigned int hallA2;   // Raw ADC value from channel AN2 (e.g., hall sensor)
unsigned int hallD2;   // Scaled ADC value from AN2 (percentage-like, 0-50)
unsigned int pulse;    // Count of hall sensor pulses (for speed/distance calculation)
unsigned long int dis; // Distance traveled in cm, scaled by 100 for precision
unsigned int v;        // Speed in cm/s, scaled by 100 (actual speed = v / 100)

// Function Declarations
void ATD_init(void);            // Initialize ADC
unsigned int ATD_read0(void);   // Read ADC channel AN0
unsigned int ATD_read1(void);   // Read ADC channel AN1
unsigned int ATD_read2(void);   // Read ADC channel AN2

// Interrupt Service Routine
void interrupt() {
    // PORTB Change Interrupt (Handles Button Presses)
    if (INTCON & 0x01) {
        if (!(PORTB & 0x10)) { // Check if RB5 (right turn button) is pressed
            PORTB |= 0x04;    // Turn on RB2 (right turn signal)
            rturn = 1;        // Set right turn flag
        }
        if (!(PORTB & 0x20)) { // Check if RB6 (left turn button) is pressed
            PORTB |= 0x08;    // Turn on RB3 (left turn signal)
            lturn = 1;        // Set left turn flag
        }
        INTCON &= 0xFE; // Clear PORTB Change Interrupt flag
    }

    // Timer0 Overflow Interrupt (Handles Timing Events)
    if (INTCON & 0x04) {
        tick++;  // Increment general-purpose Timer0 counter (~32ms per increment)
        tick3++; // Increment hall sensor pulse counter
        tick4++; // Increment speed calculation counter

        // ADC Sampling Logic (~64ms interval)
        if (tick == 2) {
            tick = 0;

            // Read ADC values for flex sensors
            flexA0 = ATD_read0();
            flexD0 = (unsigned int)(flexA0 * 50) / 1023; // Scale AN0 reading
            flexA1 = ATD_read1();
            flexD1 = (unsigned int)(flexA1 * 50) / 1023; // Scale AN1 reading

            // Control RB1 (LED or actuator) based on flex sensor thresholds
            if ((flexD0 > 34) || (flexD1 > 34)) {
                PORTB |= 0x02; // Turn on RB1
            } else {
                PORTB &= 0xFD; // Turn off RB1
            }
        }

        // Right Turn Signal Logic
        if (rturn == 1) {
            tick1++; // Increment right turn duration counter
            ticka++; // Increment right turn blinking interval counter

            if (ticka == 15) { // Toggle RB2 (right turn signal) every ~480ms
                ticka = 0;
                PORTB ^= 0x04; // Toggle RB2
            }
            if (tick1 == 150) { // Stop right turn signal after ~5 seconds
                tick1 = 0;
                rturn = 0;
                PORTB &= 0xFB; // Turn off RB2
            }
        }

        // Left Turn Signal Logic
        if (lturn == 1) {
            tick2++; // Increment left turn duration counter
            tickb++; // Increment left turn blinking interval counter

            if (tickb == 15) { // Toggle RB3 (left turn signal) every ~480ms
                tickb = 0;
                PORTB ^= 0x08; // Toggle RB3
            }
            if (tick2 == 150) { // Stop left turn signal after ~5 seconds
                tick2 = 0;
                lturn = 0;
                PORTB &= 0xF7; // Turn off RB3
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
            dis = (unsigned long int)(314 * 35 * pulse) / 2;
            // dis = 2 * pi * radius (cm) * pulse / 4
            // 314 is pi * 100, radius = 35 cm, pulse-to-revolution ratio = 4

            // Calculate speed in cm/s (scaled by 100)
            v = dis / 700;
            // Speed = distance / time (7 seconds)

            // Reset pulse counter for next calculation interval
            pulse = 0;
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
    OPTION_REG = 0x07; // Oscillator clock/4, prescaler of 256
    INTCON = 0xF8;     // Enable all interrupts
    TMR0 = 0;          // Reset Timer0

    // Initialize Variables
    tick = tick1 = tick2 = tick3 = tick4 = ticka = tickb = pulse = 0;

    // Main Loop
    while (1) {
        // Main logic is handled in the ISR
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

// Read ADC value from channel 2
unsigned int ATD_read2(void) {
    ADCON0 = (ADCON0 & 0xD7) | 0x10; // Select channel 2
    delay_us(10);      // Stabilize ADC input
    ADCON0 |= 0x04;    // Start ADC conversion
    while (ADCON0 & 0x04); // Wait for conversion to complete
    return ((ADRESH << 8) | ADRESL); // Return ADC result
}
