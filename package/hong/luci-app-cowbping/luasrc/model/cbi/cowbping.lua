local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local ipc = require "luci.ip"
local button = ""
local state_msg = ""
local a,m,s,n
local running=(luci.sys.call("ps|grep 'cowbping.sh'|grep -v grep > /dev/null") == 0)
local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end

m = Map("cowbping", translate("cowbping"))
m.description = translate("<font style='color:green'>定期ping一个网址以检测网络有无通畅，如果网络不通就执行相关设定动作以求排除故障。</font>" .. button
        .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />")

s = m:section(TypedSection, "cowbping")
s.anonymous=true
s.addremove=false
enabled = s:option(Flag, "enabled", translate("启用"), translate("为总开关，这里开启后整个程序才会启动。"))
enabled.default = 0
enabled.rmempty = true

setport =s:option(Value,"delaytime",translate("开机延迟（秒）"))
setport.description = translate("开机（或首次启用）延迟一段时间才会启动ping动作。")
setport.placeholder=60
setport.default=60
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"address",translate("地址(IP或域名)"))
setport.description = translate("用来执行ping检测的网络地址。")
setport.placeholder="8.8.4.4"
setport.default="8.8.4.4"
setport.datatype="host"
setport.rmempty=false

setport =s:option(Value,"time",translate("重复时间（秒）"))
setport.description = translate("检测网络情况时间间隔，如果使用环境比较恶劣可以适当缩短。")
setport.placeholder=60
setport.default=60
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"pkglost",translate("丢包比例（%）"))
setport.description = translate("丢包比例达到此数值就会视为网络不通。")
setport.placeholder=100
setport.default=100
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"sum",translate("失败次数（次）"))
setport.description = translate("当网络不通时会连续ping n次，n次都不通的话就会执行命令。")
setport.placeholder=1
setport.default=1
setport.datatype="port"
setport.rmempty=false

enabled = s:option(ListValue, "work_mode", translate("执行动作"))
enabled.description = translate("")
enabled:value("1", translate("1.重启系统"))
enabled:value("2", translate("2.重启WAN"))
enabled:value("3", translate("3.重启WIFI"))
enabled:value("6", translate("4.重启WIFI并改中继随机MAC"))
enabled:value("4", translate("5.重启网络"))
enabled:value("5", translate("6.自定义命令"))
enabled.default = 2

setport =s:option(Value,"command",translate("自定义命令"))
setport.description = translate("比如 /etc/init.d/xxx restart 。")
setport.rmempty=true
setport:depends("work_mode", 5)

local a = luci.http.formvalue("cbi.apply")
if a then
  io.popen("/etc/init.d/cowbping restart")
end

return m

