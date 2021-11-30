# BF/M

BrainFuck/Monitor. An 8086 operating system which only runs brainfuck.

## Building and testing

To build, run the following command

```
nasm src/main.S -f bin -o bin/bf-m.bin
```

To test, run

```
qemu-system-i386 -drive format=raw,file=bin/bf-m.bin
```

