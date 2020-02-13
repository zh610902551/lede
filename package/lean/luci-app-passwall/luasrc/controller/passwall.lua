-- Copyright 2018-2020 Lienol <lawlienol@gmail.com>
module("luci.controller.passwall", package.seeall)
local appname = "passwall"
local http = require "luci.http"
local kcptun = require "luci.model.cbi.passwall.api.kcptun"
local brook = require "luci.model.cbi.passwall.api.brook"
local v2ray = require "luci.model.cbi.passwall.api.v2ray"

function index()
    if not nixio.fs.access("/etc/config/passwall") then return end
    entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
    entry({"admin", "vpn", "passwall", "reset_config"}, call("reset_config")).leaf = true
    entry({"admin", "vpn", "passwall", "show"}, call("show_menu")).leaf = true
    entry({"admin", "vpn", "passwall", "hide"}, call("hide_menu")).leaf = true
    if nixio.fs.access("/etc/config/passwall") and
        nixio.fs.access("/etc/config/passwall_show") then
        entry({"admin", "vpn", "passwall"},
              alias("admin", "vpn", "passwall", "settings"), _("Pass Wall"), 1).dependent =
            true
    end
    entry({"admin", "vpn", "passwall", "settings"}, cbi("passwall/global"),
          _("Basic Settings"), 1).dependent = true
    entry({"admin", "vpn", "passwall", "node_list"}, cbi("passwall/node_list"),
          _("Node List"), 2).dependent = true
    -- entry({"admin", "vpn", "passwall", "auto_switch"},
    --      cbi("passwall/auto_switch"), _("Auto Switch"), 3).leaf = true
    entry({"admin", "vpn", "passwall", "other"},
          cbi("passwall/other", {autoapply = true}), _("Other Settings"), 94).leaf =
        true
    if nixio.fs.access("/usr/sbin/haproxy") then
        entry({"admin", "vpn", "passwall", "balancing"},
              cbi("passwall/balancing"), _("Load Balancing"), 95).leaf = true
    end
    entry({"admin", "vpn", "passwall", "rule"}, cbi("passwall/rule"),
          _("Rule Update"), 96).leaf = true
    entry({"admin", "vpn", "passwall", "acl"}, cbi("passwall/acl"),
          _("Access control"), 97).leaf = true
    entry({"admin", "vpn", "passwall", "rule_list"},
          cbi("passwall/rule_list", {autoapply = true}),
          _("Set Blacklist And Whitelist"), 98).leaf = true
    entry({"admin", "vpn", "passwall", "log"}, cbi("passwall/log"),
          _("Watch Logs"), 99).leaf = true
    entry({"admin", "vpn", "passwall", "node_config"},
          cbi("passwall/node_config")).leaf = true

    entry({"admin", "vpn", "passwall", "link_add_node"}, call("link_add_node")).leaf =
        true
    entry({"admin", "vpn", "passwall", "get_log"}, call("get_log")).leaf = true
    entry({"admin", "vpn", "passwall", "clear_log"}, call("clear_log")).leaf =
        true
    entry({"admin", "vpn", "passwall", "status"}, call("status")).leaf = true
    entry({"admin", "vpn", "passwall", "connect_status"}, call("connect_status")).leaf =
        true
    entry({"admin", "vpn", "passwall", "check_port"}, call("check_port")).leaf =
        true
    entry({"admin", "vpn", "passwall", "ping_node"}, call("ping_node")).leaf =
        true
    entry({"admin", "vpn", "passwall", "set_node"}, call("set_node")).leaf =
        true
    entry({"admin", "vpn", "passwall", "copy_node"}, call("copy_node")).leaf =
        true
    entry({"admin", "vpn", "passwall", "update_rules"}, call("update_rules")).leaf =
        true
    entry({"admin", "vpn", "passwall", "kcptun_check"}, call("kcptun_check")).leaf =
        true
    entry({"admin", "vpn", "passwall", "kcptun_update"}, call("kcptun_update")).leaf =
        true
    entry({"admin", "vpn", "passwall", "brook_check"}, call("brook_check")).leaf =
        true
    entry({"admin", "vpn", "passwall", "brook_update"}, call("brook_update")).leaf =
        true
    entry({"admin", "vpn", "passwall", "v2ray_check"}, call("v2ray_check")).leaf =
        true
    entry({"admin", "vpn", "passwall", "v2ray_update"}, call("v2ray_update")).leaf =
        true
end

local function http_write_json(content)
    http.prepare_content("application/json")
    http.write_json(content or {code = 1})
end

function reset_config()
    luci.sys.call('[ -f "/usr/share/passwall/config.default" ] && cp -f /usr/share/passwall/config.default /etc/config/passwall && /etc/init.d/passwall reload')
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall"))
end

function show_menu()
    luci.sys.call("touch /etc/config/passwall_show")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall"))
end

