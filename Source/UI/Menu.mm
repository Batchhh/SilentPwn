/*
 * File: ModMenu.mm
 * Project: SilentPwn
 * Author: Batchh
 * Created: 2024-12-14
 *
 * Copyright (c) 2024 Batchh. All rights reserved.
 *
 * Description: Main tweak implementation for SilentPwn iOS modification
 */
#import "Menu.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
@implementation QuickAction
+ (instancetype)actionWithTitle:(NSString *)title
                           icon:(NSString *)iconName
                         action:(void (^)(void))action {
  QuickAction *quickAction = [[QuickAction alloc] init];
  quickAction.title = title;
  quickAction.iconName = iconName;
  quickAction.action = action;
  return quickAction;
}
@end
@interface ModMenuButton ()
@property(nonatomic, strong) CAGradientLayer *gradientLayer;
@property(nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end
@implementation ModMenuButton
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.layer.cornerRadius = frame.size.width / 2;
    self.clipsToBounds = YES;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.cornerRadius = frame.size.width / 2;
    [self.layer insertSublayer:_gradientLayer atIndex:0];
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleTap)];
    [self addGestureRecognizer:tapGesture];
    _panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handlePan:)];
    [self addGestureRecognizer:_panGesture];
  }
  return self;
}
- (void)setupGradientWithColors:(NSArray<UIColor *> *)colors {
  NSMutableArray *cgColors = [NSMutableArray array];
  for (UIColor *color in colors) {
    [cgColors addObject:(id)color.CGColor];
  }
  _gradientLayer.colors = cgColors;
  _gradientLayer.startPoint = CGPointMake(0, 0);
  _gradientLayer.endPoint = CGPointMake(1, 1);
}
- (void)handleTap {
  if (self.tapHandler) {
    self.tapHandler();
  }
  [self showRippleEffect];
}
- (void)showRippleEffect {
  CAShapeLayer *rippleLayer = [CAShapeLayer layer];
  rippleLayer.frame = self.bounds;
  rippleLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
  rippleLayer.fillColor = [UIColor whiteColor].CGColor;
  rippleLayer.opacity = 0;
  [self.layer addSublayer:rippleLayer];
  CABasicAnimation *animation =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  animation.fromValue = @1.0;
  animation.toValue = @1.5;
  animation.duration = 0.3;
  CABasicAnimation *opacityAnim =
      [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnim.fromValue = @0.5;
  opacityAnim.toValue = @0;
  opacityAnim.duration = 0.3;
  [rippleLayer addAnimation:animation forKey:@"scale"];
  [rippleLayer addAnimation:opacityAnim forKey:@"opacity"];
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [rippleLayer removeFromSuperlayer];
      });
}
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
  CGPoint translation = [gesture translationInView:self.superview];
  ModMenu *menu = (ModMenu *)self.superview;
  switch (gesture.state) {
  case UIGestureRecognizerStateChanged: {
    CGPoint newCenter = self.center;
    newCenter.x += translation.x;
    newCenter.y += translation.y;
    self.center = [menu constrainPointToBounds:newCenter forView:self];
    [gesture setTranslation:CGPointZero inView:self.superview];
    for (UIView *view in self.superview.subviews) {
      if ([view isKindOfClass:[UIButton class]] && view != self &&
          !view.hidden && view.alpha > 0) {
        CGFloat dx = view.center.x - self.center.x;
        CGFloat dy = view.center.y - self.center.y;
        CGPoint buttonCenter =
            CGPointMake(self.center.x + dx, self.center.y + dy);
        view.center = [menu constrainPointToBounds:buttonCenter forView:view];
      }
    }
    if (menu.isOpen) {
      [menu updateCategoryButtonPositions];
    }
    break;
  }
  case UIGestureRecognizerStateEnded: {
    [UIView animateWithDuration:0.1
                     animations:^{
                       self.transform = CGAffineTransformIdentity;
                     }];
    [menu savePosition];
    break;
  }
  default:
    break;
  }
}
- (void)animateCategoryButtonsWithDelta:(CGPoint)delta inMenu:(ModMenu *)menu {
  NSInteger buttonCount = menu.categoryButtons.count;
  CGFloat angleIncrement = (2 * M_PI) / buttonCount;
  [menu.categoryButtons enumerateObjectsUsingBlock:^(
                            ModMenuButton *button, NSUInteger idx, BOOL *stop) {
    CGFloat angle = angleIncrement * idx;
    CGFloat delay = idx * 0.02;
    CGFloat distanceFactor = 1.0 - (idx / (float)buttonCount);
    CGFloat waveX = delta.x * distanceFactor * cos(angle);
    CGFloat waveY = delta.y * distanceFactor * sin(angle);
    [UIView animateWithDuration:0.3
        delay:delay
        usingSpringWithDamping:0.5
        initialSpringVelocity:0.8
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^{
          CGPoint currentCenter = button.center;
          button.center =
              CGPointMake(currentCenter.x + waveX, currentCenter.y + waveY);
          CGFloat rotationAngle = atan2(delta.y, delta.x) * 0.2;
          button.transform = CGAffineTransformMakeRotation(rotationAngle);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.2
                           animations:^{
                             button.transform = CGAffineTransformIdentity;
                           }
                           completion:nil];
        }];
  }];
}
@end
@interface ModMenu () <UITextFieldDelegate>
@property(nonatomic, strong) UIView *popupView;
@property(nonatomic, strong) UIImageView *hamburgerIcon;
@property(nonatomic, strong)
    NSMutableDictionary<NSNumber *, NSMutableArray *> *categorySettings;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *settingValues;
@property(nonatomic, strong) NSArray<NSArray<UIColor *> *> *categoryColors;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) UITapGestureRecognizer *tapGestureKeyboard;
@property(nonatomic, assign) CGFloat gridSpacing;
@property(nonatomic, assign) NSInteger gridColumns;
@property(nonatomic, strong)
    NSDictionary<NSNumber *, NSDictionary *> *themeColors;
