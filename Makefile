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

OBJS=	$(SOURCES:.c=.o)
TARGET= c1m2.out
LDFLAGS= -Xlinker -Map=c1m2.map
GENFLAGS= -Wall -Werror -g -O0 -std=c99

#  PLATFORM=MSP432
ifeq	($(PLATFORM),MSP432)
# Architecture MSP432 Specific Flags
	LINKER_FILE=-T msp432p401r.lds
	CPU=cortex-m4
	ARCH=armv7e-m
	SPECS=nosys.specs
	SPECS_EX = -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
# Compiler Flags and Defines	
	CC=arm-none-eabi-gcc
	LD=arm-none-eabi-ld
	CFLAGS =-DMSP432
	CPPFLAGS = $(GENFLAGS) $(SPECS_EX) -mcpu=$(CPU) -march=$(ARCH) -specs=$(SPECS)
endif

#  PLATFORM=HOST
ifeq	($(PLATFORM),HOST)
	SPECS=nosys.specs
	CC=gcc
	LD=ld
	CFLAGS =-DHOST
	CPPFLAGS = $(GENFLAGS)
endif

%.i: %.c
	$(CC) -E $^ -o $@ $(CFLAGS)  $(INCLUDES)

%.asm: %.c
	$(CC) -S $^  $(CFLAGS) $(CPPFLAGS) $(INCLUDES)

%.o: %.c
	$(CC) -c $^ -o $@ $(CFLAGS) $(CPPFLAGS) $(INCLUDES)

c1m2.out: $(OBJS)
	$(CC) $(CFLAGS) -o c1m2.out $(OBJS) $(INCLUDES) $(LDFLAGS)

# Compile all object files, but do not link.
.PHONY: compile-all
compile-all:
	make clean
	make $(OBJS)

# Compile all object files and link into a final executable.
.PHONY: build
build:
	make clean
	make c1m2.out

# Remove all compiled objects, preprocessed outputs, assembly outputs, executable files and build output files.
.PHONY: clean
clean:
	rm -f *.i *.o *.s *.map *.out
