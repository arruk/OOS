//#include "encoding.h"
#include "riscv.h"
#include "uart.h"
#include "timer.h"
#define CLINT_BASE 0x2000000
#define MTIME (volatile unsigned long long int *)(CLINT_BASE + 0xbff8)
#define MTIMECMP (volatile unsigned long long int *)(CLINT_BASE + 0x4000)

int count = 0;

void handle_interrupt(uint32_t mcause) {
	
	// machine timer interrupt
	if ((mcause << 1 >> 1) == 0x7) {
		print_s("Timer Interrupt: ");
		print_i(++count);
		print_s("\n");

		*MTIMECMP = *MTIME + 0xfffff * 5;
		if (count == 10) {
			timer_fini();
			uint32_t mie = MIE_MEIE;
			asm volatile ("csrs mie, %0" : : "r"(mie));
		}
	} else {
		print_s("Unknown interrupt: ");
		print_i(mcause << 1 >> 1);
		print_s("\n");
		while (1)
			;
	}
}

void handle_exception(uint32_t mcause) {
	
	// environment call from M-mode
	if (mcause == 0xb) {
		timer_init();
	} else {
		print_s("Unknown exception: ");
		print_i(mcause << 1 >> 1);
		print_s("\n");
		while (1)
			;
	}
}

void handle_trap() {
	uint32_t mcause, mepc;
	asm volatile("csrr %0, mcause" : "=r"(mcause));
	asm volatile("csrr %0, mepc" : "=r"(mepc));

	if (mcause >> 31) {
		handle_interrupt(mcause);
	} else {
		handle_exception(mcause);
		asm volatile("csrr t0, mepc");
		asm volatile("addi t0, t0, 0x4");
		asm volatile("csrw mepc, t0");
	}
}
