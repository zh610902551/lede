# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Smartinfo
LUCI_DEPENDS:=+smartmontools 
LUCI_PKGARCH:=all
PKG_VERSION:=3.2
PKG_RELEASE:=1

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 $${IPKG_INSTROOT}/usr/lib/smartinfo/smart_checker.sh  >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/usr/lib/smartinfo/smart_functions.sh   >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/usr/lib/smartinfo/smart_status.sh   >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/etc/init.d/smartinfo >/dev/null 2>&1
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
