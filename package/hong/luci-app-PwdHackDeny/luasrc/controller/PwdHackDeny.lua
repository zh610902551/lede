module("luci.controller.PwdHackDeny", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/PwdHackDeny") then return end

    entry({"admin", "control"}, firstchild(), "Control", 50).dependent = false
    entry({"admin", "control", "PwdHackDeny"}, cbi("PwdHackDeny"), _("异常登录拒绝"), 50).dependent = true
end