@property(nonatomic, assign) BOOL isSnappedToEdge;
@property(weak, nonatomic) ModMenu *weakSelf;
@property(nonatomic, strong) NSTimer *inactivityTimer;
@property(nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@end
@implementation ModMenu
+ (instancetype)shared {
  static ModMenu *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    CGRect frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,
                              UIScreen.mainScreen.bounds.size.height);
    sharedInstance = [[ModMenu alloc] initWithFrame:frame];
    sharedInstance.maxButtons = 3;
  });
  return sharedInstance;
}
- (UIWindow *)getWindow {
  __block UIWindow *mainWindow = nil;
  if ([NSThread isMainThread]) {
    mainWindow = [self findKeyWindow];
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      mainWindow = [self findKeyWindow];
    });
  }

  return mainWindow;
}
- (UIWindow *)findKeyWindow {
  for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
    if ([scene isKindOfClass:[UIWindowScene class]]) {
      UIWindowScene *windowScene = (UIWindowScene *)scene;
      for (UIWindow *window in windowScene.windows) {
        if (window.isKeyWindow) {
          return window;
        }
      }
    }
  }
  return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
  UIWindow *window = [self getWindow];
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.categorySettings = [NSMutableDictionary dictionary];
    self.settingValues = [NSMutableDictionary dictionary];
    self.maxVisibleOptions = 3;
    [self setupHubButton];
    [self setupCategoryButtons];
    self.isOpen = NO;
    self.userInteractionEnabled = YES;
    self.opaque = NO;
    [self performSelector:@selector(performLaunchAnimation)
               withObject:nil
               afterDelay:1.0];
    self.tapGestureKeyboard = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(dismissKeyboard)];
    self.tapGestureKeyboard.enabled = NO;
    [self addGestureRecognizer:self.tapGestureKeyboard];
    [self setupThemes];
    self.currentTheme = ModMenuThemeDark;
    [self startInactivityTimer];
    self.debugLogs = [NSMutableArray array];
    self.categoryIcons = [NSMutableDictionary dictionary];
  }
  [window addSubview:self];
  return self;
}
- (void)setupHubButton {
  _hubButton = [[ModMenuButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
  [_hubButton setupGradientWithColors:@[
    [UIColor colorWithRed:0.4 green:0.4 blue:0.5 alpha:1],
    [UIColor colorWithRed:0.2 green:0.2 blue:0.3 alpha:1]
  ]];
  self.hamburgerIcon = [[UIImageView alloc]
      initWithImage:[UIImage systemImageNamed:@"line.horizontal.3"]];
  self.hamburgerIcon.tintColor = [UIColor whiteColor];
  self.hamburgerIcon.contentMode = UIViewContentModeScaleAspectFit;
  self.hamburgerIcon.frame = CGRectMake(20, 20, 20, 20);
  [_hubButton addSubview:self.hamburgerIcon];
  ModMenu *__weak weakSelf = self;
  _hubButton.tapHandler = ^{
    ModMenu *strongSelf = weakSelf;
    if (strongSelf) {
      [strongSelf toggleMenu];
    }
  };
  [self addSubview:_hubButton];
  self.hubButton.center =
      CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  UILongPressGestureRecognizer *longPress =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handleHubLongPress:)];
  longPress.minimumPressDuration = 0.5;
  [_hubButton addGestureRecognizer:longPress];
  self.quickActions = [NSMutableArray array];
}
- (void)setupCategoryButtons {
  self.categoryColors = @[
    @[
      [UIColor colorWithRed:0.2 green:0.2 blue:0.25 alpha:1],
      [UIColor colorWithRed:0.3 green:0.3 blue:0.35 alpha:1]
    ],
    @[
      [UIColor colorWithRed:0.25 green:0.25 blue:0.3 alpha:1],
      [UIColor colorWithRed:0.35 green:0.35 blue:0.4 alpha:1]
    ],
    @[
      [UIColor colorWithRed:0.3 green:0.3 blue:0.35 alpha:1],
      [UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1]
    ],
    @[
      [UIColor colorWithRed:0.35 green:0.35 blue:0.4 alpha:1],
      [UIColor colorWithRed:0.45 green:0.45 blue:0.5 alpha:1]
    ],
    @[
      [UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1],
      [UIColor colorWithRed:0.5 green:0.5 blue:0.55 alpha:1]
    ],
    @[
      [UIColor colorWithRed:0.45 green:0.45 blue:0.5 alpha:1],
      [UIColor colorWithRed:0.55 green:0.55 blue:0.6 alpha:1]
    ]
  ];
  NSArray *titles =
      @[ @"Main", @"Player", @"Enemy", @"Misc", @"Display", @"Debug" ];
  NSArray *icons = @[
    @"gamecontroller.fill", @"person.fill", @"target", @"ellipsis.circle.fill",
    @"display", @"gearshape.fill"
  ];
  self.categoryButtons = [NSMutableArray array];
  NSInteger numberOfButtons = MIN(self.maxButtons, self.categoryColors.count);
  for (int i = 0; i < numberOfButtons; i++) {
    ModMenuButton *button =
        [[ModMenuButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    button.tag = i;
    NSString *iconName = self.categoryIcons[@(i)];
    if (!iconName) {
      switch (i) {
      case 0:
        iconName = @"gamecontroller.fill";
        break;
      case 1:
        iconName = @"person.fill";
        break;
      case 2:
        iconName = @"target";
        break;
      case 3:
        iconName = @"ellipsis.circle.fill";
        break;
      case 4:
        iconName = @"display";
        break;
      case 5:
        iconName = @"gearshape.fill";
        break;
      default:
        iconName = @"circle.fill";
        break;
      }
    }
    UIImageView *iconView =
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat iconSize = 25;
    CGFloat padding = (50 - iconSize) / 2;
    iconView.frame = CGRectMake(padding, padding, iconSize, iconSize);
    [button addSubview:iconView];
    [button setupGradientWithColors:self.categoryColors[i]];
    __weak ModMenuButton *weakButton = button;
    button.tapHandler = ^{
      [self showPopupForCategory:i withIcon:icons[i]];
      __strong ModMenuButton *strongButton = weakButton;
      if (strongButton) {
        [UIView animateWithDuration:0.15
            animations:^{
              strongButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }
            completion:^(BOOL finished) {
              [UIView animateWithDuration:0.15
                               animations:^{
                                 strongButton.transform =
                                     CGAffineTransformIdentity;
                               }];
            }];
      }
    };
    button.alpha = 0.0;
    button.hidden = YES;
    [self setContainerTitle:titles[i] forCategory:i];
    [self addSubview:button];
    [self.categoryButtons addObject:button];
  }
  [self updateCategoryButtonPositions];
}
- (void)updateCategoryButtonPositions {
  if (self.currentLayout == ModMenuLayoutRadial) {
    [self updateRadialLayout];
  } else if (self.currentLayout == ModMenuLayoutGrid) {
    [self updateGridLayout];
  } else if (self.currentLayout == ModMenuLayoutList) {
    [self updateListLayout];
  } else if (self.currentLayout == ModMenuLayoutElasticString) {
    [self updateElasticStringLayout];
  }
}
- (void)updateRadialLayout {
  CGFloat angleIncrement = (2 * M_PI) / self.categoryButtons.count;
  CGFloat radius = 80.0;
  for (int i = 0; i < self.categoryButtons.count; i++) {
    ModMenuButton *button = self.categoryButtons[i];
    CGFloat angle = angleIncrement * i - M_PI_2;
    button.transform = CGAffineTransformIdentity;
    CGPoint position =
        CGPointMake(self.hubButton.center.x + radius * cos(angle),
                    self.hubButton.center.y + radius * sin(angle));
    [UIView animateWithDuration:0.3
        delay:0.05 * i
        usingSpringWithDamping:0.5
        initialSpringVelocity:0.5
        options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
          button.center = position;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.15
                           animations:^{
                             button.transform = CGAffineTransformIdentity;
                           }];
        }];
  }
}
- (void)updateGridLayout {
  CGFloat buttonSize = 50.0;
  CGFloat spacing = 70.0;
  NSInteger rows = ceil(sqrt(self.categoryButtons.count));
  NSInteger cols = rows;
  CGFloat totalWidth = (cols - 1) * spacing;
  CGFloat startX = self.hubButton.center.x - totalWidth / 2;
  CGFloat startY = self.hubButton.center.y + buttonSize * 2;
  NSInteger buttonIndex = 0;
  for (NSInteger row = 0;
       row < rows && buttonIndex < self.categoryButtons.count; row++) {
    for (NSInteger col = 0;
         col < cols && buttonIndex < self.categoryButtons.count; col++) {
      ModMenuButton *button = self.categoryButtons[buttonIndex];
      CGPoint targetPosition =
          CGPointMake(startX + col * spacing, startY + row * spacing);
      [UIView animateWithDuration:0.6
                            delay:0.1 * buttonIndex
           usingSpringWithDamping:0.7
            initialSpringVelocity:0.3
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         button.center = targetPosition;
                         button.transform = CGAffineTransformIdentity;
                         button.transform =
                             CGAffineTransformMakeScale(0.9, 0.9);
                         button.transform = CGAffineTransformRotate(
                             button.transform, sin(buttonIndex * 0.2) * 0.05);
                         button.backgroundColor = [UIColor colorWithRed:0.8
                                                                  green:0.8
                                                                   blue:0.8
                                                                  alpha:0.2];
                       }
                       completion:nil];
      buttonIndex++;
    }
  }
}
- (void)updateListLayout {
  CGFloat buttonSize = 50.0;
  CGFloat spacing = 10.0;
  CGFloat safeRadius = self.hubButton.frame.size.height / 2 + 20.0;
  CGFloat startY = self.hubButton.center.y + safeRadius;
  CGFloat xPosition = self.hubButton.center.x - buttonSize / 2;
  CGFloat yPos = startY;
  for (NSInteger i = 0; i < self.categoryButtons.count; i++) {
    ModMenuButton *button = self.categoryButtons[i];
    [UIView animateWithDuration:0.3
                          delay:0.05 * i
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       button.center = CGPointMake(xPosition + buttonSize / 2,
                                                   yPos + buttonSize / 2);
                       button.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    yPos += buttonSize + spacing;
  }
}
- (void)updateElasticStringLayout {
  CGFloat buttonSize = 40.0;
  CGFloat dampingFactor = 0.9;
  CGFloat totalLength = (buttonSize + 15.0) * (self.categoryButtons.count - 1);
  CGFloat startX = self.hubButton.center.x - totalLength / 2;
  CGFloat startY = self.hubButton.center.y + buttonSize * 1.5;
  CGPoint previousButtonCenter = CGPointMake(startX, startY);
  for (NSInteger i = 0; i < self.categoryButtons.count; i++) {
    ModMenuButton *button = self.categoryButtons[i];
    CGPoint targetPosition = CGPointMake(startX + i * (buttonSize + 15.0),
                                         startY + sin(i * 0.5) * 10);
    [UIView animateWithDuration:0.4
                          delay:0.05 * i
         usingSpringWithDamping:dampingFactor
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       button.center = targetPosition;
                       button.transform = CGAffineTransformMakeScale(1.0, 1.0);
                       button.transform = CGAffineTransformRotate(
                           button.transform, sin(i * 0.3) * 0.1);
                     }
                     completion:nil];
    previousButtonCenter = targetPosition;
  }
}
- (void)moveToCenterRight {
  CGPoint centerRight =
      CGPointMake(self.bounds.size.width - 40, self.bounds.size.height / 2);
  centerRight = [self constrainPointToBounds:centerRight
                                     forView:self.hubButton];
  [UIView animateWithDuration:0.5
                   animations:^{
                     self.hubButton.center = centerRight;
                     [self updateCategoryButtonPositions];
                   }];
}
- (void)show {
  if (!self.isOpen) {
    self.isOpen = YES;
    for (ModMenuButton *button in self.categoryButtons) {
      button.hidden = NO;
      button.alpha = 0;
      if (self.currentLayout == ModMenuLayoutList) {
        button.center = self.hubButton.center;
        button.transform = CGAffineTransformMakeScale(0.3, 0.3);
      } else {
        button.transform = CGAffineTransformMakeScale(0.5, 0.5);
      }
    }
    [self updateCategoryButtonPositions];
    [UIView animateWithDuration:0.3
        delay:0
        usingSpringWithDamping:0.8
        initialSpringVelocity:0.5
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
          for (ModMenuButton *button in self.categoryButtons) {
            button.alpha = 1;
          }
          self.hamburgerIcon.transform = CGAffineTransformMakeRotation(M_PI_4);
        }
        completion:^(BOOL finished) {
          self.hamburgerIcon.image = [UIImage systemImageNamed:@"xmark"];
          self.hamburgerIcon.transform = CGAffineTransformIdentity;
        }];
  }
}
- (void)hide {
  if (self.isOpen) {
    self.isOpen = NO;
    [UIView animateWithDuration:0.3
        delay:0
        options:UIViewAnimationOptionCurveEaseIn
        animations:^{
          for (ModMenuButton *button in self.categoryButtons) {
            button.transform = CGAffineTransformMakeScale(0.8, 0.8);
            button.alpha = 0.0;
          }
          self.hamburgerIcon.transform = CGAffineTransformMakeRotation(-M_PI_4);
        }
        completion:^(BOOL finished) {
          for (ModMenuButton *button in self.categoryButtons) {
            button.transform = CGAffineTransformIdentity;
          }
          self.hamburgerIcon.image =
              [UIImage systemImageNamed:@"line.horizontal.3"];
          self.hamburgerIcon.transform = CGAffineTransformIdentity;
        }];
  }
}
- (void)savePosition {
  CGPoint position = self.hubButton.center;
  [[NSUserDefaults standardUserDefaults] setFloat:position.x
                                           forKey:@"hubButtonX"];
  [[NSUserDefaults standardUserDefaults] setFloat:position.y
                                           forKey:@"hubButtonY"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)loadSavedPosition {
  CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"hubButtonX"];
  CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"hubButtonY"];
  if (x && y) {
    self.hubButton.center = CGPointMake(x, y);
  } else {
    self.hubButton.center =
        CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  }
}
- (void)toggleMenu {
  if (self.isOpen) {
    [self hide];
    [self startInactivityTimer];
  } else {
    [self show];
    [self.inactivityTimer invalidate];
    self.inactivityTimer = nil;
    self.isSnappedToEdge = NO;
  }
}
- (void)addSlider:(NSString *)title
     initialValue:(float)value
         minValue:(float)min
         maxValue:(float)max
      forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = @(value);
  NSDictionary *setting = @{
    @"type" : @"slider",
    @"title" : title,
    @"value" : @(value),
    @"min" : @(min),
    @"max" : @(max)
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addToggle:(NSString *)title
     initialValue:(BOOL)value
      forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = @(value);
  NSDictionary *setting =
      @{@"type" : @"toggle", @"title" : title, @"value" : @(value)};
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addTogglePatch:(NSString *)title
          initialValue:(BOOL)value
                offset:(NSArray<NSNumber *> *)offsets
                 patch:(NSArray<NSString *> *)patches
           forCategory:(NSInteger)category
               withAsm:(BOOL)withAsm {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = @(value);
  NSDictionary *setting = @{
    @"type" : @"toggle",
    @"title" : title,
    @"value" : @(value),
    @"offsets" : offsets,
    @"patches" : patches,
    @"withAsm" : @(withAsm)
  };
  [self.categorySettings[@(category)] addObject:setting];
  if (value) {
    for (NSUInteger i = 0; i < MIN(offsets.count, patches.count); i++) {
      if (withAsm) {
        [Patch offsetAsm:[offsets[i] unsignedLongLongValue]
                asm_arch:MP_ASM_ARM64
                asm_code:[patches[i] UTF8String]];
        [self
            addDebugLog:[NSString
                            stringWithFormat:@"Toggle ASM offset: %llx -> %s",
                                             [offsets[i] unsignedLongLongValue],
                                             [patches[i] UTF8String]]];
      } else {
        [Patch offset:[offsets[i] unsignedLongLongValue] patch:patches[i]];
        [self
            addDebugLog:[NSString
                            stringWithFormat:@"Toggle offset: %llx -> %@",
                                             [offsets[i] unsignedLongLongValue],
                                             patches[i]]];
      }
    }
  }
}
- (void)addTextInput:(NSString *)title
        initialValue:(NSString *)value
            callback:(void (^)(void))callback
         forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = value;
  NSString *callbackKey = [NSString stringWithFormat:@"%@_callback", key];
  self.settingValues[callbackKey] = callback;
  NSDictionary *setting = @{
    @"type" : @"text",
    @"title" : title,
    @"value" : value,
    @"hasCallback" : @(callback != nil)
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addIndexSwitch:(NSString *)title
               options:(NSArray<NSString *> *)options
          initialIndex:(NSInteger)index
           forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = @(index);
  NSDictionary *setting = @{
    @"type" : @"index",
    @"title" : title,
    @"options" : options,
    @"value" : @(index)
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addButton:(NSString *)title
             icon:(NSString *)iconName
         callback:(void (^)(void))callback
      forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *callbackKey = [NSString stringWithFormat:@"%@_callback", title];
  self.settingValues[callbackKey] = callback;
  NSDictionary *setting = @{
    @"type" : @"button",
    @"title" : title,
    @"icon" : iconName,
    @"hasCallback" : @(callback != nil)
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addStepper:(NSString *)title
      initialValue:(double)value
          minValue:(double)min
          maxValue:(double)max
         increment:(double)step
       forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = @(value);
  NSDictionary *setting = @{
    @"type" : @"stepper",
    @"title" : title,
    @"value" : @(value),
    @"min" : @(min),
    @"max" : @(max),
    @"increment" : @(step)
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)addMultiSelect:(NSString *)title
               options:(NSArray<NSString *> *)options
       selectedIndices:(NSArray<NSNumber *> *)selectedIndices
           forCategory:(NSInteger)category {
  if (!self.categorySettings[@(category)]) {
    self.categorySettings[@(category)] = [NSMutableArray array];
  }
  NSString *key = [self keyForSetting:title inCategory:category];
  self.settingValues[key] = selectedIndices;
  NSDictionary *setting = @{
    @"type" : @"multiselect",
    @"title" : title,
    @"options" : options,
    @"selectedIndices" : selectedIndices
  };
  [self.categorySettings[@(category)] addObject:setting];
}
- (void)showPopupForCategory:(NSInteger)categoryIndex
                    withIcon:(NSString *)iconName {
  if (self.popupView) {
    [self.popupView removeFromSuperview];
  }
  [UIView animateWithDuration:0.2
      animations:^{
        self.hubButton.alpha = 0;
        for (ModMenuButton *button in self.categoryButtons) {
          button.alpha = 0;
        }
      }
      completion:^(BOOL finished) {
        self.hubButton.hidden = YES;
        for (ModMenuButton *button in self.categoryButtons) {
          button.hidden = YES;
        }
      }];
  if (!self.blurBackgroundView) {
    [self setupBlurBackground];
  }
  [self animateBlurBackground:YES];
  CGFloat popupWidth = 280;
  self.popupView = [[UIView alloc]
      initWithFrame:CGRectMake(self.bounds.size.width,
                               (self.bounds.size.height - 200) / 2, popupWidth,
                               200)];
  self.popupView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
  self.popupView.layer.cornerRadius = 15;
  UIView *headerView =
      [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupWidth, 50)];
  headerView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
  headerView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(closePopup)];
  [headerView addGestureRecognizer:tapGesture];
  UIImageView *iconView =
      [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
  iconView.tintColor = [UIColor whiteColor];
  iconView.contentMode = UIViewContentModeScaleAspectFit;
  CGFloat iconSize = 30;
  CGFloat padding = (50 - iconSize) / 2;
  iconView.frame = CGRectMake(padding, padding, iconSize, iconSize);
  [headerView addSubview:iconView];
  NSString *key =
      [NSString stringWithFormat:@"containerTitle_%ld", (long)categoryIndex];
  NSString *containerTitle = self.settingValues[key] ?: @"Default Title";
  UILabel *titleLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(55, 0, popupWidth - 70, 50)];
  titleLabel.text = containerTitle;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  [headerView addSubview:titleLabel];
  [self.popupView addSubview:headerView];
  NSArray *settings = self.categorySettings[@(categoryIndex)];
  CGFloat optionHeight = 60;
  CGFloat topMargin = 3;
  CGFloat headerHeight = 50;
  CGFloat maxContentHeight = self.maxVisibleOptions * optionHeight;
  CGFloat totalContentHeight = settings.count * optionHeight;
  CGFloat scrollViewHeight = MIN(maxContentHeight, totalContentHeight);
  CGFloat popupHeight = scrollViewHeight + headerHeight + (topMargin * 2);
  CGRect popupFrame = self.popupView.frame;
  popupFrame.size.height = popupHeight;
  popupFrame.origin.y = (self.bounds.size.height - popupHeight) / 2;
  self.popupView.frame = popupFrame;
  UIScrollView *scrollView = [[UIScrollView alloc]
      initWithFrame:CGRectMake(0, headerHeight, popupWidth, scrollViewHeight)];
  scrollView.contentInset = UIEdgeInsetsMake(topMargin, 0, topMargin, 0);
  [self.popupView addSubview:scrollView];
  UIView *contentView = [[UIView alloc]
      initWithFrame:CGRectMake(15, 0, popupWidth - 30, totalContentHeight)];
  [scrollView addSubview:contentView];
  CGFloat yOffset = 0;
  for (NSDictionary *setting in settings) {
    NSString *type = setting[@"type"];
    NSString *title = setting[@"title"];
    NSString *key = [self keyForSetting:title inCategory:categoryIndex];
    UIView *settingContainer = [[UIView alloc]
        initWithFrame:CGRectMake(0, yOffset, contentView.frame.size.width, 50)];
    settingContainer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
    settingContainer.layer.cornerRadius = 10;
    [contentView addSubview:settingContainer];
    UILabel *settingLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 120, 50)];
    settingLabel.text = title;
    settingLabel.textColor = [UIColor whiteColor];
    settingLabel.font = [UIFont systemFontOfSize:14];
    [settingContainer addSubview:settingLabel];
    if ([type isEqualToString:@"slider"]) {
      UIView *sliderContainer = [[UIView alloc]
          initWithFrame:CGRectMake(130, 10, contentView.frame.size.width - 145,
                                   30)];
      UISlider *slider = [[UISlider alloc]
          initWithFrame:CGRectMake(0, 0, sliderContainer.frame.size.width - 45,
                                   30)];
      slider.minimumValue = [setting[@"min"] floatValue];
      slider.maximumValue = [setting[@"max"] floatValue];
      slider.value = [self.settingValues[key] floatValue];
      slider.minimumTrackTintColor = [UIColor colorWithRed:0
                                                     green:0.8
                                                      blue:1
                                                     alpha:1];
      slider.maximumTrackTintColor = [UIColor colorWithWhite:0.3 alpha:1];
      UILabel *valueLabel = [[UILabel alloc]
          initWithFrame:CGRectMake(sliderContainer.frame.size.width - 40, 0, 40,
                                   30)];
      valueLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
      valueLabel.textColor = [UIColor whiteColor];
      valueLabel.font = [UIFont systemFontOfSize:12];
      valueLabel.textAlignment = NSTextAlignmentRight;
      slider.accessibilityIdentifier = key;
      valueLabel.tag = 1000;
      [slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
      [slider addTarget:self
                    action:@selector(updateSliderLabel:)
          forControlEvents:UIControlEventValueChanged];
      [sliderContainer addSubview:slider];
      [sliderContainer addSubview:valueLabel];
      [settingContainer addSubview:sliderContainer];
    } else if ([type isEqualToString:@"toggle"]) {
      UISwitch *toggle = [[UISwitch alloc]
          initWithFrame:CGRectMake(contentView.frame.size.width - 65, 10, 51,
                                   31)];
      toggle.transform = CGAffineTransformMakeScale(0.8, 0.8);
      toggle.tag = categoryIndex;
      NSString *toggleKey = [self keyForSetting:title inCategory:categoryIndex];
      toggle.on = [self.settingValues[toggleKey] boolValue];
      toggle.onTintColor = [UIColor colorWithRed:0 green:0.8 blue:1 alpha:1];
      toggle.accessibilityIdentifier = toggleKey;
      [toggle addTarget:self
                    action:@selector(toggleValueChanged:)
          forControlEvents:UIControlEventValueChanged];
      [settingContainer addSubview:toggle];
    } else if ([type isEqualToString:@"text"]) {
      BOOL hasCallback = [setting[@"hasCallback"] boolValue];
      CGFloat textFieldWidth = hasCallback ? 110 : 140;
      UIView *inputContainer = [[UIView alloc]
          initWithFrame:CGRectMake(contentView.frame.size.width - 150, 10, 140,
                                   30)];
      inputContainer.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
      inputContainer.layer.cornerRadius = 5;
      inputContainer.clipsToBounds = YES;
      UITextField *textField = [[UITextField alloc]
          initWithFrame:CGRectMake(0, 0, textFieldWidth, 30)];
      textField.backgroundColor = [UIColor clearColor];
      textField.textColor = [UIColor whiteColor];
      textField.font = [UIFont systemFontOfSize:14];
      textField.text = self.settingValues[key];
      textField.placeholder = @"Enter value...";
      UIView *paddingView =
          [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
      textField.leftView = paddingView;
      textField.leftViewMode = UITextFieldViewModeAlways;
      textField.accessibilityIdentifier = key;
      textField.delegate = self;
      textField.returnKeyType = UIReturnKeyDone;
      [textField addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
      [textField addTarget:self
                    action:@selector(textFieldDidBeginEditing:)
          forControlEvents:UIControlEventEditingDidBegin];
      [textField addTarget:self
                    action:@selector(textFieldDidEndEditing:)
          forControlEvents:UIControlEventEditingDidEnd];
      [inputContainer addSubview:textField];
      if (hasCallback) {
        NSDictionary *colors = self.themeColors[@(self.currentTheme)];
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        actionButton.frame = CGRectMake(textFieldWidth, 0, 30, 30);
        actionButton.backgroundColor =
            [colors[@"accent"] colorWithAlphaComponent:0.3];
        UIImageView *chevronImage = [[UIImageView alloc]
            initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
        chevronImage.tintColor = [UIColor whiteColor];
        chevronImage.contentMode = UIViewContentModeScaleAspectFit;
        chevronImage.frame = CGRectMake(8, 7, 16, 16);
        chevronImage.tag = 100;
        [actionButton addSubview:chevronImage];
        actionButton.accessibilityIdentifier =
            [NSString stringWithFormat:@"%@_callback", key];
        [actionButton addTarget:self
                         action:@selector(textInputButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [inputContainer addSubview:actionButton];
      }
      [settingContainer addSubview:inputContainer];
    } else if ([type isEqualToString:@"index"]) {
      settingContainer.frame =
          CGRectMake(0, yOffset, contentView.frame.size.width, 80);
      NSArray *options = setting[@"options"];
      UISegmentedControl *segmentedControl =
          [[UISegmentedControl alloc] initWithItems:options];
      segmentedControl.frame =
          CGRectMake(15, 38, contentView.frame.size.width - 30, 35);
      segmentedControl.backgroundColor = [UIColor colorWithWhite:0.15
                                                           alpha:1.0];
      segmentedControl.tintColor = [UIColor colorWithRed:0
                                                   green:0.8
                                                    blue:1
                                                   alpha:1];
      NSDictionary *normalAttributes = @{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:0.8 alpha:1.0],
        NSFontAttributeName : [UIFont systemFontOfSize:12]
      };
      NSDictionary *selectedAttributes = @{
        NSForegroundColorAttributeName : [UIColor colorWithRed:0
                                                         green:0.8
                                                          blue:1
                                                         alpha:0.2],
        NSFontAttributeName : [UIFont boldSystemFontOfSize:12]
      };
      [segmentedControl setTitleTextAttributes:normalAttributes
                                      forState:UIControlStateNormal];
      [segmentedControl setTitleTextAttributes:selectedAttributes
                                      forState:UIControlStateSelected];
      segmentedControl.selectedSegmentIndex =
          [self.settingValues[key] integerValue];
      segmentedControl.accessibilityIdentifier = key;
      [segmentedControl addTarget:self
                           action:@selector(segmentedControlValueChanged:)
                 forControlEvents:UIControlEventValueChanged];
      [settingContainer addSubview:segmentedControl];
      yOffset += 90;
      continue;
    } else if ([type isEqualToString:@"button"]) {
      BOOL hasCallback = [setting[@"hasCallback"] boolValue];
      NSString *iconName = setting[@"icon"];
      NSDictionary *colors = self.themeColors[@(self.currentTheme)];
      settingLabel.text = title;
      settingLabel.textColor = colors[@"text"];
      settingLabel.font = [UIFont systemFontOfSize:14];
      UIView *buttonContainer = [[UIView alloc]
          initWithFrame:CGRectMake(contentView.frame.size.width - 85, 10, 75,
                                   30)];
      buttonContainer.backgroundColor =
          [colors[@"accent"] colorWithAlphaComponent:0.3];
      buttonContainer.layer.cornerRadius = 5;
      buttonContainer.clipsToBounds = YES;
      UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
      button.frame = buttonContainer.bounds;
      button.backgroundColor = [UIColor clearColor];
      button.contentHorizontalAlignment =
          UIControlContentHorizontalAlignmentCenter;
      button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
      if (iconName) {
        UIImage *icon = [UIImage systemImageNamed:iconName];
        [button setImage:icon forState:UIControlStateNormal];
        button.tintColor = colors[@"text"];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat padding = 5;
        button.configuration.imagePadding = padding;
      }
      if (hasCallback) {
        button.accessibilityIdentifier =
            [NSString stringWithFormat:@"%@_callback", title];
        [button addTarget:self
                      action:@selector(buttonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self
                      action:@selector(buttonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
      }
      [buttonContainer addSubview:button];
      [settingContainer addSubview:buttonContainer];
    } else if ([type isEqualToString:@"stepper"]) {
      UIView *stepperContainer = [[UIView alloc]
          initWithFrame:CGRectMake(contentView.frame.size.width - 150, 10, 140,
                                   30)];
      stepperContainer.layer.cornerRadius = 5;
      UIStepper *stepper =
          [[UIStepper alloc] initWithFrame:CGRectMake(-7, 0, 80, 35)];
      stepper.minimumValue = [setting[@"min"] doubleValue];
      stepper.maximumValue = [setting[@"max"] doubleValue];
      stepper.stepValue = [setting[@"increment"] doubleValue];
      stepper.value = [self.settingValues[key] doubleValue];
      stepper.transform = CGAffineTransformMakeScale(0.8, 0.8);
      stepper.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
      stepper.layer.cornerRadius = 5;
      stepper.clipsToBounds = YES;
      [stepper setIncrementImage:[[UIImage systemImageNamed:@"plus"]
                                     imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysTemplate]
                        forState:UIControlStateNormal];
      stepper.tintColor = [UIColor whiteColor];
      [stepper setDecrementImage:[[UIImage systemImageNamed:@"minus"]
                                     imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysTemplate]
                        forState:UIControlStateNormal];
      stepper.tintColor = [UIColor whiteColor];
      UIView *valueContainer =
          [[UIView alloc] initWithFrame:CGRectMake(95, 2, 40, 26)];
      valueContainer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.3];
      valueContainer.layer.cornerRadius = 5;
      UILabel *valueLabel =
          [[UILabel alloc] initWithFrame:valueContainer.bounds];
      valueLabel.text = [NSString stringWithFormat:@"%.0f", stepper.value];
      valueLabel.textColor = [UIColor whiteColor];
      valueLabel.font = [UIFont systemFontOfSize:12];
      valueLabel.textAlignment = NSTextAlignmentCenter;
      valueLabel.tag = 1000;
      stepper.accessibilityIdentifier = key;
      [stepper addTarget:self
                    action:@selector(stepperValueChanged:)
          forControlEvents:UIControlEventValueChanged];
      [stepper addTarget:self
                    action:@selector(stepperTouchDown:)
          forControlEvents:UIControlEventTouchDown];
      [stepper addTarget:self
                    action:@selector(stepperTouchUp:)
          forControlEvents:UIControlEventTouchUpInside |
                           UIControlEventTouchUpOutside];
      [valueContainer addSubview:valueLabel];
      [stepperContainer addSubview:stepper];
      [stepperContainer addSubview:valueContainer];
      [settingContainer addSubview:stepperContainer];
    } else if ([type isEqualToString:@"multiselect"]) {
      settingContainer.frame =
          CGRectMake(0, yOffset, contentView.frame.size.width, 80);
      NSArray *options = setting[@"options"];
      NSArray *selectedIndices = setting[@"selectedIndices"];
      UIScrollView *optionsScroll = [[UIScrollView alloc]
          initWithFrame:CGRectMake(15, 38, contentView.frame.size.width - 30,
                                   35)];
      optionsScroll.showsHorizontalScrollIndicator = NO;
      CGFloat xOffset = 0;
      CGFloat spacing = 10;
      for (NSInteger i = 0; i < options.count; i++) {
        UIButton *optionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [optionButton setTitle:options[i] forState:UIControlStateNormal];
        CGSize textSize = [options[i] sizeWithAttributes:@{
          NSFontAttributeName : [UIFont systemFontOfSize:12]
        }];
        CGFloat buttonWidth = textSize.width + 20;
        optionButton.frame = CGRectMake(xOffset, 0, buttonWidth, 30);
        optionButton.tag = i;
        NSDictionary *colors = self.themeColors[@(self.currentTheme)];
        if ([selectedIndices containsObject:@(i)]) {
          optionButton.backgroundColor =
              [colors[@"accent"] colorWithAlphaComponent:0.3];
          optionButton.tintColor = colors[@"primary"];
        } else {
          optionButton.backgroundColor =
              [colors[@"secondary"] colorWithAlphaComponent:0.2];
          optionButton.tintColor = colors[@"text"];
        }
        optionButton.layer.cornerRadius = 6;
        [optionButton setTitleColor:[selectedIndices containsObject:@(i)]
                                        ? colors[@"primary"]
                                        : colors[@"text"]
                           forState:UIControlStateNormal];
        optionButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [optionButton addTarget:self
                         action:@selector(multiSelectOptionTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [optionsScroll addSubview:optionButton];
        xOffset += buttonWidth + spacing;
      }
      optionsScroll.contentSize = CGSizeMake(xOffset, 35);
      [settingContainer addSubview:optionsScroll];
      settingContainer.accessibilityIdentifier = key;
      yOffset += 90;
      continue;
    }
    yOffset += 60;
  }
  contentView.frame =
      CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y,
                 contentView.frame.size.width, yOffset);
  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, yOffset);
  [self addSubview:self.popupView];
  [self updatePopupColors:self.themeColors[@(self.currentTheme)]];
  [UIView animateWithDuration:0.5
                        delay:0
       usingSpringWithDamping:0.8
        initialSpringVelocity:0.5
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     self.popupView.center =
                         CGPointMake(self.bounds.size.width / 2,
                                     self.bounds.size.height / 2);
                   }
                   completion:nil];
}
- (void)closePopup {
  [self animateBlurBackground:NO];
  [UIView animateWithDuration:0.5
      animations:^{
        CGRect frame = self.popupView.frame;
        frame.origin.x = self.bounds.size.width;
        self.popupView.frame = frame;
      }
      completion:^(BOOL finished) {
        [self.popupView removeFromSuperview];
        self.popupView = nil;
        self.hubButton.hidden = NO;
        for (ModMenuButton *button in self.categoryButtons) {
          button.hidden = NO;
        }
        [UIView animateWithDuration:0.2
                         animations:^{
                           self.hubButton.alpha = 1;
                           for (ModMenuButton *button in self.categoryButtons) {
                             button.alpha = 1;
                             button.transform = CGAffineTransformIdentity;
                           }
                         }];
        self.isOpen = YES;
      }];
}
- (NSString *)keyForSetting:(NSString *)title inCategory:(NSInteger)category {
  return [NSString stringWithFormat:@"%ld_%@", (long)category, title];
}
- (void)sliderValueChanged:(UISlider *)slider {
  NSString *key = slider.accessibilityIdentifier;
  self.settingValues[key] = @(slider.value);
  if ([key containsString:@"Menu Opacity"]) {
    CGFloat opacity = slider.value / 100.0;
    self.alpha = opacity;
  } else if ([key containsString:@"Button Size"]) {
    [self updateButtonSizes:slider.value];
  }
  NSString *callbackKey = [NSString stringWithFormat:@"%@_callback", key];
  void (^callback)(id) = self.settingValues[callbackKey];
  if (callback) {
    callback(@(slider.value));
  }
  [self updateSliderLabel:slider];
}
- (void)toggleValueChanged:(UISwitch *)toggle {
  NSString *key = toggle.accessibilityIdentifier;
  self.settingValues[key] = @(toggle.isOn);
  NSInteger categoryIndex = toggle.tag;
  NSArray *categorySettings = self.categorySettings[@(categoryIndex)];
  if (!categorySettings)
    return;
  NSString *title = [key componentsSeparatedByString:@"_"].lastObject;
  NSUInteger settingIndex = [categorySettings
      indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx,
                                     BOOL *stop) {
        return [obj[@"title"] isEqualToString:title];
      }];
  if (settingIndex == NSNotFound)
    return;
  NSDictionary *setting = categorySettings[settingIndex];
  if (![setting[@"type"] isEqualToString:@"toggle"] || !setting[@"offsets"] ||
      !setting[@"patches"])
    return;
  NSArray<NSNumber *> *offsets = setting[@"offsets"];
  NSArray<NSString *> *patches = setting[@"patches"];
  for (NSUInteger i = 0; i < MIN(offsets.count, patches.count); i++) {
    uint64_t offset = [offsets[i] unsignedLongLongValue];
    NSString *patchHex = patches[i];
    if (toggle.isOn) {
      if ([setting[@"withAsm"] boolValue]) {
        [Patch offsetAsm:offset
                asm_arch:MP_ASM_ARM64
                asm_code:[patchHex UTF8String]];
        [self
            addDebugLog:[NSString
                            stringWithFormat:@"Toggle ASM offset: %llx -> %s",
                                             [offsets[i] unsignedLongLongValue],
                                             [patches[i] UTF8String]]];
      } else {
        [Patch offset:offset patch:patchHex];
        [self
            addDebugLog:[NSString
                            stringWithFormat:@"Toggle offset: %llx -> %@",
                                             [offsets[i] unsignedLongLongValue],
                                             patches[i]]];
      }
    } else {
      BOOL success = [Patch revertOffset:offset];
      if (!success) {
        [self
            addDebugLog:[NSString stringWithFormat:
                                      @"Failed to revert patch at offset: %llx",
                                      offset]];
      }
      [self addDebugLog:[NSString
                            stringWithFormat:@"Revert offset: %llx", offset]];
    }
  }
}
- (void)textFieldDidChange:(UITextField *)textField {
  NSString *key = textField.accessibilityIdentifier;
  self.settingValues[key] = textField.text;
}
- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
  NSString *key = segmentedControl.accessibilityIdentifier;
  self.settingValues[key] = @(segmentedControl.selectedSegmentIndex);
  NSString *callbackKey = [NSString stringWithFormat:@"%@_callback", key];
  void (^callback)(id) = self.settingValues[callbackKey];
  if (callback) {
    callback(@(segmentedControl.selectedSegmentIndex));
  }
}
- (float)getSliderValueFloat:(NSInteger)category withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] floatValue];
}
- (BOOL)getToggleValue:(NSInteger)category withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] boolValue];
}
- (NSInteger)getSliderValueInt:(NSInteger)category withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] integerValue];
}
- (NSString *)getTextValueForCategory:(NSInteger)category
                            withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return self.settingValues[key];
}
- (NSInteger)getIndexValueForCategory:(NSInteger)category
                            withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] integerValue];
}
- (void)updateSliderLabel:(UISlider *)slider {
  UIView *container = slider.superview;
  UILabel *valueLabel = [container viewWithTag:1000];
  valueLabel.text = [NSString stringWithFormat:@"%.0f", slider.value];
}
- (void)textInputButtonTapped:(UIButton *)button {
  UIImageView *chevronImage = [button viewWithTag:100];
  [UIView animateWithDuration:0.2
      animations:^{
        chevronImage.transform = CGAffineTransformMakeTranslation(5, 0);
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2
                         animations:^{
                           chevronImage.transform = CGAffineTransformIdentity;
                         }];
      }];
  NSString *callbackKey = button.accessibilityIdentifier;
  void (^callback)(void) = self.settingValues[callbackKey];
  if (callback) {
    callback();
  }
}
- (UIImage *)createThumbImage {
  CGRect rect = CGRectMake(0, 0, 15, 15);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  UIBezierPath *roundedRectanglePath =
      [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:7.5];
  [[UIColor whiteColor] setFill];
  [roundedRectanglePath fill];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}
