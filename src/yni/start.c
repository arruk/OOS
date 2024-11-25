#include "main.h"
#include "riscv.h"
#include "stdint.h"
#include "timer.h"

// extern void timervec();
extern void trap_entry();

void start() {
    // set M Previous Privilege mode to Supervisor, for mret.
    unsigned long x = r_mstatus();
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    w_mstatus(x);

    // set M Exception Program Counter to main, for mret.
    // requires gcc -mcmodel=medany
    w_mepc((uint32_t)main);

    // disable paging for now.
    //w_satp(0);

    // physical memory protection
    //w_pmpcfg0(0xf);
    //w_pmpaddr0(0xffffffff);

    // delegate all interrupts and exceptions to supervisor mode.
    //w_medeleg(0xffff);
    //w_mideleg(0xffff);

    // setup trap_entry
    w_mtvec((uint32_t)trap_entry);

    // keep each CPU's hartid in its tp register, for cpuid().
    int id = r_mhartid();
    w_tp(id);

    timer_init();

    // switch to supervisor mode and jump to main().
    asm volatile("mret");
}
