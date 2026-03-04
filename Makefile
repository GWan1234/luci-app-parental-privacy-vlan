include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-parental-privacy-vlan
PKG_VERSION:=1.1.0
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/eddwatts/luci-app-parental-privacy-vlan.git
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=<fill-in-after-first-build>
PKG_MAINTAINER:=Edward Watts <edd@eddtech.co.uk>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-parental-privacy-vlan
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Parental Privacy Wizard (VLAN edition)
  DEPENDS:=+luci-base +nftables +rpcd +rpcd-mod-file
  PKGARCH:=all
endef

define Package/luci-app-parental-privacy-vlan/description
  Isolated Kids WiFi with DNS filtering, SafeSearch enforcement, and
  time-based scheduling. VLAN edition — requires DSA hardware (OpenWrt 22.03+)
  and mac80211 WiFi driver (ath9k/ath10k/ath11k/mt76).
  Provides single-NAT isolation suitable for games consoles.
endef

define Build/Compile
	$(foreach po,$(wildcard $(PKG_BUILD_DIR)/po/*/*.po), \
		$(STAGING_DIR_HOST)/bin/po2lmo \
			$(po) \
			$(PKG_BUILD_DIR)/po/$(notdir $(po:.po=.lmo)); \
	)
endef

define Package/luci-app-parental-privacy-vlan/install
	# ── Directories ───────────────────────────────────────────────────────────
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/usr/share/luci/views/parental_privacy
	$(INSTALL_DIR) $(1)/usr/share/parental-privacy
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/hotplug.d/button
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n

	# ── Init script ───────────────────────────────────────────────────────────
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/parental-privacy \
		$(1)/etc/init.d/parental-privacy

	# ── Shell scripts ─────────────────────────────────────────────────────────
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/block-doh.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/safesearch.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/remove.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/rpc-status.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/rpc-apply.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/rpc-extend.sh \
		$(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/rpc-remove.sh \
		$(1)/usr/share/parental-privacy/

	# ── rpcd dispatcher ───────────────────────────────────────────────────────
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/parental-privacy-rpcd \
		$(1)/usr/libexec/rpcd/parental-privacy

	# ── UCI defaults + hotplug ────────────────────────────────────────────────
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/99-parental-privacy \
		$(1)/etc/uci-defaults/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/30-kids-wifi \
		$(1)/etc/hotplug.d/button/

	# ── LuCI JS views ─────────────────────────────────────────────────────────
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/dashboard.js \
		$(1)/usr/share/luci/views/parental_privacy/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wizard.js \
		$(1)/usr/share/luci/views/parental_privacy/

	# ── ACL ───────────────────────────────────────────────────────────────────
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/luci-app-parental-privacy.json \
		$(1)/usr/share/rpcd/acl.d/

	# ── Translations ──────────────────────────────────────────────────────────
	$(if $(wildcard $(PKG_BUILD_DIR)/po/*.lmo), \
		$(INSTALL_DATA) $(PKG_BUILD_DIR)/po/*.lmo \
			$(1)/usr/lib/lua/luci/i18n/, \
	)
endef

$(eval $(call BuildPackage,luci-app-parental-privacy-vlan))
