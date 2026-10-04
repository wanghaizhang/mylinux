# External tree makefile
#
# This file is included by Buildroot's top-level Makefile when the
# external tree is enabled with BR2_EXTERNAL=.../mylinux.
#
# Add your package build rules here. For now the tree is empty of
# custom packages, but the directory package/myserver exists for
# future custom packages.
#
include package/myserver/*.mk
