-- Copyright 2014-2016 Sandor Balazsi <sandor.balazsi@gmail.com>
-- Licensed to the public under the Apache License 2.0.

--local common = require "luci.model.cbi.rtorrent.common"
local nixio = require "nixio"

m = Map("rtorrent", translate("rTorrent - RSS Downloader"))

m.redirect = luci.dispatcher.build_url("admin/nas/rtorrent_config")

s = m:section(TypedSection, "rss-feed")
s.addremove = true
s.anonymous = true
s.sortable = true
s.template = "cbi/tblsection"
--[[
s.render = function(self, section, scope)
	luci.template.render("rtorrent/tabmenu", { self = {
		pages = common.get_admin_pages(),
		page = "RSS"
	}})
	TypedSection.render(self, section, scope)
end
]]--

name = s:option(Value, "name", translate("Name"))
name.rmempty = false

url = s:option(Value, "url", translate("RSS Feed URL"))
url.size = "65"
url.rmempty = false

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.rmempty = false

s = m:section(TypedSection, "rtorrent", translate("Settings"))
s.addremove = false
s.anonymous = true

feed_interval = s:option(Value, "feed_interval", translate("RSS feed download interval"), translate("in seconds"))
feed_interval.datatype = "uinteger"
feed_interval.rmempty = true
feed_interval.default = "300"
feed_interval.placeholder = "300"

feed_logging = s:option(Flag, "feed_logging", translate("Enable RSS feed logging"))

feed_logfile = s:option(Value, "feed_logfile", translate("RSS feed logfile"))
feed_logfile:depends("feed_logging", 1)
feed_logfile.default = "/var/run/rtorrent/rss.log"

function feed_logfile.validate(self, value, section)
	local parent_folder = nixio.fs.dirname(value)
	if parent_folder == "." or nixio.fs.stat(parent_folder, "type") ~= "dir" then
		return nil, translate("Wrong filename, please use absolute path!")
	end
	return value
end

s = m:section(TypedSection, "rtorrent", translate("Cookies"))
s.addremove = false
s.anonymous = true

cookies = s:option(Value, "_cookies", translate("Cookies"), translate("This is the content of the file '/etc/rtorrent/cookies.txt'. Useful for RSS Downloader"))
cookies.template = "cbi/tvalue"
cookies.rows = 20
cookies.rmempty = true
function cookies.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/rtorrent/cookies.txt")
end

function cookies.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("//etc/rtorrent/cookies.txt", value)
end

return m
