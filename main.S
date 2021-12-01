[BITS 16]

%include "boot.S"
%include "print.inc"

main:
	mov ax,0xb800
	mov es,ax
	call clrscr

	mov si,msg
	call puts

	jmp hang

msg db "Hello World!",0

times 1024-($-$$) db 0


