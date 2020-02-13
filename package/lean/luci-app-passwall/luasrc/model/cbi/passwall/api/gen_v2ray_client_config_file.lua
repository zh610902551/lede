local ucursor = require"luci.model.uci".cursor()
local json = require "luci.jsonc"
local api = require "luci.model.cbi.passwall.api.api"
local node_section = arg[1]
local proto = arg[2]
local redir_port = arg[3]
local socks5_proxy_port = arg[4]
local node = ucursor:get_all("passwall", node_section)
local inbound_json = {}
local inboundDetour_json = nil
local vnext = {}

if socks5_proxy_port ~= "nil" then
    inbound_json = {
        listen = "0.0.0.0",
        port = socks5_proxy_port,
        protocol = "socks",
        settings = {auth = "noauth", udp = true, ip = "127.0.0.1"}
    }
end

if redir_port ~= "nil" then
    inbound_json = {
        port = redir_port,
        protocol = "dokodemo-door",
        settings = {network = proto, followRedirect = true},
        sniffing = {enabled = true, destOverride = {"http", "tls"}}
    }
    if proto == "tcp" and node.v2ray_tcp_socks == "1" then
        inboundDetour_json = {
            listen = "0.0.0.0",
            port = tonumber(node.v2ray_tcp_socks_port),
            protocol = "socks",
            settings = {
                auth = node.v2ray_tcp_socks_auth,
                accounts = (node.v2ray_tcp_socks_auth == "password") and {
                    {
                        user = node.v2ray_tcp_socks_auth_username,
                        pass = node.v2ray_tcp_socks_auth_password
                    }
                } or nil,
                udp = true
            }
        }
    end
end

if node.v2ray_balancing_node then
    local nodes = node.v2ray_balancing_node
    local length = #nodes
    for i = 1, length do
        local id = nodes[i]
        local vnext_json = {
            address = api.uci_get_type_id(id, "address"),
            port = tonumber(api.uci_get_type_id(id, "port")),
            users = {
                {
                    id = api.uci_get_type_id(id, "v2ray_VMess_id"),
                    alterId = tonumber(api.uci_get_type_id(id, "v2ray_VMess_alterId")),
                    level = tonumber(api.uci_get_type_id(id, "v2ray_VMess_level")),
                    security = api.uci_get_type_id(id, "v2ray_security")
                }
            }
        }
        vnext[i] = vnext_json
    end
else
    vnext = {
        {
            address = node.address,
            port = tonumber(node.port),
            users = {
                {
                    id = node.v2ray_VMess_id,
                    alterId = tonumber(node.v2ray_VMess_alterId),
                    level = tonumber(node.v2ray_VMess_level),
                    security = node.v2ray_security
                }
            }
        }
    }
end

local v2ray = {
    log = {
        -- error = "/var/log/v2ray.log",
        loglevel = "warning"
    },
    -- 传入连接
    inbounds = {inbound_json, inboundDetour_json},
    -- 传出连接
    outbounds = {
        {
            protocol = node.v2ray_protocol,
            mux = {
                enabled = (node.v2ray_mux == "1") and true or false,
                concurrency = (node.v2ray_mux_concurrency) and
                    tonumber(node.v2ray_mux_concurrency) or 8
            },
            -- 底层传输配置
            streamSettings = {
                network = node.v2ray_transport,
                security = node.v2ray_stream_security,
                tlsSettings = (node.v2ray_stream_security == "tls") and {
                    serverName = node.tls_serverName,
                    allowInsecure = (node.tls_allowInsecure == "1") and true or
                        false
                } or nil,
                kcpSettings = (node.v2ray_transport == "mkcp") and {
                    mtu = tonumber(node.v2ray_mkcp_mtu),
                    tti = tonumber(node.v2ray_mkcp_tti),
                    uplinkCapacity = tonumber(node.v2ray_mkcp_uplinkCapacity),
                    downlinkCapacity = tonumber(node.v2ray_mkcp_downlinkCapacity),
                    congestion = (node.v2ray_mkcp_congestion == "1") and true or
                        false,
                    readBufferSize = tonumber(node.v2ray_mkcp_readBufferSize),
                    writeBufferSize = tonumber(node.v2ray_mkcp_writeBufferSize),
                    header = {type = node.v2ray_mkcp_guise}
                } or nil,
                wsSettings = (node.v2ray_transport == "ws") and {
                    path = node.v2ray_ws_path,
                    headers = (node.v2ray_ws_host ~= nil) and
                        {Host = node.v2ray_ws_host} or nil
                } or nil,
                httpSettings = (node.v2ray_transport == "h2") and
                    {path = node.v2ray_h2_path, host = node.v2ray_h2_host} or
                    nil,
                dsSettings = (node.v2ray_transport == "ds") and
                    {path = node.v2ray_ds_path} or nil,
                quicSettings = (node.v2ray_transport == "quic") and {
                    security = node.v2ray_quic_security,
                    key = node.v2ray_quic_key,
                    header = {type = node.v2ray_quic_guise}
                } or nil
            },
            settings = {vnext = vnext}
        }, -- 额外传出连接
        {protocol = "freedom", tag = "direct", settings = {keep = ""}}
    }
}
print(json.stringify(v2ray, 1))
