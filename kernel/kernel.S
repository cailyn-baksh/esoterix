%include "kernel.inc"

cpu 8086
org kernel_entry

; set up stack
mov sp,kernel_stack

cli
; Load IVT
; Targeting 8086, so only the first 5 need to be defined
mov bx,0x0
;mov word [bx],undefined_handler			; 0x00: Division by 0
;mov word [bx+0x04],undefined_handler	; 0x01: Single-step execution
;mov word [bx+0x08],undefined_handler	; 0x02: Non-maskable interrupt
;mov word [bx+0x0A],undefined_handler	; 0x03: Breakpoint
;mov word [bx+0x10],undefined_handler	; 0x04: Overflow
mov word [bx+0x20],handleIRQ0			; 0x08: IRQ0
mov word [bx+0x22],cs

; Set up PIT

mov al,00010001b
out 0x20,al
out 0xA0,al

mov al,0x8
out 0x21,al
mov al,0x70
out 0xA1,al

mov al,00000100b
out 0x21,al
mov al,0x2
out 0xA1,al

mov al,00000001b
out 0x21,al
out 0xA1,al

; Mask IRQ0
in al,0x21
and al,11111110b
out 0x21,al

; write to mode/command register
mov al,00110100b  ; channel 0, lobyte/hibyte, rate generator, binary mode
out 0x43,al

; write channel 0 reload value
mov ax,1193  ; 1.1931816666MHz/1193 = 1.0000152277x10^-3 seconds per cycle
out 0x40,al
mov al,ah
out 0x40,al

; enable IRQ0
;in al,0x21  ; read master PIC data line
;mov al,11111110b  ; unmask IRQ0
;out 0x21,al  ; write new value

sti

mov al,0x41
mov ah,0x0E
mov bh,0
int 0x10

;mov ax,[0x20]
;in al,0x21
;mov bx,[0x22]
;mov cx,kernel_entry
;jmp $
mov ax,1
call sleep

mov al,0x42
mov ah,0x0E
mov bh,0
int 0x10

; return
mov dx,0
call panic

; kernel panic
; error code passed in dx
panic:
	jmp [k_panic_jmp_addr]

undefined_handler:
	mov dx,KP_UNEXPECTED_INT
	call panic

div0Handler:
	iret

; sleeps for ax milliseconds
sleep:
	push ax
	mov [timerCountDown],ax
_loop@sleep:
	cli
	mov ax,[timerCountDown]
	or ax,ax
	jz _end@sleep
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	jmp _loop@sleep
_end@sleep:
	sti
	pop ax
	ret

handleIRQ0:
	push ax
	mov ax,[timerCountDown]
	or ax,ax
	jz _end@handleIRQ0
	dec ax
	mov [timerCountDown],ax
_end@handleIRQ0:
	mov al,0x20  ; signal EOI
	out 0x20,al

	pop ax
	iret
	
timerCountDown: dw 0	

kernel_end:

