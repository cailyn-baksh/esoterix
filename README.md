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

The project makefile provides functionality to assemble the source files, and to create an image of a 1.44MB floppy disk.

When you first clone the repo, run `sudo make setup` to setup the repo.

To build the code run `make build`. To create a floppy image, run `sudo make floppy`.

To test with qemu, run the following command

```
qemu-system-i386 -machine pc-i440fx-1.4 -m 1M -blockdev driver=file,node-name=f0,filename=bin/floppy.img -device floppy,drive=f0
```

