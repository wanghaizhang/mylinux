# External tree makefile
#
# This file is included by Buildroot's top-level Makefile when the
# external tree is enabled with BR2_EXTERNAL=.../mylinux.
#
# This globs every package/*.mk in the external tree, so any
# package/ directory you add later is picked up automatically.
#
include $(sort $(wildcard $(BR2_EXTERNAL_MYLINUX_PATH)/package/*/*.mk))
