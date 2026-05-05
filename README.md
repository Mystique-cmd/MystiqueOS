# Mystique OS Bootloader

A minimal 512-byte x86 boot sector that displays a welcome message.

## Prerequisites

Before running the bootloader, ensure you have the following tools installed:

- **NASM** (Netwide Assembler) - to assemble the `.asm` file
- **QEMU** (Quick Emulator) - to emulate and run the bootloader

### Installing Dependencies

**On Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install nasm qemu-system-x86
```

**On Fedora/RHEL:**
```bash
sudo dnf install nasm qemu-system-x86
```

**On macOS (using Homebrew):**
```bash
brew install nasm qemu
```

**On Windows:**
- Download NASM from https://www.nasm.us/
- Download QEMU from https://www.qemu.org/download/

## Running the Bootloader

### Step 1: Assemble the Bootloader

Convert the assembly source file into a bootable binary:

```bash
nasm -f bin bootloader.asm -o bootloader.bin
```

This creates a `bootloader.bin` file (512 bytes).

### Step 2: Run in QEMU

Boot the binary in QEMU emulator:

```bash
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
```

### Expected Output

A QEMU window will open showing:
```
Hellow, Welcome to Mystique OS!
```

The bootloader will then enter an infinite loop and wait (this is normal). To exit QEMU, press `Ctrl+Alt+Q` or close the window.

## What the Bootloader Does

1. **Initializes registers** - Sets up segment registers and stack pointer
2. **Prints a message** - Displays "Hellow, Welcome to Mystique OS!" using BIOS interrupt 0x10
3. **Infinite loop** - Uses `jmp $` to wait indefinitely

## Files

- `bootloader.asm` - The assembly source code
- `bootloader.bin` - The compiled binary (created after running Step 1)
- `README.md` - This file

## Quick Start

```bash
# Assemble
nasm -f bin bootloader.asm -o bootloader.bin

# Run
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
```
