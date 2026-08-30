#include <cstdint>

// --- 1. REGISTER DEFINITIONS (Extracted from RM0008) ---
#define PERIPH_BASE     0x40000000UL
#define APB2PERIPH_BASE (PERIPH_BASE + 0x10000UL)
#define RCC_BASE        (PERIPH_BASE + 0x21000UL)
#define GPIOC_BASE      (APB2PERIPH_BASE + 0x1000UL)

struct RCC_TypeDef {
    volatile uint32_t CR, CFGR, CIR, APB2RSTR, APB1RSTR, AHBENR, APB2ENR, APB1ENR;
};
#define RCC ((RCC_TypeDef*)RCC_BASE)

struct GPIO_TypeDef {
    volatile uint32_t CRL, CRH, IDR, ODR, BSRR, BRR, LCKR;
};
#define GPIOC ((GPIO_TypeDef*)GPIOC_BASE)

// --- 2. BARE-METAL DRIVERS ---
void gpio_init_pc13(void) {
    RCC->APB2ENR |= (1 << 4);          // Enable GPIOC clock (Bit 4)
    GPIOC->CRH &= ~(0xF << 20);        // Clear PC13 config (Bits 20-23)
    GPIOC->CRH |=  (0x1 << 20);        // PC13: Output 2MHz Push-Pull (MODE=01, CNF=00)
}

void delay(volatile uint32_t count) {
    while(count--) {}
}

// --- 3. MAIN APPLICATION ---
extern "C" int main(void) { // extern "C" prevents C++ name mangling
    gpio_init_pc13();
    
    while (true) {
        GPIOC->BSRR = (1 << (13 + 16)); // PC13 LOW (LED ON for Blue Pill)
        delay(500000);
        GPIOC->BSRR = (1 << 13);        // PC13 HIGH (LED OFF)
        delay(500000);
    }
    return 0;
}