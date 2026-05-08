; Mystique OS Kernel with Protected Mode
; Entry point at 0x10000

org 0x10000
bits 16

; GDT (Global Descriptor Table)
; A GDT defines memory segments and their access rights

gdt_start:
; GDT Entry 0: Null descriptor (required, never used)
dq 0x0000000000000000

; GDT Entry 1: Code segment (Ring 0, executable)
; Base: 0x00000000, Limit: 0xFFFFFF (4GB)
dw 0xFFFF; Limit (bits 0-15)
dw 0x0000; Base (bits 0-15)
db 0x00; Base (bits 16-23)
db 0b10011010; Access byte (present, ring 0, code, readable)
db 0b11001111; Flags (granularity, 32-bit)
db 0x00; Base (bits 24-31)

; GDT Entry 2: Data segment (Ring 0, writable)
; Base: 0x00000000, Limit: 0xFFFFFF (4GB)
dw 0xFFFF; Limit (bits 0-15)
dw 0x0000; Base (bits 0-15)
db 0x00; Base (bits 16-23)
db 0b10010010; Access byte (present, ring 0, data, writable)
db 0b11001111; Flags (granularity, 32-bit)
db 0x00; Base (bits 24-31)

gdt_end:

; GDT Descriptor (for LGDT instruction)
gdt_descriptor:
dw gdt_end - gdt_start - 1; GDT size - 1
dd gdt_start; GDT address

; Segment selectors
CODE_SEL equ 1 * 8; Code segment selector (entry 1 * 8)
DATA_SEL equ 2 * 8; Data segment selector (entry 2 * 8)

kernel_start:
; Set up 16-bit real mode segments for data
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0xFFFE

; Print message before entering protected mode
mov si, msg_before_pm
call print_string_16

; === ENTERING PROTECTED MODE ===

; Disable interrupts (to avoid issues during mode switch)
cli

; Load the GDT
lgdt [gdt_descriptor]

; Set the Protection Enable (PE) bit in CR0 to enable protected mode
mov eax, cr0
or eax, 0x1; Set PE bit (bit 0)
mov cr0, eax

; Far jump to flush CPU pipeline and enter protected mode
; This jumps to the next instruction using the code segment selector
jmp CODE_SEL:protected_mode_start

; This code runs in 32-bit protected mode
bits 32
protected_mode_start:
; Set up 32-bit protected mode segments
mov ax, DATA_SEL; Load data segment selector
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0xFFFE

; Print message in protected mode (using int 0x10 still works in many emulators)
mov esi, msg_after_pm
call print_string_32

; Hang in infinite loop
jmp $

; Print string in 16-bit real mode
; Input: si = pointer to string (null-terminated)
bits 16
print_string_16:
.loop:
lodsb
cmp al, 0
je .done

mov ah, 0x0E; Teletype output
mov bh, 0; Page number
mov bl, 0x07; Color attribute
int 0x10
jmp .loop
.done:
ret

; Print string in 32-bit protected mode
; Input: esi = pointer to string (null-terminated)
bits 32
print_string_32:
.loop:
lodsb
cmp al, 0
je .done

mov ah, 0x0E; Teletype output
mov bh, 0; Page number
mov bl, 0x07; Color attribute
int 0x10
jmp .loop
.done:
ret

; Messages
bits 16
msg_before_pm db "Kernel: Setting up protected mode...", 13, 10, 0
msg_after_pm db "Kernel: Protected mode enabled!", 13, 10, 0

; Pad kernel to at least 2 sectors (1024 bytes)
times 1024 - ($ - $$) db 0
