ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WexPyq

WexPyq_FILES = Tweak.x WexPyqMainController.m WexPyqSingleFriendController.m WexPyqMultipleFriendsController.m WexPyqTagFriendsController.m
WexPyq_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-function
WexPyq_FRAMEWORKS = UIKit Foundation
WexPyq_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk