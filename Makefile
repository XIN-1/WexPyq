ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0

INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WexPyq

WexPyq_FILES = Tweak.x WexPyqMainController.m WexPyqSingleFriendController.m WexPyqMultipleFriendsController.m WexPyqTagFriendsController.m
WexPyq_CFLAGS = -fobjc-arc
WexPyq_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk