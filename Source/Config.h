/*
 * File: Config.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Configuration file for SilentPwn
 */

#pragma once

extern const char* getCurrentFrameworkName();
extern const char* getCurrentFrameworkPath();
extern const char* getAppName();
extern const char* getAppVersion();

#define frameWork getCurrentFrameworkName()
#define frameWorkPath getCurrentFrameworkPath()
#define appName getAppName()
#define appVersion getAppVersion()

#define Author "@@@USER@@"
#define Version "@@APPVERSION@@"
#define iOSGodsAuthorProfile "https://iosgods.com/" // add your profile link

#define About "Author: " Author "\nVersion: " Version
#define changelog "Added stuff"

#define WAIT 3.0 // seconds

#define DebugMode true // This will enable debug tools
