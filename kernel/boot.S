.section ".text.boot"
.globl _start
.org 0x8000

_start:
	mrc p15,0,r5,c0,c0,5
	and r5,r5,#3
	cmp r5,#0
	bne halt
	
halt:
	wfe
	b _start
