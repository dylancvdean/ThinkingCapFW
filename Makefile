# Allow override of chip type from command line
CHIP ?= t13a

ifeq ($(CHIP),328p)
    MCU = atmega328p
    AVRDUDE_MCU = m328p
else ifeq ($(CHIP),328pb)
    MCU = atmega328pb
    AVRDUDE_MCU = m328pb
else ifeq ($(CHIP),t13a)
    MCU = attiny13a
    AVRDUDE_MCU = t13
else
    $(error Invalid CHIP specified: $(CHIP). Use 328p, 328pb, or t13a)
endif

# Clock frequency
F_CPU = 1000000

# Compiler and tools
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os
OBJCPY = avr-objcopy
AVRDUDE = avrdude
PROGRAMMER = usbtiny
PORT = /dev/ttyUSB0 # Adjust if necessary
TARGET = main

# Fuse settings
ifeq ($(CHIP),t13a)
    LFUSE = 0x6A
    HFUSE = 0xFF
    EFUSE = 0xFF # Not used on t13a
else
    LFUSE = 0x62
    HFUSE = 0xDA
    EFUSE = 0xFF
endif

# Default build rules
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
ifeq ($(CHIP),t13a)
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 \
		-U lfuse:w:$(LFUSE):m \
		-U hfuse:w:$(HFUSE):m
else
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 \
		-U lfuse:w:$(LFUSE):m \
		-U hfuse:w:$(HFUSE):m \
		-U efuse:w:$(EFUSE):m
endif


readfuses:
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -B 40 \
		-U lfuse:r:-:h -U hfuse:r:-:h -U efuse:r:-:h

install: fuses flash verify size

clean:
	rm -f $(TARGET).elf $(TARGET).hex
