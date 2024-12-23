# SilentPwn iOS Modification Wiki
## Project Description

SilentPwn is a sophisticated IOS Mod Menu framework designed for advanced runtime manipulation and system-level interactions. It provides developers and researchers with a powerful toolkit for iOS application modification, runtime method interception, and system-level customization.

### Key Features

1. **Memory Hook Module**
   - Advanced runtime method interception
   - Supports hooking by memory address and symbol name
   - Flexible callback and original method preservation mechanisms

2. **Configuration Management**
   - Centralized configuration through `Config.h`
   - Supports debug mode, versioning, and global settings
   - Customizable wait times and logging features

3. **Menu Options Module**
   - Dynamic, interactive menu system
   - Supports various UI elements like sliders and toggles
   - Categorized modifications for different application aspects

4. **Memory Patch Module**
   - Advanced memory manipulation techniques
   - IL2CPP class utilities
   - Object interaction and runtime class management

5. **Obfuscation Module**
   - Compile-time encryption
   - Runtime randomization
   - Enhanced application protection

### Technical Highlights
- Written in Objective-C++
- Low-level system interaction
- Performance-optimized runtime modifications
- Flexible and extensible architecture

### Intended Use
- iOS application research
- Game modification
- Security testing
- Runtime analysis and manipulation

### Disclaimer
This framework is intended for educational and research purposes. Always ensure compliance with legal and ethical guidelines when modifying software.

## Configuration Wiki

### Overview
The Configuration module is responsible for managing the global project configuration through `Config.h`.

### Key Components
- `Config.h`: Header file defining the global project configuration

### Components
- `Author`: Author of the project
- `Version`: Current version of the project
- `iOSGodsAuthorProfile`: Profile link of the author
- `About`: About string with author and version
- `changelog`: Changelog string
- `WAIT`: Wait time in seconds to load the menu
- `DebugMode`: Enable debug logging and other debug features

## Memory Hook Module Wiki

### Overview
The Memory Hook module provides a robust and flexible system for runtime method interception and modification in iOS applications.

### Key Components
- `Hook.h`: Header file defining the Hook interface
- `Hook.mm`: Implementation of hooking mechanisms

### Hooking Strategies

#### 1. Basic Hooking Methods

##### Hook by Memory Address
```objc
+ (BOOL)hook:(uint64_t)address
    callback:(void *)callback
    original:(void **)original;
```
- Intercepts function at a specific memory address
- Generates an automatic hook name based on address
- Returns `YES` if hook is successful

##### Hook by Symbol Name
```objc
+ (BOOL)hookSymbol:(NSString *)symbol
          callback:(void *)callback
          original:(void **)original;
```
- Hooks a function using its symbolic name
- Uses symbol name as hook identifier
- Returns `YES` if hook is successful

#### 2. Advanced Hooking Methods

##### Named Hook by Memory Address
```objc
+ (BOOL)hookAt:(uint64_t)address
      callback:(void *)callback
      original:(void **)original
      withName:(NSString *)name;
```
- Allows custom naming of hooks
- Provides more granular hook management
- Prevents duplicate hooks

##### Named Hook by Symbol
```objc
+ (BOOL)hookSymbol:(NSString *)symbol
          callback:(void *)callback
          original:(void **)original
          withName:(NSString *)name;
```
- Hooks symbol with a custom name
- Enables precise hook tracking and management

### Hook Management Methods

#### Toggle Hook
```objc
+ (BOOL)toggleHookWithName:(NSString *)name
                   enabled:(BOOL)enabled;
```
- Enable or disable a specific hook
- Dynamically control hook state
- Restore original or hooked function

#### Remove Hook
```objc
+ (BOOL)removeHookWithName:(NSString *)name;
```
- Remove a specific named hook
- Restore original function implementation

#### Remove All Hooks
```objc
+ (void)removeAllHooks;
```
- Clear all active hooks
- Reset to original system state

### Hook Status and Utilities

#### Check Hook Status
```objc
+ (BOOL)isHookEnabledWithName:(NSString *)name;
```
- Determine if a specific hook is currently active

