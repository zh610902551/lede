module("luci.controller.cpulimit",package.seeall)
function index()
require("luci.i18n")
luci.i18n.loadc("cpulimit")
if not nixio.fs.access("/etc/config/cpulimit")then
return
end
local e=entry({"admin","system","cpulimit"},cbi("cpulimit"),luci.i18n.translate("cpulimit"),65)
e.i18n="cpulimit"
e.dependent=true
end