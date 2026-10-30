# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest prompt for sbt, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
{
  config,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      system,
      ...
    }:
    let
      # The nixpkgs instance of the application. The package is built with the
      # overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.sbt ];
      };

      # The unoverlaid nixpkgs, used to evaluate the module without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      prompt = pkgs.blueforest-sbt-prompt;

      # The files of the repository that the package and the module install.
      sources = {
        plugin = ./config/sbt-prompt.sbt;
        settings = ./config/blueforest-prompt.sbt;
      };
    in
    {
      packages.blueforest-sbt-prompt = prompt;

      checks = {
        # The package carries the files of the repository, and they declare
        # the plugin and select the theme of the plugin.
        sbt-package = import ./nix/checks/package.nix {
          inherit pkgs prompt sources;
        };

        # The Home Manager module installs those files where both generations
        # of sbt read their global configuration, and only when sbt is
        # enabled.
        sbt-module = import ./nix/checks/module.nix {
          inherit lib sources;
          pkgs = basePkgs;
          homeManager = inputs.home-manager;
          module = config.flake.homeModules.sbt;
        };
      };

      # The development shell of the application, declared in TOML.
      devshells.sbt = inputs.devshell.lib.importTOML ./devshell.toml;
    };

  flake = {
    overlays.sbt = import ./nix/overlay.nix;

    # sbt reads the configuration of the user, and there is no system-wide
    # directory it reads, so the application publishes a Home Manager module
    # and no NixOS module.
    homeModules.sbt = import ./nix/module.nix;
  };
}