function hide_menu()
    luci.sys.call("rm -rf /etc/config/passwall_show")
    luci.http.redirect(luci.dispatcher.build_url("admin", "status", "overview"))
end

function link_add_node()
    local link = luci.http.formvalue("link")
    luci.sys.call('rm -f /tmp/links.conf && echo "' .. link ..
                      '" >> /tmp/links.conf')
    luci.sys.call("/usr/share/passwall/subscription.sh add >/dev/null")
end

function get_log()
    -- luci.sys.exec("[ -f /var/log/passwall.log ] && sed '1!G;h;$!d' /var/log/passwall.log > /var/log/passwall_show.log")
    luci.http.write(luci.sys.exec(
                        "[ -f '/var/log/passwall.log' ] && cat /var/log/passwall.log"))
end

function clear_log() luci.sys.call("echo '' > /var/log/passwall.log") end

function status()
    -- local dns_mode = luci.sys.exec("echo -n `uci -q get " .. appname .. ".@global[0].dns_mode`")
    local e = {}
    e.dns_mode_status = luci.sys.call("netstat -apn | grep 7913 >/dev/null") ==
                            0
    e.haproxy_status = luci.sys.call(
                           "ps -w | grep -v grep | grep -i 'haproxy -f /var/etc/" ..
                               appname .. "/haproxy.cfg' >/dev/null") == 0
    e.kcptun_status = luci.sys.call(
                          "ps -w | grep -v grep | grep -i 'log /var/etc/" ..
                              appname .. "/kcptun' >/dev/null") == 0

    local tcp_node_num = luci.sys.exec(
                             "echo -n `uci -q get %s.@global_other[0].tcp_node_num`" %
                                 appname)
    for i = 1, tcp_node_num, 1 do
        local listen_port = luci.sys.exec(
                                string.format(
                                    "[ -f '/var/etc/passwall/port/TCP_%s' ] && echo -n `cat /var/etc/passwall/port/TCP_%s`",
                                    i, i))
        e["tcp_node%s_status" % i] = luci.sys.call(
                                         string.format(
                                             "ps -w | grep -v grep | grep -i -E '%s/TCP_%s|brook tproxy -l 0.0.0.0:%s|ipt2socks -T -l %s' >/dev/null",
                                             appname, i, listen_port,
                                             listen_port)) == 0
    end

    local udp_node_num = luci.sys.exec(
                             "echo -n `uci -q get %s.@global_other[0].udp_node_num`" %
                                 appname)
    for i = 1, udp_node_num, 1 do
        local listen_port = luci.sys.exec(
                                string.format(
                                    "[ -f '/var/etc/passwall/port/UDP_%s' ] && echo -n `cat /var/etc/passwall/port/UDP_%s`",
                                    i, i))
        e["udp_node%s_status" % i] = luci.sys.call(
                                         string.format(
                                             "ps -w | grep -v grep | grep -i -E '%s/UDP_%s|brook tproxy -l 0.0.0.0:%s|ipt2socks -U -l %s' >/dev/null",
                                             appname, i, listen_port,
                                             listen_port)) == 0
    end

    local socks5_node_num = luci.sys.exec(
                                "echo -n `uci -q get %s.@global_other[0].socks5_node_num`" %
                                    appname)
    for i = 1, socks5_node_num, 1 do
        local listen_port = luci.sys.exec(
                                string.format(
                                    "[ -f '/var/etc/passwall/port/SOCKS5_%s' ] && echo -n `cat /var/etc/passwall/port/SOCKS5_%s`",
                                    i, i))
        e["socks5_node%s_status" % i] = luci.sys.call(
                                            string.format(
                                                "ps -w | grep -v grep | grep -i -E '%s/SOCKS5_%s|brook client -l 0.0.0.0:%s' >/dev/null",
                                                appname, i, listen_port)) == 0
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function connect_status()
    local e = {}
    if luci.http.formvalue("type") == "google" then
        e.status = luci.sys.call(
                       "echo `/usr/share/passwall/test.sh test_url 'www.google.com'` | grep 200 >/dev/null") ==
                       0
    else
        e.status = luci.sys.call(
                       "echo `/usr/share/passwall/test.sh test_url 'www.baidu.com'` | grep 200 >/dev/null") ==
                       0
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function ping_node()
    local index = luci.http.formvalue("index")
    local address = luci.http.formvalue("address")
    local port = luci.http.formvalue("port")
    local e = {}
    e.index = index
    if luci.sys.exec("echo -n `uci -q get %s.@global_other[0].use_tcping`" %
                         appname) == "1" and
        luci.sys.exec("echo -n `command -v tcping`") ~= "" then
        e.ping = luci.sys.exec(
                     "echo -n `tcping -q -c 1 -i 1 -p " .. port .. " " ..
                         address ..
                         " 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print$2}'`")
    else
        e.ping = luci.sys.exec(
                     "echo -n `ping -c 1 -W 1 %q 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print$2}'`" %
                         address)
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function set_node()
    local protocol = luci.http.formvalue("protocol")
    local number = luci.http.formvalue("number")
    local section = luci.http.formvalue("section")
    luci.sys.call("uci set passwall.@global[0]." .. protocol .. "_node" ..
                      number .. "=" .. section ..
                      " && uci commit passwall && /etc/init.d/passwall restart > /dev/null 2>&1 &")
    luci.http.redirect(luci.dispatcher.build_url("admin", "vpn", "passwall",
                                                 "log"))
