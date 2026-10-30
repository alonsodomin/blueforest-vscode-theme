# SPDX-License-Identifier: MPL-2.0
#
# Checks that nixvim reads the theme of the repository: the colourscheme is
# applied when the editor starts, and lualine finds the theme of the
# statusline.
#
# The check builds an editor, so it is not one of the fast ones: it is only
# run on purpose.
{
  pkgs,
  # The flake of nixvim.
  nixvim,
  # The module of the theme, for nixvim.
  module,
}:
let
  # The configuration of nixvim that the README documents.
  configuration = nixvim.lib.evalNixvim {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      module
      {
        # lualine, to see that it finds the theme of the statusline.
        plugins.lualine.enable = true;
      }
    ];
  };

  # The editor with the theme.
  editor = configuration.config.build.package;
in
pkgs.runCommand "blueforest-neovim-nixvim-check"
  {
    nativeBuildInputs = [ pkgs.jq ];

    # The probe writes what it found in this file.
    BLUEFOREST_RESULT = "result.json";
  }
  ''
    export HOME=$TMPDIR

    # The editor reads the theme when it starts: the probe runs with the
    # configuration of nixvim already loaded.
    ${editor}/bin/nvim --headless \
      -c "luafile ${./probe-nixvim.lua}" \
      -c "qa!"

    # And the probe has to have found something.
    test -f "$BLUEFOREST_RESULT"

    # The colourscheme is the one of the repository, the colours of the
    # rainbow delimiters are there, and lualine paints the statusline with
    # the theme of the repository.
    jq -e '
      .colorsName == "blueforest"
      and .normal.fg == "d0d0d0"
      and .normal.bg == "141f2e"
      and .rainbow.fg == "dc322f"
      and .lualine.bg == "ffcc33"
    ' "$BLUEFOREST_RESULT" >/dev/null

    touch $out
  ''
