#include <avr/io.h>
#include <util/delay.h>

void power_save(void) {
    #ifdef __AVR_ATtiny13A__
        // No PRR on ATtiny13A, so this function does nothing for it
    #elif defined(__AVR_ATmega328P__)
        PRR |= (1 << PRTWI);    // Disable two-wire interface (TWI)
        PRR |= (1 << PRTIM2);   // Disable Timer/Counter 2
        PRR |= (1 << PRSPI);    // Disable SPI
        PRR |= (1 << PRUSART0); // Disable USART
    #else
        #error "Unsupported microcontroller!"
    #endif
}

void pwm_init(void) {
    #ifdef __AVR_ATtiny13A__
        DDRB |= (1 << PB0); // PB0 as output (OC0A)
        TCCR0A |= (1 << WGM00) | (1 << WGM01); // Fast PWM, 8-bit
        TCCR0A |= (1 << COM0A1);               // Non-inverting mode on OC0A
        TCCR0B |= (1 << CS01);                 // Prescaler = 8
        OCR0A = 0;                             // Duty cycle 0, motor off
    #elif defined(__AVR_ATmega328P__)
        DDRB |= (1 << PB1); // PB1 as output (OC1A)
        TCCR1A |= (1 << WGM10); // Fast PWM, 8-bit
        TCCR1A |= (1 << COM1A1); // Non-inverting mode on OC1A
        TCCR1B |= (1 << WGM12); // Fast PWM, 8-bit
        TCCR1B |= (1 << CS11); // Prescaler = 8
        OCR1A = 0; // Duty cycle 0, motor off
    #else
        #error "Unsupported microcontroller!"
    #endif
}

void adc_setup(void) {
    #ifdef __AVR_ATtiny13A__
        DDRB &= ~(1 << PB3);            // PB3 as input
        DIDR0 |= (1 << ADC3D);          // Disable digital input on PB3
        ADMUX = (1 << MUX1) | (1 << MUX0); // Select ADC3 (PB3)
        ADCSRA = (1 << ADEN) | (1 << ADPS1) | (1 << ADPS0); // Enable ADC, prescaler = 8
    #elif defined(__AVR_ATmega328P__)
        DDRC &= ~(1 << PC0);            // PC0 as input
        DIDR0 |= (1 << ADC0D);          // Disable digital input on PC0
        ADMUX = (1 << REFS0);           // AVcc as reference, select ADC0 (PC0)
        ADCSRA = (1 << ADEN) | (1 << ADPS1) | (1 << ADPS0); // Enable ADC, prescaler = 8
    #else
        #error "Unsupported microcontroller!"
    #endif
}

uint16_t read_adc(void) {
    ADCSRA |= (1 << ADSC);              // Start ADC conversion
    while (ADCSRA & (1 << ADSC));       // Wait for conversion to complete
    return ADC;                         // Return ADC result
}

void set_duty(uint8_t duty) {
    #ifdef __AVR_ATtiny13A__
        OCR0A = duty; // Set duty cycle for Timer0 (OC0A)
    #elif defined(__AVR_ATmega328P__)
        OCR1A = duty; // Set duty cycle for Timer1 (OC1A)
    #else
        #error "Unsupported microcontroller!"
    #endif
}

int main(void) {
    power_save();
    pwm_init();
    adc_setup();

    while (1) {
        for (uint8_t i = 0; i < 255; i++) {
            set_duty(i);
            _delay_ms(10);
        }
        for (uint8_t i = 255; i > 0; i--) {
            set_duty(i);
            _delay_ms(10);
        }
    }
    uint8_t samples[8] = {0};
    uint8_t avg = 0;
    while (1) {
        for(uint8_t i = 0; i < 32; i++) {
            samples[(i+1)/4] += read_adc() >> 4; // 10-bit ADC to 6-bit
        }

        {
            uint16_t sum = 0;
            for(uint8_t i = 0; i < 8; i++) {
                sum+=samples[i];
            }
            avg = sum >> 3;
        }

        memset(samples, 0, sizeof(samples));
    }
}
