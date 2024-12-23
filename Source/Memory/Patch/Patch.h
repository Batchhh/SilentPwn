/*
 * File: Patch.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main patch header for SilentPwn iOS modification
 */


#import <Foundation/Foundation.h>
#import "../Kitty/MemoryPatch.hpp"
#import "../../Config.h"

@interface Patch : NSObject

// Single patch (uses default framework from Config.h)
+ (BOOL)offset:(uint64_t)offset patch:(NSString *)hexString;

// Multiple patches (uses default framework from Config.h)
+ (BOOL)patches:(NSDictionary<NSNumber *, NSString *> *)patches;

// Assembly patch (uses default framework from Config.h)
+ (BOOL)offsetAsm:(uintptr_t)address asm_arch:(MP_ASM_ARCH)asm_arch asm_code:(const std::string &)asm_code;

// Assembly patches using NSDictionary
+ (BOOL)patchesAsm:(NSDictionary<NSNumber *, NSString *> *)patches asm_arch:(MP_ASM_ARCH)asm_arch;

// Revert patches
+ (BOOL)revertOffset:(uint64_t)offset;
+ (void)revertAll;

// Get bytes
+ (NSString *)getCurrentBytesAtOffset:(uint64_t)offset;
+ (NSString *)getOriginalBytesAtOffset:(uint64_t)offset;

@end
