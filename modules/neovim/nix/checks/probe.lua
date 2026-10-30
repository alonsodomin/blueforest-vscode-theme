-- SPDX-License-Identifier: MPL-2.0
--
-- The probe of the theme check.
--
-- It reads the paths of the packages from the environment, so that the check
-- does not have to write them into the script.
--
-- The theme is a plugin, so it is put on the runtimepath the way Home
-- Manager puts it there, and lualine is put there as well.

local theme = assert(os.getenv("BLUEFOREST_THEME"), "the theme of the package is not set")
local lualine = assert(os.getenv("BLUEFOREST_LUALINE"), "lualine is not set")

vim.opt.runtimepath:append(theme)
vim.opt.runtimepath:append(lualine)

-- Neovim reads a colourscheme from the `colors` directory of the
-- runtimepath, and the name of the theme is the name of the file.
vim.cmd.colorscheme("blueforest")
assert(vim.g.colors_name == "blueforest", "the colourscheme did not set its name")

-- The colours of the theme are the ones of the repository.
local expected = {
  Normal = { fg = 0xd0d0d0, bg = 0x141f2e },
  Comment = { fg = 0xa0ffa0 },
  String = { fg = 0x80ff80 },
  DiagnosticError = { fg = 0xff8080 },
  RainbowDelimiterRed = { fg = 0xdc322f },
  RainbowDelimiterViolet = { fg = 0xa2cff5 },
}

for group, colours in pairs(expected) do
  local hl = vim.api.nvim_get_hl(0, { name = group })
  for what, colour in pairs(colours) do
    assert(hl[what] == colour, string.format("%s.%s is %s, not %s", group, what, tostring(hl[what]), tostring(colour)))
  end
end

-- lualine reads its theme from the `lua/lualine/themes` directory of the
-- runtimepath.
local loader = require("lualine.utils.loader")
local lualineTheme = loader.load_theme("blueforest")
assert(lualineTheme.normal.a.bg == "#ffcc33", "lualine did not read the theme of the repository")

-- And lualine finds the theme on its own, because the name of the theme is
-- the name of the colourscheme.
local auto = require("lualine.themes.auto")
assert(auto.normal.a.bg == "#ffcc33", "lualine did not find the theme on its own")

-- The statusline is painted with it.
require("lualine").setup({ options = { theme = "blueforest" } })
local statusline = vim.api.nvim_get_hl(0, { name = "lualine_a_normal" })
assert(statusline.bg == 0xffcc33, "the statusline is not painted with the theme")

print("the theme of the repository is the theme Neovim and lualine read")
