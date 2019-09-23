# Copyright (C) 2017 XiaoShan https://www.mivm.cn

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-ddnsto
PKG_VERSION:=1.0.0
PKG_RELEASE:=2

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=XiaoShan

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for ddnsto
	PKGARCH:=all
	DEPENDS:=
endef

define Package/$(PKG_NAME)/description
	LuCI Support for ddnsto.
endef

define Build/Prepare
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/ddnsto
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/ddnsto.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/ddnsto/
	$(INSTALL_DATA) ./luasrc/view/ddnsto/index.htm $(1)/usr/lib/lua/luci/view/ddnsto/
	$(INSTALL_DATA) ./luasrc/view/ddnsto/dvalue.htm $(1)/usr/lib/lua/luci/view/ddnsto/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/ddnsto
	$(INSTALL_DATA) ./luasrc/model/cbi/ddnsto/global.lua $(1)/usr/lib/lua/luci/model/cbi/ddnsto/
	$(INSTALL_DIR) $(1)/etc $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
#	$(INSTALL_BIN) ./root/etc/init.d/ddnsto $(1)/etc/init.d
#	$(INSTALL_CONF) ./files/config/ddnsto $(1)/etc/config/
	$(INSTALL_DIR)	$(1)/usr/bin/
	$(INSTALL_BIN) ./files/arm/ddnsto $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
