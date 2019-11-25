-- Licensed to the public under the Apache License 2.0.

module("luci.controller.qbittorrent",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qbittorrent") then
		return
	end

	entry({"admin", "services", "qbittorrent"}, cbi("qbittorrent"), _("qBittorrent"))
	entry( {"admin", "services", "qbittorrent", "status"}, call("action_status") ).leaf = true
	entry( {"admin", "services", "qbittorrent", "startstop"}, call("action_start") ).leaf = true
end

function action_status()
	local status = {
		installed = false,
		pid = 0;
	}

	status.pid = tonumber(luci.sys.exec("pidof qbittorrent-nox")) or 0

	if luci.sys.exec("opkg status qbittorrent") ~= "" then
		status.installed = true
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

function action_start(target)
	if target == "webgui" then
		local uci  = require "luci.model.uci".cursor()
		local lan = uci:get("network", "lan", "ipaddr") or "192.168.1.1"
		local port = uci:get("qbittorrent", "main", "Port") or "8080"
		local data = lan .. ":" .. port
		luci.http.prepare_content("application/json")
		luci.http.write_json(data)
	else
		luci.sys.init.start("qbittorrent")
		luci.http.prepare_content("application/json")
		luci.http.write_json("")

	end
end