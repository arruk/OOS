
.globl kerneltrap
.globl kernelvec
.align 2
kernelvec:
        # make room to save registers.
        #addi sp, sp, -256
        addi sp, sp, -128

        # save the registers.
        sw ra, 0(sp)
        sw sp, 4(sp)
        sw gp, 8(sp)
        sw tp, 12(sp)
        sw t0, 16(sp)
        sw t1, 20(sp)
        sw t2, 24(sp)
        sw s0, 28(sp)
        sw s1, 32(sp)
        sw a0, 36(sp)
        sw a1, 40(sp)
        sw a2, 44(sp)
        sw a3, 48(sp)
        sw a4, 52(sp)
        sw a5, 56(sp)
        sw a6, 60(sp)
        sw a7, 64(sp)
        sw s2, 68(sp)
        sw s3, 72(sp)
        sw s4, 76(sp)
        sw s5, 80(sp)
        sw s6, 84(sp)
        sw s7, 88(sp)
        sw s8, 92(sp)
        sw s9, 96(sp)
        sw s10, 100(sp)
        sw s11, 104(sp)
        sw t3, 108(sp)
        sw t4, 112(sp)
        sw t5, 116(sp)
        sw t6, 120(sp)

	# call the C trap handler in trap.c
        # call kerneltrap

        # restore registers.
        lw ra, 0(sp)
        lw sp, 4(sp)
        lw gp, 8(sp)
        # not this, in case we moved CPUs: lw tp, 24(sp)
        lw tp, 12(sp)
        lw t0, 16(sp)
        lw t1, 20(sp)
        lw t2, 24(sp)
        lw s0, 28(sp)
        lw s1, 32(sp)
        lw a0, 36(sp)
        lw a1, 40(sp)
        lw a2, 44(sp)
        lw a3, 48(sp)
        lw a4, 52(sp)
        lw a5, 56(sp)
        lw a6, 60(sp)
        lw a7, 64(sp)
        lw s2, 68(sp)
        lw s3, 72(sp)
        lw s4, 76(sp)
        lw s5, 80(sp)
        lw s6, 84(sp)
        lw s7, 88(sp)
        lw s8, 92(sp)
        lw s9, 96(sp)
        lw s10, 100(sp)
        lw s11, 104(sp)
        lw t3, 108(sp)
        lw t4, 112(sp)
        lw t5, 116(sp)
        lw t6, 120(sp)

        addi sp, sp, 128

        # return to whatever we were doing in the kernel.
        sret

        #
        # machine-mode timer interrupt.
        #

.globl trap_entry
.align 2
trap_entry:
        # make room to save registers.
        addi sp, sp, -128

        # save the registers.
        sw ra, 0(sp)
        sw sp, 4(sp)
        sw gp, 8(sp)
        sw tp, 12(sp)
        sw t0, 16(sp)
        sw t1, 20(sp)
        sw t2, 24(sp)
        sw s0, 28(sp)
        sw s1, 32(sp)
        sw a0, 36(sp)
        sw a1, 40(sp)
        sw a2, 44(sp)
        sw a3, 48(sp)
        sw a4, 52(sp)
        sw a5, 56(sp)
        sw a6, 60(sp)
        sw a7, 64(sp)
        sw s2, 68(sp)
        sw s3, 72(sp)
        sw s4, 76(sp)
        sw s5, 80(sp)
        sw s6, 84(sp)
        sw s7, 88(sp)
        sw s8, 92(sp)
        sw s9, 96(sp)
        sw s10, 100(sp)
        sw s11, 104(sp)
        sw t3, 108(sp)
        sw t4, 112(sp)
        sw t5, 116(sp)
        sw t6, 120(sp)

        call handle_trap
  
        # restore registers.
        lw ra, 0(sp)
        lw sp, 4(sp)
        lw gp, 8(sp)
        # not this, in case we moved CPUs: lw tp, 24(sp)
        lw tp, 12(sp)
        lw t0, 16(sp)
        lw t1, 20(sp)
        lw t2, 24(sp)
        lw s0, 28(sp)
        lw s1, 32(sp)
        lw a0, 36(sp)
        lw a1, 40(sp)
        lw a2, 44(sp)
        lw a3, 48(sp)
        lw a4, 52(sp)
        lw a5, 56(sp)
        lw a6, 60(sp)
        lw a7, 64(sp)
        lw s2, 68(sp)
        lw s3, 72(sp)
        lw s4, 76(sp)
        lw s5, 80(sp)
        lw s6, 84(sp)
        lw s7, 88(sp)
        lw s8, 92(sp)
        lw s9, 96(sp)
        lw s10, 100(sp)
        lw s11, 104(sp)
        lw t3, 108(sp)
        lw t4, 112(sp)
        lw t5, 116(sp)
        lw t6, 120(sp)

        addi sp, sp, 128 

        mret

.globl timervec
.align 2
timervec:
        # start.c has set up the memory that mscratch points to:
        # scratch[0,8,16] : register save area.
        # scratch[32] : address of CLINT's MTIMECMP register.
        # scratch[40] : desired interval between interrupts.
        
        csrrw a0, mscratch, a0
        sw a1, 0(a0)
        sw a2, 8(a0)
        sw a3, 16(a0)

        # schedule the next timer interrupt
        # by adding interval to mtimecmp.
        lw a1, 32(a0) # CLINT_MTIMECMP(hart)
        lw a2, 40(a0) # interval
        lw a3, 0(a1)
        add a3, a3, a2
        sw a3, 0(a1)

        # raise a supervisor software interrupt.
	li a1, 2
        csrw sip, a1

        lw a3, 16(a0)
        lw a2, 8(a0)
        lw a1, 0(a0)
        csrrw a0, mscratch, a0

        mret
