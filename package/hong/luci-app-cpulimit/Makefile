#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=cpulimit configuration module
LUCI_DEPENDS:=+cpulimit
PKG_VERSION:=1.0
PKG_RELEASE:=2

define Package/$(PKG_NAME)/postinst
#!/bin/sh
  chmod 755 /usr/bin/cpulimit.sh  >/dev/null 2>&1
  chmod 755 /etc/init.d/cpulimit >/dev/null 2>&1
exit 0
endef


include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature