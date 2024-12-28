/*
 * File: Framework.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main framework header for SilentPwn iOS modification
 */

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "Framework.h"

static const char *g_frameworkName = NULL;
static const char *g_frameworkPath = NULL;

const char *getFrameworkPath() {
  @autoreleasepool {
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    NSString *mainBundleName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleExecutable"];

    // First, try UnityFramework
    NSString *unityFrameworkPath =
        [appPath stringByAppendingPathComponent:
                     @"Frameworks/UnityFramework.framework/UnityFramework"];
    void *handle =
        dlopen([unityFrameworkPath fileSystemRepresentation], RTLD_LAZY);

    if (handle) {
      dlclose(handle);
      return strdup([unityFrameworkPath UTF8String]);
    }

    // If UnityFramework fails, use the main bundle executable
    NSString *finalPath = [appPath stringByAppendingPathComponent:mainBundleName];
    return strdup([finalPath UTF8String]);
  }
}

const char *getCurrentFrameworkPath() {
  if (g_frameworkPath == NULL) {
    g_frameworkPath = getFrameworkPath();
  }
  return g_frameworkPath;
}

const char *getFrameworkName() {
  @autoreleasepool {
    NSString *mainBundleName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleExecutable"];
    NSString *appPath = [[NSBundle mainBundle] bundlePath];

    // First, try UnityFramework
    NSString *unityFrameworkPath =
        [appPath stringByAppendingPathComponent:
                     @"Frameworks/UnityFramework.framework/UnityFramework"];
    void *handle =
        dlopen([unityFrameworkPath fileSystemRepresentation], RTLD_LAZY);

    if (handle) {
      dlclose(handle);
      return "UnityFramework";
    }
    // If UnityFramework fails, use the main bundle executable name
    return strdup([mainBundleName UTF8String]);
  }
}

const char *getCurrentFrameworkName() {
  if (g_frameworkName == NULL) {
    g_frameworkName = getFrameworkName();
  }
  return g_frameworkName;
}

BOOL editJSONFile(NSString *fileName, void (^editBlock)(NSMutableDictionary *jsonDict)) {
  @autoreleasepool {
    NSString *documentsPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
            firstObject];
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:fileName];

    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:fullPath
                                             options:0
                                               error:&error];
    if (error) return NO;

    NSMutableDictionary *jsonDict =
        [NSJSONSerialization JSONObjectWithData:jsonData
                                       options:NSJSONReadingMutableContainers
                                         error:&error];
    if (error) return NO;

    if (![jsonDict isKindOfClass:[NSMutableDictionary class]]) return NO;

    editBlock(jsonDict);

    NSData *updatedJsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
    if (error) return NO;

    return [updatedJsonData writeToFile:fullPath atomically:YES];
  }
}

const char *getAppName() {
  @autoreleasepool {
    NSString *bundleName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!bundleName) {
      bundleName =
          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return strdup([bundleName UTF8String]) ?: "Unknown";
  }
}

const char *getAppVersion() {
  @autoreleasepool {
    NSString *version = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return strdup([version UTF8String]) ?: "Unknown";
  }
}