#### List Active Hooks
```objc
+ (NSArray<NSString *> *)activeHooks;
```
- Retrieve names of all currently active hooks

#### Get Original Function
```objc
+ (void *)getOriginalFromName:(NSString *)name;
```
- Retrieve the original function for a named hook

#### Get Real Memory Address
```objc
+ (uint64_t)getRealAddress:(uint64_t)address;
```
- Convert virtual memory address to real memory address

### Internal Mechanism

#### Hook Information Tracking
- Uses `HookInfo` class to store hook metadata
- Tracks:
  - Memory address or symbol name
  - Callback function
  - Original function
  - Hook state (enabled/disabled)

#### Singleton Design
- Uses singleton pattern for hook management
- Ensures single, centralized hook tracking

### Error Handling
- Comprehensive logging for hook operations
- Prevents duplicate hooks
- Validates hook parameters

### Dependencies
- Requires `substrate.h` for function hooking
- Uses `dlsym` for symbol resolution
- Integrates with custom memory utilities

### Best Practices
- Always provide a unique hook name
- Check hook return values
- Be cautious when modifying system functions
- Use weak references in callback functions
- Handle potential memory management issues

### Potential Use Cases
- Runtime method interception
- Debugging and instrumentation
- Performance monitoring
- Security research
- Game modification

### Limitations and Risks
- Hooking system functions can cause instability
- Requires deep understanding of memory manipulation
- Performance overhead for complex hooks
- Potential security implications

### Recommended Environment
- Jailbroken iOS device
- Development with Theos
- Advanced debugging tools
- Comprehensive testing framework

### Example Workflow
```objc
// Hook a function
void *originalFunction = NULL;
[Hook hookSymbol:@"targetFunction"
        callback:myCustomImplementation
        original:&originalFunction];

// Toggle the hook
[Hook toggleHookWithName:@"targetFunction" enabled:NO];

// Remove the hook
[Hook removeHookWithName:@"targetFunction"];
```

### Conclusion
The Memory Hook module provides a powerful, flexible mechanism for runtime method modification, enabling advanced iOS development and modification techniques.

## Menu Options Module Wiki

### Overview
The Menu Options module provides a comprehensive, flexible system for creating dynamic, interactive mod menus with advanced configuration capabilities.

### Option Types and Management

#### 1. Slider Options
##### Adding a Slider
```objc
- (void)addSlider:(NSString *)title
     initialValue:(float)value
         minValue:(float)min
         maxValue:(float)max
      forCategory:(NSInteger)category;
```
- Creates a configurable slider
- Supports float value range
- Categorized for organization

##### Retrieving Slider Values
```objc
- (float)getSliderValueFloat:(NSInteger)category
                   withTitle:(NSString *)title;
- (NSInteger)getSliderValueInt:(NSInteger)category
                     withTitle:(NSString *)title;
```
- Retrieve float or integer slider values
- Supports different value representations

#### 2. Toggle Options
##### Adding a Toggle
```objc
- (void)addToggle:(NSString *)title
     initialValue:(BOOL)value
      forCategory:(NSInteger)category;
```
- Creates an on/off switch
- Supports boolean configuration

##### Retrieving Toggle Values
```objc
- (BOOL)getToggleValue:(NSInteger)category
             withTitle:(NSString *)title;
```
- Retrieve current toggle state

#### 3. Text Input Options
##### Adding Text Input
```objc
- (void)addTextInput:(NSString *)title
        initialValue:(NSString *)value
         forCategory:(NSInteger)category;
```
- Creates a text input field
- Supports custom initial values

##### Retrieving Text Values
```objc
- (NSString *)getTextValueForCategory:(NSInteger)category
                            withTitle:(NSString *)title;
```
- Retrieve current text input value

#### 4. Index Switch Options
##### Adding Index Switch
```objc
- (void)addIndexSwitch:(NSString *)title
               options:(NSArray<NSString *> *)options
          initialIndex:(NSInteger)index
           forCategory:(NSInteger)category;
```
- Creates a segmented control-like option
- Supports multiple discrete options

