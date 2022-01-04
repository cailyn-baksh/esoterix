#define NOEXTERN
#include "board.h"
#undef NOEXTERN

const HWData boards[4] = {
	{
		.name = "Raspi1",
		.mmio_base = 0x20000000
	},
	{
		.name = "Raspi2",
		.mmio_base = 0x3F000000
	},
	{
		.name = "Raspi3",
		.mmio_base = 0x3F000000
	},
	{
		.name = "Raspi4",
		.mmio_base = 0x3f000000
	}
};

HWData *board = NULL;

