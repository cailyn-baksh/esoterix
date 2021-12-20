ENTRY(_start)

SECTIONS
{
	. = 0x8000;
	__start = .;
	.text :
	{
		*(.text)
	}
	. = ALIGN(4096);

	.rodata :
	{
		*(.rodata)
	}
	. = ALIGN(4096);

	.data :
	{
		*(.data)
	}
	. = ALIGN(4096);
	__end = .;
}
