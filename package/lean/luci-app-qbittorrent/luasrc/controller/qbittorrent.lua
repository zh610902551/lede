module("luci.controller.qbittorrent",package.seeall)

function index()
  if not nixio.fs.access("/etc/config/qbittorrent")then
    return
  end
  entry({"admin","nas","qbittorrent"},cbi("qbittorrent"),_("qbittorrent"))
  entry({"admin","nas","qbittorrent","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep qbittorrent-nox >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end