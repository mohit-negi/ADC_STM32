.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.global Reset_Handler

.section .isr_vector
.word _estack          @ Initial Stack Pointer
.word Reset_Handler    @ Reset Handler

.text
Reset_Handler:
    ldr sp, =_estack
    bl __libc_init_array @ Initialize C++ global constructors
    bl main              @ Call main
    b .                  @ Infinite loop if main returns