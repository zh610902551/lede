#!/usr/bin/env lua

--[[ by maz-1 ohmygod19993@gmail.com ]]--

local socket = require 'socket'
local copas = require 'copas'
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"


--[[ BASE64 Functions ]]--
require('math')
local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function to_binary(integer)
    local remaining = tonumber(integer)
    local bin_bits = ''

    for i = 7, 0, -1 do
        local current_power = math.pow(2, i)

        if remaining >= current_power then
            bin_bits = bin_bits .. '1'
            remaining = remaining - current_power
        else
            bin_bits = bin_bits .. '0'
        end
    end

    return bin_bits
end

function from_binary(bin_bits)
    return tonumber(bin_bits, 2)
end


function to_base64(to_encode)
    local bit_pattern = ''
    local encoded = ''
    local trailing = ''

    for i = 1, string.len(to_encode) do
        bit_pattern = bit_pattern .. to_binary(string.byte(string.sub(to_encode, i, i)))
    end

    -- Check the number of bytes. If it's not evenly divisible by three,
    -- zero-pad the ending & append on the correct number of ``=``s.
    if math.mod(string.len(bit_pattern), 3) == 2 then
        trailing = '=='
        bit_pattern = bit_pattern .. '0000000000000000'
    elseif math.mod(string.len(bit_pattern), 3) == 1 then
        trailing = '='
        bit_pattern = bit_pattern .. '00000000'
    end

    for i = 1, string.len(bit_pattern), 6 do
        local byte = string.sub(bit_pattern, i, i+5)
        local offset = tonumber(from_binary(byte))
        encoded = encoded .. string.sub(index_table, offset+1, offset+1)
    end

    return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
end


function from_base64(to_decode)
    local padded = to_decode:gsub("%s", "")
    local unpadded = padded:gsub("=", "")
    local bit_pattern = ''
    local decoded = ''

    for i = 1, string.len(unpadded) do
        local char = string.sub(to_decode, i, i)
        local offset, _ = string.find(index_table, char)
        if offset == nil then
             error("Invalid character '" .. char .. "' found.")
        end

        bit_pattern = bit_pattern .. string.sub(to_binary(offset-1), 3)
    end

    for i = 1, string.len(bit_pattern), 8 do
        local byte = string.sub(bit_pattern, i, i+7)
        decoded = decoded .. string.char(from_binary(byte))
    end

    local padding_length = padded:len()-unpadded:len()

    if (padding_length == 1 or padding_length == 2) then
        decoded = decoded:sub(1,-2)
    end
    return decoded
end
--[[ BASE64 Functions ]]--
        
        
if uci:get("rtorrent", "main", "xmlrpc_bind_enable") ~= "1" then
    print("xmlrpc_bind_enable not set to 1")
    os.exit()
end

local auth_enabled = false
local username = uci:get("rtorrent", "main", "xmlrpc_bind_username")
local password = uci:get("rtorrent", "main", "xmlrpc_bind_password")
local user_pass_encoded
if username ~= nil and password ~= nil then
    auth_enabled = true
    user_pass_encoded = to_base64(username .. ":" .. password)
    print("Auth enabled")
end

local config = {
    newhost=uci:get("rtorrent", "main", "xmlrpc_bind_host") or "0.0.0.0",
    newport=uci:get("rtorrent", "main", "xmlrpc_bind_port") or "5002",
    oldhost="127.0.0.1",
    oldport=uci:get("rtorrent", "main", "xmlrpc_port") or "5001",
}

print("Proxying from ".. config.newhost .. ":" .. config.newport
              .." to ".. config.oldhost .. ":" .. config.oldport)

local server = socket.bind(config.newhost,config.newport)

local headers_parsers = {
    [ "connection" ]= function(h)
        return "Connection: close"
    end,
    [ "host" ]= function(h)
        return "Host: " .. config.oldhost ..":"..config.oldport
    end,
    [ "location" ]= function(h)
        local  new, old ;
        if config.newport == "80" then new = config.newhost else new = config.newhost .. ":" .. config.newport end
        if config.oldport == "80" then old = config.oldhost else old = config.oldhost .. ":" .. config.oldport end
        return string.gsub(h,old,new,1);
    end
}

function get_method(l)
    return string.gsub(l,"^(%w+).*$","%1")
end

function parse_header(l)
    local head, last
    for k in string.gmatch(l,"([^:%s]+)%s?:") do head = string.lower(k) ; break end
    if headers_parsers[head] ~= nil then
        l =  headers_parsers[head](l)
    end
    if string.len(l) == 0 then last = true end
    return l .. "\r\n",last, l
