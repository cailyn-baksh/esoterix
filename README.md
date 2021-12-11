# BF/M

BrainFuck/Monitor. A 32-bit OS for the Raspberry Pi which only runs brainfuck.

## Objectives

The objectives of this project are to
 - Produce an operating system which is only capable of running esoteric programming languages
   - By "only capable" we mean that the task of creating a compiler or interpreter for a non-esoteric for this system would be very challenging; that the ABI is more suited to implementing esoteric languages then non-esoteric language. This is likely to be implemented by not allowing code to run directly on the hardware but instead running userspace code in a virtual machine designed for esoteric languages
   - Any compilers or interpreters for this platform would either have to be implemented in an esoteric language themselves, or be dependant on another compiler which outputs binary for an intrinsically esoteric ABI.
 - Implement the entire operating system in assembly
   - While C may be more efficient and faster to develop with, i like assembly and think that its fun
   - The goal is to keep the assembly code easy to read, even at the cost of speed or efficiency. Unclear "hacks" should be sparse and well documented

## Building and testing

To build run `make`. On first build run `sudo make setup` to set up the repo.

To test, run

```
qemu-system-arm -M raspi2 -serial stdio -kernel bin/kernel7.img
```