- (void)buttonTapped:(UIButton *)button {
  [UIView animateWithDuration:0.15
      animations:^{
        button.transform = CGAffineTransformMakeScale(1.1, 1.1);
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15
                         animations:^{
                           button.transform = CGAffineTransformIdentity;
                         }];
      }];
  NSString *callbackKey = button.accessibilityIdentifier;
  void (^callback)(void) = self.settingValues[callbackKey];
  if (callback) {
    callback();
  }
}
- (void)buttonTouchDown:(UIButton *)button {
  [UIView animateWithDuration:0.1
                   animations:^{
                     button.transform = CGAffineTransformMakeScale(0.95, 0.95);
                     button.alpha = 0.8;
                   }];
}
- (void)buttonTouchUp:(UIButton *)button {
  [UIView animateWithDuration:0.1
                   animations:^{
                     button.transform = CGAffineTransformIdentity;
                     button.alpha = 1.0;
                   }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:self];
  if (self.popupView && !CGRectContainsPoint(self.popupView.frame, location)) {
    [self closePopup];
    return;
  }
  BOOL touchedOutside = YES;
  if (CGRectContainsPoint(self.hubButton.frame, location)) {
    touchedOutside = NO;
  }
  for (ModMenuButton *button in self.categoryButtons) {
    if (!button.hidden && CGRectContainsPoint(button.frame, location)) {
      touchedOutside = NO;
      break;
    }
  }
  if (touchedOutside) {
    [self hide];
    if (self.popupView) {
      [self closePopup];
    }
  }
}
- (void)setContainerTitle:(NSString *)title forCategory:(NSInteger)category {
  NSString *key =
      [NSString stringWithFormat:@"containerTitle_%ld", (long)category];
  self.settingValues[key] = title;
}
- (void)showMessage:(NSString *)message
           duration:(NSTimeInterval)duration
            credits:(NSString *)credits {
  if (self.messageLabel) {
    [self.messageLabel removeFromSuperview];
  }
  CGFloat padding = 15.0;
  CGFloat messageHeight = 70.0;
  CGFloat messageWidth = self.bounds.size.width - 4 * padding;
  UIView *messageContainer =
      [[UIView alloc] initWithFrame:CGRectMake(padding * 2, -messageHeight,
                                               messageWidth, messageHeight)];
  messageContainer.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
  messageContainer.layer.cornerRadius = 12;
  messageContainer.clipsToBounds = YES;
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = messageContainer.bounds;
  gradientLayer.colors = @[
    (id)[UIColor colorWithRed:0 green:0.9 blue:1 alpha:0.6].CGColor,
    (id)[UIColor colorWithRed:0.4 green:0.2 blue:1 alpha:0.6].CGColor
  ];
  gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(1, 1);
  CAShapeLayer *maskLayer = [CAShapeLayer layer];
  maskLayer.frame = messageContainer.bounds;
  maskLayer.path =
      [UIBezierPath bezierPathWithRoundedRect:messageContainer.bounds
                                 cornerRadius:12]
          .CGPath;
  maskLayer.lineWidth = 1.5;
  maskLayer.strokeColor = UIColor.whiteColor.CGColor;
  maskLayer.fillColor = UIColor.clearColor.CGColor;
  gradientLayer.mask = maskLayer;
  [messageContainer.layer addSublayer:gradientLayer];
  self.messageLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 10, messageWidth - 30, 30)];
  self.messageLabel.text = message;
  self.messageLabel.textColor = [UIColor whiteColor];
  self.messageLabel.textAlignment = NSTextAlignmentCenter;
  self.messageLabel.font = [UIFont boldSystemFontOfSize:16];
  [messageContainer addSubview:self.messageLabel];
  UILabel *creditsLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 35, messageWidth - 30, 25)];
  creditsLabel.text = credits;
  creditsLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
  creditsLabel.textAlignment = NSTextAlignmentCenter;
  creditsLabel.font = [UIFont systemFontOfSize:12];
  [messageContainer addSubview:creditsLabel];
  CABasicAnimation *pulseAnimation =
      [CABasicAnimation animationWithKeyPath:@"opacity"];
  pulseAnimation.duration = 1.5;
  pulseAnimation.fromValue = @(0.4);
  pulseAnimation.toValue = @(0.8);
  pulseAnimation.timingFunction = [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  pulseAnimation.autoreverses = YES;
  pulseAnimation.repeatCount = HUGE_VALF;
  [gradientLayer addAnimation:pulseAnimation forKey:@"pulse"];
  [self addSubview:messageContainer];
  [UIView animateWithDuration:0.6
      delay:0
      usingSpringWithDamping:0.7
      initialSpringVelocity:0.5
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        messageContainer.frame =
            CGRectMake(padding * 2, padding, messageWidth, messageHeight);
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5
            delay:duration
            options:UIViewAnimationOptionCurveEaseIn
            animations:^{
              messageContainer.frame = CGRectMake(padding * 2, -messageHeight,
                                                  messageWidth, messageHeight);
              messageContainer.alpha = 0;
            }
            completion:^(BOOL finished) {
              [messageContainer removeFromSuperview];
            }];
      }];
  UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(dismissMessage)];
  swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
  [messageContainer addGestureRecognizer:swipeUp];
  messageContainer.userInteractionEnabled = YES;
}
- (void)dismissMessage {
  UIView *messageContainer = self.messageLabel.superview;
  [UIView animateWithDuration:0.3
      animations:^{
        messageContainer.frame = CGRectMake(messageContainer.frame.origin.x,
                                            -messageContainer.frame.size.height,
                                            messageContainer.frame.size.width,
                                            messageContainer.frame.size.height);
        messageContainer.alpha = 0;
      }
      completion:^(BOOL finished) {
        [messageContainer removeFromSuperview];
      }];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.tapGestureKeyboard.enabled = YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
  self.tapGestureKeyboard.enabled = NO;
}
- (void)multiSelectOptionTapped:(UIButton *)button {
  UIView *container = button.superview.superview;
  NSString *key = container.accessibilityIdentifier;
  NSMutableArray *selectedIndices =
      [self.settingValues[key] mutableCopy] ?: [NSMutableArray array];
  NSNumber *index = @(button.tag);
  if ([selectedIndices containsObject:index]) {
    [selectedIndices removeObject:index];
    [UIView animateWithDuration:0.2
                     animations:^{
                       NSDictionary *colors =
                           self.themeColors[@(self.currentTheme)];
                       button.backgroundColor =
                           [colors[@"secondary"] colorWithAlphaComponent:0.2];
                       button.backgroundColor = [UIColor clearColor];
                       button.transform = CGAffineTransformIdentity;
                     }];
  } else {
    [selectedIndices addObject:index];
    [UIView animateWithDuration:0.2
        animations:^{
          NSDictionary *colors = self.themeColors[@(self.currentTheme)];
          button.backgroundColor =
              [colors[@"accent"] colorWithAlphaComponent:0.3];
          button.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.1
                           animations:^{
                             button.transform = CGAffineTransformIdentity;
                           }];
        }];
  }
  self.settingValues[key] = selectedIndices;
}
- (double)getStepperValueDouble:(NSInteger)category
                      withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] doubleValue];
}
- (NSArray<NSNumber *> *)getMultiSelectValuesForCategory:(NSInteger)category
                                               withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return self.settingValues[key];
}
- (UIImage *)imageWithColor:(UIColor *)color {
  CGRect rect = CGRectMake(0, 0, 1, 1);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}