##### Retrieving Index Values
```objc
- (NSInteger)getIndexValueForCategory:(NSInteger)category
                            withTitle:(NSString *)title;
```
- Retrieve currently selected index

#### 5. Stepper Options
##### Adding Stepper
```objc
- (void)addStepper:(NSString *)title
      initialValue:(double)value
          minValue:(double)min
          maxValue:(double)max
         increment:(double)step
       forCategory:(NSInteger)category;
```
- Creates a numeric stepper control
- Supports precise value adjustment

##### Retrieving Stepper Values
```objc
- (double)getStepperValueDouble:(NSInteger)category
                      withTitle:(NSString *)title;
- (NSInteger)getStepperIntValue:(NSInteger)category
                      withTitle:(NSString *)title;
- (float)getStepperFloatValue:(NSInteger)category
                    withTitle:(NSString *)title;
```
- Retrieve stepper values in different formats

#### 6. Multi-Select Options
##### Adding Multi-Select
```objc
- (void)addMultiSelect:(NSString *)title
               options:(NSArray<NSString *> *)options
       selectedIndices:(NSArray<NSNumber *> *)selectedIndices
           forCategory:(NSInteger)category;
```
- Creates a multi-selection option
- Supports selecting multiple items

##### Retrieving Multi-Select Values
```objc
- (NSArray<NSNumber *> *)getMultiSelectValuesForCategory:(NSInteger)category
                                               withTitle:(NSString *)title;
- (BOOL)isOptionSelected:(NSString *)option
           inMultiSelect:(NSString *)title
             forCategory:(NSInteger)category;
- (NSArray<NSString *> *)getSelectedOptionsForMultiSelect:(NSString *)title
                                              forCategory:(NSInteger)category;
```
- Retrieve selected indices or options
- Check specific option selection

### Advanced Option Management

#### Callbacks and Event Handling
```objc
- (void)addCallback:(void (^)(id))callback forKey:(NSString *)key;
```
- Add custom callbacks for option changes
- Supports dynamic event handling

#### Debug and Logging
```objc
- (void)addDebugLog:(NSString *)log;
- (void)showDebugConsole;
```
- Built-in logging mechanism
- Debug console for tracking option changes

### Categorization and Organization

#### Category Management
- Supports multiple menu categories
- Predefined categories:
  - Main
  - Player
  - Enemy
  - Misc
  - Interface
  - Debug

#### Layout and Theming
```objc
- (void)switchTo:(ModMenuLayout)layout animated:(BOOL)animated;
- (void)setTheme:(ModMenuTheme)theme animated:(BOOL)animated;
```
- Dynamic menu layout switching
- Multiple built-in themes

### Example Comprehensive Usage
```objc
ModMenu *menu = [ModMenu shared];

// Add various options
[menu addSlider:@"Player Speed"
    initialValue:1.0
        minValue:0.1
        maxValue:5.0
     forCategory:ModMenuCategoryPlayer];

[menu addToggle:@"God Mode"
    initialValue:NO
     forCategory:ModMenuCategoryPlayer];

[menu addTextInput:@"Player Name"
     initialValue:@"Anonymous"
      forCategory:ModMenuCategoryPlayer];

[menu addIndexSwitch:@"Difficulty"
             options:@[@"Easy", @"Normal", @"Hard"]
        initialIndex:1
         forCategory:ModMenuCategoryMain];

// Retrieve option values
float speed = [menu getSliderValueFloat:ModMenuCategoryPlayer
                              withTitle:@"Player Speed"];
BOOL godMode = [menu getToggleValue:ModMenuCategoryPlayer
                           withTitle:@"God Mode"];
```

### Best Practices
- Use categories to organize options
- Leverage callbacks for dynamic interactions
- Utilize different option types for flexibility
- Handle option changes gracefully
- Use debug logging for tracking

### Limitations
- Performance overhead for complex menus
- Limited by device screen size
- Requires careful memory management

### Conclusion
The Menu Options module provides a powerful, flexible system for creating dynamic and interactive mod menus, offering extensive customization and ease of use.

## Obfuscation Module Wiki

### Overview
The Obfuscation module provides advanced compile-time encryption and obfuscation techniques, designed to enhance security and protect sensitive information in iOS applications.

