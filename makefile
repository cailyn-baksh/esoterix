NAME = bf-m
SRCS = $(filter-out %.swp %.inc,$(wildcard kernel/*))
OBJS = $(addsuffix .o,$(patsubst %,bin/%,$(SRCS)))
INCLUDES = include/
TOOLCHAIN = arm-none-eabi

bin/kernel/%.S.o: kernel/%.S
	$(TOOLCHAIN)-as -I kernel -c -o $@ $^

build: $(OBJS)
	$(TOOLCHAIN)-ld -T linker.ld -o bin/$(NAME).elf $^
	$(TOOLCHAIN)-objcopy bin/$(NAME).elf -O binary bin/kernel.img

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p sysroot

clean:
	find bin/* -type f -delete
