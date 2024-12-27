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

#import "Framework.h"

static const char *g_frameworkName = NULL;
static const char *g_frameworkPath = NULL;

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
    return [[mainBundleName fileSystemRepresentation] UTF8String];
  }
}

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
      return [unityFrameworkPath UTF8String];
    }

    // If UnityFramework fails, use the main bundle executable
    return [[appPath stringByAppendingPathComponent:mainBundleName] UTF8String];
  }
}

const char *getCurrentFrameworkName() {
  if (g_frameworkName == NULL) {
    g_frameworkName = getFrameworkName();
  }
  return g_frameworkName;
}

const char *getCurrentFrameworkPath() {
  if (g_frameworkPath == NULL) {
    g_frameworkPath = getFrameworkPath();
  }
  return g_frameworkPath;
}

NSString *getAppName() {
  @autoreleasepool {
    NSString *bundleName = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!bundleName) {
      bundleName =
          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    return bundleName ?: @"Unknown";
  }
}

NSString *getAppVersion() {
  @autoreleasepool {
    NSString *version = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return version ?: @"Unknown";
  }
}

BOOL editJSONFile(NSString *fileName,
                  void (^editBlock)(NSMutableDictionary *jsonDict)) {
  @autoreleasepool {
    // If the fileName is not an absolute path, prepend the documents directory
    NSString *fullPath = fileName;
    if (![fileName hasPrefix:@"/"]) {
      NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(
          NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
      fullPath = [documentsPath stringByAppendingPathComponent:fileName];
    }

    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfFile:fullPath
                                              options:0
                                                error:&error];

    if (error) {
      NSLog(@"Error reading JSON file: %@", error);
      return NO;
    }

    NSMutableDictionary *jsonDict =
        [NSJSONSerialization JSONObjectWithData:jsonData
                                        options:NSJSONReadingMutableContainers
                                          error:&error];

    if (error) {
      NSLog(@"Error parsing JSON: %@", error);
      return NO;
    }

    if (![jsonDict isKindOfClass:[NSMutableDictionary class]]) {
      NSLog(@"JSON root is not a dictionary");
      return NO;
    }

    // Call the edit block to modify the dictionary
    editBlock(jsonDict);

    // Convert back to JSON data
    NSData *updatedJsonData =
        [NSJSONSerialization dataWithJSONObject:jsonDict
                                        options:NSJSONWritingPrettyPrinted
                                          error:&error];

    if (error) {
      NSLog(@"Error converting JSON back to data: %@", error);
      return NO;
    }

    // Write back to file
    BOOL writeSuccess = [updatedJsonData writeToFile:fullPath atomically:YES];

    if (!writeSuccess) {
      NSLog(@"Failed to write updated JSON to file");
      return NO;
    }

    return YES;
  }
}
