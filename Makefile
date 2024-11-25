SHELL = /bin/bash
ARCH = riscv32-unknown-elf
CC = $(ARCH)-gcc
LD = $(ARCH)-ld
OBJCOPY = $(ARCH)-objcopy
IDIR = inc
SDIR = src
BDIR = build
#CFLAGS = -Wall -mcmodel=medany -g -I $(IDIR) -O0 -march=rv32ima -mabi=ilp32
CFLAGS = -Wall -mcmodel=medany -g -Wcast-align -ffreestanding -fno-pic -I $(IDIR) -O0 -march=rv32ima -mabi=ilp32
SFLAGS = -g -I $(IDIR) -march=rv32ima -mabi=ilp32
OBJCOPY = $(ARM)-objcopy
S_SRCS = $(wildcard $(SDIR)/*.s)
C_SRCS = $(wildcard $(SDIR)/*.c)
S_OBJS = $(S_SRCS:$(SDIR)/%.s=$(BDIR)/%_asm.o)
C_OBJS = $(C_SRCS:$(SDIR)/%.c=$(BDIR)/%.o)


all: clean kernel.img

kernel.img: kernel.elf
	$(OBJCOPY) kernel.elf -I binary kernel.img

kernel.elf: $(S_OBJS) link.ld $(C_OBJS)
	$(LD) -nostdlib -T link.ld -m elf32lriscv -o kernel.elf $(S_OBJS) $(C_OBJS)

$(BDIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BDIR)/%_asm.o: $(SDIR)/%.s
	$(CC) $(SFLAGS) -c $< -o $@

clean:
	rm -f $(BDIR)/*_asm.o $(BDIR)/*.o kernel.elf kernel.img

run: all
	qemu-system-riscv32 -machine virt -bios none -kernel kernel.elf -serial stdio -display none -smp 1 
#	qemu-system-riscv32 -nographic -machine virt -m 128M -bios none -kernel kernel.img -display none

debug: all
	qemu-system-riscv32 -machine virt -bios none -kernel kernel.elf -serial stdio -display none -s -S
	#terminator -e "qemu-system-riscv32 -M virt -kernel kernel.elf -bios none -serial stdio -display none -s -S" --new-tab
	#terminator -e "riscv32-unknown-elf-gdb kernel.elf" --new-tab

