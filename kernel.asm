; Mystique OS Kernel - Minimal Protected Mode Test
; Entry point at 0x10000

org 0x10000
bits 16

; GDT
gdt_start:
dq 0x0000000000000000

dw 0xFFFF
dw 0x0000
db 0x00
db 0b10011010
db 0b11001111
db 0x00

dw 0xFFFF
dw 0x0000
db 0x00
db 0b10010010
db 0b11001111
db 0x00

gdt_end:

gdt_descriptor:
dw gdt_end - gdt_start - 1
dd gdt_start

CODE_SEL equ 8
DATA_SEL equ 16

kernel_start:
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0xFFFE

; Print using BIOS (we know this works)
mov al, 'K'
mov ah, 0x0E
int 0x10

mov al, 'E'
mov ah, 0x0E
int 0x10

mov al, 'R'
mov ah, 0x0E
int 0x10

; Now try to enter protected mode
cli

; Load GDT
lgdt [gdt_descriptor]

; Set PE bit
mov eax, cr0
or eax, 1
mov cr0, eax

; Far jump to protected mode (using explicit absolute address)
jmp CODE_SEL:protected_start_abs

bits 32
protected_start_abs:
mov ax, DATA_SEL
mov ds, ax
mov es, ax
mov ss, ax

; Write "Protected Mode Enabled!" to video memory at 0xB8000
mov edi, 0xB8000
mov esi, pm_msg
mov ecx, pm_msg_len

.write_loop:
cmp ecx, 0
je .done_msg
mov al, byte [esi]
mov byte [edi], al
mov byte [edi + 1], 0x0F  ; White text on black background
add edi, 2
add esi, 1
dec ecx
jmp .write_loop

.done_msg:
jmp $

pm_msg db "Protected Mode Enabled!"
pm_msg_len equ $ - pm_msg

times 1024 - ($ - $$) db 0