### Key Features
- Compile-time string encryption
- Compile-time number encryption
- Randomization techniques
- Compile-time hashing
- Cross-platform support

### Obfuscation Techniques

#### 1. Compile-Time String Encryption

##### String Encryption Macro
```objc
#define ENCRYPT(Str)
```
- Encrypts strings at compile-time
- Generates unique encryption for each compilation
- Runtime decryption with minimal performance overhead

##### Usage Example
```objc
const char *secretKey = ENCRYPT("MySecretKey");
NSString *encryptedString = NSStringEncrypt("SensitiveData");
```

#### 2. Number Encryption

##### Hex Number Encryption
```objc
#define NSNumberEncrypt(Value)
```
- Encrypts hex values at compile-time
- Uses seed-based XOR encryption
- Supports unsigned long values

##### Usage Example
```objc
NSNumber *encryptedNumber = NSNumberEncrypt(0x1234ABCD);
```

#### 3. Advanced Encryption Macros

##### Offset String Encryption
```objc
#define IGSecretHexInt(Str)
```
- Converts encrypted string to `uint64_t`
- Useful for memory offsets and addresses

##### Hex Number Encryption
```objc
#define IGSecretHexNumber(Str)
```
- Converts encrypted hex string to `NSNumber`
- Supports hex string representation

##### Hex Data Encryption
```objc
#define IGSecretHexData(Str)
```
- Encrypts hex data strings
- Provides clear, readable encryption

### Compile-Time Randomization

#### Random Number Generation
```cpp
#define vxRANDOM(Min, Max)
```
- Generates compile-time random numbers
- Varies between different compilation runs
- Useful for obfuscation and anti-debugging

#### Compile-Time Hashing
```cpp
#define HASH(Str)
```
- Generates compile-time string hash
- Case-insensitive hashing algorithm
- Provides unique hash for each string

### Internal Mechanisms

#### Encryption Strategy
- Uses XOR-based encryption
- Seed generated from compile-time
- Unique encryption for each compilation

#### Seed Generation
- Derives seed from compilation time
- Converts time string to integer
- Ensures different encryption per build

#### Performance Considerations
- Minimal runtime overhead
- Encryption performed at compile-time
- No significant performance impact

### Supported Platforms
- iOS
- macOS
- Objective-C++
- Supports cross-platform compilation

### Best Practices
- Use for sensitive strings and numbers
- Avoid overusing encryption
- Test thoroughly in target environment
- Be mindful of compilation dependencies

### Use Cases
- Protecting API keys
- Obfuscating memory addresses
- Anti-reverse engineering
- Securing configuration values
- Preventing static analysis

### Limitations
- Not a replacement for cryptographic security
- Determined attackers can still reverse
- Adds slight complexity to build process

### Security Considerations
- Provides obfuscation, not encryption
- Reduces, but does not eliminate, vulnerability
- Should be part of a comprehensive security strategy

### Example Comprehensive Usage
```objc
// Encrypt sensitive information
NSString *apiKey = NSStringEncrypt("your-secret-api-key");
uint64_t memoryOffset = IGSecretHexInt("0x1234ABCD");
NSNumber *secretNumber = IGSecretHexNumber("0xDEADBEEF");

// Runtime decryption
NSLog(@"Decrypted API Key: %@", apiKey);
NSLog(@"Memory Offset: 0x%llx", memoryOffset);
NSLog(@"Secret Number: %@", secretNumber);
```

### Conclusion
The Obfuscation module offers powerful compile-time encryption and randomization techniques, providing an additional layer of protection and complexity to iOS applications while maintaining high performance and ease of use.

## Memory Patch Module Wiki

### Overview
The Memory Patch module provides a sophisticated system for runtime memory modification in iOS applications, enabling precise and flexible memory manipulation.

### Key Components
- `Patch.h`: Header file defining the Patch interface
- `Patch.mm`: Implementation of patching mechanisms

### Patching Strategies

#### 1. Single Memory Patch Methods

