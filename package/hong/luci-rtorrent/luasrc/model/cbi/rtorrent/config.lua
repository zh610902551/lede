-- Copyright 2016 maz-1 <ohmygod19993@gmail.com> --

local SYS = require("luci.sys")
local UTIL = require("luci.util")
local HTTP = require "luci.http"
local RTCOMMON = require "luci.model.cbi.rtorrent.common"

dht_l = {
	"auto",
	"on",
	"off",
}

ionice_l = {
	"none",
	"real-time",
	"best-effort",
	"idle",
}

--[[local apply = HTTP.formvalue("cbi.apply")               
if apply then                                                
        os.execute("/etc/init.d/rtorrent reload &")       -- reload configuration
end]]--

function size_validate(self, value, section, allow_disable)
	if string.match(value, "^%d+[KMG]$") or ( allow_disable and value == "" )then
		return value
        else
                return nil, "Invalid size, should be an integer suffixed with K/M/G etc."
	end
	
end

m = Map("rtorrent", "rTorrent", translate("rTorrent is a quick and efficient BitTorrent client.") .. "<br/><a href=\"https://github.com/maz-1\">luci interface by maz-1</a>")

m:section(SimpleSection).template  = "rtorrent/overview_status"

s=m:section(TypedSection, "rtorrent", translate("Settings"))
s.addremove=false
s.anonymous=true

s:tab("general", translate("General settings"))
s:tab("path_and_file", translate("File and Path"))
s:tab("connection", translate("Connections"))
s:tab("encryption", translate("Encryption"))
s:tab("extra", translate("Extra Settings"))
--s:tab("", translate(""))

-------------------------------------------------------------------------------------------------------
        
-- special --
o=s:taboption("general", Flag, "enabled", translate("Enabled"))
o.rmempty=false

o=s:taboption("general", ListValue, "user", translate("Run as user"))
local p_user
for _, p_user in UTIL.vspairs(UTIL.split(SYS.exec("cat /etc/passwd | cut -f 1 -d :"))) do
	o:value(p_user)
end

o=s:taboption("general", Value, "pieces__memory__max__set", translate("Maximum Memory Usage"), translate("Integer suffixed with K/M/G."))
function o.validate(self, value, section)
	return size_validate(self, value, section, false)
end
o.rmempty=true

o=s:taboption("general", Flag, "enable_rss", translate("Enable RSS"), 
    "<input type=\"button\" size=\"0\" value=\"" 
    .. translate("RSS Feed Settings") .. "\" onclick=\"location.href='./rtorrent_config_rss_feed'\" />" .. "&nbsp;" .. 
    "<input type=\"button\" size=\"0\" value=\"" 
    .. translate("RSS Rule Settings") .. "\" onclick=\"location.href='./rtorrent_config_rss_rule'\" />")
o.rmempty=true

o=s:taboption("general", Flag, "xmlrpc_enable", translate("Enable XMLRPC Interface"), translate("Allow controlling rtorrent via XMLRPC"))
o.rmempty=true

o=s:taboption("general", Value, "xmlrpc_port", translate("XMLRPC Interface Port"))
o.datatype = "port"
o.placeholder = "5001"
o.rmempty=true

o=s:taboption("general", Flag, "xmlrpc_bind_enable", translate("Bind XMLRPC TO HTTP Service"), 
     translate("Start a http service and bind XMLRPC interface to it<br/>to control rtorrent via remote clients like rutorrent."))
o.rmempty=true

o=s:taboption("general", Value, "xmlrpc_bind_host", translate("HTTP Service Listen Address"))
o.datatype = "ip4addr"
o.placeholder = "0.0.0.0"
o.rmempty = true

o=s:taboption("general", Value, "xmlrpc_bind_port", translate("HTTP Service Port"))
o.datatype = "port"
o.placeholder = "5002"
o.rmempty=true

o=s:taboption("general", Value, "xmlrpc_bind_username", translate("HTTP Service Username."), translate("Leave empty to disable authentication"))
o.rmempty = true

o=s:taboption("general", Value, "xmlrpc_bind_password", translate("HTTP Service Password."), translate("Leave empty to disable authentication"))
o.rmempty = true
o.password = true
-------------------------------------------------------------------------------------------------------

o=s:taboption("path_and_file", Value, "directory", translate("Download Directory"))
o.rmempty=false

o=s:taboption("path_and_file", Value, "session", translate("Session Directory"))
o.rmempty=false

o=s:taboption("path_and_file", Value, "network__send_buffer__size", translate("Send Buffer Size"), translate("Integer suffixed with K/M/G."))
o.rmempty=false
function o.validate(self, value, section)
	return size_validate(self, value, section, false)
end

