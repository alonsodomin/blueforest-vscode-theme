-- The BlueForest theme for lualine.
--
-- A port of BlueForest by mathias[at]decodified[dot]com, published at
-- <https://github.com/sirthias/BlueForest> under the CC BY 3.0 licence, and
-- distributed here under the CC BY 4.0 licence. See NOTICE.md.
--
-- lualine reads a table of colours rather than a colourscheme, so the palette
-- of the theme is written down here for the fourth time. The colours are the
-- ones of the colourscheme: the dark background of the editor, the yellow of
-- the operators and the blue of the functions.
--
-- The name of the theme is `blueforest`, the name of the file it is loaded
-- from. lualine finds it on its own: the `auto` theme looks the theme up by
-- the name of the colourscheme, which is `blueforest` as well.
--
-- The modes that are not here fall back to `normal`, which is what lualine
-- does with a mode a theme does not describe.
return {
  normal = {
    a = { fg = "#0A101D", bg = "#ffcc33" },
    b = { fg = "#0A101D", bg = "#a2cff5" },
    c = { fg = "#D0D0D0", bg = "#1e5c1e" },
  },
  inactive = {
    a = { fg = "#e7e7e7", bg = "#0A101D" },
    b = { fg = "#e7e7e7", bg = "#1b2b40" },
    c = { fg = "#e7e7e7", bg = "#1b2b40" },
  },
}
