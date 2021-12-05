kernel_entry		equ 0x920
kernel_stack		equ 0x900

; define memory locations for kernel parameters
; NOTE: the addresses appear to point to the end of the data instead of the stard
kernel_params		equ (kernel_stack+1)
k_panic_jmp_addr	equ (kernel_params+2)		; address to jump to in case of a kernel panic (2 bytes)
k_bootDisk			equ (kernel_params+3)		; drive number of the boot drive (1 byte)
k_availableRAM		equ (kernel_params+5)		; KiB of usable RAM. EBDA should not be included in this value (2 bytes)

; error codes
ERR_LOAD_KERNEL		equ 0x1
ERR_DETECT_MEM		equ 0x2

