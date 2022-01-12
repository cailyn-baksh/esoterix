#ifndef _COMMON_H_
#define _COMMON_H_

#define OSNAME "Esoterix"
#define OSVER  "0.0.2"

#ifdef __ASSEMBLER__
/* asm-only */

#else
/* C-only */

#include <stdint.h>

/*
 * Kernel panic. Prints the error code and halts the kernel.
 */
_Noreturn void panic(uint32_t code);

#endif  // __ASSEMBLER__

#endif  // _COMMON_H_

