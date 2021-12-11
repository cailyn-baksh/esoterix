NAME = bf-m
SRCS = $(filter-out %.swp,$(wildcard kernel/*))
OBJS = $(addsuffix .o,$(patsubst %,bin/%,$(SRCS)))
INCLUDES = include/
TOOLCHAIN = arm-none-eabi

bin/%.S.o: %.S
	$(TOOLCHAIN)-as -c -o $@ $^

build: $(OBJS)
	$(TOOLCHAIN)-ld -T linker.ld -o bin/$(NAME).elf $^
	$(TOOLCHAIN)-objcopy bin/$(NAME).elf -O binary bin/kernel7.img

setup:
	mkdir -p bin
	mkdir -p bin/kernel
	mkdir -p sysroot

clean:
	find bin/* -type f -delete
