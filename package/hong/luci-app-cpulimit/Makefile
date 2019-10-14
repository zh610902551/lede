include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for cpu limit setting
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod 755 $${IPKG_INSTROOT}/usr/bin/cpulimit  >/dev/null 2>&1
chmod 755 $${IPKG_INSTROOT}/etc/init.d/cpulimit >/dev/null 2>&1
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
