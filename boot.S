cpu 8086
org 0x7c00

; BIOS Parameter Block
db 0xeb
db 0x3c
nop

oemid:				db "BF/M    "
bytesPerSector:		dw 512
sectorsPerCluster:	db 1
reservedSectors:	dw 1
nFATs:				db 2
nDirEntries:		dw 224
nSectors:			dw 2880
mediaDescriptor:	db 0xF0
sectorsPerFAT:		dw 9
sectorsPerTrack:	dw 18
nHeads:				dw 2
nHiddenSectors:		dd 0
nLargeSectors:		dd 0
driveNumber:		db 0
db 0  ; Reserved
signature:			db 0x29
volumeID:			dd 0xacabacab
volumeLabel:		db "BF/M Floppy"
fsType:				db "FAT12   "

; Boot code
	; init segments
	xor ax,ax
	mov ds,ax

	; init stack
	mov ss,ax
	mov sp,0x9c00

	cld

	mov si,bootmsg
	call bprint

	; Read the FAT
	mov al,[sectorsPerFAT]
	mov cl,[nFATs]
	mul cl  ; put number of sectors to read into al
	
	mov ah,2  ; read
	mov ch,0  ; cylinder 0
	mov cl,2  ; from sector 2
	mov dh,0
	xor bx,bx
	mov es,bx
	mov bx,FAT
	int 0x13

	clc
	mov bx,0x0F00
	call printerr

	stc
	mov bx,0x1234
	mov cx,0xabcd
	call printerr

hang:
	jmp $

; Prints the string at si
bprint:
	push ax
	push bx
_loop@bprint:
	lodsb
	or al,al
	jz _end@bprint
	mov ah,0x0E
	mov bh,0
	int 0x10
	jmp _loop@bprint
_end@bprint:
	pop bx
	pop ax
	ret

; Reports an error in the following format
;	Error CODE [at SOURCE]
; CODE is a hex representation of the value in BX
; SOURCE is a hex representation of the value in CX
; SOURCE is only included if the Carry flag is set
; Carry flag will be cleared
printerr:
	; preserve registers and carry flag
	push si
	push ax
	push dx
	lahf
	push ax
_start@printerr:
	; print start of message
	mov si,_strerr@printerr
	call bprint

	mov dx,bx
	call printDX
	
	; restore and test carry flag
	pop ax
	sahf
	jnc _end@printerr


	; print end of message
	mov si,_strsrc@printerr
	call bprint

	mov dx,cx
	call printDX
_end@printerr:
	; print newline
	mov si,CRLF
	call bprint

	; restore registers
	pop dx
	pop ax
	pop si
	ret
_strerr@printerr:	db "Error ",0
_strsrc@printerr:	db " at ",0

; Prints dec representation of AX
printDX:
	push si
	push cx
	push bx

	; set di to chars@printAX+3 (end of string)
	; while di != addrof chars@printAX
	;   bx = ax & 0xF
	;   bl = *[bx + addrof hexchars@printAX]
	;   *di = bl
	;   --di
	;   ax >>= 4;
	xor ax,ax
	mov es,ax
	mov di,chars@printDX
	add di,3
	mov cl,4
	std
_loop@printDX:
	cmp di,chars@printDX
	jl _end@printDX

	mov bx,dx					; bx = (dx & 0xF) + &_hexchars@printDX
	and bx, word 0xF
	add bx,_hexchars@printDX
	mov al,[bx]					; *di = *bx
	stosb
	sar dx,cl					; dx >>= 4

	jmp _loop@printDX
_end@printDX:
	cld
	inc di
	mov si,di
	call bprint

	pop bx
	pop cx
	pop si
	ret
_hexchars@printDX:	db "0123456789ABCDEF"
chars@printDX:		db 0,0,0,0,0

bootmsg:	db "Starting BF/M",13,10,0
CRLF:		db 13,10,0

times 510-($-$$) db 0
db 0x55
db 0xAA

FAT:

