.text
.globl _start 

_start:
    li t0, 0x23544
    li t1, 25
    sll a0, t0, t1
    ebreak
