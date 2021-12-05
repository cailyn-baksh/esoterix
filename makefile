NAME = bf-m
MOUNT = /mnt/bfm-floppy

bin/%.bin: kernel/%.S
	nasm -f bin -I kernel/ -o $@ $^

build: bin/boot.bin bin/kernel.bin

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
	mkdir -p /mnt/bfm-floppy

clean:
	find bin/* -type f -delete
