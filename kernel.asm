; Mystique OS Kernel
; Entry point at 0x10000

org 0x10000
bits 16

kernel_start:
	; Set up basic segments for kernel
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0xFFFE
	
	; Print kernel message
	mov si, kernel_msg
	call print_string
	
	; Hang in infinite loop
	jmp $

; Print string
; Input: si = pointer to string (null-terminated)
print_string:
.loop:
	lodsb
	cmp al, 0
	je .done
	
	mov ah, 0x0E			; Teletype output
	mov bh, 0			; Page number
	mov bl, 0x07			; Color attribute
	int 0x10
	jmp .loop
.done:
	ret

kernel_msg db "Kernel loaded and running!", 13, 10, 0

; Pad kernel to at least one sector (512 bytes)
times 512 - ($ - $$) db 0
