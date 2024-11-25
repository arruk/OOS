//#include <timer.h>

//#include "encoding.h"
//#include "kalloc.h"
//#include "kvm.h"
//#include "mm.h"
#include "trap.h"
#include "uart.h"

int main() {
	uart_init();
	//    kinit();
	//    kvminit();
	//    kvminithart();
	//    paginginit();
	print_s("Hello world!\n");
	print_s("Raise exception to enable timer...\n");
	asm volatile("ecall");
	print_s("Back to user mode\n");
	while (1){
		print_c((char)uart_get());
	}
	return 0;
}
