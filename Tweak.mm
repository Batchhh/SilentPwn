/*
 * File: Tweak.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main tweak implementation for SilentPwn iOS modification
 */

// Sources
#import "Source/Memory/Memory.h"
#import "Source/UI/UI.h"

// Libraries
#import "Lib/Obfuscation/Obfuscate.h"
/*
Obfuscation
NSStringEncrypt - Compile-time string encryption macro
NSNumberEncrypt - Compile-time NSNumber encryption macro
IGSecretHexInt - Compile-time offset string encryption macro
IGSecretHexNumber - Compile-time NSNumber hex string encryption macro
IGSecretHexData - Compile-time hex string encryption macro
*/
#import "Lib/Resolver/IL2CPP_Resolver.hpp"

void il2cpp() {

  // This section will be used for il2cpp resolver

  bool success = IL2CPP::Initialize(true, 60, frameWorkPath);
  if (!success)
    [menu showMessage:@"Failed to initialize IL2CPP"
             duration:3.0
              credits:@"IL2CPP"];
}

void hooks() {
  // This section will be used to add hooks to the game

  /**
   * Hooks a function in memory.
   *
   * @param address The memory address of the function to hook. uint64_t.
   * @param callback The callback function to call instead of the hooked
   * function. (void *)namefunction.
   * @param original A pointer to a pointer to store the original function.
   * (void **)orginalfunction.
   *
   * Example:
   * [Hook hook:0x12345678 callback:(void *)myCallbackFunction original:(void
   * **)&originalFunction];
   */

  /**
   * Hooks a function by symbol name.
   *
   * @param symbol The symbol name of the function to hook. NSString.
   * @param callback The callback function to call instead of the hooked
   * function. (void *)namefunction.
   * @param original A pointer to a pointer to store the original function.
   * (void **)orginalfunction.
   *
   * Example:
   * [Hook hookSymbol:@"myFunction" callback:(void *)myCallbackFunction
   * original:(void **)&originalFunction];
   */

  /**
   * Hooks a function at a specific memory address.
   *
   * @param address The memory address of the function to hook. uint64_t.
   * @param callback The callback function to call instead of the hooked
   * function. (void *)namefunction.
   * @param original A pointer to a pointer to store the original function.
   * (void **)orginalfunction.
   * @param name The name to give this hook. NSString.
   *
   * Example:
   * [Hook hookAt:0x12345678 callback:(void *)myCallbackFunction original:(void
   * **)&originalFunction withName:@"myHook"];
   */

  /**
   * Hooks a function by symbol name and assigns a name to this hook.
   *
   * @param symbol The symbol name of the function to hook. NSString.
   * @param callback The callback function to call instead of the hooked
   * function. (void *)namefunction.
   * @param original A pointer to a pointer to store the original function.
   * (void **)orginalfunction.
   * @param name The name to give this hook. NSString.
   *
   * Example:
   * [Hook hookSymbol:@"myFunction" callback:(void *)myCallbackFunction
   * original:(void **)&originalFunction withName:@"myHook"];
   */

  /**
   * Checks if a hook is currently enabled.
   *
   * @param name The name of the hook to check. NSString.
   *
   * Example:
   * BOOL enabled = [Hook isHookEnabledWithName:@"myHook"];
   */

  /**
   * Gets all hooks currently enabled.
   *
   * Example:
   * NSArray<NSString *> *activeHooks = [Hook activeHooks];
   */

  /**
   * Gets the original function of a hook by name.
   *
   * @param name The name of the hook to get the original function for.
   * NSString.
   * @return The original function of the hook. void *.
   *
   * Example:
   * void *originalFunction = [Hook getOriginalFromName:@"myHook"];
   */

  /**
   * Gets the real address of a memory address.
   *
   * @param address The memory address to get the real address for. uint64_t.
   * @return The real address of the memory address. uint64_t.
   *
   * Example:
   * uint64_t realAddress = [Hook getRealAddress:0x12345678];
   */

  /**
   * Toggles a hook on or off.
   *
   * @param name The name of the hook to toggle. NSString.
   * @param enabled Whether to enable or disable the hook. BOOL.
   *
   * Example:
   * [Hook toggleHookWithName:@"myHook" enabled:YES];
   */

  /**
   * Removes a hook by name.
   *
   * @param name The name of the hook to remove. NSString.
   *
   * Example:
   * [Hook removeHookWithName:@"myHook"];
   */

  /**
   * Removes all hooks.
   *
   * Example:
   * [Hook removeAllHooks];
   */
}

