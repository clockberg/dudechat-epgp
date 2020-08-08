local _, addon = ...

addon.data = addon.data or {}
addon.data.default_options = {
	["ItemTooltip.show"] = true,
	["ItemDistribute.x"] = 200,
	["ItemDistribute.y"] = -200,
	["ItemDistribute.lock"] = false,
	["ItemDistribute.announce_raid_warning"] = false,
	["ItemDistribute.default_price"] = 1,
}
