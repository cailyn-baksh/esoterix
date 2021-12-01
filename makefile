NAME = bf-m

bin/%.bin: %.S
	nasm -f bin -o $@ $^

build: bin/boot.bin bin/main.bin

floppy: build
	dd if=/dev/zero of=bin/disk.img bs=512 count=2880
	dd if=bin/boot.bin of=bin/disk.img seek=0 count=1 conv=notrunc
	losetup /dev/loop0 bin/disk.img
	mkdosfs /dev/loop0
	mount -t msdos /dev/loop0 /mnt/bfm-floppy
	umount /dev/loop0
	losetup -d /dev/loop0

setup:
	mkdir -p bin
	mkdir -p /mnt/bfm-floppy

clean:
	find bin/* -type f -delete
