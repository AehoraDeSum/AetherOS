.section .text._start,"ax"
.global _start
.type _start,%function

_start:
    b stage0_entry

.size _start, . - _start
