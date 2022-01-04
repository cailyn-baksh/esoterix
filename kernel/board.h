#ifndef _BOARD_H_
#define _BOARD_H_

#ifndef __ASSEMBLER__

#include <stddef.h>
#include <stdint.h>

/*
 * Hardware-specific constants for every supported board
 *
 * name
 *   A human-readable name for this board
 * mmio_base
 *   A pointer to the beginning of memory-mapped I/O
 */
typedef struct {
	char name[8];
	int : 8;  // make room for errant null terminators
	void *mmio_base;
} HWData;

#ifndef NOEXTERN
extern const HWData boards[4];

extern HWData *board;
#endif  // NOEXTERN

#endif  // __ASSEMBLER__
#endif  // _BOARD_H_

