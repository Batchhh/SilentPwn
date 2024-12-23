/*
 * File: Helper.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Helper functions for KittyMemory framework
 */


#include "Helper.h"
#include <string>

// Comprehensive list of ARM64 assembly language patterns
namespace ASM {
    // Basic Control Flow
    const std::string RET = "ret";                     // Return from function
    const std::string NOP = "nop";                     // No operation
    const std::string BREAKPOINT = "brk #0";           // Trigger breakpoint
    const std::string INFINITE_LOOP = "b #0; nop";     // Infinite loop

    // Register Manipulation
    const std::string BOOL_TRUE = "mov w0, #1; ret";   // Set return value to true
    const std::string BOOL_FALSE = "mov w0, #0; ret";  // Set return value to false

    // Stack and Frame Management (Extended)
    const std::string PUSH_ALL_REGS = "stp x29, x30, [sp, #-16]!; add x29, sp, #0";  // Save frame and link registers
    const std::string POP_ALL_REGS = "ldp x29, x30, [sp], #16; ret";  // Restore frame and link registers
    const std::string STACK_FRAME_SETUP = "add sp, sp, #-16; mov fp, sp";  // Allocate stack frame
    const std::string STACK_FRAME_TEAR = "add sp, sp, #16; ret";  // Deallocate stack frame

    // Additional Stack Management Instructions
    const std::string PUSH_CALLEE_SAVED_REGS = "stp x19, x20, [sp, #-16]!; stp x21, x22, [sp, #-16]!";  // Push callee-saved registers
    const std::string POP_CALLEE_SAVED_REGS = "ldp x21, x22, [sp], #16; ldp x19, x20, [sp], #16";  // Restore callee-saved registers
    const std::string ALLOCATE_STACK_LARGE = "sub sp, sp, #256";  // Allocate a large stack frame (256 bytes)
    const std::string DEALLOCATE_STACK_LARGE = "add sp, sp, #256";  // Deallocate a large stack frame
    const std::string STACK_PROBE = "mov x16, sp; str xzr, [x16, #-16]!";  // Stack probe to ensure stack guard page is mapped
    const std::string SAVE_LINK_REGISTER = "str x30, [sp, #-16]!";  // Save link register to stack
    const std::string RESTORE_LINK_REGISTER = "ldr x30, [sp], #16";  // Restore link register from stack
    const std::string ALIGN_STACK_16BYTE = "and sp, sp, #-16";  // Ensure 16-byte stack alignment
    const std::string CREATE_STACK_FRAME_WITH_LOCALS = "stp x29, x30, [sp, #-32]!; mov x29, sp; sub sp, sp, #16";  // Create stack frame with space for local variables

    // System and Memory Interactions
    const std::string SYSCALL_INTERRUPT = "svc #0";    // System call
    const std::string MEMORY_BARRIER = "dmb sy";       // Data memory barrier
    const std::string MEMORY_SYNC = "dsb sy";          // Data synchronization barrier

    // Branching and Jumping
    const std::string BRANCH_LINK = "bl #4";           // Branch with link (function call)
    const std::string CONDITIONAL_JUMP = "b.ne #8";    // Conditional branch if not equal
    const std::string JUMP_ALWAYS = "b #0";            // Unconditional jump

    // High Value Constants and Floating Point
    const std::string HIGH_FLOAT = "fmov s0, #3.402823e+38; ret";  // Max single-precision float
    const std::string HIGH_DOUBLE = "fmov d0, #1.797693e+308; ret";  // Max double-precision float
    const std::string MAX_INT = "mov x0, #0x7FFFFFFFFFFFFFFF; ret";  // Maximum 64-bit signed integer

    // Bit Manipulation
    const std::string CLEAR_REGISTER = "mov x0, #0";   // Clear a register
    const std::string SET_ALL_BITS = "mov x0, #-1";    // Set all bits in register

    // Comparison and Conditional Execution
    const std::string COMPARE_ZERO = "cmp x0, #0";     // Compare register to zero
    const std::string EQUAL_ZERO = "beq #8";           // Branch if equal to zero
    const std::string NOT_EQUAL_ZERO = "bne #8";       // Branch if not equal to zero

    // Advanced Memory Operations
    const std::string PREFETCH_MEMORY = "prfm pldl1keep, [x0]";  // Prefetch memory
    const std::string CACHE_INVALIDATE = "dc civac, x0";  // Clean and invalidate data cache

    // Atomic Operations
    const std::string ATOMIC_INCREMENT = "ldadd w1, w2, [x0]";  // Atomic add
    const std::string ATOMIC_COMPARE_SWAP = "casal w1, w2, [x0]";  // Atomic compare and swap

    // Exception Handling
    const std::string EXCEPTION_RETURN = "eret";       // Exception return
    const std::string SUPERVISOR_CALL = "svc #0";      // Supervisor call

    // Floating Point and SIMD
    const std::string VECTOR_ZERO = "movi v0.16b, #0";  // Zero a vector register
    const std::string FLOATING_POINT_MOVE = "fmov d0, d1";  // Move floating point register

