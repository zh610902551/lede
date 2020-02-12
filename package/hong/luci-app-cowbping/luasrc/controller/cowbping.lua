module("luci.controller.cowbping", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/cowbping") then return end

    entry({"admin", "network", "cowbping"}, cbi("cowbping"), _("CowBPing"), 90).dependent = true
end
