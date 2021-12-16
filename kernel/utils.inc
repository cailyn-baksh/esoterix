@ Utility macros

@ Moves int32 into register
.macro mov32 reg:req,val:req
	mov \reg,\val & 0xFFFF
	movt \reg, \val >> 16
.endm

@ loads address base+offset into dst
.macro ldoffset dst:req, base:req, offset:req
	mov32 \dst,\offset
	add \dst,\base,\dst
.endm

