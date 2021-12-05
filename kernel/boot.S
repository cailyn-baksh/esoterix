cpu 8086
org 0x7c00

%include "kernel.inc"

; BIOS Parameter Block
db 0xeb
db 0x3c
nop

oemid:				db "BF/M    "
bytesPerSector:		dw 512
sectorsPerCluster:	db 1
reservedSectors:	dw 2
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

	; store drive number before it gets overwritten
	mov byte [k_bootDisk],dl

	mov si,bootmsg
	call bprint

	; detect available ram
	clc
	int 0x12
	jc memDetectFailed
	sub ax,128  ; subtract size of the EBDA
	mov word [k_availableRAM],ax

	; load the kernel
	mov si,loadmsg
	call bprint

	mov ah,2  ; read
	mov al,1  ; 1 sector
	mov cl,2  ; starting from sector 2
	mov dl,[k_bootDisk]  ; on the boot disk
	mov ch,0  ; cylinder 0
	mov dh,0  ; head 0
	xor bx,bx
	mov es,bx
	mov bx,kernel_entry
	int 0x13

	jc kernelLoadFailed

	; Jump to kernel
	mov word [k_panic_jmp_addr],handlePanic  ; give kernel an address to jump to on panic
	jmp kernel_entry

handlePanic:
	mov si,kp_msg
	call bprint
	call printerr
	jmp $

memDetectFailed:
	mov dx,ERR_DETECT_MEM
	call printerr
	jmp $

kernelLoadFailed:
	mov dx,ERR_LOAD_KERNEL
	call printerr
	jmp $

hang:
	jmp $

bootDisk: db 0

; Prints the string at si
; si will be moved to the end of the string
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
;	Err CODE
; CODE is a hex representation of the value in DX
; SOURCE is a hex representation of the value in CX
; SOURCE is only included if the Carry flag is set
; Carry flag will be cleared
printerr:
	; preserve registers and carry flag
	push si
	
	; print start of message
	mov si,_strerr@printerr
	call bprint
	call printDX
	
	; print newline
	mov si,CRLF
	call bprint

	; restore registers
	pop si
	ret
_strerr@printerr:	db "Err ",0

; Prints dec representation of DX
printDX:
	push si
	push ax
	push bx
	push cx

	; set di to chars@printDX+3 (end of string)
	; while di != addrof chars@printDX
	;   bx = ax & 0xF
	;   bl = *[bx + addrof hexchars@printDX]
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

	pop cx
	pop bx
	pop ax
	pop si
	ret
_hexchars@printDX:	db "0123456789ABCDEF"
chars@printDX:		db 0,0,0,0,0

bootmsg:	db "Starting BF/M",13,10,0
loadmsg:	db "Loading Kernel",13,10,0
kp_msg:		db 13,10,"Kernel Panic",13,10,0
CRLF:		db 13,10,0

times 510-($-$$) db 0
db 0x55
db 0xAA

