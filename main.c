#define F_CPU 1000000UL //1MHz
#include <avr/io.h>
#include <util/delay.h>

int main(void){
	PRR |= (1 << PRTWI); //Disable two wire
	PRR |= (1 << PRTIM2); //Disable Timer/Counter 2
	PRR |= (1 << PRTIM0); //Disable Timer/Counter 0
	PRR |= (1 << PRTIM1); //Disable Timer/Counter 1
	PRR |= (1 << PRSPI);
	PRR |= (1 << PRUSART0);
	DDRB |= (1 << PB5);

}

