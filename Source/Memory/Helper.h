/*
 * File: Helper.h
 * Project: SilentPwn
 * Description: Low-level Assembly Language Helpers for ARM64 Architecture
 *
 * This header provides a comprehensive set of ARM64 assembly language patterns
 * and instructions for low-level memory manipulation, type handling, and
 * system-level operations.
 *
 * Key Features:
 * - Direct ARM64 assembly language snippets
 * - Numeric type handling (int, long, float, double)
 * - Stack and frame management
 * - Bitwise and arithmetic operations
 * - Type conversions
 *
 * Usage:
 * These assembly patterns can be used for:
 * - Performance-critical code
 * - Memory manipulation
 * - Custom numeric algorithms
 * - Low-level system interactions
 */

#pragma once

#include <limits>
#include <mach-o/dyld.h>
#include <string>
#include <substrate.h>

// Memory read and write operations
template <typename T>
void SetValue(void* ptr, uint64_t offset, T value) {  
  *(T*)((uint64_t)(ptr) + offset) = value;
}

template <typename T>
T GetValue(void* ptr, uint64_t offset) {
  return *(T*)((uint64_t)(ptr) + offset);
}

inline void* AccessClass(void* ptr, uint64_t offset) {
  return *(void**)((uint64_t)(ptr) + offset);
}

namespace ASM {
    // Basic Control Flow
    extern const std::string RET;           // Return from function
    extern const std::string NOP;           // No operation
    extern const std::string BREAKPOINT;    // Trigger breakpoint
    extern const std::string INFINITE_LOOP; // Infinite loop
    extern const std::string JUMP_ALWAYS;   // Unconditional jump

    // Register Manipulation
    extern const std::string BOOL_TRUE;     // Set return value to true
    extern const std::string BOOL_FALSE;    // Set return value to false

    // Stack and Frame Management
    extern const std::string PUSH_ALL_REGS;         // Save frame and link registers
    extern const std::string POP_ALL_REGS;          // Restore frame and link registers
    extern const std::string STACK_FRAME_SETUP;     // Allocate stack frame
    extern const std::string STACK_FRAME_TEAR;      // Deallocate stack frame
    extern const std::string PUSH_CALLEE_SAVED_REGS;    // Push callee-saved registers
    extern const std::string POP_CALLEE_SAVED_REGS;     // Pop callee-saved registers
    extern const std::string ALLOCATE_STACK_LARGE;      // Allocate large stack frame
    extern const std::string DEALLOCATE_STACK_LARGE;    // Deallocate large stack frame
    extern const std::string STACK_PROBE;           // Ensure stack guard page is mapped
    extern const std::string SAVE_LINK_REGISTER;    // Save link register to stack
    extern const std::string RESTORE_LINK_REGISTER; // Restore link register from stack
    extern const std::string ALIGN_STACK_16BYTE;    // Ensure 16-byte stack alignment
    extern const std::string CREATE_STACK_FRAME_WITH_LOCALS; // Create stack frame with local variables

    // System and Memory Interactions
    extern const std::string SYSCALL_INTERRUPT;  // System call
    extern const std::string MEMORY_BARRIER;     // Data memory barrier
    extern const std::string MEMORY_SYNC;        // Data synchronization barrier

    // Branching and Jumping
    extern const std::string BRANCH_LINK;        // Branch with link (function call)
    extern const std::string CONDITIONAL_JUMP;   // Conditional branch if not equal

    // Integer Operations
    extern const std::string ASM_INT_ZERO;     // Set 32-bit integer to zero
    extern const std::string ASM_LONG_ZERO;    // Set 64-bit integer to zero
    extern const std::string ASM_INT_MAX_VAL;  // Set 32-bit integer to maximum value
    extern const std::string ASM_LONG_MAX_VAL; // Set 64-bit integer to maximum value
    extern const std::string ASM_INT_MIN_VAL;  // Set 32-bit integer to minimum value
    extern const std::string ASM_LONG_MIN_VAL; // Set 64-bit integer to minimum value

    // Integer Arithmetic
    extern const std::string INT_ADD;      // Add two 32-bit integers
    extern const std::string LONG_ADD;     // Add two 64-bit integers
    extern const std::string INT_SUB;      // Subtract two 32-bit integers
    extern const std::string LONG_SUB;     // Subtract two 64-bit integers
    extern const std::string INT_MUL;      // Multiply two 32-bit integers
    extern const std::string LONG_MUL;     // Multiply two 64-bit integers

    // Floating Point Operations
    extern const std::string FLOAT_ZERO;   // Set single-precision float to zero
    extern const std::string DOUBLE_ZERO;  // Set double-precision float to zero
    extern const std::string FLOAT_MAX;    // Set single-precision float to maximum value
    extern const std::string DOUBLE_MAX;   // Set double-precision float to maximum value
    extern const std::string FLOAT_MIN;    // Set single-precision float to minimum value
    extern const std::string DOUBLE_MIN;   // Set double-precision float to minimum value

