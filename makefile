NAME = bf-m
MOUNT = /mnt/bfm-sd
OBJS = $(addsuffix .o,$(patsubst %,bin/%,$(wildcard kernel/*)))
INCLUDES = include/
TOOLCHAIN = aarch64-elf

bin/%.S.o: %.S
	$(TOOLCHAIN)-as -c -o $@ $^

build: $(OBJS)
	$(TOOLCHAIN)-ld -T linker.ld -o bin/$(NAME).elf $^
	$(TOOLCHAIN)-objcopy bin/$(NAME).elf -O binary bin/kernel7.img

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

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p sysroot
	mkdir -p $(MOUNT)

clean:
	find bin/* -type f -delete
