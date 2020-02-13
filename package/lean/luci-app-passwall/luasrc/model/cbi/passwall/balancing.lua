local e = require "nixio.fs"
local e = require "luci.sys"
local net = require"luci.model.network".init()
local uci = require"luci.model.uci".cursor()
local ifaces = e.net:devices()
local appname = "passwall"

local n = {}
uci:foreach(appname, "nodes", function(e)
    if e.remarks and e.address and e.port and e.address ~= "127.0.0.1" then
        e.remark = "[%s] %s:%s" % {e.remarks, e.address, e.port}
        n[e[".name"]] = e
    end
end)

local key_table = {}
for key, _ in pairs(n) do table.insert(key_table, key) end
table.sort(key_table)

m = Map(appname)

-- [[ Haproxy Settings ]]--
s = m:section(TypedSection, "global_haproxy", translate("Load Balancing"))
s.anonymous = true

s:append(Template("passwall/haproxy/status"))

---- Balancing Enable
o = s:option(Flag, "balancing_enable", translate("Enable Load Balancing"))
o.rmempty = false
o.default = false

---- Console Username
o = s:option(Value, "console_user", translate("Console Username"))
o.default = "admin"
o:depends("balancing_enable", 1)

---- Console Password
o = s:option(Value, "console_password", translate("Console Password"))
o.password = true
o.default = "admin"
o:depends("balancing_enable", 1)

---- Console Port
o = s:option(Value, "console_port", translate("Console Port"), translate(
                 "In the browser input routing IP plus port access, such as:192.168.1.1:1188"))
o.default = "1188"
o:depends("balancing_enable", 1)

---- Haproxy Port
o = s:option(Value, "haproxy_port", translate("Haproxy Port"),
             translate("Configure this node with 127.0.0.1: this port"))
o.default = "1181"
o:depends("balancing_enable", 1)

-- [[ Balancing Settings ]]--
s = m:section(TypedSection, "balancing", translate("Load Balancing Setting"),
              translate(
                  "Add a node, Export Of Multi WAN Only support Multi Wan. Load specific gravity range 1-256. Multiple primary servers can be load balanced, standby will only be enabled when the primary server is offline!"))
s.template = "cbi/tblsection"
s.sortable = true
s.anonymous = true
s.addremove = true

---- Node Address
o = s:option(Value, "lbss", translate("Node Address"))
for _, key in pairs(key_table) do
    o:value(n[key].address .. ":" .. n[key].port, n[key].remark)
end
o.rmempty = false

---- Node Port
o = s:option(Value, "lbort", translate("Node Port"))
o:value("default", translate("Default"))
o.rmempty = false

---- Node Weight
o = s:option(Value, "lbweight", translate("Node Weight"))
o.default = "5"
o.rmempty = false

---- Export
o = s:option(ListValue, "export", translate("Export Of Multi WAN"))
o:value(0, translate("Auto"))
for _, iface in ipairs(ifaces) do
    if (iface:match("^pppoe*")) then
        local nets = net:get_interface(iface)
        nets = nets and nets:get_networks() or {}
        for k, v in pairs(nets) do nets[k] = nets[k].sid end
        nets = table.concat(nets, ",")
        o:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
    end
end
o.default = 0
o.rmempty = false

---- Mode
o = s:option(ListValue, "backup", translate("Mode"))
o:value(0, translate("Primary"))
o:value(1, translate("Standby"))
o.rmempty = false

return m
