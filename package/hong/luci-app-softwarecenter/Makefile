#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for Software Center
PKG_NAME:=luci-app-softwarecenter
LUCI_PKGARCH:=all
LUCI_DEPENDS:=
PKG_VERSION:=1.0.6

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 $${IPKG_INSTROOT}/usr/bin/softwarecenter/*.sh  >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/etc/init.d/softwarecenter  >/dev/null 2>&1
/etc/init.d/softwarecenter enable >/dev/null 2>&1
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
