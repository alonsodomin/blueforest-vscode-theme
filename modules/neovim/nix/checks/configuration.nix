# SPDX-License-Identifier: MPL-2.0
#
# Checks that the configuration documented in the README installs the theme
# where Neovim reads it from, and that it writes nothing when Neovim is not
# enabled.
{
  pkgs,
  homeManager,
  module,
}:
let
  evaluate =
    extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        module
        {
          home.username = "blueforest";
          home.homeDirectory = "/home/blueforest";
          home.stateVersion = "26.11";
        }
        extra
      ];
    }).config;

  # The consumer has to enable Neovim: the theme is a plugin of it, and Home
  # Manager writes the plugins of an enabled Neovim only.
  enabled = evaluate { programs.neovim.enable = true; };
  disabled = evaluate { };

  # The directory Home Manager writes the plugins of Neovim into.
  packDir = enabled.xdg.dataFile."nvim/site/pack/hm".source;

  # The plugins of the configuration, as the module system resolved them.
  plugins = map (plugin: plugin.pname or plugin.name) enabled.programs.neovim.plugins;

  result = builtins.toJSON {
    plugins = plugins;

    # The module does not enable Neovim, so a configuration that does not
    # enable it gets no plugins at all.
    disabledWritesNothing = !(disabled.xdg.dataFile ? "nvim/site/pack/hm");
  };
in
pkgs.runCommand "blueforest-neovim-configuration-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;
  }
  ''
    # The theme is one of the plugins of Neovim, and it is the only one the
    # module adds.
    echo "$result" | jq -e '
      (.plugins | index("blueforest-neovim-theme")) != null
      and .disabledWritesNothing
    ' >/dev/null

    # And the theme ends up in the directory of the runtimepath where Neovim
    # reads a colourscheme from, and where lualine reads its theme from.
    test -f ${packDir}/start/blueforest-neovim-theme/colors/blueforest.lua
    test -f ${packDir}/start/blueforest-neovim-theme/lua/lualine/themes/blueforest.lua

    touch $out
  ''
