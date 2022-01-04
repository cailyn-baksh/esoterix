.include "board.inc"
.include "utils.inc"

.global mbox_call

@ I can't figure out how this works, and i cant find good documentation on it or on
@ the mailbox interface.
@ Taken from https://github.com/bztsrc/raspi3-tutorial/blob/master/04_mailboxes/mbox.c

@ Takes a mailbox channel in r0, returns 0 in r0 on failure, non-zero otherwise
mbox_call:
	SAVEFRAME
	push {r4, r5, r6, r7}

	@ Store address of mailbox channel
	ldr r4,=mboxBuffer
	bic r4,r4,#0xF
	and r0,r0,#0xF
	orr r4,r4,r0

	gethwdata r6,"mmio_base"
	ldoffset r5,r6,#MBOX_STATUS_OFFSET
1:
	nop
	ldr r7,[r5]
	tst r7,#MBOX_FULL
	bne 1b

	@ write to mailbox
	ldoffset r5,r6,#MBOX_WRITE_OFFSET
	str r4,[r5]

	@ Wait for a response
	ldoffset r5,r6,#MBOX_STATUS_OFFSET
	ldoffset r6,r6,#MBOX_READ_OFFSET
2:
	nop
	ldr r7,[r5]
	tst r7,#MBOX_EMPTY
	bne 2b

	
	ldr r7,[r6]
	cmp r4,r7
	bne 2b

	ldr r7,=mboxBuffer
	ldr r6,[r7, #4]
	cmp r6,#MBOX_RESPONSE
	moveq r0,#1
	movne r0,#0

0:
	pop {r4, r5, r6, r7}
	RESTOREFRAME
	bx lr	

