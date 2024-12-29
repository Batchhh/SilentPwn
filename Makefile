ARCHS = arm64 #arm64e
DEBUG = 1 #0
FOR_RELEASE = 0 #1
FINALPACKAGE = 0 #1

# Only set this to 1 if you are building the tweak in a mobile device
MOBILE_THEOS=0
ifeq ($(MOBILE_THEOS),1)
  # path to your sdk
  SDK_PATH = $(THEOS)/sdks/iPhoneOS15.5.sdk/
  $(info ===> Setting SYSROOT to $(SDK_PATH)...)
  SYSROOT = $(SDK_PATH)
else
  TARGET = iphone:clang:latest:15.5
endif

THEOS_PACKAGE_SCHEME = rootless #rootfull

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = @@PROJECTNAME@@

${TWEAK_NAME}_CFLAGS = -fobjc-arc -std=c++17 -I$(THEOS_PROJECT_DIR)/Lib/Keystone/includes
${TWEAK_NAME}_CCFLAGS = -std=c++17
${TWEAK_NAME}_CXXFLAGS = -std=c++17
${TWEAK_NAME}_FRAMEWORKS = UIKit Foundation QuartzCore
${TWEAK_NAME}_LDFLAGS += $(THEOS_PROJECT_DIR)/Lib/Keystone/arm64/libkeystone.a
${TWEAK_NAME}_CFLAGS += -I$(THEOS_PROJECT_DIR)/Lib/Keystone/includes

${TWEAK_NAME}_FILES = Tweak.mm \
	${wildcard Source/Memory/Kitty/*.cpp} \
	${wildcard Source/Memory/Kitty/*.mm} \
	${wildcard Source/UI/*.mm} \
	${wildcard Source/Memory/Hook/*.mm} \
	${wildcard Source/Memory/Patch/*.mm} \
	${wildcard Source/Memory/Helper.mm} \
	${wildcard Source/Framework/*.mm} \
	${wildcard Source/Memory/Thread/*.mm}

${TWEAK_NAME}_LIBRARIES += substrate

include $(THEOS_MAKE_PATH)/tweak.mk
