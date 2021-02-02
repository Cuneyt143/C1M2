#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# Simple makefile for multitarget build system 
#
# Use: make [TARGET] [PLATFORM-OVERRIDES]
#      TARGET:
#	    %.i - Generate the preprocessed output of all c-program implementation files(use the -E flag)
#	    %.asm - Generate the assembly output of c-program implementation files and the final output executable(use the -S flag and the objdump utility)
#           %.o Generate the object file for all c-source files(but do not link) by specifying the object file you want to compilde
#           compilde-all - Compilde all object files, but DO NOT link.
#           Build - Compile all object files and link into a final executable.
#           Clean - This should remove all compiled object, preprocessed outputs, assembly outputs, executable file and build output files.
#      
#       Overrides:
#            PLATFORM - Host or msp432
#
#
#------------------------------------------------------------------------------
include sources.mk

#PLATFORM:=$(shell uname -s)

CPU = cortex-m4
BASENAME = src
TARGET = $(BASENAME).out
ARC = thumb
SPECS = nosys.specs
MARCH = armv7e-m 
MFLOAT = hard
MFPU = fpv4-sp-d16
LDFLAGS= -Wl, -Map=$(BASENAME).map
 
ifeq ($(PLATFORM),HOST)
	TARGET = -DHOST
	CC = gcc
	CFLAGS = -Wall -Werror -g -O0 -std=c99
endif

ifeq ($(PLATFORM),MSP432)
	CC = arm-none-eabi-gcc
	LD = arm-none-eabi-ld
	LINKER_FILE = -T msp432p401r.lds
	CFLAGS = -mcpu=$(CPU) -m$(ARC) -march=$(MARCH) -Wall -Werror -g -O0 -std=c99 -mfloat-abi=hard -mfpu=$(MFPU) --specs=$(SPECS)
	
	TARGET = -DMSP432 
endif


OBJS = $(SOURCES:.c=.o)
%.o : %.c
	$(CC)  -c  $<  $(CFLAGS)  -o  $@
    
%.i : %.c
	$(CC)  -c  $<  $(CFLAGS)  -o  $@ -E 
    
%.asm : %.c $(TARGET)
	$(CC) -S 
    
.PHONY: build
build: all
.PHONNY: all
all: $(TARGET)
$(TARGET) : $(OBJS)
	$(CC)  $(OBJS)  $(CFLAGS) $(LDFLAGS) $(PLATFORM_TARGET) -o c1m2.out $@

.PHONY: clean
clean:
	rm -f $(OBJS)  $(TARGET) $(BASENAME)

.PHONY: compilde-all
compile-all:%.o 
	$(CC) 


