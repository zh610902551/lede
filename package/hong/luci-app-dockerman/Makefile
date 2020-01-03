#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for the Docker
LUCI_DEPENDS:=+docker-ce +luci-lib-json
LUCI_PKGARCH:=all
PKG_VERSION:=v0.1.7
PKG_RELEASE:=beta

PKG_MAINTAINER:=lisaac <https://github.com/lisaac/luci-app-dockerman>

$(eval $(call BuildPackage,$(PKG_NAME)))