DEBUG = 0
FINALPACKAGE = 1

# Support arm64 and arm64e architectures
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = treasu

treasu_FILES = tweak.mm
treasu_CFLAGS = -fobjc-arc -std=c++14
treasu_FRAMEWORKS = UIKit QuartzCore Foundation Security

include $(THEOS_MAKE_PATH)/tweak.mk
