/*
 * File: Patch.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Patching system for SilentPwn
 */


#import "Patch.h"
#import <map>

// Store patches to allow reverting
static std::map<std::pair<std::string, uint64_t>, MemoryPatch> patches;

@implementation Patch

#pragma mark - Single Patch

+ (BOOL)offset:(uint64_t)offset patch:(NSString *)hexString {
    if (!hexString) return NO;

    const char *hex = [hexString UTF8String];

    MemoryPatch patch = MemoryPatch::createWithHex(frameWork, offset, hex);
    if (!patch.isValid()) return NO;

    patches[std::make_pair(frameWork, offset)] = patch;

    return patch.Modify();
}

+ (BOOL)offsetAsm:(uintptr_t)address asm_arch:(MP_ASM_ARCH)asm_arch asm_code:(const std::string &)asm_code {
    MemoryPatch patch = MemoryPatch::createWithAsm(frameWork, address, asm_arch, asm_code);
    if (!patch.isValid()) return NO;

    patches[std::make_pair(frameWork, address)] = patch;

    return patch.Modify();
}

#pragma mark - Multiple Patches

+ (BOOL)patches:(NSDictionary<NSNumber *, NSString *> *)patches {
    if (!patches || patches.count == 0) return NO;

    BOOL success = YES;
    for (NSNumber *offset in patches) {
        NSString *hex = patches[offset];
        success &= [self offset:offset.unsignedLongLongValue patch:hex];
    }
    return success;
}

+ (BOOL)patchesAsm:(NSDictionary<NSNumber *, NSString *> *)patches asm_arch:(MP_ASM_ARCH)asm_arch {
    if (!patches || patches.count == 0) return NO;

    BOOL success = YES;
    for (NSNumber *offset in patches) {
        NSString *asmCode = patches[offset];
        success &= [self offsetAsm:offset.unsignedLongLongValue
                          asm_arch:asm_arch
                          asm_code:[asmCode UTF8String]];
    }
    return success;
}

#pragma mark - Revert Patches

+ (BOOL)revertOffset:(uint64_t)offset {
    auto key = std::make_pair(frameWork, offset);
    auto it = patches.find(key);
    if (it == patches.end()) return NO;

    BOOL success = it->second.Restore();
    if (success) {
        patches.erase(it);
    }
    return success;
}

+ (void)revertAll {
    auto it = patches.begin();
    while (it != patches.end()) {
        if (it->first.first == frameWork) {
            if (it->second.Restore()) {
                it = patches.erase(it);
            } else {
                ++it;
            }
        } else {
            ++it;
        }
    }
}

#pragma mark - Get Bytes

+ (NSString *)getCurrentBytesAtOffset:(uint64_t)offset {
    auto key = std::make_pair(frameWork, offset);
    auto it = patches.find(key);
    if (it == patches.end()) return nil;

    std::string bytes = it->second.get_CurrBytes();
    return [NSString stringWithUTF8String:bytes.c_str()];
}

+ (NSString *)getOriginalBytesAtOffset:(uint64_t)offset {
    auto key = std::make_pair(frameWork, offset);
    auto it = patches.find(key);
    if (it == patches.end()) return nil;

    std::string bytes = it->second.get_OrigBytes();
    return [NSString stringWithUTF8String:bytes.c_str()];
}

@end
