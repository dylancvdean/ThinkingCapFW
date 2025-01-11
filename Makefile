MCU = atmega328p
F_CPU = 1000000
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os
OBJCPY = avr-objcopy
AVRDUDE = avrdude
PROGRAMMER = usbtiny
PORT = /dev/ttyUSB0 # Adjust if necessary
TARGET = main

# Fuse settings
LFUSE = 0x62
HFUSE = 0xDA
EFUSE = 0xFF

all: $(TARGET).hex

$(TARGET).elf: $(TARGET).c
	$(CC) $(CFLAGS) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCPY) -O ihex $< $@

flash: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -B 40 -U flash:w:$(TARGET).hex

fuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -B 40 \
	        -U lfuse:w:$(LFUSE):m \
	        -U hfuse:w:$(HFUSE):m \
	        -U efuse:w:$(EFUSE):m

install: fuses flash

readfuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -B 40 \
	        -U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h

clean:
	rm -f $(TARGET).elf $(TARGET).hex