#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=softwarecenter
PKG_VERSION:=1.1.1

PKG_MAINTAINER:=Jianpeng Xiang <1505020109@mail.hnust.edu.cn>
PKG_LICENSE:=GPLv3

include $(INCLUDE_DIR)/package.mk

define Package/softwarecenter
  CATEGORY:=Packages
  TITLE:=Software Center
  PKGARCH:=all
endef

define Package/softwarecenter/conffiles
/etc/config/softwarecenter
endef

define Package/softwarecenter/description
    The software center is designed for the automated and unified configuration of software applications. It provides us with a simple and friendly interactive interface, which aims to make the configuration process easier and simpler!
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/softwarecenter/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin/softwarecenter
    
	$(INSTALL_CONF) ./config/softwarecenter $(1)/etc/config/softwarecenter
	$(INSTALL_BIN) ./init.d/softwarecenter $(1)/etc/init.d/softwarecenter
	$(INSTALL_BIN) ./script/* $(1)/usr/bin/softwarecenter/
endef

$(eval $(call BuildPackage,softwarecenter))
