/*
 * File: Framework.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main framework header for SilentPwn iOS modification
 */

#pragma once
#import <Foundation/Foundation.h>
#import <dlfcn.h>

const char* getFrameworkName();
const char* getFrameworkPath();
const char* getCurrentFrameworkName();
const char* getCurrentFrameworkPath();

NSString* getAppName();
NSString* getAppVersion();

BOOL editJSONFile(NSString *fileName, void (^editBlock)(NSMutableDictionary *jsonDict));