end

function pass_headers_html(reader,writer)
    local len
    while true do
        local req = reader:receive()
        if req == nil then req = "" end
        if string.lower(string.sub(req,0,14)) == "content-length" then len = string.gsub(req,"[^:]+:%s*(%d+)","%1") end
        local header, last, h = parse_header(req)
        if last then break end
    end
        local respond_code = "HTTP/1.1 200 OK\r\n"
        local server_name = "Server: lua-copas/2.0.0\r\n"
	local content_type = "Content-Type: text/xml\r\n"
	local content_len
        if len ~= nil then
            content_len = "Content-Length: " .. tonumber(len) .. "\r\n"
        else
            content_len = "Content-Length: 0"
        end
	local connection_type = "Connection: keep-alive\r\n\r\n"
	local header = respond_code .. server_name .. content_type .. content_len .. connection_type
        writer:send(header)
    return len
end

function pass_headers_scgi(reader)
    local method, len, auth
    while true do
        local req = reader:receive()
        if req == nil then req = "" end
        if method == nil then method = get_method(req) end
        if string.lower(string.sub(req,0,14)) == "content-length" then len = string.gsub(req,"[^:]+:%s*(%d+)","%1") end
        if string.lower(string.sub(req,0,13)) == "authorization" then auth = string.gsub(req,"[^:]+:%s*(.+)","%1") end
        --print("<=" .. req)
        local header, last, h = parse_header(req)
        if last then break end
    end
    
    if string.lower(method) == "post" then 
        local null = "\0"
        local content_length
        --print("SENDING\n\n")
        if len ~= nil then
            content_length = "CONTENT_LENGTH" .. null .. tonumber(len) .. null
        else
            content_length = "CONTENT_LENGTH" .. null .. "0" .. null
        end
        local scgi_enable = "SCGI" .. null .. "1" .. null
        local request_method = "REQUEST_METHOD" .. null .. "POST" .. null
        local server_protocol = "SERVER_PROTOCOL" .. null .. "HTTP/1.1" .. null
        local header = content_length .. scgi_enable .. request_method .. server_protocol
        --writer:send(string.len(header) .. ":" .. header .. ",")
        return len, auth, string.lower(method), string.len(header) .. ":" .. header .. ","
    else
        return nil
    end
end

function pass_body(reader,writer, len)
    if len == nil then
        while true do
            local res, err, part = reader:receive(512)
            if err == "closed" or err == 'timeout' then
                if part ~= nil then writer:send(part) end
                break
            end
            writer:send(res)
        end
    else
        if len == 0 then return nil end
        local res, err, part =  reader:receive(len)
        writer:send(res)
    end
end

function ask_for_auth(writer)
    local header = [[HTTP/1.1 401 Authorization Required
Server: lua-copas/2.0.0
WWW-Authenticate: Basic realm="lede"
Content-Length: 401
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>401 Authorization Required</title>
</head><body>
<h1>Authorization Required</h1>
<p>This server could not verify that you
are authorized to access the document
requested.  Either you supplied the wrong
credentials (e.g., bad password), or your
browser doesn't understand how to supply
the credentials required.</p>
</body></html>]]
    writer:send(header)
end

function invalid_op(writer)
    local header = [[HTTP/1.1 400 Bad Request
Server: lua-copas/2.0.0
Content-Length: 190
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>400 Bad Request</title>
</head><body>
<h1>Bad Request</h1>
<p>This is not a web service :-)</p>
</body></html>]]
    writer:send(header)
end

function send_and_get(s, len, c, len2, buffer)
    s:send(buffer)
    if len ~= nil then pass_body(c,s,tonumber(len)) end
    local len2 = pass_headers_html(s,c)
    pass_body(s,c,len2)
end

function handler(sk8)
    local c = copas.wrap(sk8)
    local s = socket.connect(config.oldhost,config.oldport)
    if s == nil then 
        print("Cannot connect to xmlrpc interface")
        os.exit()
    end
    
    s:settimeout(3)
    local len,auth,method,buffer = pass_headers_scgi(c)
    
    if method == "post" then
      if auth ~= nil and auth_enabled == true then
        local auth_str = string.gsub(auth,"%w+%s*(.+)","%1")
        if user_pass_encoded == auth_str then
            send_and_get(s, len, c, len2, buffer)
        else
            ask_for_auth(c)
        end
      else
        if auth_enabled == true then
            ask_for_auth(c)
        else
            send_and_get(s, len, c, len2, buffer)
        end
      end
    else
      invalid_op(c)
    end
    s:close()
end

copas.addserver(server, handler)
copas.loop()
