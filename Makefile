# Allow override of chip type from command line
CHIP ?= 328p

ifeq ($(CHIP),328p)
    MCU = atmega328p
    AVRDUDE_MCU = m328p
else ifeq ($(CHIP),328pb)
    MCU = atmega328pb
    AVRDUDE_MCU = m328pb
else
    $(error Invalid CHIP specified: $(CHIP). Use 328p or 328pb)
endif

F_CPU = 1000000
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os
OBJCPY = avr-objcopy
AVRDUDE = avrdude
PROGRAMMER = usbtiny
PORT = /dev/ttyUSB0 # Adjust if necessary
TARGET = main

# Fuse settings (same for both chips)
LFUSE = 0x62
HFUSE = 0xDA
EFUSE = 0xFF

all: $(TARGET).hex size

$(TARGET).elf: $(TARGET).c
	$(CC) $(CFLAGS) -o $@ $^

$(TARGET).hex: $(TARGET).elf
	$(OBJCPY) -O ihex $< $@

flash: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 -U flash:w:$(TARGET).hex

verify:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 -U flash:v:$(TARGET).hex

size: $(TARGET).elf
	avr-size --format=avr --mcu=$(MCU) "$<"

fuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 \
		-U lfuse:w:$(LFUSE):m \
		-U hfuse:w:$(HFUSE):m \
		-U efuse:w:$(EFUSE):m

readfuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 \
		-U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h

install: fuses flash verify size

clean:
	rm -f $(TARGET).elf $(TARGET).hex