- (void)stepperTouchDown:(UIStepper *)stepper {
  [UIView animateWithDuration:0.1
                   animations:^{
                     stepper.transform = CGAffineTransformMakeScale(0.75, 0.75);
                     stepper.alpha = 0.8;
                   }];
}
- (void)stepperTouchUp:(UIStepper *)stepper {
  [UIView animateWithDuration:0.2
                        delay:0
       usingSpringWithDamping:0.5
        initialSpringVelocity:0.5
                      options:UIViewAnimationOptionCurveEaseOut
                   animations:^{
                     stepper.transform = CGAffineTransformMakeScale(0.8, 0.8);
                     stepper.alpha = 1.0;
                   }
                   completion:nil];
}
- (void)stepperValueChanged:(UIStepper *)stepper {
  NSString *key = stepper.accessibilityIdentifier;
  self.settingValues[key] = @(stepper.value);
  UIView *container = stepper.superview;
  UILabel *valueLabel = [container viewWithTag:1000];
  [UIView animateWithDuration:0.2
      animations:^{
        valueLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
        valueLabel.alpha = 0.7;
      }
      completion:^(BOOL finished) {
        valueLabel.text = [NSString stringWithFormat:@"%.0f", stepper.value];
        [UIView animateWithDuration:0.2
                         animations:^{
                           valueLabel.transform = CGAffineTransformIdentity;
                           valueLabel.alpha = 1.0;
                         }];
      }];
}
- (NSInteger)getStepperIntValue:(NSInteger)category
                      withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] integerValue];
}
- (float)getStepperFloatValue:(NSInteger)category withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:category];
  return [self.settingValues[key] floatValue];
}
- (void)switchTo:(ModMenuLayout)layout animated:(BOOL)animated {
  self.currentLayout = layout;
  if (animated) {
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       [self updateCategoryButtonPositions];
                     }
                     completion:nil];
  } else {
    [self updateCategoryButtonPositions];
  }
}
- (void)setupThemes {
  self.themeColors = @{
    @(ModMenuThemeDark) : @{
      @"primary" : [UIColor colorWithRed:0.2 green:0.2 blue:0.25 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.3 green:0.3 blue:0.35 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0 green:0.8 blue:1 alpha:1.0],
      @"background" : [UIColor colorWithWhite:0.1 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
    @(ModMenuThemeCyberpunk) : @{
      @"primary" : [UIColor colorWithRed:0.9 green:0.2 blue:0.5 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.2 green:0.8 blue:0.8 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.95],
      @"text" : [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0]
    },
    @(ModMenuThemeNeon) : @{
      @"primary" : [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0],
      @"background" : [UIColor colorWithWhite:0.0 alpha:0.98],
      @"text" : [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]
    },
    @(ModMenuThemeMinimal) : @{
      @"primary" : [UIColor colorWithWhite:0.9 alpha:1.0],
      @"secondary" : [UIColor colorWithWhite:0.8 alpha:1.0],
      @"accent" : [UIColor colorWithWhite:0.3 alpha:1.0],
      @"background" : [UIColor colorWithWhite:1.0 alpha:0.98],
      @"text" : [UIColor blackColor]
    },
    @(ModMenuThemePastel) : @{
      @"primary" : [UIColor colorWithRed:0.9 green:0.8 blue:0.9 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.9 green:0.7 blue:0.8 alpha:1.0],
      @"background" : [UIColor colorWithRed:1.0
                                      green:0.98
                                       blue:0.98
                                      alpha:0.98],
      @"text" : [UIColor colorWithRed:0.4 green:0.4 blue:0.5 alpha:1.0]
    },
    @(ModMenuThemeRetro) : @{
      @"primary" : [UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.6 green:0.3 blue:0.1 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.2 green:0.15 blue:0.1 alpha:0.95],
      @"text" : [UIColor colorWithRed:1.0 green:0.9 blue:0.7 alpha:1.0]
    },
    @(ModMenuThemeOcean) : @{
      @"primary" : [UIColor colorWithRed:0.0 green:0.4 blue:0.6 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.0 green:0.5 blue:0.7 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.0 green:0.2 blue:0.3 alpha:0.95],
      @"text" : [UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:1.0]
    },
    @(ModMenuThemeForest) : @{
      @"primary" : [UIColor colorWithRed:0.2 green:0.5 blue:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.3 green:0.6 blue:0.3 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.8 green:0.9 blue:0.3 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.1 green:0.2 blue:0.1 alpha:0.95],
      @"text" : [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0]
    },
    @(ModMenuThemeSunset) : @{
      @"primary" : [UIColor colorWithRed:0.9 green:0.4 blue:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.8 green:0.3 blue:0.4 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.2 green:0.1 blue:0.15 alpha:0.95],
      @"text" : [UIColor colorWithRed:1.0 green:0.95 blue:0.9 alpha:1.0]
    },
    @(ModMenuThemeMonochrome) : @{
      @"primary" : [UIColor colorWithWhite:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithWhite:0.3 alpha:1.0],
      @"accent" : [UIColor colorWithWhite:0.8 alpha:1.0],
      @"background" : [UIColor colorWithWhite:0.0 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
    @(ModMenuThemeChristmas) : @{
      @"primary" : [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.9 green:0.3 blue:0.3 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95],
      @"text" : [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
    },
    @(ModMenuThemeLavender) : @{
      @"primary" : [UIColor colorWithRed:0.6 green:0.4 blue:0.8 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.7 green:0.5 blue:0.9 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.9 green:0.7 blue:1.0 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.2 green:0.1 blue:0.3 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
    @(ModMenuThemeVaporwave) : @{
      @"primary" : [UIColor colorWithRed:0.8 green:0.4 blue:0.8 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.4 green:0.8 blue:0.9 alpha:1.0],
      @"accent" : [UIColor colorWithRed:1.0 green:0.6 blue:0.8 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
    @(ModMenuThemeSteampunk) : @{
      @"primary" : [UIColor colorWithRed:0.4 green:0.3 blue:0.2 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.5 green:0.4 blue:0.3 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.8 green:0.6 blue:0.4 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.95],
      @"text" : [UIColor colorWithRed:0.9 green:0.8 blue:0.7 alpha:1.0]
    },
    @(ModMenuThemeGalaxy) : @{
      @"primary" : [UIColor colorWithRed:0.2 green:0.0 blue:0.4 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.3 green:0.0 blue:0.5 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.8 green:0.4 blue:1.0 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.0 green:0.0 blue:0.1 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
    @(ModMenuThemeAqua) : @{
      @"primary" : [UIColor colorWithRed:0.0 green:0.6 blue:0.8 alpha:1.0],
      @"secondary" : [UIColor colorWithRed:0.0 green:0.7 blue:0.9 alpha:1.0],
      @"accent" : [UIColor colorWithRed:0.4 green:0.9 blue:1.0 alpha:1.0],
      @"background" : [UIColor colorWithRed:0.0 green:0.2 blue:0.3 alpha:0.95],
      @"text" : [UIColor whiteColor]
    },
  };
}
- (void)setTheme:(ModMenuTheme)theme animated:(BOOL)animated {
  self.currentTheme = theme;
  NSDictionary *colors = self.themeColors[@(theme)];
  void (^updateColors)(void) = ^{
    [self.hubButton
        setupGradientWithColors:@[ colors[@"primary"], colors[@"secondary"] ]];
    self.hamburgerIcon.tintColor = colors[@"text"];
    for (ModMenuButton *button in self.categoryButtons) {
      [button setupGradientWithColors:@[
        colors[@"primary"], colors[@"secondary"]
      ]];
      for (UIView *subview in button.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
          ((UIImageView *)subview).tintColor = colors[@"text"];
        }
      }
    }
    if (self.popupView) {
      [self updatePopupColors:colors];
    }
  };
  if (animated) {
    [UIView animateWithDuration:0.3 animations:updateColors];
  } else {
    updateColors();
  }
}
- (void)updatePopupColors:(NSDictionary *)colors {
  if (!self.popupView)
    return;
  UIView *headerView = [self.popupView.subviews firstObject];
  headerView.backgroundColor = colors[@"primary"];
  self.popupView.backgroundColor = colors[@"background"];
  [self recursivelyUpdateViewColors:self.popupView withColors:colors];
}
- (void)recursivelyUpdateViewColors:(UIView *)view
                         withColors:(NSDictionary *)colors {
  if ([view isKindOfClass:[UILabel class]]) {
    ((UILabel *)view).textColor = colors[@"text"];
  } else if ([view isKindOfClass:[UISlider class]]) {
    UISlider *slider = (UISlider *)view;
    slider.minimumTrackTintColor = colors[@"accent"];
    slider.maximumTrackTintColor =
        [colors[@"secondary"] colorWithAlphaComponent:0.5];
    slider.thumbTintColor = colors[@"secondary"];
    [slider setThumbImage:[self createThumbImage]
                 forState:UIControlStateNormal];
    [slider setThumbImage:[self createThumbImage]
                 forState:UIControlStateHighlighted];
  } else if ([view isKindOfClass:[UISwitch class]]) {
    UISwitch *switchControl = (UISwitch *)view;
    switchControl.onTintColor = colors[@"accent"];
    switchControl.thumbTintColor = colors[@"secondary"];
  } else if ([view isKindOfClass:[UIButton class]]) {
    UIButton *button = (UIButton *)view;
    [button setTitleColor:colors[@"text"] forState:UIControlStateNormal];
    if (button.tag == 100) {
      button.tintColor = colors[@"accent"];
    }
  } else if ([view isKindOfClass:[UITextField class]]) {
    UITextField *textField = (UITextField *)view;
    textField.textColor = colors[@"text"];
    textField.backgroundColor =
        [colors[@"secondary"] colorWithAlphaComponent:0.2];
    textField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:textField.placeholder
            attributes:@{
              NSForegroundColorAttributeName :
                  [colors[@"text"] colorWithAlphaComponent:0.5]
            }];
  } else if ([view isKindOfClass:[UISegmentedControl class]]) {
    UISegmentedControl *segmentControl = (UISegmentedControl *)view;
    segmentControl.backgroundColor =
        [colors[@"secondary"] colorWithAlphaComponent:0.3];
    segmentControl.tintColor = colors[@"accent"];
    NSDictionary *normalAttributes = @{
      NSForegroundColorAttributeName : colors[@"text"],
      NSFontAttributeName : [UIFont systemFontOfSize:12]
    };
    NSDictionary *selectedAttributes = @{
      NSForegroundColorAttributeName : colors[@"primary"],
      NSFontAttributeName : [UIFont boldSystemFontOfSize:12]
    };
    [segmentControl setTitleTextAttributes:normalAttributes
                                  forState:UIControlStateNormal];
    [segmentControl setTitleTextAttributes:selectedAttributes
                                  forState:UIControlStateSelected];
  } else if ([view isKindOfClass:[UIStepper class]]) {
    UIStepper *stepper = (UIStepper *)view;
    stepper.tintColor = colors[@"accent"];
  }
  for (UIView *subview in view.subviews) {
    [self recursivelyUpdateViewColors:subview withColors:colors];
  }
}
- (void)handleHubLongPress:(UILongPressGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateBegan) {
    [self showQuickActionsMenu];
  }
}
- (void)addQuickAction:(NSString *)title
                  icon:(NSString *)iconName
                action:(void (^)(void))action {
  QuickAction *quickAction = [QuickAction actionWithTitle:title
                                                     icon:iconName
                                                   action:action];
  [self.quickActions addObject:quickAction];
}
- (void)showQuickActionsMenu {
  if (self.quickActions.count == 0)
    return;
  if ([self hasVisibleQuickActions]) {
    [self dismissQuickActions];
    return;
  }
  NSDictionary *colors = self.themeColors[@(self.currentTheme)];
  CGFloat radius = 70.0;
  CGFloat buttonSize = 45.0;
  CGFloat angleIncrement = (2 * M_PI) / self.quickActions.count;
  for (NSInteger i = 0; i < self.quickActions.count; i++) {
    QuickAction *action = self.quickActions[i];
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    actionButton.frame = CGRectMake(0, 0, buttonSize, buttonSize);
    actionButton.backgroundColor = colors[@"primary"];
    actionButton.layer.cornerRadius = buttonSize / 2;
    actionButton.tag = i;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = actionButton.bounds;
    gradientLayer.colors =
        @[ (id)colors[@"primary"], (id)colors[@"secondary"] ];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.cornerRadius = buttonSize / 2;
    [actionButton.layer insertSublayer:gradientLayer atIndex:0];
    UIImageView *iconView = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:action.iconName]];
    iconView.tintColor = colors[@"text"];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake(12, 12, 21, 21);
    [actionButton addSubview:iconView];
    CGFloat angle = angleIncrement * i - M_PI_2;
    CGFloat x = self.hubButton.center.x + radius * cos(angle);
    CGFloat y = self.hubButton.center.y + radius * sin(angle);
    actionButton.center = self.hubButton.center;
    actionButton.alpha = 0;
    [self addSubview:actionButton];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(handleQuickActionPan:)];
    [actionButton addGestureRecognizer:panGesture];
    [actionButton addTarget:self
                     action:@selector(quickActionTapped:)
           forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.3
                          delay:i * 0.05
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       actionButton.center = CGPointMake(x, y);
                       actionButton.alpha = 1;
                       actionButton.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
  }
}
- (BOOL)hasVisibleQuickActions {
  for (UIView *view in self.subviews) {
    if ([view isKindOfClass:[UIButton class]] && view != self.hubButton &&
        view.alpha > 0) {
      return YES;
    }
  }
  return NO;
}
- (void)handleQuickActionPan:(UIPanGestureRecognizer *)gesture {
  UIButton *button = (UIButton *)gesture.view;
  CGPoint translation = [gesture translationInView:self];
  switch (gesture.state) {
  case UIGestureRecognizerStateChanged: {
    CGPoint newCenter = button.center;
    newCenter.x += translation.x;
    newCenter.y += translation.y;
    CGFloat dx = newCenter.x - self.hubButton.center.x;
    CGFloat dy = newCenter.y - self.hubButton.center.y;
    CGFloat distance = sqrt(dx * dx + dy * dy);
    CGFloat maxDistance = 100.0;
    if (distance > maxDistance) {
      CGFloat angle = atan2(dy, dx);
      newCenter.x = self.hubButton.center.x + maxDistance * cos(angle);
      newCenter.y = self.hubButton.center.y + maxDistance * sin(angle);
    }
    button.center = newCenter;
    [gesture setTranslation:CGPointZero inView:self];
    CGFloat scale = 1.0 - (distance / (maxDistance * 2));
    button.transform =
        CGAffineTransformMakeScale(MAX(0.8, scale), MAX(0.8, scale));
    break;
  }
  case UIGestureRecognizerStateEnded: {
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       button.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    break;
  }
  default:
    break;
  }
}
- (void)dismissQuickActions {
  [UIView animateWithDuration:0.2
      animations:^{
        for (UIView *view in self.subviews) {
          if ([view isKindOfClass:[UIButton class]] && view != self.hubButton) {
            view.alpha = 0;
            view.transform = CGAffineTransformMakeScale(0.5, 0.5);
          }
        }
      }
      completion:^(BOOL finished) {
        for (UIView *view in self.subviews) {
          if ([view isKindOfClass:[UIButton class]] && view != self.hubButton) {
            [view removeFromSuperview];
          }
        }
      }];
}
- (void)quickActionTapped:(UIButton *)button {
  QuickAction *action = self.quickActions[button.tag];
  [self showQuickMessage:action.title];
  if (action.action) {
    action.action();
  }
  [self dismissQuickActions];
}
- (void)showQuickMessage:(NSString *)message {
  CGSize size =
      [message
          boundingRectWithSize:CGSizeMake(250, CGFLOAT_MAX)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{
                      NSFontAttributeName : [UIFont boldSystemFontOfSize:14]
                    }
                       context:nil]
          .size;
  UILabel *popupLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 0, size.width + 20, size.height + 20)];
  popupLabel.text = message;
  popupLabel.textColor = [UIColor whiteColor];
  popupLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.9];
  popupLabel.textAlignment = NSTextAlignmentCenter;
  popupLabel.font = [UIFont boldSystemFontOfSize:14];
  popupLabel.layer.cornerRadius = 20;
  popupLabel.clipsToBounds = YES;
  popupLabel.center =
      CGPointMake(self.hubButton.center.x, self.hubButton.center.y - 80);
  popupLabel.alpha = 0;
  [self addSubview:popupLabel];
  [UIView animateWithDuration:0.3
      animations:^{
        popupLabel.alpha = 1;
        popupLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3
            delay:1.0
            options:UIViewAnimationOptionCurveEaseOut
            animations:^{
              popupLabel.alpha = 0;
              popupLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
            }
            completion:^(BOOL finished) {
              [popupLabel removeFromSuperview];
            }];
      }];
}
- (void)createMessage:(NSString *)message {
  UIView *existingMessage = [self viewWithTag:999];
  if (existingMessage) {
    [existingMessage removeFromSuperview];
  }
  UIView *container = [[UIView alloc]
      initWithFrame:CGRectMake(self.bounds.size.width - 160, 20, 140, 40)];
  container.tag = 999;
  container.backgroundColor = [UIColor colorWithRed:0 green:0.8 blue:1 alpha:1];
  container.layer.cornerRadius = 5;
  container.clipsToBounds = YES;
  UIImageView *iconView = [[UIImageView alloc]
      initWithImage:[UIImage systemImageNamed:@"info.circle.fill"]];
  iconView.frame = CGRectMake(10, 10, 20, 20);
  iconView.tintColor = [UIColor whiteColor];
  [container addSubview:iconView];
  UILabel *popupLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(35, 0, container.bounds.size.width - 45,
                               container.bounds.size.height)];
  popupLabel.text = message;
  popupLabel.textColor = [UIColor whiteColor];
  popupLabel.textAlignment = NSTextAlignmentLeft;
  popupLabel.font = [UIFont systemFontOfSize:14];
  popupLabel.numberOfLines = 0;
  [container addSubview:popupLabel];
  container.alpha = 0;
  [self addSubview:container];
  [UIView animateWithDuration:0.3
      delay:0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        container.alpha = 1;
        CGPoint point = container.center;
        point.x = self.bounds.size.width - container.bounds.size.width / 2;
        container.center = point;
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3
            delay:1.5
            options:UIViewAnimationOptionCurveEaseInOut
            animations:^{
              container.alpha = 0;
              CGPoint point = container.center;
              point.x =
                  self.bounds.size.width + container.bounds.size.width / 2;
              container.center = point;
            }
            completion:^(BOOL finished) {
              [container removeFromSuperview];
            }];
      }];
}
- (void)setMaxButtons:(NSInteger)maxButtons {
  _maxButtons = maxButtons;
  for (ModMenuButton *button in self.categoryButtons) {
    [button removeFromSuperview];
  }
  [self.categoryButtons removeAllObjects];
  [self setupCategoryButtons];
  if (self.isOpen) {
    [self updateCategoryButtonPositions];
  }
}
- (void)performLaunchAnimation {
  self.hubButton.alpha = 0;
  self.hubButton.transform = CGAffineTransformMakeScale(0.01, 0.01);
  CALayer *glowLayer = [CALayer layer];
  glowLayer.frame = CGRectMake(-25, -25, self.hubButton.bounds.size.width + 50,
                               self.hubButton.bounds.size.height + 50);
  glowLayer.cornerRadius = glowLayer.frame.size.width / 2;
  glowLayer.backgroundColor =
      [UIColor colorWithRed:0 green:0.9 blue:1 alpha:0.3].CGColor;
  glowLayer.shadowColor =
      [UIColor colorWithRed:0 green:0.9 blue:1 alpha:1.0].CGColor;
  glowLayer.shadowOffset = CGSizeZero;
  glowLayer.shadowRadius = 15;
  glowLayer.shadowOpacity = 0.8;
  [self.hubButton.layer insertSublayer:glowLayer atIndex:0];
  CABasicAnimation *pulseAnimation =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  pulseAnimation.duration = 2.0;
  pulseAnimation.fromValue = @1.0;
  pulseAnimation.toValue = @1.3;
  pulseAnimation.autoreverses = YES;
  pulseAnimation.repeatCount = 3;
  pulseAnimation.timingFunction = [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [glowLayer addAnimation:pulseAnimation forKey:@"pulse"];
  CAShapeLayer *haloLayer = [CAShapeLayer layer];
  UIBezierPath *circlePath = [UIBezierPath
      bezierPathWithArcCenter:CGPointMake(self.hubButton.bounds.size.width / 2,
                                          self.hubButton.bounds.size.height / 2)
                       radius:40
                   startAngle:0
                     endAngle:2 * M_PI
                    clockwise:YES];
  haloLayer.path = circlePath.CGPath;
  haloLayer.strokeColor =
      [UIColor colorWithRed:0.2 green:0.8 blue:1 alpha:0.6].CGColor;
  haloLayer.fillColor = [UIColor clearColor].CGColor;
  haloLayer.lineWidth = 2;
  [self.hubButton.layer addSublayer:haloLayer];
  CABasicAnimation *rotationAnimation =
      [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.toValue = @(2 * M_PI);
  rotationAnimation.duration = 3;
  rotationAnimation.repeatCount = 2;
  [haloLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
  for (int i = 0; i < 12; i++) {
    CALayer *particle = [CALayer layer];
    particle.frame = CGRectMake(0, 0, 4, 4);
    particle.cornerRadius = 2;
    particle.backgroundColor =
        [UIColor colorWithRed:0 green:0.9 blue:1 alpha:0.8].CGColor;
    particle.position = self.hubButton.center;
    [self.layer addSublayer:particle];
    CGFloat angle = (2 * M_PI * i) / 12;
    CGFloat distance = 100;
    CGPoint endPoint =
        CGPointMake(self.hubButton.center.x + cos(angle) * distance,
                    self.hubButton.center.y + sin(angle) * distance);
    CABasicAnimation *moveAnim =
        [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnim.fromValue = [NSValue valueWithCGPoint:self.hubButton.center];
    moveAnim.toValue = [NSValue valueWithCGPoint:endPoint];
    moveAnim.duration = 1.5;
    CABasicAnimation *fadeAnim =
        [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = @1.0;
    fadeAnim.toValue = @0.0;
    fadeAnim.duration = 1.5;
    CABasicAnimation *scaleAnim =
        [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnim.fromValue = @1.0;
    scaleAnim.toValue = @0.1;
    scaleAnim.duration = 1.5;
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[ moveAnim, fadeAnim, scaleAnim ];
    group.duration = 1.5;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [particle addAnimation:group forKey:@"burst"];
  }
  [UIView animateWithDuration:1.2
      delay:0.3
      usingSpringWithDamping:0.5
      initialSpringVelocity:0.6
      options:UIViewAnimationOptionCurveEaseOut
      animations:^{
        self.hubButton.alpha = 1;
        self.hubButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4
            animations:^{
              self.hubButton.transform = CGAffineTransformIdentity;
            }
            completion:^(BOOL finished) {
              [UIView animateWithDuration:0.8
                  delay:0.4
                  options:UIViewAnimationOptionCurveEaseInOut
                  animations:^{
                    [self moveToCenterRight];
                  }
                  completion:^(BOOL finished) {
                    [UIView
                        animateWithDuration:0.3
                                      delay:0
                                    options:
                                        UIViewAnimationOptionAutoreverse |
                                        UIViewAnimationOptionRepeat |
                                        UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                   self.hubButton.transform =
                                       CGAffineTransformMakeScale(1.05, 1.05);
                                 }
                                 completion:nil];
                  }];
            }];
      }];
}
- (void)startInactivityTimer {
  [self.inactivityTimer invalidate];
  self.inactivityTimer =
      [NSTimer scheduledTimerWithTimeInterval:2.0
                                       target:self
                                     selector:@selector(handleInactivity)
                                     userInfo:nil
                                      repeats:NO];
}
- (void)handleInactivity {
  if (!self.isOpen) {
    CGRect bounds = self.superview.bounds;
    CGPoint center = self.hubButton.center;
    CGFloat buttonRadius = self.hubButton.bounds.size.width / 2;
    BOOL isNearEdge = NO;
    CGPoint targetCenter = center;
    if (center.x < buttonRadius * 3) {
      targetCenter.x = buttonRadius / 2;
      isNearEdge = YES;
    } else if (center.x > bounds.size.width - buttonRadius * 3) {
      targetCenter.x = bounds.size.width - buttonRadius / 2;
      isNearEdge = YES;
    }
    if (center.y < buttonRadius * 3) {
      targetCenter.y = buttonRadius / 2;
      isNearEdge = YES;
    } else if (center.y > bounds.size.height - buttonRadius * 3) {
      targetCenter.y = bounds.size.height - buttonRadius / 2;
      isNearEdge = YES;
    }
    if (isNearEdge && !self.isSnappedToEdge) {
      self.isSnappedToEdge = YES;
      [UIView animateWithDuration:0.3
                            delay:0
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         self.hubButton.center = targetCenter;
                       }
                       completion:nil];
    }
  }
}
- (BOOL)isOptionSelected:(NSString *)option
           inMultiSelect:(NSString *)title
             forCategory:(NSInteger)category {
  NSString *key = [self keyForSetting:title inCategory:category];
  NSArray<NSNumber *> *selectedIndices = self.settingValues[key];
  NSArray *settings = self.categorySettings[@(category)];
  for (NSDictionary *setting in settings) {
    if ([setting[@"type"] isEqualToString:@"multiselect"] &&
        [setting[@"title"] isEqualToString:title]) {
      NSArray *options = setting[@"options"];
      NSInteger optionIndex = [options indexOfObject:option];
      if (optionIndex != NSNotFound)
        return [selectedIndices containsObject:@(optionIndex)];
      break;
    }
  }
  return NO;
}
- (BOOL)isIndexSelected:(NSInteger)index
          inMultiSelect:(NSString *)title
            forCategory:(NSInteger)category {
  NSString *key = [self keyForSetting:title inCategory:category];
  NSArray<NSNumber *> *selectedIndices = self.settingValues[key];
  return [selectedIndices containsObject:@(index)];
}
- (NSArray<NSString *> *)getSelectedOptionsForMultiSelect:(NSString *)title
                                              forCategory:(NSInteger)category {
  NSString *key = [self keyForSetting:title inCategory:category];
  NSArray<NSNumber *> *selectedIndices = self.settingValues[key];
  NSMutableArray<NSString *> *selectedOptions = [NSMutableArray array];
  NSArray *settings = self.categorySettings[@(category)];
  for (NSDictionary *setting in settings) {
    if ([setting[@"type"] isEqualToString:@"multiselect"] &&
        [setting[@"title"] isEqualToString:title]) {
      NSArray *options = setting[@"options"];
      for (NSNumber *index in selectedIndices) {
        if (index.integerValue < options.count) {
          [selectedOptions addObject:options[index.integerValue]];
        }
      }
      break;
    }
  }
  return [selectedOptions copy];
}
- (void)addDebugLog:(NSString *)log {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"HH:mm:ss.SSS";
  NSString *timestamp = [formatter stringFromDate:[NSDate date]];
  NSString *formattedLog =
      [NSString stringWithFormat:@"[%@] %@", timestamp, log];
  [self.debugLogs addObject:formattedLog];
  if (self.logTextView && self.logTextView.superview) {
    self.logTextView.text = [self.debugLogs componentsJoinedByString:@"\n"];
    [self.logTextView
        scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 0)];
  }
}
- (void)clearDebugLogs {
  [self.debugLogs removeAllObjects];
  if (self.logTextView) {
    self.logTextView.text = @"";
  }
}
- (void)showDebugConsole {
  if (self.logTextView && self.logTextView.superview) {
    [self.logTextView removeFromSuperview];
    return;
  }
  CGFloat padding = 20;
  CGFloat consoleWidth = self.bounds.size.width - (padding * 2);
  CGFloat consoleHeight = self.bounds.size.height * 0.6;
  UIView *consoleContainer = [[UIView alloc]
      initWithFrame:CGRectMake(padding,
                               (self.bounds.size.height - consoleHeight) / 2,
                               consoleWidth, consoleHeight)];
  consoleContainer.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
  consoleContainer.layer.cornerRadius = 15;
  UIView *headerView =
      [[UIView alloc] initWithFrame:CGRectMake(0, 0, consoleWidth, 44)];
  headerView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
  headerView.layer.cornerRadius = 15;
  [self setupCornerMask:headerView];
  UILabel *titleLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
  titleLabel.text = @"Debug Console";
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  [headerView addSubview:titleLabel];
  UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  closeButton.frame = CGRectMake(consoleWidth - 160, 7, 70, 30);
  [closeButton setTitle:@"Close" forState:UIControlStateNormal];
  [closeButton setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
  closeButton.backgroundColor = [UIColor colorWithRed:0.3
                                                green:0.3
                                                 blue:0.3
                                                alpha:1.0];
  closeButton.layer.cornerRadius = 15;
  [closeButton addTarget:self
                  action:@selector(closeDebugConsoleAnimated)
        forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:closeButton];
  UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
  clearButton.frame = CGRectMake(consoleWidth - 80, 7, 70, 30);
  [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
  [clearButton setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
  clearButton.backgroundColor = [UIColor colorWithRed:0.7
                                                green:0.2
                                                 blue:0.2
                                                alpha:1.0];
  clearButton.layer.cornerRadius = 15;
  [clearButton addTarget:self
                  action:@selector(clearDebugLogs)
        forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:clearButton];
  [consoleContainer addSubview:headerView];
  self.logTextView = [[UITextView alloc]
      initWithFrame:CGRectMake(10, 54, consoleWidth - 20, consoleHeight - 64)];
  self.logTextView.backgroundColor = [UIColor clearColor];
  self.logTextView.textColor = [UIColor colorWithRed:0.2
                                               green:1.0
                                                blue:0.2
                                               alpha:1.0];
  self.logTextView.font = [UIFont fontWithName:@"Menlo" size:12];
  self.logTextView.editable = NO;
  self.logTextView.text = [self.debugLogs componentsJoinedByString:@"\n"];
  [consoleContainer addSubview:self.logTextView];
  [self addSubview:consoleContainer];
  consoleContainer.alpha = 0;
  consoleContainer.transform = CGAffineTransformMakeScale(0.8, 0.8);
  [UIView animateWithDuration:0.3
                   animations:^{
                     consoleContainer.alpha = 1;
                     consoleContainer.transform = CGAffineTransformIdentity;
                   }];
}
- (void)closeDebugConsoleAnimated {
  UIView *consoleContainer = self.logTextView.superview;
  [UIView animateWithDuration:0.3
      animations:^{
        consoleContainer.alpha = 0;
        consoleContainer.transform = CGAffineTransformMakeScale(0.8, 0.8);
      }
      completion:^(BOOL finished) {
        [consoleContainer removeFromSuperview];
        self.logTextView = [[UITextView alloc] init];
      }];
}
- (UIButton *)createStyledButton:(NSString *)title
                        withIcon:(NSString *)iconName
                 backgroundColor:(UIColor *)color {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.backgroundColor = color;
  button.layer.cornerRadius = 10;
  button.titleLabel.font = [UIFont systemFontOfSize:14];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  if (iconName) {
    UIImage *icon = [UIImage systemImageNamed:iconName];
    [button setImage:icon forState:UIControlStateNormal];
    button.tintColor = [UIColor whiteColor];
    button.configuration.imagePadding = -8;
  }
  [button setTitle:title forState:UIControlStateNormal];
  return button;
}
- (void)addCallback:(void (^)(id))callback forKey:(NSString *)key {
  NSString *callbackKey = [NSString stringWithFormat:@"%@_callback", key];
  self.settingValues[callbackKey] = callback;
}
- (void)resetPosition {
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.hubButton.center =
                         CGPointMake(self.bounds.size.width / 2,
                                     self.bounds.size.height / 2);
                     [self updateCategoryButtonPositions];
                   }];
}
- (void)previewCurrentLayout {
  if (!self.isOpen) {
    [self show];
  }
  [UIView animateWithDuration:0.3
      animations:^{
        for (ModMenuButton *button in self.categoryButtons) {
          button.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2
                         animations:^{
                           for (ModMenuButton *button in self.categoryButtons) {
                             button.transform = CGAffineTransformIdentity;
                           }
                         }];
      }];
}
- (void)updateButtonSizes:(CGFloat)size {
  [UIView
      animateWithDuration:0.3
               animations:^{
                 for (ModMenuButton *button in self.categoryButtons) {
                   CGPoint center = button.center;
                   button.bounds = CGRectMake(0, 0, size, size);
                   button.center = center;
                   button.layer.cornerRadius = size / 2;
                   CAGradientLayer *gradientLayer =
                       (CAGradientLayer *)[button.layer.sublayers firstObject];
                   if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
                     gradientLayer.frame = button.bounds;
                     gradientLayer.cornerRadius = size / 2;
                   }
                   for (UIView *subview in button.subviews) {
                     if ([subview isKindOfClass:[UIImageView class]]) {
                       UIImageView *iconView = (UIImageView *)subview;
                       CGFloat iconSize = size * 0.5;
                       CGFloat padding = (size - iconSize) / 2;
                       iconView.frame =
                           CGRectMake(padding, padding, iconSize, iconSize);
                     }
                   }
                 }
                 if (size >= 40 && size <= 70) {
                   CGPoint hubCenter = self.hubButton.center;
                   CGFloat hubSize = size + 10;
                   self.hubButton.bounds = CGRectMake(0, 0, hubSize, hubSize);
                   self.hubButton.center = hubCenter;
                   self.hubButton.layer.cornerRadius = hubSize / 2;
                   CAGradientLayer *hubGradient = (CAGradientLayer *)
                       [self.hubButton.layer.sublayers firstObject];
                   if ([hubGradient isKindOfClass:[CAGradientLayer class]]) {
                     hubGradient.frame = self.hubButton.bounds;
                     hubGradient.cornerRadius = hubSize / 2;
                   }
                   CGFloat iconSize = hubSize * 0.4;
                   CGFloat padding = (hubSize - iconSize) / 2;
                   self.hamburgerIcon.frame =
                       CGRectMake(padding, padding, iconSize, iconSize);
                 }
                 [self updateCategoryButtonPositions];
               }];
}
- (void)updatePopupViewForCategory:(NSInteger)category {
  if (!self.popupView)
    return;
  for (UIView *subview in self.popupView.subviews) {
    if (![subview isKindOfClass:[UIView class]] || subview.tag != 100) {
      [subview removeFromSuperview];
    }
  }
  NSArray *settings = self.categorySettings[@(category)];
  CGFloat yOffset = 60.0;
  for (NSDictionary *setting in settings) {
    if ([setting[@"type"] isEqualToString:@"label"]) {
      UIView *container = [[UIView alloc]
          initWithFrame:CGRectMake(20, yOffset,
                                   self.popupView.bounds.size.width - 40, 40)];
      container.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
      container.layer.cornerRadius = 10;
      UILabel *titleLabel = [[UILabel alloc]
          initWithFrame:CGRectMake(15, 0, container.bounds.size.width - 130,
                                   container.bounds.size.height)];
      titleLabel.text = setting[@"title"];
      titleLabel.textColor = [UIColor whiteColor];
      titleLabel.font = [UIFont systemFontOfSize:16];
      [container addSubview:titleLabel];
      UILabel *valueLabel = [[UILabel alloc]
          initWithFrame:CGRectMake(container.bounds.size.width - 115, 0, 100,
                                   container.bounds.size.height)];
      valueLabel.text = setting[@"value"];
      valueLabel.textColor = [UIColor whiteColor];
      valueLabel.font = [UIFont systemFontOfSize:16];
      valueLabel.textAlignment = NSTextAlignmentRight;
      [container addSubview:valueLabel];
      [self.popupView addSubview:container];
      yOffset += 50;
    }
  }
}
- (UIView *)viewForCategory:(NSInteger)category {
  if (self.popupView && self.selectedCategory == category) {
    for (UIView *subview in self.popupView.subviews) {
      if ([subview isKindOfClass:[UIScrollView class]]) {
        return [subview.subviews firstObject];
      }
    }
  }
  return self.popupView;
}
- (void)setCategoryIcon:(NSString *)iconName forCategory:(NSInteger)category {
  self.categoryIcons[@(category)] = iconName;
  for (ModMenuButton *button in self.categoryButtons) {
    if (button.tag == category) {
      for (UIView *subview in button.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
          [subview removeFromSuperview];
        }
      }
      UIImageView *iconView = [[UIImageView alloc]
          initWithImage:[UIImage systemImageNamed:iconName]];
      iconView.tintColor = [UIColor whiteColor];
      iconView.contentMode = UIViewContentModeScaleAspectFit;
      CGFloat buttonSize = button.bounds.size.width;
      CGFloat iconSize = buttonSize * 0.5;
      CGFloat padding = (buttonSize - iconSize) / 2;
      iconView.frame = CGRectMake(padding, padding, iconSize, iconSize);
      [button addSubview:iconView];
    }
  }
}
- (void)showPopupMessage:(NSString *)message
                   title:(NSString *)title
                    icon:(NSString *)iconName {
  UIView *popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 350)];
  popup.center = self.center;
  popup.backgroundColor = [UIColor colorWithRed:0.15
                                          green:0.15
                                           blue:0.15
                                          alpha:1.0];
  popup.layer.cornerRadius = 15;
  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
  header.backgroundColor = [UIColor colorWithRed:0.1
                                           green:0.1
                                            blue:0.1
                                           alpha:1.0];
  UIImageView *iconView =
      [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
  iconView.tintColor = [UIColor whiteColor];
  iconView.frame = CGRectMake(15, 10, 30, 30);
  [header addSubview:iconView];
  UILabel *titleLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 30)];
  titleLabel.text = title;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  [header addSubview:titleLabel];
  UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  closeButton.frame = CGRectMake(260, 10, 30, 30);
  [closeButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
               forState:UIControlStateNormal];
  closeButton.tintColor = [UIColor whiteColor];
  [closeButton addTarget:self
                  action:@selector(closePopup:)
        forControlEvents:UIControlEventTouchUpInside];
  [header addSubview:closeButton];
  UITextView *messageView =
      [[UITextView alloc] initWithFrame:CGRectMake(20, 60, 260, 280)];
  messageView.text = message;
  messageView.textColor = [UIColor whiteColor];
  messageView.font = [UIFont systemFontOfSize:16];
  messageView.backgroundColor = [UIColor clearColor];
  messageView.editable = NO;
  messageView.scrollEnabled = YES;
  [popup addSubview:messageView];
  [popup addSubview:header];
  popup.alpha = 0;
  popup.transform = CGAffineTransformMakeScale(0.8, 0.8);
  [self addSubview:popup];
  [UIView animateWithDuration:0.3
                   animations:^{
                     popup.alpha = 1;
                     popup.transform = CGAffineTransformIdentity;
                   }];
}
- (void)closePopup:(UIButton *)sender {
  UIView *popup = sender.superview.superview;
  [UIView animateWithDuration:0.2
      animations:^{
        popup.alpha = 0;
        popup.transform = CGAffineTransformMakeScale(0.8, 0.8);
      }
      completion:^(BOOL finished) {
        [popup removeFromSuperview];
      }];
}
- (void)showAlert:(NSString *)message
            title:(NSString *)title
         okButton:(NSString *)okTitle
     cancelButton:(NSString *)cancelTitle
         callback:(void (^)(BOOL confirmed))callback {
  UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
  containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
  UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
  alertView.center =
      CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
  alertView.backgroundColor = [UIColor colorWithRed:0.15
                                              green:0.15
                                               blue:0.15
                                              alpha:1.0];
  alertView.layer.cornerRadius = 15;
  alertView.clipsToBounds = YES;
  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
  header.backgroundColor = [UIColor colorWithRed:0.2
                                           green:0.2
                                            blue:0.2
                                           alpha:1.0];
  UILabel *titleLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 270, 25)];
  titleLabel.text = title;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  [header addSubview:titleLabel];
  UILabel *messageLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 260, 75)];
  messageLabel.text = message;
  messageLabel.textColor = [UIColor whiteColor];
  messageLabel.font = [UIFont systemFontOfSize:14];
  messageLabel.numberOfLines = 0;
  [alertView addSubview:messageLabel];
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
  cancelButton.frame = CGRectMake(20, 140, 125, 40);
  [cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
  [cancelButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
  cancelButton.backgroundColor = [UIColor colorWithRed:0.3
                                                 green:0.3
                                                  blue:0.3
                                                 alpha:1.0];
  cancelButton.layer.cornerRadius = 8;
  [cancelButton addTarget:self
                   action:@selector(handleAlertResponse:)
         forControlEvents:UIControlEventTouchUpInside];
  cancelButton.tag = 0;
  [alertView addSubview:cancelButton];
  UIButton *okButton = [UIButton buttonWithType:UIButtonTypeSystem];
  okButton.frame = CGRectMake(155, 140, 125, 40);
  [okButton setTitle:okTitle forState:UIControlStateNormal];
  [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  okButton.backgroundColor = [UIColor colorWithRed:0.8
                                             green:0.2
                                              blue:0.2
                                             alpha:1.0];
  okButton.layer.cornerRadius = 8;
  [okButton addTarget:self
                action:@selector(handleAlertResponse:)
      forControlEvents:UIControlEventTouchUpInside];
  okButton.tag = 1;
  [alertView addSubview:okButton];
  [alertView addSubview:header];
  [containerView addSubview:alertView];
  objc_setAssociatedObject(containerView, "alertCallback", callback,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
  containerView.alpha = 0;
  alertView.transform = CGAffineTransformMakeScale(0.8, 0.8);
  [self addSubview:containerView];
  [UIView animateWithDuration:0.3
                   animations:^{
                     containerView.alpha = 1;
                     alertView.transform = CGAffineTransformIdentity;
                   }];
}
- (void)handleAlertResponse:(UIButton *)sender {
  UIView *alertView = sender.superview;
  UIView *containerView = alertView.superview;
  void (^callback)(BOOL) =
      objc_getAssociatedObject(containerView, "alertCallback");
  [UIView animateWithDuration:0.2
      animations:^{
        containerView.alpha = 0;
        alertView.transform = CGAffineTransformMakeScale(0.8, 0.8);
      }
      completion:^(BOOL finished) {
        if (callback) {
          callback(sender.tag == 1);
        }
        [containerView removeFromSuperview];
      }];
}
- (void)showPatchManager:(NSString *)title icon:(NSString *)iconName {
  UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
  container.center = self.center;
  container.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
  container.layer.cornerRadius = 15;

  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
  header.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];

  UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
  iconView.tintColor = [UIColor whiteColor];
  iconView.frame = CGRectMake(15, 10, 30, 30);
  [header addSubview:iconView];

  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 30)];
  titleLabel.text = title;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:16];
  [header addSubview:titleLabel];

  UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
  closeButton.frame = CGRectMake(260, 10, 30, 30);
  [closeButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
  closeButton.tintColor = [UIColor whiteColor];
  [closeButton addTarget:self action:@selector(closePatchManager:) forControlEvents:UIControlEventTouchUpInside];
  [header addSubview:closeButton];

  UIView *inputContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 60, 280, 45)];
  inputContainer.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  inputContainer.layer.cornerRadius = 12;

  UITextField *offsetField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 110, 35)];
  offsetField.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  offsetField.placeholder = @"Offset...";
  offsetField.textColor = [UIColor whiteColor];
  offsetField.layer.cornerRadius = 6;
  offsetField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
  offsetField.leftViewMode = UITextFieldViewModeAlways;
  offsetField.returnKeyType = UIReturnKeyDone;
  offsetField.delegate = self;
  NSAttributedString *offsetPlaceholder = [[NSAttributedString alloc]
      initWithString:@"Offset..."
          attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1.0]}];
  offsetField.attributedPlaceholder = offsetPlaceholder;
  [inputContainer addSubview:offsetField];

  UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake(125, 5, 85, 35)];
  valueField.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  valueField.placeholder = @"Patch...";
  valueField.textColor = [UIColor whiteColor];
  valueField.layer.cornerRadius = 6;
  valueField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
  valueField.leftViewMode = UITextFieldViewModeAlways;
  valueField.returnKeyType = UIReturnKeyDone;
  valueField.delegate = self;
  NSAttributedString *valuePlaceholder = [[NSAttributedString alloc]
      initWithString:@"Patch..."
          attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1.0]}];
  valueField.attributedPlaceholder = valuePlaceholder;
  [inputContainer addSubview:valueField];

  UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
  addButton.frame = CGRectMake(220, 5, 50, 35);
  [addButton setTitle:@"+" forState:UIControlStateNormal];
  addButton.titleLabel.font = [UIFont systemFontOfSize:16];
  [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  addButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
  addButton.layer.cornerRadius = 6;
  [addButton addTarget:self action:@selector(handleAddPatch:) forControlEvents:UIControlEventTouchUpInside];
  [inputContainer addSubview:addButton];

  UIView *patchesContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 115, 280, 260)];
  patchesContainer.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  patchesContainer.layer.cornerRadius = 12;

  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 280, 260)];
  scrollView.backgroundColor = [UIColor clearColor];
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.directionalLockEnabled = YES;
  [self updatePatchList:scrollView];
  [patchesContainer addSubview:scrollView];

  [container addSubview:header];
  [container addSubview:inputContainer];
  [container addSubview:patchesContainer];

  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
      initWithTarget:self action:@selector(dismissKeyboard)];
  [container addGestureRecognizer:tapGesture];

  objc_setAssociatedObject(container, "patchScrollView", scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  container.alpha = 0;
  container.transform = CGAffineTransformMakeScale(0.8, 0.8);
  [self addSubview:container];

  [UIView animateWithDuration:0.3 animations:^{
    container.alpha = 1;
    container.transform = CGAffineTransformIdentity;
  }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}
- (void)dismissKeyboard {
  [self endEditing:YES];
}
- (void)handleAddPatch:(UIButton *)sender {
    UIView *addSection = sender.superview;
    UITextField *offsetField = [addSection.subviews objectAtIndex:0];
    UITextField *valueField = [addSection.subviews objectAtIndex:1];
    NSString *offsetStr = [offsetField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef"];
    NSCharacterSet *inputSet = [NSCharacterSet characterSetWithCharactersInString:offsetStr];
    if (![hexSet isSupersetOfSet:inputSet]) {
        [self showQuickMessage:@"Invalid hex format for offset"];
        return;
    }

    uint64_t offset;
    NSScanner *scanner = [NSScanner scannerWithString:offsetStr];
    if (![scanner scanHexLongLong:&offset] || offset == 0) {
        [self showQuickMessage:@"Invalid offset value"];
        return;
    }

    NSString *value = valueField.text;
    if (value.length == 0) {
        [self showQuickMessage:@"Patch value cannot be empty"];
        return;
    }

    if (!self.memoryPatches) {
        self.memoryPatches = [NSMutableArray array];
    }

    BOOL isAsm = [self isValidAsmInstruction:value];
    NSDictionary *newPatch = @{@"offset" : @(offset), @"value" : value, @"enabled" : @NO, @"withAsm" : @(isAsm)};
    [self.memoryPatches addObject:newPatch];

    offsetField.text = @"";
    valueField.text = @"";

    UIView *container = addSection.superview.superview;
    UIScrollView *scrollView = (UIScrollView *)objc_getAssociatedObject(container, "patchScrollView");

    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }

    CGFloat yOffset = 10;
    for (NSDictionary *patch in self.memoryPatches) {
        [self addPatchView:patch toScrollView:scrollView atOffset:&yOffset];
    }
    scrollView.contentSize = CGSizeMake(300, MAX(yOffset, scrollView.frame.size.height));
    [scrollView layoutIfNeeded];
    [scrollView.superview layoutIfNeeded];

    [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height) animated:YES];
    [self addDebugLog:[NSString stringWithFormat:@"Added new patch - Offset: 0x%llx, Value: %@, ASM: %@", offset, value, isAsm ? @"Yes" : @"No"]];
    [self showQuickMessage:@"Patch added!"];
}