o=s:taboption("path_and_file", Value, "network__receive_buffer__size", translate("Receive Buffer Size"), translate("Integer suffixed with K/M/G."))
o.rmempty=false
function o.validate(self, value, section)
	return size_validate(self, value, section, false)
end

o=s:taboption("path_and_file", Value, "encoding_list", translate("Encoding List"))
o.rmempty=false

o=s:taboption("path_and_file", Flag, "check_hash", translate("Check Hash For Finished Torrents"))
o.rmempty=true
o.enabled = "yes"

o=s:taboption("path_and_file", Flag, "system__file__allocate__set", translate("Preallocate Files"), translate("You must build rtorrent with --with-posix-fallocate to enable this"))
o.rmempty=true

o=s:taboption("path_and_file", Value, "system__file__split_size__set", translate("Split Files Larger Than Size"), translate("Integer suffixed with K/M/G. Leave empty to disable."))
o.rmempty=true
function o.validate(self, value, section)
	return size_validate(self, value, section, false)
end

o=s:taboption("path_and_file", Value, "system__file__split_suffix__set", translate("Suffix of Splited Files"))
o.placeholder = ".part"
o.rmempty=true

-------------------------------------------------------------------------------------------------------

o=s:taboption("connection", Value, "download_rate", translate("Download Rate"), "KiB/s")
o.datatype = "uinteger"
o.rmempty=false

o=s:taboption("connection", Value, "upload_rate", translate("Upload Rate"), "KiB/s")
o.datatype = "uinteger"
o.rmempty=false

o=s:taboption("connection", Flag, "protocol__pex__set", translate("Peer Exchange"))
o.rmempty=false
o.enabled = "yes"
o.disabled = "no"

o=s:taboption("connection", Value, "min_peers", translate("Minimum Peers"))
o.datatype = "uinteger"
o.rmempty=false

o=s:taboption("connection", Value, "max_peers", translate("Maximum Peers"))
o.datatype = "uinteger"
o.rmempty=false

o=s:taboption("connection", Value, "min_peers_seed", translate("Minimum Peers While Seeding"), translate("Set to -1 means same as ") .. translate("Minimum Peers"))
o.datatype = "min(-1)"
o.rmempty=false

o=s:taboption("connection", Value, "max_peers_seed", translate("Maximum Peers While Seeding"), translate("Set to -1 means same as ") .. translate("Maximum Peers"))
o.datatype = "min(-1)"
o.rmempty=false

o=s:taboption("connection", Value, "max_uploads", translate("Maximum Uploads"))
o.datatype = "uinteger"

o=s:taboption("connection", Value, "port_range", translate("BT Port Range"))
o.datatype = "portrange"
o.rmempty=false

o=s:taboption("connection", Flag, "port_random", translate("Random Port From Port Range"))
o.rmempty=true
o.enabled = "yes"
o.disabled = "no"

o=s:taboption("connection", Flag, "trackers__use_udp__set", translate("Use UDP Trackers"))
o.rmempty=true
o.enabled = "yes"

o=s:taboption("connection", ListValue, "dht", translate("Enable DHT"))
for i,v in ipairs(dht_l) do
	o:value(v)
end
o.rmempty=false

-------------------------------------------------------------------------------------------------------
--encryption=a,b,c,d....

o=s:taboption("encryption", Flag, "encryption_allow_incoming", translate("Allow Incoming Encrypted Connections"))
o.rmempty=true

o=s:taboption("encryption", Flag, "encryption_try_outgoing", translate("Use Encryption For Outgoing Connections"))
o.rmempty=true

o=s:taboption("encryption", Flag, "encryption_require", translate("Disable Unencrypted Handshakes"))
o.rmempty=true

o=s:taboption("encryption", Flag, "encryption_require_RC4", translate("Disable plaintext transmission after the initial encrypted handshake"))
o.rmempty=true

o=s:taboption("encryption", Flag, "encryption_enable_retry", translate("Retry With Encryption Toggled On/Off When Initial Outgoing Connection Fails"))
o.rmempty=true

o=s:taboption("encryption", Flag, "encryption_prefer_plaintext", translate("Choose Plaintext When Peer Offers A Choice Between Plaintext and RC4"))
o.rmempty=true


------------extra------------------------------------------------------------------------------------

extra = s:taboption("extra", Value, "_extra_settings", translate("Extra settings"), translate("This is the content of the file '/etc/rtorrent/rtorrent.rc.extra' which will be appended to configuration file"))
extra.template = "cbi/tvalue"
extra.rows = 20
extra.rmempty = true
function extra.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/rtorrent/rtorrent.rc.extra")
end

function extra.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("//etc/rtorrent/rtorrent.rc.extra", value)
end

return m
