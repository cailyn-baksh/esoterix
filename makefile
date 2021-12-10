NAME = bf-m
MOUNT = /mnt/bfm-sd
OBJS = $(addsuffix .o,$(patsubst %,bin/%,$(wildcard kernel/*)))
INCLUDES = include/

bin/%.S/o: %.S
	aarch64-elf-as -c -o $@ $^

build: $(OBJS)
	aarch64-elf-ld -T linker.ld --oformat binary -o bin/kernel7.img

image: build
	dd if=/dev/zero of=bin/sd.img bs=4M count
	mkfs.vfat bin/sd.img
	losetup /dev/loop0 bin/sd.img
	mount /dev/loop0 $(MOUNT)
	cp bin/kernel7.img $(MOUNT)/kernel7.img
	cp sysroot/* $(MOUNT)/
	umount /dev/loop0
	losetup -d /dev/loop0
	chmod -R 777 bin/

floppy: build
	dd if=/dev/zero of=bin/floppy.img bs=512 count=2880
	mkdosfs bin/floppy.img -R 2
	cat bin/boot.bin bin/kernel.bin > bin/$(NAME).bin
	dd if=bin/$(NAME).bin of=bin/floppy.img seek=0 conv=notrunc
	losetup /dev/loop0 bin/floppy.img
	mount -t msdos /dev/loop0 $(MOUNT)
	mkdir $(MOUNT)/sys
	umount /dev/loop0
	losetup -d /dev/loop0
	chmod -R 777 bin/

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p sysroot
	mkdir -p $(MOUNT)

clean:
	find bin/* -type f -delete