void patches() {

  // This section will be used to add patches to the game

  /**
   * Applies a single patch to the game.
   *
   * @param offset The memory offset to patch. uint64_t.
   * @param patch The patch to apply. NSString.
   *
   * Example:
   * [Patch offset:0x12345678 patch:@"90 90 90 90"];
   */

  /**
   * Applies a single patch to the game with a given ASM architecture.
   *
   * @param offset The memory offset to patch. uintptr_t.
   * @param asm_arch The ASM architecture to use for the patch. MP_ASM_ARCH.
   * @param asm_code The ASM code to patch. const std::string &.
   *
   * Example:
   * [Patch offsetAsm:0x12345678 asm_arch:MP_ASM_ARM64 asm_code:"mov x0, #0"];
   */

  /**
   * Applies a dictionary of patches to the game.
   *
   * @param patches The dictionary of patches to apply. NSDictionary<NSNumber*,NSString *> *.
   *
   * Example:
   * NSDictionary *patches = @{
   *     @(0x12345678) : @"90 90 90 90",
   *     @(0x23456789) : @"mov x0, #0"
   * };
   * [Patch patches:patches];
   */

  /**
   * Applies a dictionary of patches with a given ASM architecture.
   *
   * @param patches The dictionary of patches to apply. NSDictionary<NSNumber
   * *,NSString *> *.
   * @param asm_arch The ASM architecture to use for the patches. MP_ASM_ARCH.
   *
   * Example:
   * NSDictionary *patches = @{
   *     @(0x12345678) : @"mov x0, #0",
   *     @(0x23456789) : @"mov x1, #1"
   * };
   * [Patch patchesAsm:patches asm_arch:MP_ASM_ARM64];
   */

  /**
   * Reverts a patch at a given offset.
   *
   * @param offset The memory offset to revert. uint64_t.
   *
   * Example:
   * [Patch revertOffset:0x12345678];
   */

  /**
   * Reverts all patches.
   * [Patch revertAll];
   */

  /**
   * Gets the original bytes at a given offset.
   *
   * @param offset The memory offset to get the original bytes from. uint64_t.
   * @return The original bytes. NSString *.
   *
   * Example:
   * NSString *originalBytes = [Patch getOriginalBytesAtOffset:0x12345678];
   */

  /**
   * Gets the current bytes at a given offset.
   *
   * @param offset The memory offset to get the current bytes from. uint64_t.
   * @return The current bytes. NSString *.
   *
   * Example:
   * NSString *currentBytes = [Patch getCurrentBytesAtOffset:0x12345678];
   */
}

