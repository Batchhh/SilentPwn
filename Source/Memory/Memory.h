/*
 * File: Memory.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main memory header for SilentPwn iOS modification
 */


#pragma once

// Core Memory Utilities
#import "Kitty/KittyMemory.hpp"
#import "Kitty/KittyUtils.hpp"
#import "Kitty/MemoryPatch.hpp"

// Helper Utilities
#import "Helper.h"

// Patching & Hooking
#import "Hook/Hook.h"
#import "Patch/Patch.h"

// Common namespace for easy access to ASM patterns
using namespace ASM;
