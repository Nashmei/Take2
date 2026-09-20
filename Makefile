ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES =

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = take2
take2_FILES = Sources/Entry.mm Sources/T2Runtime.mm Sources/T2Overlay.mm
take2_CFLAGS = -fobjc-arc -Wall
take2_CCFLAGS = -std=c++17
take2_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/library.mk
