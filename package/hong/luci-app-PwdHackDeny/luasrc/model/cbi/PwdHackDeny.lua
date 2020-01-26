local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local ipc = require "luci.ip"
local button = ""
local state_msg = ""
local m,s,n
local running=(luci.sys.call("pidof PwdHackDeny.sh > /dev/null") == 0)
local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end

m = Map("PwdHackDeny", translate("PwdHackDeny"))
m.description = translate("<font style='color:green'>用于监控SSH以及路由异常登录情况，频率为10分钟一次，外网统计IP次数，内网统计MAC次数，密码错误历史纪录达到5次，不论内外网，都永久禁止连接dropbear以及uhttp的登录端口，不会因为重启而停止，直到手动删除禁止名单里相应的IP/MAC为止。</font>" .. button
        .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />")

s = m:section(TypedSection, "PwdHackDeny")
s.anonymous=true
s.addremove=false
enabled = s:option(Flag, "enabled", translate("启用"), translate("启用或禁用功能。要先禁用、再去更改相关功能的端口、再启用。"))
enabled.default = 0
enabled.rmempty = true

setport =s:option(Value,"time",translate("巡查时间"))
setport.description = translate("单位为“秒”，如果使用环境比较恶劣可以适当缩短巡查时间。")
setport.placeholder=600
setport.default=600
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"sum",translate("失败次数"))
setport.description = translate("登入密码错误次数达到此数值的IP就会被永久加入禁止名单。")
setport.placeholder=5
setport.default=5
setport.datatype="port"
setport.rmempty=false


s = m:section(TypedSection, "PwdHackDeny")

s:tab("config1", translate("<font style='color:gray'>SSH错误登录日志</font>"))
conf = s:taboption("config1", Value, "editconf1", nil, translate("<font style='color:red'>新的信息需要刷新页面才会有所显示。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/tmp/PwdHackDeny/badip.log.ssh", value) or ""
end

s:tab("config2", translate("<font style='color:gray'>web错误登录日志</font>"))
conf = s:taboption("config2", Value, "editconf2", nil, translate("<font style='color:red'>新的信息需要刷新页面才会有所显示。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/tmp/PwdHackDeny/badip.log.web", value) or ""
end

s:tab("config3", translate("<font style='color:black'>SSH禁止名单</font>"))
conf = s:taboption("config3", Value, "editconf3")
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/SSHbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/SSHbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/SSHbadip.log /etc/SSHbadip.log") == 1) then
            fs.writefile("/etc/SSHbadip.log", value)
        end
        fs.remove("/tmp/SSHbadip.log")
    end
end

s:tab("config4", translate("<font style='color:black'>WEB禁止名单</font>"))
conf = s:taboption("config4", Value, "editconf4")
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/WEBbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/WEBbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/WEBbadip.log /etc/WEBbadip.log") == 1) then
            fs.writefile("/etc/WEBbadip.log", value)
        end
        fs.remove("/tmp/WEBbadip.log")
    end
end

local e=luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/PwdHackDeny start")
end

return m

