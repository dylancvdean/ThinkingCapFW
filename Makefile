MCU = atmega328p
F_CPU = 1000000
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os
OBJCPY = avr-objcopy
AVRDUDE = avrdude
PROGRAMMER = usbasp
PORT = /dev/ttyUSB0 # Adjust if necessary

TARGET = main

all: $(TARGET).hex

$(TARGET).elf: $(TARGET).c
	$(CC) $(CFLAGS) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCPY) -O ihex $< $@

install: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:w:$(TARGET).hex

clean:
	rm -f $(TARGET).elf $(TARGET).hex
