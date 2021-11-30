%include "print.S"

hang:
	jmp hang

main:
	call clrscr

	mov si,msg
	call puts

	jmp hang

msg db "Hello World!",0

