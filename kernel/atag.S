.global read_atags

.equiv ATAG_HIGH,		0x5441	@ high word of all ATAG values
.equiv ATAG_NONE,		0x0		@ ATAG_NONE does not use ATAG_HIGH!!
.equiv ATAG_CORE,		0x1
.equiv ATAG_MEM,		0x2
.equiv ATAG_VIDEOTEXT,	0x3
.equiv ATAG_RAMDISK,	0x4
.equiv ATAG_INITRD2,	0x5
.equiv ATAG_SERIAL,		0x6
.equiv ATAG_REVISION,	0x7
.equiv ATAG_VIDEOLFB,	0x8
.equiv ATAG_CMDLINE,	0x9

.section ".text"

@ Parses atags from address in r0
read_atags:
	stmia sp!, {r4, r5, r6, sl, fp}

1:
	ldr r6,[r0]  @ load size
	add r0,r0,#4
	ldr r4,[r0]  @ load tag
	add r0,r0,#4

	mov r5, #ATAG_HIGH
	cmp r5, r4, lsr #8
	bne 2f  @ unrecognised (high word is not #ATAG_HIGH)
	mov r5,#0xFFFF
	and r4,r4,r5

	@ Check tag type and determine where to store value
	cmp r4,#ATAG_CORE			@ if r4 == ATAG_CORE
	cmpne r4,#ATAG_MEM			@ else if r4 == ATAG_CORE
	cmpne r4,#ATAG_VIDEOTEXT	@ else if r4 == ATAG_VIDEOTEXT
	cmpne r4,#ATAG_RAMDISK		@ else if r4 == ATAG_RAMDISK
	cmpne r4,#ATAG_INITRD2		@ else if r4 == ATAG_INITRD2
	cmpne r4,#ATAG_SERIAL		@ else if r4 == ATAG_SERIAL
	cmpne r4,#ATAG_REVISION		@ else if r4 == ATAG_REVISION
	cmpne r4,#ATAG_VIDEOLFB		@ else if r4 == ATAG_VIDEOLFB
	cmpne r4,#ATAG_CMDLINE		@ else if r4 == ATAG_CMDLINE
	cmpne r4,#ATAG_NONE			@ else if r4 == ATAG_NONE
2:  @ else	

@	cmp r4,#ATAG_CORE  @ if r4 == ATAG_CORE
@	ite eq
@		nop
@	cmpne r4,#ATAG_MEM  @ else if r4 == ATAG_MEM
@	ite eq
@		nop
@	cmpne r4,#ATAG_VIDEOTEXT  @ else if r4 == ATAG_VIDEOTEXT
@	ite eq
@		nop
@	cmpne r4,#ATAG_RAMDISK  @ else if r4 == ATAG_RAMDISK
@	ite eq
@		@ we dont support ramdisks; do nothing
@		nop
@	cmpne r4,#ATAG_INITRD2  @ else if r4 == ATAG_INITRD2
@	ite eq
@		@ we dont support ramdicks; do nothing
@		nop
@	cmpne r4,#ATAG_SERIAL  @ else if r4 == ATAG_SERIAL
@	ite eq
@		nop
@	cmpne r4,#ATAG_REVISION  @ else if r4 == ATAG_REVISION
@	ite eq
@		nop
@	cmpne r4,#ATAG_VIDEOLFB  @ else if r4 == ATAG_VIDEOLFB
@	ite eq
@		nop
@	cmpne r4,#ATAG_CMDLINE  @ else if r4 == ATAG_CMDLINE
@	ite eq
@		nop
@	cmpne r4,#ATAG_NONE  @ else if r4 == ATAG_NONE
@	ite eq
@		@ end of list
@		beq 4f
@2:	@ else
@		@ unrecognised tag
@		nop

3:	@ Read data
	cmp r6,#0
	beq 1b  @ done reading data
	
	sub r6,r6,#1
	b 3b  @ keep reading data

	@ return
4:	ldmia sp!, {r4, r5, r6, sl, fp}
	bx lr

