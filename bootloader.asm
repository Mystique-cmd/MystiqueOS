; This is a minimal 512-byte boot sector
 org 0x7C00
 address 0x7C00
 
 bits 16
;--The use of the  16 bit registers is because the CPU starts in real mode during boot 
 start:
 	xor ax, ax
 	mov ds, ax
 	mov ex, ax
 	mov ss, ax
 	mov sp, 0x7C00
 	
 	mov si, message
 	call print_string
 	
 	jmp $
 print_string:
 .loop:
 	lodsb
 	cmp al, 0
 	je .done
 	
 	mov ah, 0x0E
 	mov bh, 0	;--Page Number
 	mov bl, 0x07 ;--Color attribute
 	int 0x10
 	jmp .loop
 .done:
 	ret
 	
 message db "Hello, Welcome to Mystique OS!"
 times 510 - ($ - $$) db 0
 dw 0xAA55
