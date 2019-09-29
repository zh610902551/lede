--[[
Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)

This is free software, licensed under the GNU General Public License v3.
]]--

require("luci.sys")
require("luci.util")
--得到Map对象，并初始化。参一：指定cbi文件，参二：设置标题，参三：设置标题下的注释
m=Map("softwarecenter",translate("Software Center"),translate("The software center is designed for the automated and unified configuration of software applications. It provides us with a simple and friendly interactive interface, which aims to make the configuration process easier and simpler!"))
--各个软件的状态
m:section(SimpleSection).template="software_status"

s=m:section(TypedSection,"softwarecenter",translate("Software Center Settings"))
s.addremove=false
s.anonymous=true

s:tab("entware",translate("Entware Settings"))
nginx_tab=s:tab("nginx",translate("Nginx Settings"))
mysql_tab=s:tab("mysql",translate("MySQL Settings"))

deploy_entware=s:taboption("entware",Flag,"deploy_entware",translate("Deploy Entware"),translate("This is a software repository for network attached storages, routers and other embedded devices.Browse through 2000+ packages for different platforms."))
cpu_architecture=s:taboption("entware",ListValue,"cpu_architecture",translate("CPU architecture"),translate("You must select a right cpu architecture!<br>wrong cpu architecture will cause the installation failed"))
cpu_architecture:value("mipsel","mipsel")
cpu_architecture:value("mips","mips")
cpu_architecture:value("armv7","armv7")
cpu_architecture:depends("deploy_entware",1)
entware_disk_mount=s:taboption("entware",ListValue,"entware_disk_mount",translate("Entware install path"),translate("The select mount point will be reformat to ext4 filesystem,make sure that certain software can running normally<br>Warning: If select disk filesystem is not ext4,the disk will be reformat,please make sure there are no important data on the disk or make sure the disk's filesystem already is ext4"))
for _, list_disk_mount in luci.util.vspairs(luci.util.split(luci.sys.exec("mount | awk '{print $3}' | grep mnt"))) do
	if(string.len(list_disk_mount) > 0)
	then
		entware_disk_mount:value(list_disk_mount)
	end
end
entware_disk_mount:depends("deploy_entware",1)
entware_enable=s:taboption("entware",Flag,"entware_enable",translate("Enabled"),translate("You must enable this option,otherwise the nginx and mysql settings will not be available"))
entware_enable:depends("deploy_entware",1)
deploy_nginx=s:taboption("entware",Flag,"deploy_nginx",translate("Deploy Nginx"),translate("If enabled,it will auto deploy the Nginx server and the php7 environment from the Entware software source<br>the installation process will cost lots of time,but when it finish installation and installed sucessful,you can see the server runing status in this page"))
deploy_nginx:depends("entware_enable",1)
deploy_mysql=s:taboption("entware",Flag,"deploy_mysql",translate("Deploy MySQL"),translate("If enabled,it will auto deploy the MySQL server from the Entware software source<br>the installation process will cost lots of time,but when it finish installation and installed sucessful,you can see the server runing status in this page"))
deploy_mysql:depends("entware_enable",1)

nginx_enable=s:taboption("nginx",Flag,"nginx_enabled",translate("Enabled"))
nginx_enable:depends("deploy_nginx",1)

mysql_enable=s:taboption("mysql",Flag,"mysql_enabled",translate("Enabled"),translate("First runing,the default user is 'root' and password is '123456'"))
mysql_enable:depends("deploy_mysql",1)

website_section=m:section(TypedSection,"website",translate("Website Manager"))
website_section.addremove=true
website_enabled=website_section:option(Flag,"website_enabled",translate("Enabled"),translate("Make sure that Nginx has installed and running!<br>Some website need the database server"))
autodeploy_enable=website_section:option(Flag,"autodeploy_enable",translate("Enable website auto deploy"))
autodeploy_enable:depends("customdeploy_enabled",0)
website_select=website_section:option(ListValue,"website_select",translate("website"),translate("Select you website to deploy!"))
website_select:value("0","tz（雅黑PHP探针）")
website_select:value("1","phpMyAdmin（数据库管理工具）")
website_select:value("2","WordPress（使用最广泛的CMS）")
website_select:value("3","Owncloud（经典的私有云）")
website_select:value("4","Nextcloud（Owncloud团队的新作，美观强大的个人云盘）")
website_select:value("5","h5ai（优秀的文件目录）")
website_select:value("6","Lychee（一个很好看，易于使用的Web相册）")
website_select:value("7","Kodexplorer（可道云aka芒果云在线文档管理器）")
website_select:value("8","Typecho (流畅的轻量级开源博客程序)")
website_select:value("9","Z-Blog (体积小，速度快的PHP博客程序)")
website_select:value("10","DzzOffice (开源办公平台)")
website_select:depends("autodeploy_enable",1)
redis_enabled=website_section:option(Flag,"redis_enabled",translate("Enable Redis"),translate("Only Owncloud and Nextcloud can use"))
redis_enabled:depends("website_select","3")
redis_enabled:depends("website_select","4")
customdeploy_enabled=website_section:option(Flag,"customdeploy_enabled",translate("Enable website custom deploy"))
customdeploy_enabled:depends("autodeploy_enable",0)
website_dir=website_section:option(Value,"website_dir",translate("Website dir name"),translate("This is your custom website dir name, this dir must be put in USB_DEVICE/opt/wwwroot/<br>The USB_DEVICE is the root path in you usb device, like /mnt/sda"))
website_dir:depends("customdeploy_enabled",1)
port=website_section:option(Value,"port",translate("Port number"),translate("Website access port,this option must be set and make sure the port number uniquely!"))
port.rmempty=false
return m
