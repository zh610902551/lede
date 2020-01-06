module("luci.controller.wobl", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/wobl") then return end

    entry({"admin", "control"}, firstchild(), "Control", 50).dependent = false
    entry({"admin", "control", "wobl"}, cbi("wobl"), _("名单控制"), 11).dependent = true
end
