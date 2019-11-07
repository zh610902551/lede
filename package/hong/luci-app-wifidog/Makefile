include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for wifidog
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
        ( . /etc/uci-defaults/luci-app-wifidog ) && rm -f /etc/uci-defaults/luci-app-wifidog
        chmod 755 /etc/init.d/wifidog >/dev/null 2>&1
        /etc/init.d/wifidog enable >/dev/null 2>&1
        exit 0
}
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
