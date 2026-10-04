################################################################################
#
# myserver
#
################################################################################

MYSERVER_VERSION = 1.0
MYSERVER_SITE = $(BR2_EXTERNAL_MYLINUX_PATH)/package/myserver/src
MYSERVER_SITE_METHOD = local

define MYSERVER_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(@D)/myserver \
		$(@D)/myserver.c
endef

define MYSERVER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/myserver \
		$(TARGET_DIR)/usr/bin/myserver
endef

$(eval $(generic-package))
