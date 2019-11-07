--[[
LuCI - Lua Configuration Interface - rtorrent support

Copyright 2016 maz-1 <ohmygod19993@gmail.com>

]]--

module("luci.controller.rtorrent", package.seeall)
local dm = require "luci.model.cbi.rtorrent.download"
local uci = luci.model.uci.cursor()

function index()
	if not nixio.fs.access("/etc/config/rtorrent") then
		return
	end

	entry({"admin", "nas"}, firstchild(), "NAS", 45).dependent = false
	local page = entry({"admin", "nas", "rtorrent_config"}, cbi("rtorrent/config"), _("rTorrent Settings"))
	page.dependent = true
	entry({"admin", "nas", "rtorrent_config_rss_feed"}, cbi("rtorrent/config_rss_feed"), nil).leaf = true
	entry({"admin", "nas", "rtorrent_config_rss_rule"}, cbi("rtorrent/config_rss_rule"), nil).leaf = true
	entry({"admin", "nas", "rtorrent_config_rss_rule_detail"}, cbi("rtorrent/config_rss_rule_detail"), nil).leaf = true
        
	entry({"admin", "nas", "rtorrent_status"}, call("get_pid") ).leaf = true
	entry({"admin", "nas", "rtorrent_startstop"}, post("startstop") ).leaf = true
	
        --WEBUI
		entry({"admin", "rtorrent"},  firstchild(), nil).dependent = false
		entry({"admin", "rtorrent", "main"}, cbi("rtorrent/web_main"), nil).leaf = true
		entry({"admin", "rtorrent", "add"}, cbi("rtorrent/web_add", {autoapply=true}), nil).leaf = true
		entry({"admin", "rtorrent", "info"}, cbi("rtorrent/torrent/info"), nil).leaf = true
		entry({"admin", "rtorrent", "files"}, cbi("rtorrent/torrent/files"), nil).leaf = true
		entry({"admin", "rtorrent", "trackers"}, cbi("rtorrent/torrent/trackers"), nil).leaf = true
		entry({"admin", "rtorrent", "peers"}, cbi("rtorrent/torrent/peers"), nil).leaf = true
		
		entry({"admin", "rtorrent", "download"}, call("download"), nil).leaf = true
		entry({"admin", "rtorrent", "downloadall"}, call("downloadall"), nil).leaf = true

end

function download()
	dm.download_file(nixio.bin.b64decode(luci.dispatcher.context.requestpath[4]))
end

function downloadall()
	dm.download_all(nixio.bin.b64decode(luci.dispatcher.context.requestpath[4]))
end

function get_pid(from_lua)
	local pid_rtorrent = tonumber(luci.sys.exec("pidof rtorrent|awk '{print $1}'")) or 0 
        local rtorrent_stat =false
	if pid_rtorrent > 0 and not nixio.kill(pid_rtorrent, 0) then
		pid_rtorrent = 0
	end
        
        if pid_rtorrent > 0 then
            rtorrent_stat =true
        else
            rtorrent_stat =false
        end
        
        local rtorrentweb_stat = uci:get("rtorrent", "main", "xmlrpc_enable")
        
	local status = {
		rtorrent = rtorrent_stat,
		rtorrent_pid = pid_rtorrent,
		rtorrent_web = rtorrentweb_stat
	}
        
	if from_lua then
		return pid_rtorrent
	else
		luci.http.prepare_content("application/json")
		luci.http.write_json(status)	
	end
end

function startstop()
	local pid = get_pid(true)
	if pid > 0 then
		luci.sys.call("/etc/init.d/rtorrent stop")
		nixio.nanosleep(1)		-- sleep a second
		if nixio.kill(pid, 0) then	-- still running
			nixio.kill(pid, 9)	-- send SIGKILL
		end
		pid = 0
	else
		luci.sys.call("/etc/init.d/rtorrent start")
		nixio.nanosleep(1)		-- sleep a second
		pid = tonumber(luci.sys.exec("pidof rtorrent")) or 0 
		if pid > 0 and not nixio.kill(pid, 0) then
			pid = 0		-- process did not start
		end
	end
	luci.http.write(tostring(pid))	-- HTTP needs string not number
end
