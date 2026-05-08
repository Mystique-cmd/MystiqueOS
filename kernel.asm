; Mystique OS Kernel with Protected Mode
; Entry point at 0x10000

org 0x10000
bits 16

; GDT (Global Descriptor Table)
gdt_start:
; GDT Entry 0: Null descriptor
dq 0x0000000000000000

; GDT Entry 1: Code segment (Ring 0)
dw 0xFFFF; Limit (bits 0-15)
dw 0x0000; Base (bits 0-15)
db 0x00; Base (bits 16-23)
db 0b10011010; Access byte
db 0b11001111; Flags
db 0x00; Base (bits 24-31)

; GDT Entry 2: Data segment (Ring 0)
dw 0xFFFF; Limit (bits 0-15)
dw 0x0000; Base (bits 0-15)
db 0x00; Base (bits 16-23)
db 0b10010010; Access byte
db 0b11001111; Flags
db 0x00; Base (bits 24-31)

gdt_end:

; GDT Descriptor
gdt_descriptor:
dw gdt_end - gdt_start - 1
dd gdt_start

CODE_SEL equ 1 * 8
DATA_SEL equ 2 * 8

kernel_start:
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0xFFFE

; Print message before entering protected mode using BIOS
mov si, msg_before_pm
call print_string_bios

; === ENTERING PROTECTED MODE ===
cli
lgdt [gdt_descriptor]

mov eax, cr0
or eax, 0x1
mov cr0, eax

jmp CODE_SEL:protected_mode_start

bits 32
protected_mode_start:
mov ax, DATA_SEL
mov ds, ax
mov es, ax
mov ss, ax
mov esp, 0xFFFE

; Write directly to video memory (no BIOS needed)
; Video memory starts at 0xB8000
mov edi, 0xB8000
mov esi, msg_after_pm_offset
call print_string_pm

; Infinite loop
jmp $

; BIOS print (real mode only)
bits 16
print_string_bios:
.loop:
lodsb
cmp al, 0
je .done

mov ah, 0x0E
mov bh, 0
mov bl, 0x07
int 0x10
jmp .loop
.done:
ret

; Protected mode print using video memory
; Input: edi = video memory address, esi = string offset from kernel start
bits 32
print_string_pm:
add esi, 0x10000; Convert offset to absolute address
.loop:
mov al, [esi]
cmp al, 0
je .done

; Write character and attribute to video memory
mov byte [edi], al; Character
mov byte [edi + 1], 0x0F; Attribute (white on black)
add edi, 2
add esi, 1
jmp .loop
.done:
ret

bits 16
msg_before_pm db "Kernel: Setting up protected mode...", 13, 10, 0

; Message location relative to kernel start
msg_after_pm_offset equ msg_after_pm - kernel_start
msg_after_pm db "Kernel: Protected mode enabled!", 0

; Pad kernel to 2 sectors
times 1024 - ($ - $$) db 0
