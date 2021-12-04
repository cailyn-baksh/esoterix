cpu 8086
org 0x500

mov al,0x41
mov ah,0x0E
mov bh,0
int 0x10
jmp $

cli
times 512-($-$$) db 0
