SECTIONS
{
	. = 0x8000;
	.text :
	{
		KEEP(*(.text.boot))
		*(.text)
	}
	. = ALIGN(4096);
}
