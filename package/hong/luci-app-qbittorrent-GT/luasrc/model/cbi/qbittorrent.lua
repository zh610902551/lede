require("luci.sys")
local e=require"luci.model.uci".cursor()
local o=e:get_first("qbittorrent","Preferences","port")or 6565
local a=(luci.sys.call("pidof qbittorrent-nox > /dev/null")==0)
local t=""
local e=""
if a then
t="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("打开Web管理器").." \" onclick=\"window.open('http://'+window.location.hostname+':"..o.."')\"/>"
end
if a then
e="<b><font color=\"green\">"..translate("已经启动").."</font></b>"
else
e="<b><font color=\"red\">"..translate("没有启动").."</font></b>"
end

m = Map("qbittorrent", translate("qBittorrent"), translate("一个基于Qt的BT/PT下载器")..t
.."<br/><br/>"..translate("qBittorrent状态").." : "..e.."<br/>")

s_basic = m:section(TypedSection, "basic", translate("Basic Settings"))
s_basic.anonymous = true
enable = s_basic:option(Flag, "enable", translate("Enable"))
profile_dir = s_basic:option(Value,"profile_dir",translate("配置文件目录"),translate("配置文件存放目录"))
profile_dir.default = "/etc/config"
program_dir = s_basic:option(Value,"program_dir",translate("程序目录"),translate("程序文件目录"))
program_dir.default = "/usr/bin"
library_dir = s_basic:option(Value,"library_dir",translate("链接库目录"),translate("链接库目录"))
library_dir.default = "/usr/lib"

s_download = m:section(TypedSection, "Preferences", translate("下载设置"))
s_download.anonymous = true
download_dir = s_download:option(Value,"download_dir",translate("下载目录"),translate("下载文件存放目录"))
download_dir.default = "/mnt/sda"

s_webui = m:section(TypedSection, "Preferences", translate("Web UI设置"))
s_webui.anonymous = true
port = s_webui:option(Value,"port",translate("监听端口"),translate("Web UI监听端口"))
port.default = "6565"

local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/qbittorrent restart")
end

return m
