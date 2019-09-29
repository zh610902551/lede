--[[
Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)

This is free software, licensed under the GNU General Public License v3.
]]--

module("luci.controller.softwarecenter",package.seeall)

function index() 
	local page = entry({"admin","services","softwarecenter"},cbi("softwarecenter"),_("Software Center"))
	page.i18n="softwarecenter"
	page.dependent=true
	
	entry({"admin","services","softwarecenter","status"}, call("connection_status"))
end

local function nginx_status_report()
	return luci.sys.call("pidof nginx > /dev/null") == 0
end

local function mysql_status_report()
	return luci.sys.call("pidof mysqld > /dev/null") == 0
end

local function php_status_report()
	return luci.sys.call("pidof php-fpm > /dev/null") == 0
end

local function nginx_installed_report()
	return luci.sys.call("ls /opt/etc/init.d/S80nginx > /dev/null") == 0
end

local function mysql_installed_report()
	return luci.sys.call("ls /opt/etc/init.d/S70mysqld > /dev/null") == 0
end

local function php_install_report()
	return luci.sys.call("ls /opt/etc/init.d/S79php7-fpm > /dev/null") == 0
end 

local function get_website_list()
	return luci.sys.exec("sh /usr/bin/softwarecenter/website_list_for_luci.sh 1")
end

local function get_website_list_size()
	return luci.sys.exec("sh /usr/bin/softwarecenter/website_list_for_luci.sh")
end

function connection_status()
  luci.http.prepare_content("application/json")
  luci.http.write_json({nginx_state=nginx_status_report(),
  mysql_state=mysql_status_report(),
  php_state=php_status_report(),
  nginx_installed=nginx_installed_report(),
  mysql_installed=mysql_installed_report(),
  php_installed=php_install_report(),
  website_list_size=get_website_list_size(),
  website_list=get_website_list()
  })
end
