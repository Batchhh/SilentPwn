/*
 * File: Hook.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main hook header for SilentPwn iOS modification
 */


// Hook.h
#import <Foundation/Foundation.h>
#import "../Kitty/MemoryPatch.hpp"
#import "../../UI/Menu.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (*HookCallback)(void);

@interface Hook : NSObject

// Basic hooking
+ (BOOL)hook:(uint64_t)address callback:(void * _Nonnull)callback original:(void * _Nullable * _Nullable)original;
+ (BOOL)hookSymbol:(NSString *)symbol callback:(void * _Nonnull)callback original:(void * _Nullable * _Nullable)original;

// Advanced hooking with toggle support
+ (BOOL)hookAt:(uint64_t)address
      callback:(void * _Nonnull)callback
      original:(void * _Nullable * _Nullable)original
     withName:(NSString *)name;

+ (BOOL)hookSymbol:(NSString *)symbol
         callback:(void * _Nonnull)callback
         original:(void * _Nullable * _Nullable)original
         withName:(NSString *)name;

// Hook management
+ (BOOL)toggleHookWithName:(NSString *)name enabled:(BOOL)enabled;
+ (BOOL)removeHookWithName:(NSString *)name;
+ (void)removeAllHooks;

// Hook status
+ (BOOL)isHookEnabledWithName:(NSString *)name;
+ (NSArray<NSString *> *)activeHooks;

// Utilities
+ (void * _Nullable)getOriginalFromName:(NSString *)name;
+ (uint64_t)getRealAddress:(uint64_t)address;

@end

NS_ASSUME_NONNULL_END
