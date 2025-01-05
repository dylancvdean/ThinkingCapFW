MCU = atmega328p
F_CPU = 1000000
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os
OBJCPY = avr-objcopy
AVRDUDE = avrdude
PROGRAMMER = usbasp

TARGET = main

all: $(TARGET).hex

$(TARGET).elf: $(TARGET).c
	$(CC) $(CFLAGS) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCPY) -O ihex $< $@