    // Floating Point Arithmetic
    extern const std::string FLOAT_ADD;    // Add two single-precision floats
    extern const std::string DOUBLE_ADD;   // Add two double-precision floats
    extern const std::string FLOAT_SUB;    // Subtract two single-precision floats
    extern const std::string DOUBLE_SUB;   // Subtract two double-precision floats
    extern const std::string FLOAT_MUL;    // Multiply two single-precision floats
    extern const std::string DOUBLE_MUL;   // Multiply two double-precision floats

    // Boolean and Comparison Operations
    extern const std::string BOOL_SET_TRUE;        // Set boolean to true
    extern const std::string BOOL_SET_FALSE;       // Set boolean to false
    extern const std::string INT_COMPARE_EQUAL;    // Compare two 32-bit integers for equality
    extern const std::string LONG_COMPARE_EQUAL;   // Compare two 64-bit integers for equality
    extern const std::string FLOAT_COMPARE_EQUAL;  // Compare two single-precision floats for equality
    extern const std::string DOUBLE_COMPARE_EQUAL; // Compare two double-precision floats for equality

    // Type Conversion
    extern const std::string INT_TO_FLOAT;     // Convert 32-bit integer to single-precision float
    extern const std::string INT_TO_DOUBLE;    // Convert 32-bit integer to double-precision float
    extern const std::string LONG_TO_FLOAT;    // Convert 64-bit integer to single-precision float
    extern const std::string LONG_TO_DOUBLE;   // Convert 64-bit integer to double-precision float
    extern const std::string FLOAT_TO_INT;     // Convert single-precision float to 32-bit integer
    extern const std::string DOUBLE_TO_INT;    // Convert double-precision float to 32-bit integer

    // Bitwise Operations
    extern const std::string INT_BITWISE_AND;   // Bitwise AND for 32-bit integers
    extern const std::string LONG_BITWISE_AND;  // Bitwise AND for 64-bit integers
    extern const std::string INT_BITWISE_OR;    // Bitwise OR for 32-bit integers
    extern const std::string LONG_BITWISE_OR;   // Bitwise OR for 64-bit integers
    extern const std::string INT_BITWISE_XOR;   // Bitwise XOR for 32-bit integers
    extern const std::string LONG_BITWISE_XOR;  // Bitwise XOR for 64-bit integers

    // Floating Point and SIMD
    extern const std::string VECTOR_ZERO;           // Zero a vector register
    extern const std::string FLOATING_POINT_MOVE;   // Move floating point register

    // Instance Variable and Function Pointer Operations
    // Memory Load and Store
    extern const std::string LOAD_INSTANCE_VAR_8BIT;   // Load 8-bit instance variable
    extern const std::string LOAD_INSTANCE_VAR_16BIT;  // Load 16-bit instance variable
    extern const std::string LOAD_INSTANCE_VAR_32BIT;  // Load 32-bit instance variable
    extern const std::string LOAD_INSTANCE_VAR_64BIT;  // Load 64-bit instance variable
    extern const std::string STORE_INSTANCE_VAR_8BIT;  // Store 8-bit instance variable
    extern const std::string STORE_INSTANCE_VAR_16BIT; // Store 16-bit instance variable
    extern const std::string STORE_INSTANCE_VAR_32BIT; // Store 32-bit instance variable
    extern const std::string STORE_INSTANCE_VAR_64BIT; // Store 64-bit instance variable

    // Function Pointer Manipulation
    extern const std::string LOAD_FUNCTION_PTR;        // Load function pointer
    extern const std::string STORE_FUNCTION_PTR;       // Store function pointer
    extern const std::string CALL_FUNCTION_PTR;        // Call function through pointer
    extern const std::string COMPARE_FUNCTION_PTR;     // Compare function pointers

    // Pointer Arithmetic and Manipulation
    extern const std::string OFFSET_INSTANCE_VAR;      // Calculate offset to instance variable
    extern const std::string NULL_CHECK_PTR;           // Check if pointer is null
    extern const std::string VALIDATE_PTR_RANGE;       // Validate pointer is within a memory range

    // Advanced Pointer Operations
    extern const std::string ATOMIC_PTR_SWAP;          // Atomic pointer swap
    extern const std::string VOLATILE_PTR_LOAD;        // Volatile pointer load
    extern const std::string VOLATILE_PTR_STORE;       // Volatile pointer store

    // Object Method Invocation
    extern const std::string LOAD_SELF_PTR;            // Load self/this pointer
    extern const std::string VIRTUAL_METHOD_CALL;      // Call virtual method through vtable
    extern const std::string INTERFACE_METHOD_DISPATCH; // Interface method dispatch
}
