%include "kernel.inc"

cpu 8086
org kernel_entry

mov al,0x41
mov ah,0x0E
mov bh,0
int 0x10

; set up stack
mov sp,kernel_stack  ; gives us 1KiB of stack space below the kernel

; return
mov dx,5
call panic

; kernel panic
; error code passed in dx
panic:
	jmp [panic_jmp_addr]

