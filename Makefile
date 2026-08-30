##########################################################################################################################
# Modified Bare-Metal C++ Makefile
##########################################################################################################################

TARGET = blink_baremetal
DEBUG = 1
OPT = -Og
BUILD_DIR = build

# Sources
C_SOURCES = main.cpp
ASM_SOURCES = startup.s

# Binaries
PREFIX = arm-none-eabi-
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)g++
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)g++
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
# Flags
CPU = -mcpu=cortex-m3
MCU = $(CPU) -mthumb
C_DEFS = -DSTM32F103x6

# ADD -std=c++17 here
CFLAGS = $(MCU) $(C_DEFS) $(OPT) -Wall -fdata-sections -ffunction-sections -std=c++17
ASFLAGS = $(MCU) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# Linker
LDSCRIPT = STM32F103C6.ld
LIBS = -lc -lm -lnosys 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex

# Build Rules
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.cpp=.o)))
vpath %.cpp $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.cpp Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.cpp=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR):
	mkdir $@		

clean:
	-rm -fR $(BUILD_DIR)
  
-include $(wildcard $(BUILD_DIR)/*.d)