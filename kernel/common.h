#ifndef _COMMON_H_
#define _COMMON_H_

#define OSNAME "Esoterix"
#define OSVER  "0.0.2"

#ifdef __ASSEMBLER__
/* asm-only */

// TODO: remove and replace these
// Saves the stack frame when entering a function
.macro SAVEFRAME
	mov ip,sp
	stmdb sp!, {fp, ip, lr}
	sub fp, ip, #3
.endm

// Restores the stack frame when exiting a function
.macro RESTOREFRAME
	ldm sp, {fp,sp,lr}
.endm

// logical shift left 64-bit register Ry:Rx
.macro lsl64 Rx:req, Ry:req, sh:req
    lsl \Ry,\Ry,\sh
    lsls \Rx,\Rx,\sh
    adc \Ry,\Ry,#0
.endm

// logical shift right 64-bit register Ry:Rx
.macro lsr64 Rx:req, Ry:req, sh:req
    lsr \Rx,\Rx,\sh
    lsrs \Ry,\Ry,\sh
    adc \Rx,\Rx,#0
.endm

#else
/* C-only */

#include <stdint.h>

/*
 * Kernel panic. Prints the error code and halts the kernel.
 */
_Noreturn void panic(uint32_t code);

#endif  // __ASSEMBLER__

#endif  // _COMMON_H_

