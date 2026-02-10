local M = require("lualine.component"):extend()

local default_options = {
	--- Number of tag slots to display
	number_of_tags = 4,
	--- Highlight group for brackets
	highlight_bracket = "Punctuation",
	--- Highlight group for the tag index number
	highlight_index = "Number",
	--- Highlight group for the active (current) tag name
	highlight_name_active = "Folded",
	--- Highlight group for inactive tag names
	highlight_name_inactive = "lualine_c_normal",
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

---Ensure custom highlight groups exist for both active and inactive states.
---Foreground comes from the configured bracket/index groups, background
---matches the surrounding name highlight so there are no visual artifacts.
---@param opts table
local function ensure_highlights(opts)
	local bracket_fg = get_fg(opts.highlight_bracket)
	local index_fg = get_fg(opts.highlight_index)

	local states = {
		{ suffix = "", bg_group = opts.highlight_name_inactive },
		{ suffix = "Active", bg_group = opts.highlight_name_active },
	}

	for _, state in ipairs(states) do
		local bg = get_bg(state.bg_group)
		if bracket_fg then
			vim.api.nvim_set_hl(0, "LualineGrappleBracket" .. state.suffix, { fg = bracket_fg, bg = bg })
		end
		if index_fg then
			vim.api.nvim_set_hl(0, "LualineGrappleIndex" .. state.suffix, { fg = index_fg, bg = bg })
		end
	end
end

function M:init(options)
	M.super.init(self, options)
	self.options = vim.tbl_deep_extend("keep", self.options or {}, default_options)
end

function M:update_status()
	local ok, grapple = pcall(require, "grapple")
	if not ok then
		return ""
	end

	ensure_highlights(self.options)

	local current_path = vim.api.nvim_buf_get_name(0)
	local parts = {}

	for i = 1, self.options.number_of_tags do
		if grapple.exists({ index = i }) then
			local tag = grapple.find({ index = i })
			local name = vim.fn.fnamemodify(tag.path, ":t")
			local is_active = tag.path == current_path
			local suffix = is_active and "Active" or ""
			local name_hl = is_active and self.options.highlight_name_active or self.options.highlight_name_inactive

			local text = "%#LualineGrappleBracket"
				.. suffix
				.. "#["
				.. "%#LualineGrappleIndex"
				.. suffix
				.. "#"
				.. i
				.. "%#LualineGrappleBracket"
				.. suffix
				.. "#]"
				.. "%#"
				.. name_hl
				.. "#"
				.. " "
				.. name

			parts[#parts + 1] = text
		end
	end

	return table.concat(parts, " ")
end

return M
