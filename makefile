NAME = esoterix
SRCS = $(filter-out %.swp %.inc %.h,$(wildcard kernel/*))
OBJS = $(addsuffix .o,$(patsubst %,bin/%,$(SRCS)))
INCLUDES = include/
TOOLCHAIN = arm-none-eabi
CFLAGS = -march=armv6k -mabi=aapcs -ffreestanding -nostdlib -nostartfiles -O2 -Wall
CSTD = c17

.PHONY: build updateBuildNum setup clean FORCE

build: $(OBJS)
	$(TOOLCHAIN)-ld -nostdlib -T linker.ld -o bin/$(NAME).elf $^
	$(TOOLCHAIN)-objcopy bin/$(NAME).elf -O binary bin/kernel.img

bin/kernel/%.c.o: kernel/%.c
	$(TOOLCHAIN)-gcc $(CFLAGS) -std=$(CSTD) -I kernel -c -o $@ $<

bin/kernel/version.c.o: kernel/version.c FORCE
	$(TOOLCHAIN)-gcc $(CFLAGS) -DVERSION_BUILD=$(shell ./buildnum.sh) -I kernel -c -o $@ $<

bin/kernel/%.S.o: kernel/%.S
	$(TOOLCHAIN)-gcc $(CFLAGS) -I kernel -c -o $@ $^

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p sysroot

clean:
	find bin/* -type f -delete

FORCE:

