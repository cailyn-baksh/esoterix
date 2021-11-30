[ORG 0x7c00]
	; init segments
	xor ax,ax
	mov ds,ax

	; init stack
	mov ss,ax
	mov sp,0x9c00

	cld

	; init text video buffer
	mov ah,0
	mov al,3
	int 0x10	

	mov ax,0xb800
	mov es,ax

	jmp main

	times 510-($-$$) db 0
	db 0x55
	db 0xAA

%include "main.S"