##### Hex Byte Patch
```objc
+ (BOOL)offset:(uint64_t)offset
         patch:(NSString *)hexString;
```
- Applies a patch at a specific memory offset
- Uses hexadecimal byte representation
- Returns `YES` if patch is successful

##### Assembly Patch
```objc
+ (BOOL)offsetAsm:(uintptr_t)address
         asm_arch:(MP_ASM_ARCH)asm_arch
         asm_code:(const std::string &)asm_code;
```
- Applies architecture-specific assembly patches
- Supports multiple assembly architectures
- Returns `YES` if patch is successful

#### 2. Multiple Patch Methods

##### Multiple Hex Byte Patches
```objc
+ (BOOL)patches:(NSDictionary<NSNumber *, NSString *> *)patches;
```
- Apply multiple hex byte patches simultaneously
- Uses dictionary for offset-patch mapping
- Returns `YES` if all patches are successful

##### Multiple Assembly Patches
```objc
+ (BOOL)patchesAsm:(NSDictionary<NSNumber *, NSString *> *)patches
          asm_arch:(MP_ASM_ARCH)asm_arch;
```
- Apply multiple assembly patches in a single operation
- Supports architecture-specific patching
- Returns `YES` if all patches are successful

### Patch Management Methods

#### Revert Single Patch
```objc
+ (BOOL)revertOffset:(uint64_t)offset;
```
- Restore original memory state at a specific offset
- Removes the patch from tracking
- Returns `YES` if reversion is successful

#### Revert All Patches
```objc
+ (void)revertAll;
```
- Restore all patches for the current framework
- Clears patch tracking

### Patch Inspection Methods

#### Get Current Bytes
```objc
+ (NSString *)getCurrentBytesAtOffset:(uint64_t)offset;
```
- Retrieve current bytes at a patched memory offset
- Returns `nil` if no patch exists

#### Get Original Bytes
```objc
+ (NSString *)getOriginalBytesAtOffset:(uint64_t)offset;
```
- Retrieve original bytes before patching
- Returns `nil` if no patch exists

### Internal Mechanism

#### Patch Tracking
- Uses `std::map` to store and manage patches
- Tracks patches by framework and memory offset
- Supports patch restoration and inspection

#### Memory Patch Creation
- Utilizes `MemoryPatch` class from custom memory utility
- Supports multiple patch types:
  - Hex byte patches
  - Assembly patches
- Validates patch before application

### Supported Architectures
- Multiple Assembly Architecture Support
- Configurable through `MP_ASM_ARCH` enum
- Supports:
  - ARM
  - ARM64
  - x86
  - x86_64

### Dependencies
- Requires custom memory utility (`MemoryPatch`)
- Uses C++ standard library containers
- Integrates with framework configuration

### Best Practices
- Always validate patch before application
- Use architecture-specific patches
- Handle potential patch failures
- Minimize patch scope
- Restore patches when no longer needed

### Potential Use Cases
- Game modification
- Runtime behavior alteration
- Performance optimization
- Debugging and instrumentation
- Security research

### Limitations and Risks
- Incorrect patches can cause system instability
- Performance overhead for complex patches
- Requires deep understanding of memory manipulation
- Potential security implications

### Recommended Environment
- Jailbroken iOS device
- Theos development framework
- Advanced debugging tools
- Comprehensive testing infrastructure

### Example Workflow
```objc
// Single Hex Patch
[Patch offset:0x1234 patch:@"90 90 90"];

// Multiple Patches
NSDictionary *patches = @{
    @(0x1234): @"90 90 90",
    @(0x5678): @"mov x0, #0"
};
[Patch patches:patches];

// Assembly Patch
[Patch offsetAsm:0x1234
        asm_arch:MP_ASM_ARM64
        asm_code:"mov x0, #0"];

// Revert Patch
[Patch revertOffset:0x1234];
[Patch revertAll];
```

### Conclusion
The Memory Patch module offers a powerful, flexible mechanism for runtime memory modification, enabling advanced iOS development and modification techniques with robust error handling and architectural support.

## IL2CPP Resolver Library: Class and Helper Utilities

### `Lib/Resolver/API/Class.hpp`

