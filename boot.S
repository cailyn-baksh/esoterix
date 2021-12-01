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

	mov si,bootmsg
	call puts

	mov si,loadmsg
	call puts

	mov ah,2	; read
	mov al,1	; 63 sectors
	mov ch,0	; from cylinder 0
	mov dh,0	; on head 0
	mov cl,2
	xor bx,bx
	mov es,bx
	mov bx,0x7e00
	int 0x13
	
	mov ah,1
	int 0x13

	jc read_failed

	jmp 0x7e00

read_failed:
	mov ax,0xb800
	mov es,ax
	mov si,failmsg
	call puts
	jmp $

bootmsg	db "Booting BF/M",0
loadmsg db "Loading sectors",0
failmsg db "Loading sectors failed",0

hang:
	jmp hang

times 510-($-$$) db 0
db 0x55
db 0xAA