- (BOOL)isValidAsmInstruction:(NSString *)instruction {
    NSArray *validInstructions = @[@"mov", @"add", @"sub", @"mul", @"div", @"and", @"or", @"xor", @"shl", @"shr", @"ret", @"push", @"pop", @"call", @"jmp", @"cmp", @"test", @"fmov", @"nop"];
    NSArray *components = [instruction componentsSeparatedByString:@" "];

    if (components.count < 1) return NO;

    NSString *opcode = [components[0] lowercaseString];
    return [validInstructions containsObject:opcode];
}
- (void)patchToggled:(UISwitch *)sender {
  UIView *patchView = sender.superview;
  UIScrollView *scrollView = (UIScrollView *)patchView.superview;
  NSArray *patchViews = scrollView.subviews;
  NSInteger index = [patchViews indexOfObject:patchView];
  if (index != NSNotFound && index < self.memoryPatches.count) {
    NSMutableDictionary *patch = [self.memoryPatches[index] mutableCopy];
    patch[@"enabled"] = @(sender.isOn);
    self.memoryPatches[index] = patch;
    uint64_t offset = [patch[@"offset"] unsignedLongLongValue];
    NSString *patchHex = patch[@"value"];
    if (sender.isOn) {
      if ([patch[@"withAsm"] boolValue]) {
        [Patch offsetAsm:offset
                asm_arch:MP_ASM_ARM64
                asm_code:[patchHex UTF8String]];
        [self addDebugLog:[NSString
                              stringWithFormat:@"Toggle ASM offset: %llx -> %@",
                                               offset, patchHex]];
      } else {
        [Patch offset:offset patch:patchHex];
        [self
            addDebugLog:[NSString stringWithFormat:@"Toggle offset: %llx -> %@",
                                                   offset, patchHex]];
      }
    } else {
      BOOL success = [Patch revertOffset:offset];
      if (!success) {
        [self
            addDebugLog:[NSString stringWithFormat:
                                      @"Failed to revert patch at offset: %llx",
                                      offset]];
      }
      [self addDebugLog:[NSString
                            stringWithFormat:@"Revert offset: %llx", offset]];
    }
  }
}
- (void)closePatchManager:(UIButton *)sender {
  UIView *container = sender.superview.superview;
  [UIView animateWithDuration:0.2
      animations:^{
        container.alpha = 0;
        container.transform = CGAffineTransformMakeScale(0.8, 0.8);
      }
      completion:^(BOOL finished) {
        [container removeFromSuperview];
      }];
}
- (UITextField *)createStylizedTextField:(CGRect)frame
                             placeholder:(NSString *)placeholder {
  UITextField *field = [[UITextField alloc] initWithFrame:frame];
  field.backgroundColor = [UIColor colorWithRed:0.2
                                          green:0.22
                                           blue:0.25
                                          alpha:1.0];
  field.placeholder = placeholder;
  field.textColor = [UIColor whiteColor];
  field.layer.cornerRadius = 8;
  field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
  field.leftViewMode = UITextFieldViewModeAlways;
  field.layer.borderWidth = 1;
  field.layer.borderColor =
      [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:0.3].CGColor;
  NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:placeholder
          attributes:@{
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5
                                                               alpha:1.0]
          }];
  field.attributedPlaceholder = attributedPlaceholder;
  return field;
}
- (UIButton *)createStylizedButton:(CGRect)frame title:(NSString *)title {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame = frame;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = button.bounds;
  gradient.colors = @[
    (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.8 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:0.3 green:0.5 blue:0.9 alpha:1.0].CGColor
  ];
  gradient.cornerRadius = 8;
  [button.layer insertSublayer:gradient atIndex:0];
  button.layer.shadowColor =
      [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0].CGColor;
  button.layer.shadowOffset = CGSizeZero;
  button.layer.shadowRadius = 8;
  button.layer.shadowOpacity = 0.5;
  return button;
}
- (void)togglePatch:(NSInteger)index enabled:(BOOL)enabled {
  if (index < self.memoryPatches.count) {
    NSMutableDictionary *patch = [self.memoryPatches[index] mutableCopy];
    patch[@"enabled"] = @(enabled);
    self.memoryPatches[index] = patch;
    NSString *offsetStr = patch[@"offset"];
    NSString *patchHex = patch[@"value"];
    uint64_t offset;
    if ([offsetStr hasPrefix:@"0x"]) {
      offsetStr = [offsetStr substringFromIndex:2];
    }
    NSScanner *scanner = [NSScanner scannerWithString:offsetStr];
    [scanner scanHexLongLong:&offset];
    if (enabled) {
      if ([patch[@"withAsm"] boolValue]) {
        [Patch offsetAsm:offset
                asm_arch:MP_ASM_ARM64
                asm_code:[patchHex UTF8String]];
        [self
            addDebugLog:[NSString
                            stringWithFormat:@"Toggle ASM offset: 0x%llx -> %@",
                                             offset, patchHex]];
      } else {
        [Patch offset:offset patch:patchHex];
        [self addDebugLog:[NSString
                              stringWithFormat:@"Toggle offset: 0x%llx -> %@",
                                               offset, patchHex]];
      }
    } else {
      BOOL success = [Patch revertOffset:offset];
      if (!success) {
        [self addDebugLog:[NSString
                              stringWithFormat:
                                  @"Failed to revert patch at offset: 0x%llx",
                                  offset]];
      }
      [self addDebugLog:[NSString
                            stringWithFormat:@"Revert offset: 0x%llx", offset]];
    }
  }
}
- (void)setupCornerMask:(UIView *)view {
  if (@available(iOS 11.0, *)) {
    view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
  } else {
    view.layer.cornerRadius = 10;
  }
}
- (void)setupSegmentedControl:(UISegmentedControl *)segmentedControl {
  segmentedControl.tintColor = [UIColor colorWithRed:0
                                               green:0.8
                                                blue:1
                                               alpha:1];
}
- (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color {
  UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  [color setFill];
  CGContextTranslateCTM(context, 0, image.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextSetBlendMode(context, kCGBlendModeColorBurn);
  CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
  CGContextDrawImage(context, rect, image.CGImage);
  CGContextSetBlendMode(context, kCGBlendModeSourceIn);
  CGContextAddRect(context, rect);
  CGContextDrawPath(context, kCGPathFill);
  UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return coloredImage;
}
- (void)clearLogTextView {
  [self.logTextView removeFromSuperview];
  self.logTextView = [[UITextView alloc] initWithFrame:CGRectZero];
}
- (void)addTextInput:(NSString *)title
        initialValue:(NSString *)value
         forCategory:(NSInteger)category {
  void (^emptyCallback)(void) = ^{
  };
  [self addTextInput:title
        initialValue:value
            callback:emptyCallback
         forCategory:category];
}
- (void)deletePatch:(NSInteger)index {
  if (index < self.memoryPatches.count) {
    [self.memoryPatches removeObjectAtIndex:index];
  }
}
- (NSString *)getTextValue:(NSInteger)index withTitle:(NSString *)title {
  NSString *key = [self keyForSetting:title inCategory:index];
  return self.settingValues[key];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *hitView = [super hitTest:point withEvent:event];
  if (hitView == self.hubButton) {
    return hitView;
  }
  if (self.isOpen) {
    for (ModMenuButton *button in self.categoryButtons) {
      if (hitView == button) {
        return hitView;
      }
    }
  }
  if (self.popupView && [hitView isDescendantOfView:self.popupView]) {
    return hitView;
  }
  if (hitView == self) {
    return nil;
  }
  return hitView;
}
- (CGPoint)constrainPointToBounds:(CGPoint)point forView:(UIView *)view {
  CGFloat halfWidth = view.bounds.size.width / 2;
  CGFloat halfHeight = view.bounds.size.height / 2;
  UIEdgeInsets safeArea = UIEdgeInsetsZero;
  if (@available(iOS 11.0, *)) {
    safeArea = self.safeAreaInsets;
  }
  CGFloat minX = halfWidth + safeArea.left;
  CGFloat maxX = self.bounds.size.width - halfWidth - safeArea.right;
  CGFloat minY = halfHeight + safeArea.top;
  CGFloat maxY = self.bounds.size.height - halfHeight - safeArea.bottom;
  point.x = MAX(minX, MIN(maxX, point.x));
  point.y = MAX(minY, MIN(maxY, point.y));
  return point;
}
- (void)updatePatchList:(UIScrollView *)scrollView {
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }

    CGFloat yOffset = 10;
    for (NSDictionary *patch in self.memoryPatches) {
        [self addPatchView:patch toScrollView:scrollView atOffset:&yOffset];
    }

    scrollView.contentSize = CGSizeMake(300, MAX(yOffset, scrollView.frame.size.height));
    [scrollView layoutIfNeeded];
    [scrollView.superview layoutIfNeeded];
}
- (void)addPatchView:(NSDictionary *)patch
        toScrollView:(UIScrollView *)scrollView
            atOffset:(CGFloat *)yOffset {
  UIView *patchView =
      [[UIView alloc] initWithFrame:CGRectMake(10, *yOffset, 260, 40)];
  patchView.backgroundColor = [UIColor colorWithRed:0.15
                                              green:0.15
                                               blue:0.15
                                              alpha:1.0];
  patchView.layer.cornerRadius = 8;
  UILabel *infoLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 180, 20)];
  uint64_t offset = [patch[@"offset"] unsignedLongLongValue];
  infoLabel.text =
      [NSString stringWithFormat:@"0x%llX → %@", offset, patch[@"value"]];
  infoLabel.textColor = [UIColor whiteColor];
  infoLabel.font = [UIFont systemFontOfSize:14];
  [patchView addSubview:infoLabel];
  UISwitch *toggleSwitch =
      [[UISwitch alloc] initWithFrame:CGRectMake(200, 5, 51, 31)];
  toggleSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
  toggleSwitch.onTintColor = [UIColor colorWithRed:0.4
                                             green:0.8
                                              blue:1.0
                                             alpha:1.0];
  toggleSwitch.on = [patch[@"enabled"] boolValue];
  [toggleSwitch addTarget:self
                   action:@selector(patchToggled:)
         forControlEvents:UIControlEventValueChanged];
  [patchView addSubview:toggleSwitch];
  UILongPressGestureRecognizer *longPress =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handlePatchLongPress:)];
  [patchView addGestureRecognizer:longPress];
  [scrollView addSubview:patchView];
  *yOffset += 45;
}
- (void)setupBlurBackground {
  [self.blurBackgroundView removeFromSuperview];
  UIBlurEffect *blurEffect =
      [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  self.blurBackgroundView =
      [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  self.blurBackgroundView.frame = self.bounds;
  self.blurBackgroundView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.blurBackgroundView.alpha = 0.0;
  [self insertSubview:self.blurBackgroundView atIndex:0];
}
- (void)animateBlurBackground:(BOOL)show {
  [UIView animateWithDuration:0.5
                        delay:0
       usingSpringWithDamping:0.8
        initialSpringVelocity:0.5
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.blurBackgroundView.alpha = show ? 1.0 : 0.0;
                     self.blurBackgroundView.transform =
                         show ? CGAffineTransformIdentity
                              : CGAffineTransformMakeScale(1.2, 1.2);
                   }
                   completion:nil];
}
- (void)addDefaultOptions:(BOOL)developerMode {
  __weak ModMenu *weakMenu = self;
  [self addButton:@"About"
             icon:@"info.circle.fill"
         callback:^{
           [weakMenu showPopupMessage:@About
                                title:@"About Mod Menu"
                                 icon:@"info.circle.fill"];
         }
      forCategory:3];
  [self addButton:@"Changelog"
             icon:@"questionmark.circle"
         callback:^{
           [weakMenu showPopupMessage:@changelog
                                title:@"What's New"
                                 icon:@"questionmark.circle"];
         }
      forCategory:3];
  [self addButton:@"iOSGods Creator"
             icon:@"link"
         callback:^{
           [[UIApplication sharedApplication]
                         openURL:[NSURL URLWithString:@iOSGodsAuthorProfile]
                         options:@{}
               completionHandler:nil];
         }
      forCategory:3];
  [self addButton:@"Cycle Layout"
             icon:@"square.grid.3x3.fill"
         callback:^{
           ModMenuLayout currentLayout = weakMenu.currentLayout;
           ModMenuLayout nextLayout = static_cast<ModMenuLayout>(
               (static_cast<int>(currentLayout) + 1) % 4);
           [weakMenu switchTo:nextLayout animated:YES];
           NSArray *layoutNames =
               @[ @"Radial", @"Grid", @"List", @"ElasticString" ];
           NSString *layoutName = layoutNames[nextLayout];
           [weakMenu
               addDebugLog:[NSString stringWithFormat:@"Layout changed to %@",
                                                      layoutName]];
           [weakMenu
               showQuickMessage:[NSString
                                    stringWithFormat:@"Layout changed to %@",
                                                     layoutName]];
         }
      forCategory:4];
  [self addButton:@"Cycle Theme"
             icon:@"arrow.triangle.swap"
         callback:^{
           ModMenuTheme currentTheme = weakMenu.currentTheme;
           ModMenuTheme nextTheme = static_cast<ModMenuTheme>(
               (static_cast<int>(currentTheme) + 1) % 16);
           [weakMenu setTheme:nextTheme animated:YES];
           NSArray *themeNames = @[
             @"Dark",
             @"Cyber",
             @"Neon",
             @"Minimal",
             @"Pastel",
             @"Retro",
             @"Ocean",
             @"Forest",
             @"Sunset",
             @"Monochrome",
             @"Christmas",
             @"Lavender",
             @"Vaporwave",
             @"Steampunk",
             @"Galaxy",
             @"Aqua",
           ];
           NSString *themeName = themeNames[nextTheme];
           [weakMenu addDebugLog:[NSString stringWithFormat:@"Theme set to: %@",
                                                            themeName]];
           [weakMenu resetPosition];
           [weakMenu
               showQuickMessage:[NSString
                                    stringWithFormat:@"Theme changed to %@",
                                                     themeName]];
         }
      forCategory:4];
  [self addSlider:@"Menu Opacity"
      initialValue:100
          minValue:50
          maxValue:100
       forCategory:4];
  [self addSlider:@"Button Size"
      initialValue:50
          minValue:37
          maxValue:50
       forCategory:4];
  [self addButton:@"Reset Position"
             icon:@"arrow.counterclockwise"
         callback:^{
           [weakMenu resetPosition];
         }
      forCategory:4];
  if (developerMode) {
    [self addButton:@"Debug Console"
               icon:@"terminal.fill"
           callback:^{
             [weakMenu showDebugConsole];
           }
        forCategory:5];
    [self addButton:@"App Info"
               icon:@"app.badge.fill"
           callback:^{
             NSBundle *mainBundle = [NSBundle mainBundle];
             NSString *appInfo = [NSString
                 stringWithFormat:
                     @"App Information:\n\n"
                      "Name: %@\n"
                      "Bundle ID: %@\n"
                      "Version: %@\n"
                      "Build: %@\n",
                     [mainBundle objectForInfoDictionaryKey:@"CFBundleName"]
                         ?: @"Unknown",
                     mainBundle.bundleIdentifier ?: @"Unknown",
                     [mainBundle objectForInfoDictionaryKey:
                                     @"CFBundleShortVersionString"]
                         ?: @"Unknown",
                     [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"]
                         ?: @"Unknown"];
             [weakMenu showPopupMessage:appInfo
                                  title:@"App Information"
                                   icon:@"app.badge.fill"];
           }
        forCategory:5];
    [self addButton:@"Patch Manager"
               icon:@"memorychip.fill"
           callback:^{
             [weakMenu showPatchManager:@"Memory Patch" icon:@"memorychip.fill"];
           }
        forCategory:5];
  }
}

- (void)handlePatchLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    UIView *patchView = gestureRecognizer.view;
    UIScrollView *scrollView = (UIScrollView *)patchView.superview;

    NSInteger index = [self.memoryPatches indexOfObjectPassingTest:^BOOL(NSDictionary *patch, NSUInteger idx, BOOL *stop) {
        UILabel *label = [patchView.subviews objectAtIndex:0];
        uint64_t patchOffset = [patch[@"offset"] unsignedLongLongValue];
        NSString *patchText = [NSString stringWithFormat:@"0x%llX → %@", patchOffset, patch[@"value"]];
        return [label.text isEqualToString:patchText];
    }];

    if (index != NSNotFound) {
        [self.memoryPatches removeObjectAtIndex:index];
        [UIView performWithoutAnimation:^{
            [self updatePatchList:scrollView];
            [scrollView layoutIfNeeded];
            [scrollView.superview layoutIfNeeded];
        }];
        [self showQuickMessage:@"Patch removed!"];
    }
}

@end
