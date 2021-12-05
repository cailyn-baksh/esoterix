kernel_entry		equ 0x920
kernel_stack		equ 0x900

; define memory locations for kernel parameters
kernel_params		equ 0x901
panic_jmp_addr		equ kernel_params