end

function copy_node()
    local e = {}
    local section = luci.http.formvalue("section")
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function check_port()
    local s
    local node_name = ""
    local uci = luci.model.uci.cursor()

    local retstring = "<br />"
    -- retstring = retstring .. "<font color='red'>暂时不支持UDP检测</font><br />"

    if luci.sys.exec("echo -n `uci -q get %s.@global_other[0].use_tcping`" %
                         appname) == "1" and
        luci.sys.exec("echo -n `command -v tcping`") ~= "" then
        retstring = retstring ..
                        "<font color='green'>使用tcping检测端口延迟</font><br />"
        uci:foreach("passwall", "nodes", function(s)
            local ret = ""
            local tcp_socket
            if (s.use_kcp and s.use_kcp == "1" and s.kcp_port) or
                (s.v2ray_transport and s.v2ray_transport == "mkcp" and s.port) then
            else
                local type = s.type
                if type and type ~= "V2ray_balancing" and s.address and s.port and
                    s.remarks then
                    node_name = "[%s] [%s:%s]" % {s.remarks, s.address, s.port}
                    result = luci.sys.exec(
                                 "echo -n `tcping -q -c 1 -i 1 -p " .. s.port ..
                                     " " .. s.address ..
                                     " 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print$2}'`")
                    if result and result ~= "" then
                        retstring = retstring .. "<font color='green'>" ..
                                        node_name .. "   " .. result ..
                                        "ms.</font><br />"
                    else
                        retstring = retstring .. "<font color='red'>" ..
                                        node_name .. "   Timeout.</font><br />"
                    end
                    ret = ""
                end
            end
        end)
    else
        retstring = retstring ..
                        "<font color='green'>使用socket检测端口是否打开</font><br />"
        uci:foreach("passwall", "nodes", function(s)
            local ret = ""
            local tcp_socket
            local udp_socket
            if (s.use_kcp and s.use_kcp == "1" and s.kcp_port) or
                (s.v2ray_transport and s.v2ray_transport == "mkcp" and s.port) then
            else
                local type = s.type
                if type and type ~= "V2ray_balancing" and s.address and s.port and
                    s.remarks then
                    node_name = "%s：[%s] %s:%s" %
                                    {s.type, s.remarks, s.address, s.port}
                    tcp_socket = nixio.socket("inet", "stream")
                    tcp_socket:setopt("socket", "rcvtimeo", 3)
                    tcp_socket:setopt("socket", "sndtimeo", 3)
                    ret = tcp_socket:connect(s.address, s.port)
                    if tostring(ret) == "true" then
                        retstring = retstring .. "<font color='green'>" ..
                                        node_name .. "   OK.</font><br />"
                    else
                        retstring = retstring .. "<font color='red'>" ..
                                        node_name .. "   Error.</font><br />"
                    end
                    ret = ""
                end
            end
            if tcp_socket then tcp_socket:close() end
            if udp_socket then udp_socket:close() end
        end)
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json({ret = retstring})
end

function update_rules()
    local update = luci.http.formvalue("update")
    luci.sys.call("nohup /usr/share/passwall/rule_update.sh '" .. update ..
                      "' 2>&1 &")
end

function kcptun_check()
    local json = kcptun.to_check("")
    http_write_json(json)
end

function kcptun_update()
    local json = nil
    local task = http.formvalue("task")
    if task == "extract" then
        json = kcptun.to_extract(http.formvalue("file"),
                                 http.formvalue("subfix"))
    elseif task == "move" then
        json = kcptun.to_move(http.formvalue("file"))
    else
        json = kcptun.to_download(http.formvalue("url"))
    end

    http_write_json(json)
end

function brook_check()
    local json = brook.to_check("")
    http_write_json(json)
end

function brook_update()
    local json = nil
    local task = http.formvalue("task")
    if task == "move" then
        json = brook.to_move(http.formvalue("file"))
    else
        json = brook.to_download(http.formvalue("url"))
    end

    http_write_json(json)
end

function v2ray_check()
    local json = v2ray.to_check("")
    http_write_json(json)
end

function v2ray_update()
    local json = nil
    local task = http.formvalue("task")
    if task == "extract" then
        json =
            v2ray.to_extract(http.formvalue("file"), http.formvalue("subfix"))
    elseif task == "move" then
        json = v2ray.to_move(http.formvalue("file"))
    else
        json = v2ray.to_download(http.formvalue("url"))
    end

    http_write_json(json)
end
