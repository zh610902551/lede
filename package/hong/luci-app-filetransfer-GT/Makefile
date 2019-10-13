#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-tool
LUCI_TITLE:=LuCI page for IPK upload
LUCI_DEPENDS:=+luci-lib-fs +luci-app-samba +block-mount +kmod-usb-storage +kmod-usb-storage-extras +kmod-fs-vfat +kmod-fs-ext4 +kmod-fs-exfat +ntfs-3g
PKG_VERSION:=1
PKG_RELEASE:=2

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/15-automount $(1)/etc/15-automount
	$(INSTALL_BIN) ./files/zzz-move-automount $(1)/etc/uci-defaults/zzz-move-automount
	$(INSTALL_DIR) $(1)/etc/hotplug.d/block
	$(INSTALL_BIN) ./files/20-smb $(1)/etc/hotplug.d/block/20-smb
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


