local M = require("lualine.component"):extend()

local default_options = {
	--- Number of tag slots to display
	number_of_tags = 4,
	--- Override highlight groups via config.
	--- Keys are: Bracket, BracketActive, Index, IndexActive, Name, NameActive.
	--- Values are either a highlight group name (string) or a highlight
	--- definition table (same as nvim_set_hl opts).
	---@type table<string, string|vim.api.keyset.highlight>|nil
	colors = nil,
}

local hl_prefix = "LualineGrapple"

local hl_keys = {
	"Bracket",
	"BracketActive",
	"Index",
	"IndexActive",
	"Name",
	"NameActive",
}

---Get the foreground color (as integer) from a highlight group
---@param name string
---@return integer|nil
local function get_fg(name)
	return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
end

---Get the background color (as integer) from a highlight group
---@param name string
---@return integer|nil
local function get_bg(name)
	return vim.api.nvim_get_hl(0, { name = name, link = false }).bg
end

---Set up default highlight groups. Uses `default = true` so that themes
---or users can override any of these by defining the same group themselves.
local function setup_default_highlights()
	local bracket_fg = get_fg("Punctuation")
	local index_fg = get_fg("Number")
	local name_inactive_bg = get_bg("lualine_c_normal")
	local name_active_bg = get_bg("Folded")

	-- Inactive state
	vim.api.nvim_set_hl(0, hl_prefix .. "Bracket", { fg = bracket_fg, bg = name_inactive_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "Index", { fg = index_fg, bg = name_inactive_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "Name", { link = "lualine_c_normal", default = true })

	-- Active state
	vim.api.nvim_set_hl(0, hl_prefix .. "BracketActive", { fg = bracket_fg, bg = name_active_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "IndexActive", { fg = index_fg, bg = name_active_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "NameActive", { link = "Folded", default = true })
end

---Apply user-supplied color overrides from the `colors` config option.
---These are set without `default = true`, so they take priority over
---theme-defined and default highlights.
---@param colors table<string, vim.api.keyset.highlight>
local function apply_color_overrides(colors)
	for _, key in ipairs(hl_keys) do
		local value = colors[key]
		if value then
			if type(value) == "string" then
				vim.api.nvim_set_hl(0, hl_prefix .. key, { link = value })
			else
				vim.api.nvim_set_hl(0, hl_prefix .. key, value)
			end
		end
	end
end

function M:init(options)
	M.super.init(self, options)
	self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
	setup_default_highlights()
	if self.options.colors then
		apply_color_overrides(self.options.colors)
	end

	-- Refresh lualine immediately when grapple tags change so the statusline
	-- updates without waiting for the next CursorMoved/ModeChanged event.
	vim.api.nvim_create_autocmd("User", {
		pattern = "GrappleUpdate",
		callback = function()
			require("lualine").refresh()
		end,
	})
end

end

function M:update_status()
	local ok, grapple = pcall(require, "grapple")
	if not ok then
		return ""
	end

	local current_path = vim.api.nvim_buf_get_name(0)
	local parts = {}

	for i = 1, self.options.number_of_tags do
		if grapple.exists({ index = i }) then
			local tag = grapple.find({ index = i })
			local name = vim.fn.fnamemodify(tag.path, ":t")
			local is_active = tag.path == current_path
			local suffix = is_active and "Active" or ""

			local text = "%#" .. hl_prefix .. "Bracket"
				.. suffix
				.. "#["
				.. "%#" .. hl_prefix .. "Index"
				.. suffix
				.. "#"
				.. i
				.. "%#" .. hl_prefix .. "Bracket"
				.. suffix
				.. "#]"
				.. "%#" .. hl_prefix .. "Name"
				.. suffix
				.. "#"
				.. " "
				.. name

			parts[#parts + 1] = text
		end
	end

	return table.concat(parts, " ")
end

return M
