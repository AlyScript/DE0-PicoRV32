#!/bin/bash

/opt/riscv/bin/riscv64-unknown-elf-gcc -mno-save-restore -march=rv32i2p0 -mabi=ilp32 -nostartfiles -O1 -nostdlib --static -c main.c -o main.o

/opt/riscv/bin/riscv64-unknown-elf-gcc -mno-save-restore -march=rv32i2p0 -mabi=ilp32 -nostartfiles -O1 -nostdlib --static -c entry.S -o start.o

/opt/riscv/bin/riscv64-unknown-elf-gcc -o prog.elf -Tlink.ld     -march=rv32i2p0 -mabi=ilp32     -nostartfiles -nostdlib     start.o main.o

/opt/riscv/bin/riscv64-unknown-elf-objcopy -O binary prog.elf prog.bin          

srec_cat prog.bin -binary -offset 0x0 -o blinker.hex -intel
