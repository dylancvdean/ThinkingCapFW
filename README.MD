This is a work in progress to go with the sister repository thinkingcapHW
You need the avr suite to build and install this, as well as Make.
On arch, this is obtained with `sudo pacman -S avrdude avr-binutils avr-gcc avr-gdb avr-libc make`
##Building
To build, run `make`. You can specify the chip with e.g. `make CHIP=t13a`. Currently the t13a, 328p, and 328pb are supported. 
The resulting hex file can be installed, and the fuses set, with `make install`, again specifying the chip, e.g. `make CHIP=t13a install`
