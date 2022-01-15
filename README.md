# Esoterix

A 32-bit OS for the Raspberry Pi which only runs esoteric programming languages.

Compatible platforms are:
 - Raspberry Pi Zero PCB v1.2
 - Raspberry Pi Zero PCB v1.3
 - Raspberry Pi Zero W
 - Raspberry Pi Zero 2 W
 - Raspberry Pi 1 Model A
 - Raspberry Pi 1 Model A+
 - Raspberry Pi 1 Model B
 - Raspberry Pi 1 Model B+
 - Raspberry Pi 2 Model B
 - Raspberry Pi 2 Model B v1.2
 - Raspberry Pi 3 Model A+
 - Raspberry Pi 3 Model B
 - Raspberry Pi 3 Model B+
 - Raspberry Pi 4 Model B

## Objectives

The objectives of this project are to
 - Produce an operating system which is only capable of running esoteric programming languages
   - By "only capable" we mean that the task of creating a compiler or interpreter for a non-esoteric for this system would be very challenging; that the ABI is more suited to implementing esoteric languages then non-esoteric language. This is likely to be implemented by not allowing code to run directly on the hardware but instead running userspace code in a virtual machine designed for esoteric languages
   - Any compilers or interpreters for this platform would either have to be implemented in an esoteric language themselves, or be dependant on another compiler which outputs binary for an intrinsically esoteric ABI.

## Building and testing

To build run `make`. On first build run `sudo make setup` to set up the repo.

To test, run `make test`

## Todo

 - [x] Kernel debug printf
 - [ ] Process kernel arguments
 - [ ] CLI over UART0
 - [ ] System timer
 - [ ] Mailboxes
 - [ ] Disk and filesystem
 - [ ] initrd
 - [ ] Virtual Memory
 - [ ] Virtual Machine
 - [ ] Cross Assembler
 - [ ] Native Assembler
 - [ ] Multitasking

