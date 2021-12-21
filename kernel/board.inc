.equiv BOARD_RPI1,0x0
.equiv BOARD_RPI2,0x1
.equiv BOARD_RPI3,0x2
.equiv BOARD_RPI4,0x3

@ GPIO register offsets from MMIO_BASE
.equiv GPFSEL0_OFFSET,		0x200000
.equiv GPFSEL1_OFFSET,		0x200004
.equiv GPFSEL2_OFFSET,		0x200008
.equiv GPFSEL3_OFFSET,		0x20000C
.equiv GPFSEL4_OFFSET,		0x200010
.equiv GPFSEL5_OFFSET,		0x200014

.equiv GPSET0_OFFSET,		0x20001C
.equiv GPSET1_OFFSET,		0x200020

.equiv GPCLR0_OFFSET,		0x200028
.equiv GPCLR1_OFFSET,		0x20002C

.equiv GPLEV0_OFFSET,		0x200034
.equiv GPLEV1_OFFSET,		0X200038

.equiv GPEDS0_OFFSET,		0x200040
.equiv GPEDS1_OFFSET,		0x200044

.equiv GPREN0_OFFSET,		0x20004C
.equiv GPREN1_OFFSET,		0x200050

.equiv GPFEN0_OFFSET,		0x200058
.equiv GPFEN1_OFFSET,		0x20005C

.equiv GPHEN0_OFFSET,		0x200064
.equiv GPHEN1_OFFSET,		0x200068

.equiv GPLEN0_OFFSET,		0x200070
.equiv GPLEN1_OFFSET,		0x200074

.equiv GPAREN0_OFFSET,		0x20007C
.equiv GPAREN1_OFFSET,		0x200080

.equiv GPAFEN0_OFFSET,		0x200088
.equiv GPAFEN1_OFFSET,		0x20008C

.equiv GPPUD_OFFSET,		0x200094
.equiv GPPUDCLK0_OFFSET,	0x200098
.equiv GPPUDCLK1_OFFSET,	0x20009C

@ offsets from MMIO_BASE
.equiv AUX_ENABLE_OFFSET,		0x00215004
.equiv AUX_MU_IO_OFFSET,		0x00215040  @ TODO: figure out what these names stand for and rename them appropriately
.equiv AUX_MU_IIR_OFFSET,		0x00215044
.equiv AUX_MU_IER_OFFSET,		0x00215048
.equiv AUX_MU_LCR_OFFSET,		0x0021504C
.equiv AUX_MU_MCR_OFFSET,		0x00215050
.equiv AUX_MU_LSR_OFFSET,		0x00215054
.equiv AUX_MU_MSR_OFFSET,		0x00215058


.equiv AUX_MU_SCRATCH_OFFSET,	0x0021505C
.equiv AUX_MU_CNTL_OFFSET,		0x00215060
.equiv AUX_MU_STAT_OFFSET,		0x00215064
.equiv AUX_MU_BAUD_OFFSET,		0x00215068

@ Reads property from selected HWDATA struct into reg
.macro gethwdata reg:req,property:req
	ldr \reg,=boardDataStructPtr
	ldr \reg,[\reg]
	.if "\property"=="id"
		ldr \reg,[\reg]
	.elseif "\property"=="mmio_base"
		ldr \reg,[\reg, #1]
	.elseif "\property"=="board_name"
		ldr \reg,[\reg, #5]
	.endif
.endm

