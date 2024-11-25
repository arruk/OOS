#include "riscv.h"
#include "uart.h"
#define CLINT_BASE 0x2000000
#define MTIME (volatile unsigned long long int *)(CLINT_BASE + 0xbff8)
#define MTIMECMP (volatile unsigned long long int *)(CLINT_BASE + 0x4000)

void timer_init() {
    *MTIMECMP = *MTIME + 0xfffff * 5;
    uint32_t mie = MIE_MTIE;
    asm volatile("csrs mie, %0" : : "r"(mie));
}

void timer_fini() {
	uint32_t mie = MIE_MTIE;
	asm volatile("csrc mie, %0" : : "r"(mie));
}
