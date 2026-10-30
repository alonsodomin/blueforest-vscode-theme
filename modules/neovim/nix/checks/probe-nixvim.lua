-- SPDX-License-Identifier: MPL-2.0
--
-- The probe of the nixvim check.
--
-- It writes what the editor found in the file the check reads. The editor is
-- started with the configuration of nixvim, so the colourscheme has been
-- applied and the plugins have been set up by the time this runs.

local function colour(hl, what)
  local value = hl[what]
  if value == nil then
    return nil
  end
  return string.format("%06x", value)
end

local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
local rainbow = vim.api.nvim_get_hl(0, { name = "RainbowDelimiterRed" })
local statusline = vim.api.nvim_get_hl(0, { name = "lualine_a_normal" })

local result = {
  colorsName = vim.g.colors_name,
  normal = {
    fg = colour(normal, "fg"),
    bg = colour(normal, "bg"),
  },
  rainbow = {
    fg = colour(rainbow, "fg"),
  },
  lualine = {
    bg = colour(statusline, "bg"),
  },
}

local path = assert(os.getenv("BLUEFOREST_RESULT"), "the file of the result is not set")
local file = assert(io.open(path, "w"))
file:write(vim.json.encode(result))
file:close()
