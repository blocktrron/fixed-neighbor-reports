#!/usr/bin/lua

local uci = require 'uci'.cursor()
local ubus = require('ubus').connect()

local neighbor_reports = {}

function hasKey(tab, key)
	for k, v in pairs(tab) do
		if k == key then return true end
	end
	return false
end

uci:foreach('static-neighbor-report', 'neighbor', function (config)
	if hasKey(config, "disabled") and config.disabled ~= '0' then
		return
	end

	if not hasKey(neighbor_reports, config["iface"]) then
		neighbor_reports[config["iface"]] = {}
	end

	table.insert(neighbor_reports[config["iface"]], {config["bssid"], config["ssid"], config["neighbor_report"]})
end)

for k, v in pairs(neighbor_reports) do
	ubus:call('hostapd.' .. k, 'rrm_nr_set', {list=v})
end