#### Overview
The `Class.hpp` module provides advanced reflection and introspection capabilities for IL2CPP (Intermediate Language to C++) runtime, enabling deep interaction with Unity game classes and objects.

#### Key Namespaces and Components
- `IL2CPP::Class`: Core namespace for class-related operations
- `IL2CPP::Class::Utils`: Utility functions for class manipulation
- `IL2CPP::CClass`: Wrapper class for advanced object interactions

#### Main Functionalities

1. **Class Discovery and Retrieval**
   - `Find(const char* m_pName)`: Locate a class across all loaded assemblies
   - `GetFromName(Unity::il2cppImage* m_pImage, const char* m_pNamespace, const char* m_pName)`: Retrieve a class from a specific image

2. **Field and Method Introspection**
   - `GetFields()`: Enumerate class fields
   - `GetMethods()`: Enumerate class methods
   - `FetchFields()`: Collect all fields into a vector
   - `FetchMethods()`: Collect all methods into a vector

3. **Advanced Reflection Utilities**
   - `GetFieldOffset()`: Retrieve memory offset of a specific field
   - `GetStaticField()`: Access static field values
   - `SetStaticField()`: Modify static field values
   - `GetMethodPointer()`: Retrieve method function pointers

4. **Obscured Value Handling**
   - `GetObscuredValue()`: Safely retrieve obscured/encrypted field values
   - `SetObscuredValue()`: Safely set obscured/encrypted field values

#### Security and Performance Considerations
- Uses runtime reflection with minimal overhead
- Supports encrypted/obscured field access
- Provides type-safe template methods
- Handles potential runtime errors gracefully

### `Lib/Resolver/Utils/Helper.hpp`

#### Overview
The `Helper.hpp` module provides high-level utility functions for Unity game object manipulation, method invocation, and runtime interactions.

#### Key Namespaces
- `IL2CPP::Helper`: Comprehensive utility functions for Unity interactions

#### Main Functionalities

1. **GameObject Management**
   - `GetMonoBehaviour()`: Find a MonoBehaviour component
   - `CloneGameObject()`: Create a clone of a game object
   - `FindGameObjectByName()`: Locate a game object by name
   - `FindGameObjectsWithTag()`: Find multiple game objects with a specific tag

2. **Component and Object Interaction**
   - `GetComponent<T>()`: Retrieve a specific component from a game object
   - `GetComponents<T>()`: Retrieve multiple components
   - `GetPropertyValue<T>()`: Read object property values
   - `SetPropertyValue<T>()`: Modify object property values

3. **Method Invocation**
   - `InvokeStaticMethod<Ret, Args>()`: Call static methods dynamically
   - `CreateInstanceAndInvoke()`: Create an instance and invoke a method
   - `InvokeMethodByDelegate()`: Call methods using function delegates
   - `InvokeMethodOnComponent()`: Invoke methods on specific components

4. **Debugging and Introspection**
   - `PrintInstanceFields()`: Debug method to print object fields
   - `CountAndPrintInstances()`: Count and display instances of a class
   - `FindAllInstancesByClass()`: Locate all instances of a specific class

#### Advanced Features
- Template-based generic method calls
- Error handling and logging
- Support for runtime method invocation
- Safe object and component manipulation

#### Security and Performance Notes
- Provides runtime type-safe method calls
- Minimal performance overhead
- Comprehensive error checking
- Supports complex Unity runtime interactions

#### Usage Examples

```cpp
// Find a GameObject
auto player = IL2CPP::Helper::FindGameObjectByName("Player");

// Get a component
auto playerController = IL2CPP::Helper::GetComponent<PlayerController>(player);

// Invoke a method
IL2CPP::Helper::InvokeMethodOnComponent<void>(player, "PlayerController", "Respawn");

// Get/Set property
float health = IL2CPP::Helper::GetPropertyValue<float>(player, "PlayerController", "Health");
IL2CPP::Helper::SetPropertyValue(player, "PlayerController", "Health", 100.0f);
```

#### Limitations
- Requires valid IL2CPP runtime
- Performance overhead for complex reflections
- Potential runtime exceptions if classes/methods are not found
