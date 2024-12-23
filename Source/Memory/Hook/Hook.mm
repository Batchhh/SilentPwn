/*
 * File: Hook.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Memory hooking implementation for SilentPwn iOS modification
 */


// Hook.mm
#import "Hook.h"
#import <dlfcn.h>
#import <substrate.h>

@interface HookInfo : NSObject
@property (nonatomic, assign) uint64_t address;
@property (nonatomic, assign) void *callback;
@property (nonatomic, assign) void *original;
@property (nonatomic, assign) BOOL isSymbol;
@property (nonatomic, strong) NSString *symbolName;
@property (nonatomic, assign) BOOL isEnabled;
@end

@implementation HookInfo
@end

@implementation Hook {
    NSMutableDictionary<NSString *, HookInfo *> *_hooks;
}

#pragma mark - Initialization

+ (instancetype)shared {
    static Hook *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Hook alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _hooks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Basic Hooking

+ (BOOL)hook:(uint64_t)address callback:(void *)callback original:(void **)original {
    NSString *name = [NSString stringWithFormat:@"hook_%llx", address];
    return [self hookAt:address callback:callback original:original withName:name];
}

+ (BOOL)hookSymbol:(NSString *)symbol callback:(void *)callback original:(void **)original {
    return [self hookSymbol:symbol callback:callback original:original withName:symbol];
}

#pragma mark - Advanced Hooking

+ (BOOL)hookAt:(uint64_t)address
      callback:(void *)callback
      original:(void **)original
     withName:(NSString *)name {
    if (!callback || !name.length) return NO;

    Hook *instance = [Hook shared];

    // Check if hook already exists
    if (instance->_hooks[name]) {
        NSLog(@"Hook already exists with name: %@", name);
        return NO;
    }

    void *targetAddress = (void *)KittyMemory::getRealOffset(address);
    if (!targetAddress) {
        NSLog(@"Failed to get real address for: 0x%llx", address);
        return NO;
    }

    // Create hook info
    HookInfo *info = [[HookInfo alloc] init];
    info.address = address;
    info.callback = callback;
    info.isSymbol = NO;
    info.isEnabled = YES;

    // Apply hook
    void *originalFunc = NULL;
    MSHookFunction(targetAddress, callback, &originalFunc);

    if (!originalFunc) {
        NSLog(@"Failed to hook address: 0x%llx", address);
        return NO;
    }

    info.original = originalFunc;
    if (original) *original = originalFunc;

    // Store hook info
    instance->_hooks[name] = info;

    NSLog(@"Successfully hooked address: 0x%llx with name: %@", address, name);
    return YES;
}

+ (BOOL)hookSymbol:(NSString *)symbol
         callback:(void *)callback
         original:(void **)original
         withName:(NSString *)name {
    if (!callback || !symbol.length || !name.length) return NO;

    Hook *instance = [Hook shared];

    // Check if hook already exists
    if (instance->_hooks[name]) {
        NSLog(@"Hook already exists with name: %@", name);
        return NO;
    }

    void *targetAddress = dlsym(RTLD_DEFAULT, symbol.UTF8String);
    if (!targetAddress) {
        NSLog(@"Failed to find symbol: %@", symbol);
        return NO;
    }

    // Create hook info
    HookInfo *info = [[HookInfo alloc] init];
    info.symbolName = symbol;
    info.callback = callback;
    info.isSymbol = YES;
    info.isEnabled = YES;

    // Apply hook
    void *originalFunc = NULL;
    MSHookFunction(targetAddress, callback, &originalFunc);

    if (!originalFunc) {
        NSLog(@"Failed to hook symbol: %@", symbol);
        return NO;
    }

    info.original = originalFunc;
    if (original) *original = originalFunc;

    // Store hook info
    instance->_hooks[name] = info;

    NSLog(@"Successfully hooked symbol: %@ with name: %@", symbol, name);
    return YES;
}

#pragma mark - Hook Management

+ (BOOL)toggleHookWithName:(NSString *)name enabled:(BOOL)enabled {
    if (!name.length) return NO;

    Hook *instance = [Hook shared];
    HookInfo *info = instance->_hooks[name];

    if (!info) {
        NSLog(@"No hook found with name: %@", name);
        return NO;
    }

    if (info.isEnabled == enabled) return YES;

    void *targetAddress;
    if (info.isSymbol) {
        targetAddress = dlsym(RTLD_DEFAULT, [info.symbolName UTF8String]);
    } else {
        targetAddress = (void *)KittyMemory::getRealOffset(info.address);
    }

    if (!targetAddress) return NO;

    if (enabled) {
        MSHookFunction(targetAddress, info.callback, NULL);
    } else {
        MSHookFunction(targetAddress, info.original, NULL);
    }

    info.isEnabled = enabled;
    return YES;
}

+ (BOOL)removeHookWithName:(NSString *)name {
    if (!name.length) return NO;

    Hook *instance = [Hook shared];
    HookInfo *info = instance->_hooks[name];

    if (!info) return NO;

    // Restore original function
    if (info.isEnabled) {
        [self toggleHookWithName:name enabled:NO];
    }

    [instance->_hooks removeObjectForKey:name];
    return YES;
}

+ (void)removeAllHooks {
    Hook *instance = [Hook shared];
    NSArray *hookNames = instance->_hooks.allKeys;

    for (NSString *name in hookNames) {
        [self removeHookWithName:name];
    }
}

#pragma mark - Hook Status

+ (BOOL)isHookEnabledWithName:(NSString *)name {
    Hook *instance = [Hook shared];
    HookInfo *info = instance->_hooks[name];
    return info ? info.isEnabled : NO;
}

+ (NSArray<NSString *> *)activeHooks {
    Hook *instance = [Hook shared];
    return instance->_hooks.allKeys;
}

#pragma mark - Utilities

+ (void *)getOriginalFromName:(NSString *)name {
    Hook *instance = [Hook shared];
    HookInfo *info = instance->_hooks[name];
    return info ? info.original : NULL;
}

+ (uint64_t)getRealAddress:(uint64_t)address {
    return KittyMemory::getRealOffset(address);
}

@end
