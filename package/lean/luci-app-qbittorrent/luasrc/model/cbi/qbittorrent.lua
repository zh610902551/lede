local a,t,e
local o=luci.util.trim(luci.sys.exec("HOME=/tmp qbittorrent-nox -v | awk '{print $2}'"))
function titlesplit(e)
return"<p style=\"font-size:20px;font-weight:bold;color: DodgerBlue\">"..translate(e).."</p>"
end
a=Map("qbittorrent",translate("qBittorrent"),"%s <br\> %s"%{translate("一个基于QT的跨平台的开源BitTorrent客户端。"
.."<a href='https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent'  target='_blank'>(更多信息)</a>"),
"<b style=\"color:green\">"..translatef("当前qBittorrent版本:  %s.",o).."</b>"})
a:append(Template("qbittorrent/qbt_status"))
t=a:section(NamedSection,"main","qbittorrent")
t:tab("basic",translate("Basic Settings"))
e=t:taboption("basic",Flag,"enabled",translate("Enabled"))
e.default="1"
e=t:taboption("basic",ListValue,"user",translate("用户组"))
local o
for t in luci.util.execi("cat /etc/passwd | cut -d ':' -f1")do
e:value(t)
end
e=t:taboption("basic",Value,"profile",translate("配置保存路径"),translate("使用命令存储配置文件文件夹的路径。例如：<code>/etc/config</code>"))
e.default='/tmp'
e=t:taboption("basic",Value,"configuration",translate("配置目录后缀"),translate("配置文件目录的后缀。例如 <b>qBittorrent_[NAME]</b>"))
e=t:taboption("basic",Value,"Locale",translate("WebUI界面语言"))
e:value("en",translate("英文"))
e:value("zh",translate("中文"))
e.default="zh"
e=t:taboption("basic",Flag,"Enabled",translate("启用日志"),translate("启用日志文件存储。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("basic",Value,"Path",translate("日志文件"),translate("日志文件存储的路径。例如：<code>/etc/config</code>"))
e:depends("Enabled","true")
e=t:taboption("basic",Flag,"Backup",translate("启用日志备份"),translate("当备份文件超出给定大小时。"))
e:depends("Enabled","true")
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("basic",Flag,"DeleteOld",translate("删除旧备份"),translate("删除旧的日志文件。"))
e:depends("Enabled","true")
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("basic",Value,"MaxSizeBytes",translate("日志最大大小"),translate("日志文件的最大大小（单位：字节）。"))
e:depends("Enabled","true")
e.placeholder="66560"
e=t:taboption("basic",Value,"SaveTime",translate("日志保存期限"),translate("到设定时间后日志文件将删除。1d-1天，1m-1个月，1y-1年。"))
e:depends("Enabled","true")
e.datatype="string"

t:tab("connection",translate("连接设置"))
e=t:taboption("connection",Flag,"UPnP",translate("端口自动转发"),translate("使用路由器的UPnP/NAT-PMP端口自动转发。"
.."<a href='https://en.wikipedia.org/wiki/Port_forwarding' target='_blank'>(更多信息)</a>"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("connection",Flag,"UseRandomPort",translate("使用随机端口"),translate("在每次启动时使用不同的端口。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("connection",Value,"PortRangeMin",translate("连接端口"),translate("随机生成"),translate("全局下载速度限制(单位 KiB/s)，0为无限制。"))
e:depends("UseRandomPort",false)
e.placeholder="8999"
e.datatype="range(1024,65535)"
e.template="qbittorrent/qbt_value"
e.btnclick="randomToken();"
e=t:taboption("connection",Value,"GlobalDLLimit",translate("全局下载限制"),translate("全局下载速度限制(单位 KiB/s)，0为无限制。"))
e.datatype="float"
e.placeholder="0"
e=t:taboption("connection",Value,"GlobalUPLimit",translate("全局上传限制"),translate("全局上传速度限制(单位 KiB/s)，0为无限制。"))
e.datatype="float"
e.placeholder="0"
e=t:taboption("connection",Value,"GlobalDLLimitAlt",translate("备用下载限制"),translate("备用下载速度限制(单位 KiB/s)，0为无限制。"))
e.datatype="float"
e.placeholder="10"
e=t:taboption("connection",Value,"GlobalUPLimitAlt",translate("备用上传限制"),translate("备用上传速度限制(单位 KiB/s)，0为无限制。"))
e.datatype="float"
e.placeholder="10"
e=t:taboption("connection",ListValue,"BTProtocol",translate("启用的协议"),translate("已启用的协议。"))
e:value("Both",translate("TCP和UTP"))
e:value("TCP",translate("TCP"))
e:value("UTP",translate("UTP"))
e.default="Both"
e=t:taboption("connection",Value,"InetAddress",translate("输入地址"),translate("响应跟踪器的地址。"))

t:tab("downloads",translate("下载设置"))
e=t:taboption("downloads",DummyValue,"Saving Management",titlesplit("当添加种子时"))
e=t:taboption("downloads",Flag,"CreateTorrentSubfolder",translate("创建目录"),translate("为含多个文件的种子创建子文件夹。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("downloads",Flag,"StartInPause",translate("开始暂停"),translate("添加种子后不要马上开始下载文件。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("downloads",Flag,"AutoDeleteAddedTorrentFile",translate("删除种子"),translate("下载完成后自动删除这个种子文件。"))
e.enabled="IfAdded"
e.disabled="Never"
e.default=e.disabled
e=t:taboption("downloads",Flag,"PreAllocation",translate("磁盘分配"),translate("为刚添加的文件预分配磁盘空间。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("downloads",Flag,"UseIncompleteExtension",translate("使用扩展名"),translate("为不完整的文件添加后缀名<code>!qB</code>"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("downloads",Value,"SavePath",translate("文件保存路径"),translate("默认下载文件的保存路径。例如：<code>/mnt/sda1/download</code>"))
e.placeholder="/tmp/download"
e=t:taboption("downloads",Flag,"TempPathEnabled",translate("启用临时目录"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("downloads",Value,"TempPath",translate("临时路径"),translate("可以设置绝对和相对路径。"))
e:depends("TempPathEnabled","true")
e.placeholder="temp/"
e=t:taboption("downloads",Value,"DiskWriteCacheSize",translate("磁盘缓存"),translate("数值1是自动的，0是禁用的。默认设置为64MiB。"))
e.datatype="integer"
e.placeholder="64"
e=t:taboption("downloads",Value,"DiskWriteCacheTTL",translate("磁盘缓存TTL"),translate("默认设置为60秒。"))
e.datatype="integer"
e.placeholder="60"
e=t:taboption("downloads",DummyValue,"Saving Management",titlesplit("保存管理"))
e=t:taboption("downloads",ListValue,"DisableAutoTMMByDefault",translate("默认种子管理模式"))
e:value("true",translate("手动"))
e:value("false",translate("自动"))
e.default="true"
e=t:taboption("downloads",ListValue,"CategoryChanged",translate("当种子分类修改时"),translate("选择种子类别更改时的操作。"))
e:value("true",translate("将种子切换到手动模式"))
e:value("false",translate("重新定位种子"))
e.default="false"
e=t:taboption("downloads",ListValue,"DefaultSavePathChanged",translate("当默认保存路径修改时"),translate("选择默认保存路径更改时的操作。"))
e:value("true",translate("将受影响的种子切换到手动模式"))
e:value("false",translate("重新定位种子"))
e.default="true"
e=t:taboption("downloads",ListValue,"CategorySavePathChanged",translate("当分类保存路径修改时"),translate("选择分类保存路径更改时的操作。"))
e:value("true",translate("将受影响的种子切换到手动模式"))
e:value("false",translate("重新定位种子"))
e.default="true"
e=t:taboption("downloads",Value,"TorrentExportDir",translate("种子导出目录"),translate("种子文件将被复制到目标目录。例如：<code>/etc/config</code>"))
e=t:taboption("downloads",Value,"FinishedTorrentExportDir",translate("复制种子文件"),translate("将已下载完成的种子文件复制到目标目录。例如：<code>/etc/config</code>"))

t:tab("bittorrent",translate("BT设置"))
e=t:taboption("bittorrent",Flag,"DHT",translate("启用DHT"),translate("启用DHT(去中心化网络) 以找到更多用户。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("bittorrent",Flag,"PeX",translate("启用PeX"),translate("启用用户交换(PeX)以找到更多用户。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("bittorrent",Flag,"LSD",translate("启用LSD"),translate("启用本地用户发现以找到更多用户。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("bittorrent",Flag,"uTP_rate_limited",translate("uTP速率限制"),translate("对µTP协议进行速度限制。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("bittorrent",ListValue,"Encryption",translate("加密模式"),translate("使DHT（分散网络）能够找到更多的对等点。"))
e:value("0",translate("偏好加密"))
e:value("1",translate("强制加密"))
e:value("2",translate("禁用加密"))
e.default="0"
e=t:taboption("bittorrent",Value,"MaxConnecs",translate("连接数限制"),translate("全局最大连接数。"))
e.datatype="integer"
e.placeholder="500"
e=t:taboption("bittorrent",Value,"MaxConnecsPerTorrent",translate("种子连接数限制"),translate("每个种子的最大连接数。"))
e.datatype="integer"
e.placeholder="100"
e=t:taboption("bittorrent",Value,"MaxUploads",translate("最大上传数"),translate("全局最大上传线程数。"))
e.datatype="integer"
e.placeholder="8"
e=t:taboption("bittorrent",Value,"MaxUploadsPerTorrent",translate("种子上传限制"),translate("每个种子上传线程最大值。"))
e.datatype="integer"
e.placeholder="4"
e=t:taboption("bittorrent",DummyValue,"Saving Management",titlesplit("分享率限制"))
e=t:taboption("bittorrent",Value,"MaxRatio",translate("最大的分享率"),translate("分享的最大比例设定。-1是禁用做种。"))
e.datatype="float"
e.placeholder="-1"
e=t:taboption("bittorrent",Value,"GlobalMaxSeedingMinutes",translate("最大做种时间"),translate("做种最大比例设定。单位：分钟"))
e.datatype="integer"
e=t:taboption("bittorrent",ListValue,"MaxRatioAction",translate("达到后"),translate("达到设定分享率和时间后的动作。"))
e:value("0",translate("暂停"))
e:value("1",translate("删除"))
e.defaule="0"
e=t:taboption("bittorrent",DummyValue,"Queueing Setting",titlesplit("种子排队设置"))
e=t:taboption("bittorrent",Flag,"QueueingEnabled",translate("启用种子排队"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("bittorrent",Value,"MaxActiveDownloads",translate("最大活动的下载数"))
e.datatype="integer"
e.placeholder="3"
e=t:taboption("bittorrent",Value,"MaxActiveUploads",translate("最大活动的上传数"))
e.datatype="integer"
e.placeholder="3"
e=t:taboption("bittorrent",Value,"MaxActiveTorrents",translate("最大活动的种子数"))
e.datatype="integer"
e.placeholder="5"
e=t:taboption("bittorrent",Flag,"IgnoreSlowTorrents",translate("忽略慢速的种子"),translate("慢速种子不计入限制内。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("bittorrent",Value,"SlowTorrentsDownloadRate",translate("下载速度阈值"),translate("单位：KiB/s"))
e.datatype="integer"
e.placeholder="2"
e=t:taboption("bittorrent",Value,"SlowTorrentsUploadRate",translate("上传速度阈值"),translate("单位：KiB/s"))
e.datatype="integer"
e.placeholder="2"
e=t:taboption("bittorrent",Value,"SlowTorrentsInactivityTimer",translate("种子不活动时间"),translate("单位：分钟"))
e.datatype="integer"
e.placeholder="60"

t:tab("webgui",translate("WebUI设置"))
e=t:taboption("webgui",Value,"Username",translate("WebUI登录名"),translate("WebUI的登录名设置。"))
e.placeholder="admin"
e=t:taboption("webgui",Value,"Password",translate("WebUI密码"),translate("WebUI的登录密码设置。"))
e.password=true
e=t:taboption("webgui",Value,"Port",translate("WebUI端口"),translate("WebUI的侦听端口设置，默认：8080。"))
e.datatype="port"
e.placeholder="8080"
e=t:taboption("webgui",Flag,"UseUPnP",translate("WebUI用UPnP"),translate("使用路由器的UPnP/NAT-PMP端口连接到WebUI。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("webgui",Flag,"HostHeaderValidation",translate("主机标头验证"),translate("启用主机标头验证"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("webgui",Flag,"LocalHostAuth",translate("本地主机认证"),translate("对本地主机上的客户端跳过身份验证。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("webgui",Flag,"AuthSubnetWhitelistEnabled",translate("启用IP子网白名单"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("webgui",DynamicList,"AuthSubnetWhitelist",translate("IP子网白名单"),translate("对IP子网白名单中的客户端跳过身份验证。"))
e:depends("AuthSubnetWhitelistEnabled","true")
e=t:taboption("webgui",Flag,"CSRFProtection",translate("CSRF保护"),translate("启用跨站点请求伪造(CSRF)保护。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("webgui",Flag,"ClickjackingProtection",translate("劫持保护"),translate("启用“点击劫持”保护。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled


t:tab("log",translate("日志显示"))
e=t:taboption("log",TextValue,"SuperSeeding"),TextValue("")
e.description = translate("当前qBittorrent运行状态。")


t:tab("advanced",translate("高级设置"))
e=t:taboption("advanced",Flag,"AnonymousMode",translate("匿名模式"),translate("启用后，将采取某些措施来掩盖其身份。<a href='https://github.com/qbittorrent/qBittorrent/wiki/Anonymous-Mode'  target='_blank'>(更多信息)</a>"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("advanced",Flag,"SuperSeeding",translate("超级种子"),translate("超级种子模式。"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("advanced",Flag,"IncludeOverhead",translate("开销限制"),translate("对传送总开销进行速度限制"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("advanced",Flag,"IgnoreLimitsLAN",translate("LAN限制"),translate("忽略对LAN的速度限制。"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("advanced",Flag,"osCache",translate("使用缓存"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
e=t:taboption("advanced",Value,"OutgoingPortsMax",translate("Max Outgoing Port"),translate("The max outgoing port."))
e.datatype="port"
e=t:taboption("advanced",Value,"OutgoingPortsMin",translate("Min Outgoing Port"),translate("The min outgoing port."))
e.datatype="port"
e=t:taboption("advanced",ListValue,"SeedChokingAlgorithm",translate("Choking Algorithm"),translate("The strategy of choking algorithm."))
e:value("RoundRobin",translate("Round Robin"))
e:value("FastestUpload",translate("Fastest Upload"))
e:value("AntiLeech",translate("Anti-Leech"))
e.default="FastestUpload"
e=t:taboption("advanced",Flag,"AnnounceToAllTrackers",translate("Announce To All Trackers"))
e.enabled="true"
e.disabled="false"
e.default=e.disabled
e=t:taboption("advanced",Flag,"AnnounceToAllTiers",translate("Announce To All Tiers"))
e.enabled="true"
e.disabled="false"
e.default=e.enabled
return a
