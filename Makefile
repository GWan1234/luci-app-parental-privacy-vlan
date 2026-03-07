include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-parental-privacy-vlan
PKG_VERSION:=1.3.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Edward Watts <edd@eddtech.co.uk>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-parental-privacy-vlan
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Parental Privacy Wizard (VLAN edition)
	DEPENDS:=+luci-base +nftables +rpcd +rpcd-mod-rpcsys +udp-broadcast-relay-redux +umdns
	PKGARCH:=all
endef

define Package/luci-app-parental-privacy-vlan/description
	LuCI wizard and dashboard for a fully isolated Kids Network.
	Supports VLAN mode (DSA/mac80211) and Bridge mode (Broadcom/Legacy).

	MULTI-STAGE CHILD SAFETY:
	- DNS Interception: Forcibly redirects all Port 53 traffic to a local filtered instance.
	- Provider Choice: Selectable upstream safety resolvers (Cloudflare, OpenDNS, AdGuard).
	- Local Enforcement: SafeSearch CNAMEs and App Blocking (TikTok/Snapchat) applied at the router.
	- Encryption Blocking: Prevents bypass via DNS-over-HTTPS (DoH) and DNS-over-TLS (DoT).

	NETWORK & SCHEDULING:
	- Automatic hardware detection and VLAN/Bridge isolation.
	- Non-disruptive firewall-based time scheduling via cron.
	- Cross-network discovery for printers and gaming via UDP relay.
endef

define Build/Compile
endef

define Package/luci-app-parental-privacy-vlan/install
	$(INSTALL_DIR) $(1)/usr/share/luci/views/parental_privacy
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/usr/share/parental-privacy
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/etc/hotplug.d/button
	$(INSTALL_DIR) $(1)/etc/init.d

	$(INSTALL_BIN) ./files/parental-privacy.init $(1)/etc/init.d/parental-privacy

	$(INSTALL_BIN) ./files/block-doh.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/block-dot.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/broadcast-relay.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/safesearch.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/schedule-block.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/remove.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/pause-device.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-status.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-apply.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-extend.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-remove.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-blocklist.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-pause.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-list-paused.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/rpc-get-logs.sh $(1)/usr/share/parental-privacy/
	$(INSTALL_BIN) ./files/update-blocklists.