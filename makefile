NAME = bf-m

bin/%.bin: kernel/%.S
	nasm -f bin -o $@ $^

build: bin/boot.bin bin/kernel.bin

floppy: build
	dd if=/dev/zero of=bin/floppy.img bs=512 count=2880
	mkdosfs bin/floppy.img -R 2
	dd if=bin/boot.bin of=bin/floppy.img seek=0 count=1 conv=notrunc
	dd if=bin/kernel.bin of=bin/floppy.img seek=1 count=1 conv=notrunc
	losetup /dev/loop0 bin/disk.img
	mount -t msdos /dev/loop0 /mnt/bfm-floppy
	umount /dev/loop0
	losetup -d /dev/loop0
	chmod -R 777 bin/

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p /mnt/bfm-floppy

clean:
	find bin/* -type f -delete
