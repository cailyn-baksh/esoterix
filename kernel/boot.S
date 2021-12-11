.section ".text.boot"
.globl _start
.org 0x8000

_start:
	wfe
	b _start
