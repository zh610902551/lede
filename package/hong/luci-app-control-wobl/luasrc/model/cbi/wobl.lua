local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local ipc = require "luci.ip"
local conffile = "/tmp/woblwatchdog"
local button = ""
local state_msg = ""
local m,s,n
local running=(luci.sys.call("pidof woblwatchdog.sh > /dev/null") == 0)
local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行(如非白名单模式无须理会）") .. "</font></b>"
end

m = Map("wobl", translate("White Or Black List Restriction"))
m.description = translate("<font style='color:green'>允许以白名单或黑名单方式控制用户联网（或控制联某些目标IP的网）。</font></br>权限优先级为：管理MAC（放行）>黑名单MAC（禁止）>白名单MAC、黑名单IP（禁止）>白名单IP。" .. button
        .. "<br/><br/>" .. translate("白名单守护").. " : "  .. state_msg .. "<br />")

s = m:section(TypedSection, "wobl")
s.anonymous=true
s.addremove=false
enabled = s:option(Flag, "enabled", translate("启用"), translate("启用或禁用名单过滤功能"))
enabled.default = 0
enabled.rmempty = true

s = m:section(TypedSection, "wobl")
s.anonymous=true
s.addremove=false
enabled = s:option(Flag, "macblack_any_mode_enabled", translate("MAC黑名单</br>总打开过滤"), translate("任何时候都过滤MAC黑名单，即使在MAC/IP白名单或IP黑名单模式。"))
enabled.default = 0
enabled.rmempty = true

enabled = s:option(ListValue, "work_mode", translate("模式选择"))
enabled.description = translate("可以以一种模式或者与MAC黑名单组合运行，MAC黑名单将优先执行。")
--by wulishui 20191231
enabled:value("macwhitelist", translate("MAC白名单--（仅放行MAC名单内用户访问网络，其余禁止）"))
enabled:value("macblacklist", translate("MAC黑名单--（仅禁止MAC名单内用户访问网络，其余放行）"))
enabled:value("ipwhitelist", translate("IP白名单------（仅放行IP名单内用户访问外网，其余禁止）"))
enabled:value("ipblacklist", translate("IP黑名单------（仅禁止IP名单内用户访问网络，其余放行）"))
enabled.default = ipwhitelist


enabled = s:option(ListValue, "drop_mode", translate("拦截路径"))
enabled.description = translate("<font color=\"red\">*入站拦截连路由管理页面也不能进入，使用白名单模式前一定要将管理MAC加入超级白名单！</br>*入站+IP白名单模式的客户端需要设定名单内包含的静态IP才能访问网络，黑名单模式无须。</font>")
--by wulishui 20191231
enabled:value("INPUT", translate("入站--（控制访问内、外网，网关亦不可访问）"))
enabled:value("FORWARD", translate("转发--（仅控制访问外部网络，局域网可访问）"))
enabled.default = FORWARD

host = s:option(Value, "admin_mac", translate("超级白名单"),translate("<font color=\"black\">此的MAC不受任何软件内或外的规则限制，为安全起见仅能设一个。</font>"))
--host:depends("drop_mode", INPUT)
sys.net.mac_hints(function(mac, name)
	host:value(mac, "%s (%s)" %{ mac, name })
end)


host = s:option(Value, "config_mac", translate("MAC白名单"),translate("<font color=\"black\">选中的MAC会被添加到MAC白名单末尾，但再次更改后不会自动删除。</font>"))
host:depends("work_mode", macwhitelist)
sys.net.mac_hints(function(mac, name)
	host:value(mac, "%s (%s)" %{ mac, name })
end)

s = m:section(TypedSection, "wobl")

s:tab("config1", translate("<font style='color:green'>MAC白名单</font>"))
conf = s:taboption("config1", Value, "editconf1", nil, translate("<font style='color:red'>请注意检查格式，如果有格式错误，错误名单后面的列表都不能添加！可到日志里查看具体添加的名单条数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
conf:depends("work_mode", macwhitelist)
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/wobl/macwhitelist") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/macwhitelist", value)
        if (luci.sys.call("cmp -s /tmp/macwhitelist /etc/wobl/macwhitelist") == 1) then
            fs.writefile("/etc/wobl/macwhitelist", value)
        end
        fs.remove("/tmp/macwhitelist")
    end
end

s:tab("config2", translate("<font style='color:red'>MAC黑名单</font>"))
conf = s:taboption("config2", Value, "editconf2", nil, translate("<font style='color:red'>请注意检查格式，如果有格式错误，错误名单后面的列表都不能添加！可到日志里查看具体添加的名单条数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
conf:depends("work_mode", macblacklist)
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/wobl/macblacklist") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/macblacklist", value)
        if (luci.sys.call("cmp -s /tmp/macblacklist /etc/wobl/macblacklist") == 1) then
            fs.writefile("/etc/wobl/macblacklist", value)
        end
        fs.remove("/tmp/macblacklist")
    end
end

s:tab("config3", translate("<font style='color:green'>IP白名单</font>"))
conf = s:taboption("config3", Value, "editconf3", nil, translate("<font style='color:red'>请注意检查格式，如果有格式错误，错误名单后面的列表都不能添加！可到日志里查看具体添加的名单条数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/wobl/ipwhitelist") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/ipwhitelist", value)
        if (luci.sys.call("cmp -s /tmp/ipwhitelist /etc/wobl/ipwhitelist") == 1) then
            fs.writefile("/etc/wobl/ipwhitelist", value)
        end
        fs.remove("/tmp/ipwhitelist")
    end
end

s:tab("config4", translate("<font style='color:red'>IP黑名单</font>"))
conf = s:taboption("config4", Value, "editconf4", nil, translate("<font style='color:red'>请注意检查格式，如果有格式错误，错误名单后面的列表都不能添加！可到日志里查看具体添加的名单条数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/wobl/ipblacklist") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/ipblacklist", value)
        if (luci.sys.call("cmp -s /tmp/ipblacklist /etc/wobl/ipblacklist") == 1) then
            fs.writefile("/etc/wobl/ipblacklist", value)
        end
        fs.remove("/tmp/ipblacklist")
    end
end

s:tab("config5", translate("<font style='color:gray'>日志</font>"))
conf = s:taboption("config5", Value, "editconf5", nil, translate("<font style='color:red'>可供查看运行信息，比如成功导入名单的条数和运行日志，有时需要刷新页面才会有所显示。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 25
conf.wrap = "off"
conf.readonly="readonly"
conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/tmp/woblwatchdog", value) or ""
end



--            luci.sys.call("/etc/init.d/wobl restart >/dev/null")

local e=luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/wobl start")
end

return m


