.include "board.inc"
.include "atags.inc"

.global _start
.global mmio_base
.global board_type

.org 0x8000
.syntax unified
.thumb

.section ".rodata"

@ Hardware data structures.
@ These structures define hardware-specific constants for every
@ supported board
@
@ byte ID
@   Board identifier
@ dword MMIO_BASE
@   MMIO base address
@ str BOARD_NAME
@   null terminated string with board name. Since this is the last
@   element its size is irrelevant

@ Raspberry Pi 1
rpi1_data:
.byte BOARD_RPI1
.4byte 0x20000000
.asciz "Raspi1"

@ Raspberry Pi 2
rpi2_data:
.byte BOARD_RPI2
.4byte 0x3F000000
.asciz "Raspi2"

@ Raspberry Pi 3
rpi3_data:
.byte BOARD_RPI3
.4byte 0x3F000000
.asciz "Raspi3"

@ Raspberry Pi 4
rpi4_data:
.byte BOARD_RPI4
.4byte 0xFE000000
.asciz "Raspi4"

.section ".data"

@ Address of hardware data struct
boardDataStructPtr: .4byte 0

.section ".text.boot"

_start:
	@ disable all cores except core 0
	mrc p15,0,r5,c0,c0,5
	and r5,r5,#3
	cmp r5,#0
	bne halt

	@ init stack
	mov sp,#0x8000
	
	@ check board version
	mrc p15,0,r5,c0,c0,0

	@ Rpi 1
	mov r4,#0xB76
	cmp r5,r4
	beq 1f

	@ Rpi 2
	mov r4,#0xC07
	cmp r5,r4
	beq 2f

	@ Rpi 3
	mov r4,#0xD03
	cmp r5,r4
	beq 3f

	@ Rpi 4
	mov r4,#0xD08
	cmp r5,r4
	beq 3f

	@ Unknown board
	b halt

1:
	ldr r3,=rpi1_data
	b 5f
2:
	ldr r3,=rpi2_data
	b 5f
3:
	ldr r3,=rpi3_data
	b 5f
4:
	ldr r3,=rpi4_data
5:
	ldr r4,=boardDataStructPtr
	str r3,[r4]

	@ handle ATAGs
6:
	ldr r3,[r2]  @ load size
	add r2,r2,4
	ldr r4,[r2]  @ load tag

	mov r5, #ATAG_HIGH
	tst r4, r5, lsl #8
	beq 7f  @ r4 & 0x54410000 sets zero flag; unrecognised
	and r4,r4,#0xFF
	and r4,r4,#0xFF00

	@ Check tag type and determine where to store value
	cmp r4,#ATAG_CORE  @ if r4 == ATAG_CORE
	ite eq
		nop
	cmpne r4,#ATAG_MEM  @ else if r4 == ATAG_MEM
	ite eq
		nop
	cmpne r4,#ATAG_VIDEOTEXT  @ else if r4 == ATAG_VIDEOTEXT
	ite eq
		nop
	cmpne r4,#ATAG_RAMDISK  @ else if r4 == ATAG_RAMDISK
	ite eq
		nop
	cmpne r4,#ATAG_INITRD2  @ else if r4 == ATAG_INITRD2
	ite eq
		nop
	cmpne r4,#ATAG_SERIAL  @ else if r4 == ATAG_SERIAL
	ite eq
		nop
	cmpne r4,#ATAG_REVISION  @ else if r4 == ATAG_REVISION
	ite eq
		nop
	cmpne r4,#ATAG_VIDEOLFB  @ else if r4 == ATAG_VIDEOLFB
	ite eq
		nop
	cmpne r4,#ATAG_CMDLINE  @ else if r4 == ATAG_CMDLINE
	ite eq
		nop
	cmpne r4,#ATAG_NONE  @ else if r4 == ATAG_NONE
	ite eq
		@ end of list
		nop
7:	@ else
		@ unrecognised tag
		nop 

	@ Read data
8:
	

	b kernel_main

.section ".text"

kernel_main:
	

halt:
	wfe
	b _start

