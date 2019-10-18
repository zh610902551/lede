include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-clash
LUCI_DEPENDS:=+bash +coreutils-nohup +wget
PKG_VERSION:=0.31.0
PKG_RELEASE:=1
PKG_MAINTAINER:=frainzy1477


define Package/$(PKG_NAME)/postinst
#!/bin/sh
rm -rf /tmp/luci*
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature