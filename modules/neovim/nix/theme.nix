# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Neovim.
#
# The theme is a plugin, because that is where Neovim reads a colourscheme
# from: the `colors` directory of the runtimepath. lualine reads its own
# theme from the `lua/lualine/themes` directory of the same runtimepath, so
# the package carries both, and one package is the whole theme.
#
# The colours are CC BY 4.0, the packaging of them is MPL-2.0.
{ lib, pkgs }:
let
  # The version of the application, with the newline of the file removed.
  version = lib.removeSuffix "\n" (builtins.readFile ../VERSION);

  # The runtimepath of the plugin: the colourscheme where Neovim looks for
  # it, and the theme of lualine where lualine looks for it.
  sources = pkgs.runCommand "blueforest-neovim-theme-sources" { } ''
    mkdir -p $out/colors $out/lua/lualine/themes $out/share/doc/blueforest
    cp ${../themes/blueforest.lua} $out/colors/blueforest.lua
    cp ${../themes/lualine-blueforest.lua} $out/lua/lualine/themes/blueforest.lua

    # The attribution of the theme travels with the package.
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  '';
in
pkgs.vimUtils.buildVimPlugin {
  pname = "blueforest-neovim-theme";
  inherit version;
  src = sources;

  meta = {
    description = "BlueForest theme for Neovim";
    homepage = "https://github.com/alonsodomin/blueforest-theme";
    license = [
      lib.licenses.mpl20
      lib.licenses.cc-by-40
    ];
    platforms = lib.platforms.all;
  };
}
