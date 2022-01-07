#ifndef _COMMON_H_
#define _COMMON_H_

#define OSNAME "Esoterix"
#define OSVER  "0.0.2"

#ifdef __ASSEMBLER__
/* asm-only */

// Saves the stack frame when entering a function
.macro SAVEFRAME
	mov ip,sp
	stmdb sp!, {fp, ip, lr}
	sub fp, ip, #3
.endm

// Restores the stack frame when exiting a function
.macro RESTOREFRAME
	ldm sp,{fp,sp,lr}
.endm

// loads address base+offset into dst
.macro ldoffset dst:req, base:req, offset:req
	ldr \dst,=\offset
	add \dst,\base,\dst
.endm

#else
/* C-only */

typedef unsigned char byte;

#endif  // __ASSEMBLER__

#endif  // _COMMON_H_

