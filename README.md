# BF/M

BrainFuck/Monitor. An 8086 operating system which only runs brainfuck.

## Building and testing

The project makefile provides functionality to assemble the source files, and to create an image of a 1.44MB floppy disk.

When you first clone the repo, run `sudo make setup` to setup the repo.

To build the code run `make build`. To create a floppy image, run `sudo make floppy`.

To test with qemu, run the following command

```
qemu-system-i386 -blockdev driver=file,node-name=f0,filename=bin/floppy.img -device floppy,drive=f0
```

