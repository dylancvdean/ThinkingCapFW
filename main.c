#define F_CPU 1000000UL //1MHz
#include <avr/io.h>
#include <util/delay.h>

void power_save(void){

	PRR |= (1 << PRTWI); //Disable two wire
	PRR |= (1 << PRTIM2); //Disable Timer/Counter 2
	PRR |= (1 << PRSPI); //Disable SPI
	PRR |= (1 << PRUSART0); //Disable USART
}

void pwm_init(void){

	DDRB |= (1 << PB1); //PB1 as output
	
	TCCR1A |= (1 << WGM10); //Fast PWM, 8 bit
	TCCR1A |= (1 << COM1A1); //Non-inverting mode on OC1A
	TCCR1B |= (1 << WGM12); //Fast PWM, 8 bit
	TCCR1B |= (1 << CS11); //Prescaler=8
	
	OCR1A = 0; //Duty cycle 0, motor off
}

void set_duty(uint8_t duty){

	OCR1A = duty;
}

int main(void){
	
	power_save();
	pwm_init();

	while(1){
		for(uint8_t i = 0; i<255; i++){
			set_duty(i);
			_delay_ms(10);
		}
		for (uint8_t i = 255; i> 0; i--){
			set_duty(i);
			_delay_ms(10);
		}
	}

}

