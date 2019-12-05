#
# Copyright (C) 2017-2019 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qbittorrent
PKG_VERSION:=4.2.0
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/qbittorrent/qBittorrent/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=2f367b89d7049c09e808fc5f7c338ce1820d91bcaecddcad681e9ba18b13206d

PKG_BUILD_DIR:=$(BUILD_DIR)/qBittorrent-release-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/qbittorrent
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=BitTorrent
	DEPENDS:=+qt5-core +qt5-network +qt5-xml +rblibtorrent
	TITLE:=bittorrent client programmed in C++ / Qt
	URL:=https://www.qbittorrent.org/
	PROVIDES:=qBittorrent
endef

define Package/qbittorrent/description
  qBittorrent is a bittorrent client programmed in C++ / Qt that uses
  libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
  It aims to be a good alternative to all other bittorrent clients out
  there. qBittorrent is fast, stable and provides unicode support as
  well as many features.
endef

#CONFIGURE_VARS += \
#	QT_QMAKE="$(STAGING_DIR)/usr/bin" \
#	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"

CONFIGURE_ARGS += \
	--disable-gui \
	--enable-stacktrace=no \
	--with-boost=$(STAGING_DIR)/usr

MAKE_VARS += \
	INSTALL_ROOT="$(PKG_INSTALL_DIR)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/<context>/{:a;N;/<\/context>/!ba;/\/gui\//d}' `ls $(PKG_BUILD_DIR)/src/lang/qbittorrent_*.ts`
endef

define Package/qbittorrent/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/man/man1
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/man/man1/qbittorrent-nox.1 $(1)/usr/man/man1/qbittorrent-nox.1
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qbittorrent-nox $(1)/usr/bin
#	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
#	$(INSTALL_BIN) ./files/qbittorrent.init $(1)/etc/init.d/qbittorrent
#	$(INSTALL_CONF) ./files/qbittorrent.conf $(1)/etc/config/qbittorrent

endef

$(eval $(call BuildPackage,qbittorrent))
