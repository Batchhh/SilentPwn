/*
 * File: Menu.h
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main menu header for SilentPwn iOS modification
 */


 #import "../Memory/Patch/Patch.h"
 #import <UIKit/UIKit.h>
 #include <cstdint>
 
 NS_ASSUME_NONNULL_BEGIN
 
 @interface ModMenuButton : UIView
 
 @property(nonatomic, copy) void (^tapHandler)(void);
 @property(nonatomic, assign) BOOL isGlowing;
 - (void)setupGradientWithColors:(NSArray<UIColor *> *)colors;
 - (void)showRippleEffect;
 
 @end
 
 @interface QuickAction : NSObject
 @property(nonatomic, strong) NSString *title;
 @property(nonatomic, strong) NSString *iconName;
 @property(nonatomic, copy) void (^action)(void);
 + (instancetype)actionWithTitle:(NSString *)title
                            icon:(NSString *)iconName
                          action:(void (^)(void))action;
 @end
 
 @interface ModMenu : UIView <UITextFieldDelegate>
 
 typedef NS_ENUM(NSInteger, ModMenuCategory) {
   ModMenuCategoryMain,
   ModMenuCategoryPlayer,
   ModMenuCategoryEnemy,
   ModMenuCategoryMisc,
   ModMenuCategoryInterface,
   ModMenuCategoryDebug
 };
 
 typedef NS_ENUM(NSInteger, ModMenuLayout) {
   ModMenuLayoutRadial,
   ModMenuLayoutGrid,
   ModMenuLayoutList,
   ModMenuLayoutElasticString,
 };
 
 typedef NS_ENUM(NSInteger, ModMenuTheme) {
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
 };
 
 @property(nonatomic, strong) ModMenuButton *hubButton;
 @property(nonatomic, strong) NSMutableArray<ModMenuButton *> *categoryButtons;
 @property(nonatomic, strong) UIVisualEffectView *optionsPanel;
 @property(nonatomic, assign) BOOL isOpen;
 @property(nonatomic, assign) ModMenuCategory selectedCategory;
 @property(nonatomic, assign) NSInteger maxVisibleOptions;
 @property(nonatomic, assign) ModMenuLayout currentLayout;
 @property(nonatomic, assign) ModMenuTheme currentTheme;
 @property(nonatomic, strong) NSMutableArray<QuickAction *> *quickActions;
 @property(nonatomic, assign) NSInteger maxButtons;
 @property(nonatomic, strong) NSMutableArray<NSString *> *debugLogs;
 @property(nonatomic, strong) UITextView *logTextView;
 @property(nonatomic, strong)
     NSMutableDictionary<NSNumber *, NSString *> *categoryIcons;
 @property(nonatomic, strong) NSMutableArray<NSDictionary *> *memoryPatches;
 
 + (instancetype)shared;
 - (void)show;
 - (void)hide;
 - (void)savePosition;
 - (void)loadSavedPosition;
 - (void)setupCategoryButtons;
 - (void)toggleMenu;
 - (void)updateCategoryButtonPositions;
 
 - (void)addSlider:(NSString *)title
      initialValue:(float)value
          minValue:(float)min
          maxValue:(float)max
       forCategory:(NSInteger)category;
 - (void)addToggle:(NSString *)title
      initialValue:(BOOL)value
       forCategory:(NSInteger)category;
 
 - (float)getSliderValueFloat:(NSInteger)category
                          withTitle:(NSString *)title;
 - (BOOL)getToggleValue:(NSInteger)category
                         withTitle:(NSString *)title;
 - (NSInteger)getSliderValueInt:(NSInteger)category
                                 withTitle:(NSString *)title;
 
 - (void)addTextInput:(NSString *)title
         initialValue:(NSString *)value
          forCategory:(NSInteger)category;
 - (void)addIndexSwitch:(NSString *)title
                options:(NSArray<NSString *> *)options
           initialIndex:(NSInteger)index
            forCategory:(NSInteger)category;
 - (NSString *)getTextValueForCategory:(NSInteger)category
                             withTitle:(NSString *)title;
 - (NSInteger)getIndexValueForCategory:(NSInteger)category
                             withTitle:(NSString *)title;
 - (void)addTextInput:(NSString *)title
         initialValue:(NSString *)value
             callback:(void (^)(void))callback
          forCategory:(NSInteger)category;
 
 - (void)addButton:(NSString *)title
              icon:(NSString *)iconName
          callback:(void (^)(void))callback
       forCategory:(NSInteger)category;
 
 - (void)setContainerTitle:(NSString *)title forCategory:(NSInteger)category;
 - (void)showMessage:(NSString *)message
            duration:(NSTimeInterval)duration
             credits:(NSString *)credits;
 
 - (void)addStepper:(NSString *)title
       initialValue:(double)value
           minValue:(double)min
           maxValue:(double)max
          increment:(double)step
        forCategory:(NSInteger)category;
 
 - (void)addMultiSelect:(NSString *)title
                options:(NSArray<NSString *> *)options
        selectedIndices:(NSArray<NSNumber *> *)selectedIndices
            forCategory:(NSInteger)category;
 
 - (NSArray<NSNumber *> *)getMultiSelectValuesForCategory:(NSInteger)category
                                                withTitle:(NSString *)title;
 
 - (double)getStepperValueDouble:(NSInteger)category
                            withTitle:(NSString *)title;
 - (NSInteger)getStepperIntValue:(NSInteger)category
                                  withTitle:(NSString *)title;
 - (float)getStepperFloatValue:(NSInteger)category
                                withTitle:(NSString *)title;
 
 - (void)switchTo:(ModMenuLayout)layout animated:(BOOL)animated;
 
 - (void)setTheme:(ModMenuTheme)theme animated:(BOOL)animated;
 
 - (void)addQuickAction:(NSString *)title
                   icon:(NSString *)iconName
                 action:(void (^)(void))action;
 - (void)showQuickActionsMenu;
 
 
 - (BOOL)isOptionSelected:(NSString *)option
            inMultiSelect:(NSString *)title
              forCategory:(NSInteger)category;
 - (BOOL)isIndexSelected:(NSInteger)index
           inMultiSelect:(NSString *)title
             forCategory:(NSInteger)category;
 - (NSArray<NSString *> *)getSelectedOptionsForMultiSelect:(NSString *)title
                                               forCategory:(NSInteger)category;
 
 - (void)addDebugLog:(NSString *)log;
 - (void)clearDebugLogs;
 - (void)showDebugConsole;
 
 - (void)addCallback:(void (^)(id))callback forKey:(NSString *)key;
 - (void)resetPosition;
 - (void)previewCurrentLayout;
 - (NSString *)keyForSetting:(NSString *)title inCategory:(NSInteger)category;
 
 - (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl;
 - (void)sliderValueChanged:(UISlider *)slider;
 
 - (UIView *)viewForCategory:(NSInteger)category;
 - (void)showQuickMessage:(NSString *)message;
 
 - (void)setCategoryIcon:(NSString *)iconName forCategory:(NSInteger)category;
 
 - (void)showPopupMessage:(NSString *)message
                    title:(NSString *)title
                     icon:(NSString *)iconName;
 
 
 - (void)showAlert:(NSString *)message
             title:(NSString *)title
          okButton:(NSString *)okTitle
      cancelButton:(NSString *)cancelTitle
          callback:(void (^)(BOOL confirmed))callback;
 
 - (void)showPatchManager:(NSString *)title icon:(NSString *)iconName;
 - (void)togglePatch:(NSInteger)index enabled:(BOOL)enabled;
 - (void)deletePatch:(NSInteger)index;
 
 
 - (UITextField *)createStylizedTextField:(CGRect)frame
                              placeholder:(NSString *)placeholder;
 - (UIButton *)createStylizedButton:(CGRect)frame title:(NSString *)title;
 
 - (NSString *)getTextValue:(NSInteger)index withTitle:(NSString *)title;
 
 - (void)startInactivityTimer;
 - (void)updateButtonSizes:(CGFloat)size;
 
 - (void)updatePopupColors:(NSDictionary *)colors;
 - (void)handleHubLongPress:(UILongPressGestureRecognizer *)gesture;
 
 - (CGPoint)constrainPointToBounds:(CGPoint)point forView:(UIView *)view;
 
 - (void)updatePatchList:(UIScrollView *)scrollView;
 - (void)addPatchView:(NSDictionary *)patch
         toScrollView:(UIScrollView *)scrollView
             atOffset:(CGFloat *)yOffset;
 
 - (void)addTogglePatch:(NSString *)title
           initialValue:(BOOL)value
                 offset:(NSArray<NSNumber *> *)offsets
                  patch:(NSArray<NSString *> *)patches
            forCategory:(NSInteger)category
               withAsm:(BOOL)withAsm;
 
 - (void)addDefaultOptions:(BOOL)developerMode;
 - (void)createMessage:(NSString *)message;
 
 - (void)saveSettings;
 - (void)loadSettings;
 
 @end
 
 NS_ASSUME_NONNULL_END
 