    // Numeric Type Handling and Manipulation
    // Integer Operations
    const std::string ASM_INT_ZERO = "mov w0, #0";  // Set 32-bit integer to zero
    const std::string ASM_LONG_ZERO = "mov x0, #0";  // Set 64-bit integer to zero
    const std::string ASM_INT_MAX_VAL = "mov w0, #0x7FFFFFFF";  // Set 32-bit integer to maximum value
    const std::string ASM_LONG_MAX_VAL = "mov x0, #0x7FFFFFFFFFFFFFFF";  // Set 64-bit integer to maximum value
    const std::string ASM_INT_MIN_VAL = "mov w0, #0x80000000";  // Set 32-bit integer to minimum value
    const std::string ASM_LONG_MIN_VAL = "mov x0, #0x8000000000000000";  // Set 64-bit integer to minimum value

    // Integer Arithmetic
    const std::string INT_ADD = "add w0, w1, w2";  // Add two 32-bit integers
    const std::string LONG_ADD = "add x0, x1, x2";  // Add two 64-bit integers
    const std::string INT_SUB = "sub w0, w1, w2";  // Subtract two 32-bit integers
    const std::string LONG_SUB = "sub x0, x1, x2";  // Subtract two 64-bit integers
    const std::string INT_MUL = "mul w0, w1, w2";  // Multiply two 32-bit integers
    const std::string LONG_MUL = "mul x0, x1, x2";  // Multiply two 64-bit integers

    // Floating Point Operations
    const std::string FLOAT_ZERO = "fmov s0, #0.0";  // Set single-precision float to zero
    const std::string DOUBLE_ZERO = "fmov d0, #0.0";  // Set double-precision float to zero
    const std::string FLOAT_MAX = "fmov s0, #3.402823e+38";  // Set single-precision float to maximum value
    const std::string DOUBLE_MAX = "fmov d0, #1.797693e+308";  // Set double-precision float to maximum value
    const std::string FLOAT_MIN = "fmov s0, #-3.402823e+38";  // Set single-precision float to minimum value
    const std::string DOUBLE_MIN = "fmov d0, #-1.797693e+308";  // Set double-precision float to minimum value

    // Floating Point Arithmetic
    const std::string FLOAT_ADD = "fadd s0, s1, s2";  // Add two single-precision floats
    const std::string DOUBLE_ADD = "fadd d0, d1, d2";  // Add two double-precision floats
    const std::string FLOAT_SUB = "fsub s0, s1, s2";  // Subtract two single-precision floats
    const std::string DOUBLE_SUB = "fsub d0, d1, d2";  // Subtract two double-precision floats
    const std::string FLOAT_MUL = "fmul s0, s1, s2";  // Multiply two single-precision floats
    const std::string DOUBLE_MUL = "fmul d0, d1, d2";  // Multiply two double-precision floats

    // Boolean and Comparison Operations
    const std::string BOOL_SET_TRUE = "mov w0, #1";  // Set boolean to true
    const std::string BOOL_SET_FALSE = "mov w0, #0";  // Set boolean to false
    const std::string INT_COMPARE_EQUAL = "cmp w0, w1; beq #8";  // Compare two 32-bit integers for equality
    const std::string LONG_COMPARE_EQUAL = "cmp x0, x1; beq #8";  // Compare two 64-bit integers for equality
    const std::string FLOAT_COMPARE_EQUAL = "fcmp s0, s1; beq #8";  // Compare two single-precision floats for equality
    const std::string DOUBLE_COMPARE_EQUAL = "fcmp d0, d1; beq #8";  // Compare two double-precision floats for equality

    // Type Conversion
    const std::string INT_TO_FLOAT = "scvtf s0, w0";  // Convert 32-bit integer to single-precision float
    const std::string INT_TO_DOUBLE = "scvtf d0, w0";  // Convert 32-bit integer to double-precision float
    const std::string LONG_TO_FLOAT = "scvtf s0, x0";  // Convert 64-bit integer to single-precision float
    const std::string LONG_TO_DOUBLE = "scvtf d0, x0";  // Convert 64-bit integer to double-precision float
    const std::string FLOAT_TO_INT = "fcvtzs w0, s0";  // Convert single-precision float to 32-bit integer
    const std::string DOUBLE_TO_INT = "fcvtzs w0, d0";  // Convert double-precision float to 32-bit integer

    // Bitwise Operations
    const std::string INT_BITWISE_AND = "and w0, w1, w2";  // Bitwise AND for 32-bit integers
    const std::string LONG_BITWISE_AND = "and x0, x1, x2";  // Bitwise AND for 64-bit integers
    const std::string INT_BITWISE_OR = "orr w0, w1, w2";  // Bitwise OR for 32-bit integers
    const std::string LONG_BITWISE_OR = "orr x0, x1, x2";  // Bitwise OR for 64-bit integers
    const std::string INT_BITWISE_XOR = "eor w0, w1, w2";  // Bitwise XOR for 32-bit integers
    const std::string LONG_BITWISE_XOR = "eor x0, x1, x2";  // Bitwise XOR for 64-bit integers
} // namespace ASM
