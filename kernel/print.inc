; put char in al on screen with attribs in ah
putc:
	mov cx,ax
	
	; go to (x,y)
	movzx ax, byte [_putc_y]
	mov dx,160
	mul dx		; dx * ax
	movzx bx, byte [_putc_x]
	shl bx,1	; bx * 2

	; offset to correct position in text memory
	mov di,0
	add di,ax
	add di,bx

	; write char and attrib
	mov ax,cx
	stosw
	add byte [_putc_x],1

	ret

_putc_x	db 0
_putc_y	db 0

; puts
; draws the null terminated string at si in text video memory
_ch@puts:
	mov ah,0x0f
	call putc
puts:
	lodsb
	or al,al
	jz _end@puts
	jmp _ch@puts

_end@puts:
	; crlf
	add byte [_putc_y],1
	mov byte [_putc_x],0
	ret

; clears the text video buffer
clrscr:
	; set bx to size of buffer
	mov bx,4000
	
	; initialize cx and ax
	mov cx,0
	mov ax,0

_loop@clrscr:
	mov di,cx
	stosw
	add cx,2
	cmp cx,bx
	jl _loop@clrscr
	ret