void setupOptions(ModMenu *menu) {

  // This section will be used to add options to the menu

  // Use weak reference to avoid retain cycle with menu in the action block
  // __weak ModMenu *weakMenu = menu;

  /**
   * Adds a slider to the menu that controls the speed of the character.
   *
   * @param title The title of the slider. NSString.
   * @param initialValue The initial value of the slider.
   * @param minValue The minimum value of the slider.
   * @param maxValue The maximum value of the slider.
   * @param category The category to add the slider to.
   */
  [menu addSlider:@"Speed"
      initialValue:50
          minValue:0
          maxValue:100
       forCategory:0];

  // retrieve the slider value
  // @category The category of the slider.
  // @title The title of the slider.
  //
  // [menu getSliderValueFloat:(NSInteger) withTitle:(nonnull NSString *)];
  // [menu getSliderValueInt:(NSInteger) withTitle:(nonnull NSString *)];

  /**
   * Adds a toggle switch to the menu that controls a feature.
   *
   * @param title The title of the toggle switch. NSString.
   * @param initialValue The initial value of the toggle switch.
   * @param category The category to add the toggle switch to.
   */
  [menu addToggle:@"Enable Feature" initialValue:YES forCategory:0];

  // retrieve the toggle switch value
  //  @category The category of the toggle switch.
  //  @title The title of the toggle switch.
  //
  //  [menu getToggleValue:(NSInteger) withTitle:(nonnull NSString *)];

  /**
   * Adds a toggle switch with a patch to the menu that controls the canJump
   * variable.
   *
   * @param title The title of the toggle switch.
   * @param initialValue The initial value of the toggle switch.
   * @param offset The offset(s) of the patch. NSNumber array for multiple
   * patches.
   * @param patch The patch itself. NSString array for multiple patches.
   * @param category The category to add the toggle switch to.
   * @param withAsm Whether or not to use assembly code for the patch.
   */
  [menu addTogglePatch:@"canJump"
          initialValue:NO
                offset:@[ @0x2CB60 ]
                 patch:@[ @"20008052C0035FD6" ]
           forCategory:0
               withAsm:NO];

[menu addTogglePatch:@"canJumpWithAsm"
          initialValue:NO
                offset:@[ @0x2CB60 ]
                 patch:@[ @"mov x0, #1; ret" ]
           forCategory:0
               withAsm:YES];

  /**
   * Adds a index switch to the menu that controls the damage type.
   *
   * @param title The title of the index switch. NSString.
   * @param options The options to display in the index switch. NSArray of
   * NSString.
   * @param initialIndex The initial index of the index switch.
   * @param category The category to add the index switch to.
   */
  [menu addIndexSwitch:@"Damage Type"
               options:@[ @"Normal", @"Fire", @"Electric", @"Water" ]
          initialIndex:0
           forCategory:0];

  // retrieve the index switch value
  //  @category The category of the index switch.
  //  @title The title of the index switch.
  //
  //  [menu getIndexSwitchValue:(NSInteger) withTitle:(nonnull NSString *)];

  /**
   * Adds a multi-select to the menu that controls the HP type.
   *
   * @param title The title of the multi-select. NSString.
   * @param options The options to display in the multi-select. NSArray of
   * NSString.
   * @param selectedIndices The selected indices of the multi-select. NSArray of
   * NSNumber.
   * @param category The category to add the multi-select to.
   */
  [menu addMultiSelect:@"HP Type"
               options:@[ @"Normal", @"Fire", @"Electric", @"Water" ]
       selectedIndices:@[ @0 ]
           forCategory:0];

  // retrieve the multi-select value
  //  @category The category of the multi-select.
  //  @title The title of the multi-select.
  //
  //  [menu getMultiSelectValue:(NSInteger) withTitle:(nonnull NSString *)];
  //  [menu getSelectedOptionsForMultiSelect:(nonnull NSString *)
  //  forCategory:(NSInteger)]

  /**
   * Adds a stepper to the menu that controls a setting.
   *
   * @param title The title of the stepper. NSString.
   * @param initialValue The initial value of the stepper.
   * @param minValue The minimum value of the stepper.
   * @param maxValue The maximum value of the stepper.
   * @param increment The increment value of the stepper.
   * @param category The category to add the stepper to.
   */
  [menu addStepper:@"Stepper"
      initialValue:0.0
          minValue:0.0
          maxValue:100.0
         increment:1.0
       forCategory:0];

  // retrieve the stepper value
  //  @category The category of the stepper.
  //  @title The title of the stepper.
  //
  //  [menu getStepperValueFloat:(NSInteger) withTitle:(nonnull NSString *)];
  //  [menu getStepperValueInt:(NSInteger) withTitle:(nonnull NSString *)];

  /**
   * Adds a text input to the menu that controls a setting.
   *
   * @param title The title of the text input. NSString.
   * @param initialValue The initial value of the text input. NSString.
   * @param callback The callback block to run button beside the text input is
   * pressed.
   * @param category The category to add the text input to.
   */
  [menu addTextInput:@"Text Input"
        initialValue:@""
            callback:^{
              // Code to run when the text input is changed
            }
         forCategory:0];

  // retrieve the text input value
  //  @category The category of the text input.
  //  @title The title of the text input.
  //
  //  [menu getTextValueForCategory:(NSInteger) withTitle:(nonnull NSString *)];

  /**
   * Adds a button to the menu that controls a feature.
   *
   * @param title The title of the button. NSString.
   * @param iconName The icon name of the button. NSString.
   * @param callback The callback block to run when the button is tapped.
   * @param category The category to add the button to.
   */
  [menu addButton:@"Button"
             icon:@"arrow.counterclockwise"
         callback:^{
           // Code to run when the button is tapped
         }
      forCategory:0];
}

void setupQuickActions(ModMenu *menu) {

  // This action will appear when the hub button is long pressed

  // Use weak reference to avoid retain cycle with menu in the action block
  // __weak ModMenu *weakMenu = menu;

  /**
   * Add a quick action
   * function: addQuickAction
   *
   * @param name  Name of the action
   * @param icon  Icon for the action
   * @param action Code to run when the action is tapped
   */

  [menu addQuickAction:@"Reset All"
                  icon:Icons::RESET
                action:^{
                  NSLog(@"Resetting all settings...");
                }];

  [menu addQuickAction:@"Save"
                  icon:Icons::SQUARE_AND_ARROW_DOWN
                action:^{
                  NSLog(@"Saving settings...");
                }];

  [menu addQuickAction:@"Share"
                  icon:Icons::SQUARE_AND_ARROW_UP
                action:^{
                  NSLog(@"Sharing settings...");
                }];

  [menu addQuickAction:@"Help"
                  icon:Icons::QUESTIONMARK_CIRCLE
                action:^{
                  NSLog(@"Showing help...");
                }];
}

