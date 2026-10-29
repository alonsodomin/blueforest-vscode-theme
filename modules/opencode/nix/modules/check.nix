# SPDX-License-Identifier: MPL-2.0
#
# Evaluates the Home Manager configuration documented in the README against
# the module shipped by this flake, and reports what the module system
# resolved.
#
# The result only contains JSON-serialisable values, so that it can be
# asserted on from a derivation.
{
  lib,
  pkgs,
  # The home-manager flake.
  homeManager,
  # The module under test.
  module,
  # The theme of the repository.
  source,
}:
let
  # The configuration of a consumer that enables OpenCode and imports the
  # module of this application.
  evaluated = homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    lib = pkgs.lib;
    modules = [
      module
      {
        home.username = "blueforest";
        home.homeDirectory = "/home/blueforest";
        home.stateVersion = "26.11";

        # The consumer has to enable OpenCode: the theme is part of the
        # configuration of the program.
        programs.opencode.enable = true;
      }
    ];
  };

  config = evaluated.config;

  # The files Home Manager writes for OpenCode.
  themeFile = config.xdg.configFile."opencode/themes/blueforest.json";
  cliFile = config.xdg.configFile."opencode/cli.json";
in
{
  # The theme ends up in the directory OpenCode reads the themes from.
  themeTarget = "${config.xdg.configHome}/opencode/themes/blueforest.json";

  # The theme that ends up installed is the theme of this repository.
  themeIsTheRepositoryTheme = builtins.readFile themeFile.source == builtins.readFile source;

  # The file Home Manager writes for the settings of the terminal. It is
  # read at build time, because a file of the store cannot be read while the
  # flake is evaluated.
  cliFile = builtins.toString cliFile.source;

  # The settings of the terminal, as the module system resolved them.
  selectedTheme = config.programs.opencode.cli.theme.name or null;
  selectedMode = config.programs.opencode.cli.theme.mode or null;
}
