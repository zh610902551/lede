local e=require"nixio.fs"
local t=require"luci.sys"
local t=luci.model.uci.cursor()
m=Map("advanced",translate("高级设置"),translate("<br /><font color=\"Red\"><strong>配置文档是直接编辑的！除非你知道自己在干什么，否则请不要轻易修改这些配置文档。配置不正确可能会导致不能开机等错误。</strong></font><br/>"))
m.apply_on_parse=true
s=m:section(TypedSection,"advanced")
s.anonymous=true
s:tab("base",translate("Basic Settings"))
o=s:taboption("base",Flag,"usb3_disable",translate("关闭USB3.0"),translate("勾选以关闭USB3.0，降低2.4G无线干扰。"))
o.default=0
if(luci.sys.call("cat /etc/openwrt_release | grep DISTRIB_TARGET | grep -w ramips/mt7621 >/dev/null")==0)then
o=s:taboption("base",ListValue,"lan2wan",translate("LAN改WAN"),translate("选择将其中一个LAN口改设为WAN口，以使用多线接入。"))
o:value("none",translate("当前模式"))
o:value("1",translate("LAN1"))
o:value("0",translate("LAN2"))
o:value("2",translate("LAN3"))
o:value("factory",translate("默认状态"))
o.default="none"
end
rollbacktime=t:get("luci","apply","rollback")
o=s:taboption("base",Value,"rollback",translate("超时时间"),translate("设置LUCI超时回滚时间，默认30秒。"))
o.datatypes="and(uinteger,min(20))"
o.default=rollbacktime
o=s:taboption("base",ListValue,"webshell",translate("WebShell"),translate("Choose Which WebShell Service to Use"))
o:value("ttyd",translate("ttyd"))
o:value("shellinabox",translate("shellinabox"))
o.default="shellinabox"
o=s:taboption("base",ListValue,"route_mode",translate("运行模式"),translate("AP模式：请通过WAN网口连接，AP自身管理地址由上级路由DHCP分配，如需固定请修改LAN口地址。<br>并闭AP模式请选回“路由模式”。两种模式均为一次性动作，切换完成之后运行模式将自动显示为“当前模式。"))
o.default="none"
o:value("none",translate("当前模式"))
o:value("apmode",translate("AP模式"))
o:value("dhcpmode",translate("路由模式"))
if nixio.fs.access("/etc/config/network")then
s:tab("netwrokconf",translate("配置网络"),translate("本页是配置/etc/config/network的文档内容。应用保存后自动重启生效"))
o=s:taboption("netwrokconf",Button,"_nrestart")
o.inputtitle=translate("重启网络")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/network restart >/dev/null")
end
conf=s:taboption("netwrokconf",Value,"netwrokconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/network")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/network",t)
if(luci.sys.call("cmp -s /tmp/network /etc/config/network")==1)then
e.writefile("/etc/config/network",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/network")
end
end
end
if nixio.fs.access("/etc/dnsmasq.conf")then
s:tab("dnsmasqconf",translate("配置dnsmasq"),translate("本页是配置/etc/dnsmasq.conf的文档内容。编辑后点击重启按钮后生效"))

o=s:taboption("dnsmasqconf",Button,"_drestart")
o.inputtitle=translate("重启dnsmasq")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/dnsmasq restart >/dev/null")
end

conf=s:taboption("dnsmasqconf",Value,"dnsmasqeditconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/dnsmasq.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dnsmasq.conf",t)
if(luci.sys.call("cmp -s /tmp/dnsmasq.conf /etc/dnsmasq.conf")==1)then
e.writefile("/etc/dnsmasq.conf",t)
end
e.remove("/tmp/dnsmasq.conf")
end
end
end
if nixio.fs.access("/etc/config/wireless")then
s:tab("wifidogconf",translate("配置无线网络"),translate("本页是配置/etc/config/wireless的文档内容。应用保存后自动重启生效"))
conf=s:taboption("wifidogconf",Value,"wifidogconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/wireless")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/wireless",t)
if(luci.sys.call("cmp -s /tmp/wireless /etc/config/wireless")==1)then
e.writefile("/etc/config/wireless",t)
end
e.remove("/tmp/wireless")
end
end
end
if nixio.fs.access("/etc/config/dhcp")then
s:tab("dhcpconf",translate("配置DHCP"),translate("本页是配置/etc/config/DHCP的文档内容。应用保存后自动重启生效"))
o=s:taboption("dhcpconf",Button,"_dhrestart")
o.inputtitle=translate("重启网络")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/network restart >/dev/null")
end
conf=s:taboption("dhcpconf",Value,"dhcpconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/dhcp")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/dhcp",t)
if(luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp")==1)then
e.writefile("/etc/config/dhcp",t)
luci.sys.call("/etc/init.d/network restart >/dev/null")
end
e.remove("/tmp/dhcp")
end
end
end
if nixio.fs.access("/etc/config/mwan3")then
s:tab("mwan3conf",translate("配置mwan3"),translate("本页是配置/etc/config/mwan3的文档内容。编辑后点击重启按钮后生效"))
o=s:taboption("mwan3conf",Button,"_mwan3restart")
o.inputtitle=translate("重启mwan3")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/mwan3 restart >/dev/null")
end
conf=s:taboption("mwan3conf",Value,"mwan3conf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/mwan3")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/mwan3",t)
if(luci.sys.call("cmp -s /tmp/mwan3 /etc/config/mwan3")==1)then
e.writefile("/etc/config/mwan3",t)
end
e.remove("/tmp/mwan3")
end
end
end
if nixio.fs.access("/etc/hosts")then
s:tab("hostsconf",translate("配置hosts"),translate("本页是配置/etc/hosts的文档内容。应用保存后自动重启生效"))
o=s:taboption("hostsconf",Button,"_hrestart")
o.inputtitle=translate("重启dnsmasq")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/dnsmasq restart >/dev/null")
end
conf=s:taboption("hostsconf",Value,"hostsconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/hosts")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/hosts.tmp",t)
if(luci.sys.call("cmp -s /tmp/hosts.tmp /etc/hosts")==1)then
e.writefile("/etc/hosts",t)
luci.sys.call("/etc/init.d/dnsmasq restart >/dev/null")
end
e.remove("/tmp/hosts.tmp")
end
end
end
if nixio.fs.access("/etc/config/firewall")then
s:tab("firewallconf",translate("配置防火墙"),translate("本页是配置/etc/config/firewall的文档内容。应用保存后自动重启生效"))
o=s:taboption("firewallconf",Button,"_frestart")
o.inputtitle=translate("重启防火墙")
o.inputstyle="apply"
function o.write(e,e)
luci.sys.exec("/etc/init.d/firewall restart >/dev/null")
end
conf=s:taboption("firewallconf",Value,"firewallconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/config/firewall")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/firewall",t)
if(luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall")==1)then
e.writefile("/etc/config/firewall",t)
luci.sys.call("/etc/init.d/firewall restart >/dev/null")
end
e.remove("/tmp/firewall")
end
end
end
if nixio.fs.access("/etc/pcap-dnsproxy/Config.conf")then
s:tab("pcapconf",translate("配置pcap-dnsproxy"),translate("本页是配置/etc/pcap-dnsproxy/Config.conf的文档内容。应用保存后自动重启生效"))
conf=s:taboption("pcapconf",Value,"pcapconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/pcap-dnsproxy/Config.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/Config.conf",t)
if(luci.sys.call("cmp -s /tmp/Config.conf /etc/pcap-dnsproxy/Config.conf")==1)then
e.writefile("/etc/pcap-dnsproxy/Config.conf",t)
luci.sys.call("/etc/init.d/pcap-dnsproxy restart >/dev/null")
end
e.remove("/tmp/Config.conf")
end
end
end
if nixio.fs.access("/etc/wifidog.conf")then
s:tab("wifidogconf",translate("配置wifidog"),translate("本页是配置/etc/wifidog.conf的文档内容。应用保存后自动重启生效"))
conf=s:taboption("wifidogconf",Value,"wifidogconf",nil,translate("开头的数字符号（＃）或分号的每一行（;）被视为注释；删除（;）启用指定选项。"))
conf.template="cbi/tvalue"
conf.rows=50
conf.wrap="off"
conf.cfgvalue=function(t,t)
return e.readfile("/etc/wifidog.conf")or""
end
conf.write=function(a,a,t)
if t then
t=t:gsub("\r\n?","\n")
e.writefile("/tmp/wifidog.conf",t)
if(luci.sys.call("cmp -s /tmp/wifidog.conf /etc/wifidog.conf")==1)then
e.writefile("/etc/wifidog.conf",t)
end
e.remove("/tmp/wifidog.conf")
end
end
end
if nixio.fs.access("/bin/nuc")then
s:tab("mode",translate("模式切换(适用软路由）"),translate("<br />可以在这里切换NUC和正常模式，重置你的网络设置。<br /><font color=\"Red\"><strong>点击后会立即重启设备，没有确认过程，请谨慎操作！</strong></font><br/>"))
o=s:taboption("mode",Button,"nucmode",translate("切换为NUC模式"),"<strong><font color=\"green\">本模式适合于单网口主机，如NUC、单网口电脑，需要配合VLAN交换机使用！<br />设置教程：</font><a style=\"color: #ff0000;\" href=\"http://koolshare.cn/forum.php?mod=viewthread&tid=63503\">跳转链接到Koolshare论坛教程贴</a></strong>")
o.inputtitle=translate("NUC模式")
o.inputstyle="reload"
o.write=function()
luci.sys.call("/bin/nuc")
end
o=s:taboption("mode",Button,"normalmode",translate("切换成正常模式"),"<strong><font color=\"green\">本模式适合于有两个网口或以上的设备使用，如多网口软路由或者虚拟了两个以上网口的虚拟机使用！</font></strong>")
o.inputtitle=translate("正常模式")
o.inputstyle="reload"
o.write=function()
luci.sys.call("/bin/normalmode")
end
end
return m
