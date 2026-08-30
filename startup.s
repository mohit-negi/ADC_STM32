.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.global Reset_Handler
.type Reset_Handler, %function   @ <-- CRITICAL: Tells linker to set the Thumb bit (LSB = 1)

.section .isr_vector, "a", %progbits  @ Ensures the section is allocated
.word _estack                    @ Initial Stack Pointer
.word Reset_Handler              @ Reset Handler

.text
.align 2
Reset_Handler:
    ldr sp, =_estack
    bl __libc_init_array         @ Initialize C++ global constructors
    bl main                      @ Call main
    b .                          @ Infinite loop if main returns