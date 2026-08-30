#include <cstdint>

// --- 1. REGISTER DEFINITIONS (Extracted from RM0008) ---
#define PERIPH_BASE     0x40000000UL
#define APB2PERIPH_BASE (PERIPH_BASE + 0x10000UL)
#define RCC_BASE        (PERIPH_BASE + 0x21000UL)
#define GPIOA_BASE      (APB2PERIPH_BASE + 0x0800UL) // Updated to GPIOA (0x40010800)

struct RCC_TypeDef {
    volatile uint32_t CR, CFGR, CIR, APB2RSTR, APB1RSTR, AHBENR, APB2ENR, APB1ENR;
};
#define RCC ((RCC_TypeDef*)RCC_BASE)

struct GPIO_TypeDef {
    volatile uint32_t CRL, CRH, IDR, ODR, BSRR, BRR, LCKR;
};
#define GPIOA ((GPIO_TypeDef*)GPIOA_BASE)

// --- 2. BARE-METAL DRIVERS ---
extern "C" void _init(void) {
    // Dummy function to satisfy newlib's __libc_init_array
}

void gpio_init_pa8(void) {
    RCC->APB2ENR |= (1 << 2);          // Enable GPIOA clock (Bit 2 is IOPAEN)
    
    // PA8 is controlled by the first 4 bits of CRH (Bits 0-3)
    GPIOA->CRH &= ~(0xF << 0);         // Clear PA8 config
    GPIOA->CRH |=  (0x1 << 0);         // PA8: Output 10MHz Push-Pull (MODE=01, CNF=00)
}

void delay(volatile uint32_t count) {
    while(count--) {
        __asm__ volatile ("nop");
    }
}

// --- 3. MAIN APPLICATION ---
extern "C" int main(void) { 
    gpio_init_pa8();
    
    while (true) {
        GPIOA->BSRR = (1 << 8);         // PA8 HIGH (LED ON for Active-High)
        delay(500000);
        GPIOA->BSRR = (1 << (8 + 16));  // PA8 LOW (LED OFF)
        delay(500000);
    }
    return 0;
}
// extern "C" void _init(void) {
//     // Dummy function to satisfy newlib's __libc_init_array
// }