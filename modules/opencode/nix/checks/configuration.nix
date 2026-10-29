# SPDX-License-Identifier: MPL-2.0
#
# Checks that the configuration documented in the README installs the theme
# where OpenCode reads it, and selects it.
{
  lib,
  pkgs,
  source,
  homeManager,
  module,
}:
let
  evaluated = import ./lib/evaluation.nix {
    inherit
      lib
      pkgs
      source
      homeManager
      module
      ;
  };

  result = builtins.toJSON ({
    inherit (evaluated)
      selectedMode
      selectedTheme
      themeIsTheRepositoryTheme
      themeTarget
      ;
  });
in
pkgs.runCommand "blueforest-opencode-configuration-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;

    # The file Home Manager writes for the settings of the terminal.
    cliFile = evaluated.cliFile;
  }
  ''
    # The theme ends up where OpenCode reads the themes from, and it is the
    # theme of this repository.
    echo "$result" | jq -e '
      .themeTarget == "/home/blueforest/.config/opencode/themes/blueforest.json"
      and .themeIsTheRepositoryTheme
      and .selectedTheme == "blueforest"
      and .selectedMode == "dark"
    ' >/dev/null

    # And the settings of the terminal are the ones OpenCode 2 reads.
    jq -e '
      ."$schema" == "https://opencode.ai/v2/cli.json"
      and .theme.name == "blueforest"
      and .theme.mode == "dark"
    ' "$cliFile" >/dev/null

    touch $out
  ''
