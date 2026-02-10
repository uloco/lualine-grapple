local M = require("lualine.component"):extend()

local default_options = {
	--- Number of tag slots to display
	number_of_tags = 4,
	--- Override highlight groups via config.
	--- Keys are: Bracket, BracketActive, Index, IndexActive, Name, NameActive, Path, PathActive.
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
	"Path",
	"PathActive",
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

	local muted_fg = get_fg("Comment")

	-- Inactive state
	vim.api.nvim_set_hl(0, hl_prefix .. "Bracket", { fg = bracket_fg, bg = name_inactive_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "Index", { fg = index_fg, bg = name_inactive_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "Name", { link = "lualine_c_normal", default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "Path", { fg = muted_fg, bg = name_inactive_bg, default = true })

	-- Active state
	vim.api.nvim_set_hl(0, hl_prefix .. "BracketActive", { fg = bracket_fg, bg = name_active_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "IndexActive", { fg = index_fg, bg = name_active_bg, default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "NameActive", { link = "Folded", default = true })
	vim.api.nvim_set_hl(0, hl_prefix .. "PathActive", { fg = muted_fg, bg = name_active_bg, default = true })
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

---Detect which tag indices have duplicate filenames and need a
---disambiguating parent path shown alongside the name.
---@param tags table[] array of {index, path} entries
---@return table<number, boolean> set of indices that have duplicate basenames
local function find_duplicates(tags)
	-- Group indices by basename.
	local by_name = {}
	for _, t in ipairs(tags) do
		local name = vim.fn.fnamemodify(t.path, ":t")
		by_name[name] = by_name[name] or {}
		by_name[name][#by_name[name] + 1] = t.index
	end
	local dupes = {}
	for _, indices in pairs(by_name) do
		if #indices > 1 then
			for _, idx in ipairs(indices) do
				dupes[idx] = true
			end
		end
	end
	return dupes
end

function M:update_status()
	local ok, grapple = pcall(require, "grapple")
	if not ok then
		return ""
	end

	local current_path = vim.api.nvim_buf_get_name(0)

	-- Collect all visible tags first so we can detect duplicate names.
	local tags = {}
	for i = 1, self.options.number_of_tags do
		if grapple.exists({ index = i }) then
			local tag = grapple.find({ index = i })
			tags[#tags + 1] = { index = i, path = tag.path }
		end
	end

	local dupes = find_duplicates(tags)
	local parts = {}

	for _, t in ipairs(tags) do
		local i = t.index
		local name = vim.fn.fnamemodify(t.path, ":t")
		local is_active = t.path == current_path
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

		-- For duplicate filenames, append the parent directory in a muted color.
		if dupes[i] then
			local rel = vim.fn.fnamemodify(t.path, ":.:h")
			text = text
				.. " "
				.. "%#" .. hl_prefix .. "Path"
				.. suffix
				.. "#"
				.. rel
		end

		parts[#parts + 1] = text
	end

	return table.concat(parts, " ")
end

return M
