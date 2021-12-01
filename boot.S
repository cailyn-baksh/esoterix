[ORG 0x7c00]

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
	mov bp,15
	jmp $

bootmsg	db "Starting BF/M",13,10,0

; Prints the string at si
bprint:
	lodsb
	or al,al
	jz _end@bprint
	mov ah,0x0E
	mov bh,0
	int 0x10
	jmp bprint
_end@bprint:
	ret

times 510-($-$$) db 0
db 0x55
db 0xAA

