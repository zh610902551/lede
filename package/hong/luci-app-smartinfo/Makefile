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
chmod 755 /usr/lib/smartinfo/smart_checker.sh  
chmod 755 /usr/lib/smartinfo/smart_functions.sh   
chmod 755 /usr/lib/smartinfo/smart_status.sh   
chmod 755 /etc/init.d/smartinfo 
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