/**
 * Sets up the ModMenu view and configures it to be used in the application.
 *
 * This function initializes the ModMenu shared instance and configures it to be
 * used in the application. The menu is configured to have a maximum of 6
 * buttons surrounding the hub button, with a maximum of 5 visible options in a
 * category. The menu is also configured to have a Monochrome theme by default.
 */
void setupModMenu() {
  menu = [ModMenu shared]; // Init the menu

  // Configure menu
  menu.maxButtons =
      6; // Max button surrounding the hub button | By default is 3 [MAX 6]
  menu.maxVisibleOptions =
      3; // Visible option in a category | By default is 3 [MAX 5]

  // Welcome message - optional
  [menu showMessage:[NSString stringWithFormat:@"@@APPNAME@@ %s Mod Menu!", Version]
           duration:3.0
            credits:[NSString stringWithFormat:@"Developed by %s", Author]];

  // Set container titles for each category - optional
  // [menu setContainerTitle:@"Hooks" forCategory:0];
  // [menu setContainerTitle:@"Memory" forCategory:1];
  // [menu setContainerTitle:@"Options" forCategory:2];
  // [menu setContainerTitle:@"Info" forCategory:3];
  // [menu setContainerTitle:@"Interface" forCategory:4];
  // [menu setContainerTitle:@"System" forCategory:5];

  // set category icons for each category - optional
  // [menu setCategoryIcon:Icons::GAMEPAD forCategory:0];
  // [menu setCategoryIcon:Icons::MEMORY_CHIP forCategory:1];
  // [menu setCategoryIcon:Icons::SETTINGS forCategory:2];
  // [menu setCategoryIcon:Icons::INFO forCategory:3];
  // [menu setCategoryIcon:Icons::EDIT forCategory:4];
  // [menu setCategoryIcon:Icons::TERMINAL forCategory:5];

  // Setup default - optional
  // @param DebugMode to display debug options
  [menu addDefaultOptions:DebugMode];

  // Setup options main customization
  setupOptions(menu);

  // Setup quick actions - optional | Long press the hub button
  setupQuickActions(menu);

  // Set Menu layout to Perspective Tunnel by default
  [menu switchTo:ModMenuLayoutRadial animated:YES];
  /*
    ModMenuLayoutRadial, // Radial layout | button in a circle
    ModMenuLayoutGrid,   // Grid layout | buttons in a grid
    ModMenuLayoutList,   // List layout | buttons in a list
    ModMenuLayoutElasticString, // Elastic String
  */

  // Set Button's theme - Monochrome by default
  [menu setTheme:ModMenuThemeMinimal animated:YES];
  /*
    ModMenuThemeDark,      // Default dark theme
    ModMenuThemeCyberpunk, // Vibrant cyberpunk colors
    ModMenuThemeNeon,      // Bright neon colors
    ModMenuThemeMinimal,   // Clean minimal design
    ModMenuThemePastel,    // Soft pastel colors
    ModMenuThemeRetro,     // Retro-style colors
    ModMenuThemeOcean,     // Ocean-inspired colors
    ModMenuThemeForest,    // Nature-inspired colors
    ModMenuThemeSunset,    // Warm sunset colors
    ModMenuThemeMonochrome, // Black and white
    ModMenuThemeChristmas,  // Christmas-inspired colors
    ModMenuThemeLavender,   // Soft lavender and purple theme
    ModMenuThemeVaporwave,  // Nostalgic 80s/90s aesthetic
    ModMenuThemeSteampunk,  // Industrial metallic theme
    ModMenuThemeGalaxy,     // Space and cosmic colors
    ModMenuThemeAqua,       // Water and aquatic theme
  */

  // Il2cpp Resolver handler
  il2cpp();

  // Add hooks and patches
  hooks();
  patches();
}

void waitBeforeLaunch() {
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WAIT * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        setupModMenu();
      });
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer,
                               CFStringRef name, const void *object,
                               CFDictionaryRef info) {
  waitBeforeLaunch();
}

void launchEvent() {
  // Add observer for app launch
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching,
      (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL,
      CFNotificationSuspensionBehaviorDrop);
}

// Entry point
__attribute__((constructor)) static void initialize() { launchEvent(); }
