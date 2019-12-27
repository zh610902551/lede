#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=parted
PKG_VERSION:=2.4
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/parted-$(PKG_VERSION)
PKG_SOURCE:=parted-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/parted
PKG_MD5SUM:=76a6457ea88447d79d50ca331069b19c
PKG_CAT:=zcat

include $(INCLUDE_DIR)/package.mk

define Package/parted
	SECTION:=utils
	CATEGORY:=Utilities
	SUBMENU:=disc
	DEFAULT:=n
	TITLE:=GNU Parted manipulates partition tables
	URL:=http://www.gnu.org/software/parted/
	DEPENDS:= +libuuid +libreadline +libncurses +libblkid
endef

define Package/parted/description
	GNU Parted manipulates partition tables. This is useful for creating 
	space for new operating systems, reorganizing disk usage, copying data 
	on hard disks and disk imaging. The package contains a library, 
	libparted, as well as well as a command-line frontend, parted, 
	which can also be used in scripts.
endef

define Package/parted/config
	source "$(SOURCE)/Config.in"
endef

define Build/Configure
	$(call Build/Configure/Default, \
                --enable-static --disable-device-mapper \
        )
endef

define Package/parted/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/parted/.libs/parted $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libparted/.libs/libparted.so.0.0.2 $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libparted/.libs/libparted.so.0 $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libparted/.libs/libparted.so $(1)/usr/lib/
endef

$(eval $(call BuildPackage,parted))
