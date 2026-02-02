local ls = require "luasnip"

local s = ls.snippet
local f = ls.function_node
local t = ls.text_node

math.randomseed(tonumber(tostring(vim.loop.hrtime()):sub(-9)))

local function random_color()
	local r = math.random(0, 255)
	local g = math.random(0, 255)
	local b = math.random(0, 255)
	-- Keep alpha at 0x00 to match your example: 0x00_rr_gg_bb
	return string.format("0x00_%02x_%02x_%02x", r, g, b)
end

-- ZTRACY zone
ls.add_snippets("zig", {
	s("zone", {
		t('const zone = @import("ztracy").ZoneNC(@src(), @src().file ++ "|" ++ @src().fn_name, '),
		f(function() return random_color() end),
		t({ ");", "defer zone.End();", "" }),
	}),
})
