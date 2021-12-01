[ORG 0x7c00]

; BIOS Parameter Block
db 0xeb
db 0x3e
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
	mov al,1	; 1 sector
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

%include "print.inc"

times 510-($-$$) db 0
db 0x55
db 0xAA

