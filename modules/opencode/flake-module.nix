# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for OpenCode, as a flake-parts module.
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
      # The nixpkgs instance of the application. The theme is built with the
      # overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.opencode ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      theme = pkgs.blueforest-opencode-theme;

      # The theme of the repository.
      source = ./themes/blueforest.json;
    in
    {
      packages.blueforest-opencode-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository, and every
        # colour of the theme resolves.
        opencode-theme = import ./nix/checks/theme.nix {
          inherit
            lib
            pkgs
            theme
            source
            ;
        };

        # The configuration documented in the README installs the theme where
        # OpenCode reads it, and selects it.
        opencode-configuration = import ./nix/checks/configuration.nix {
          inherit lib pkgs source;
          homeManager = inputs.home-manager;
          module = import ./nix/modules/default.nix;
        };

        # The modules add the overlay of the application.
        opencode-module = import ./nix/checks/module.nix {
          inherit lib;
          pkgs = basePkgs;
          modules = {
            nixos = config.flake.nixosModules.opencode;
            home = config.flake.homeModules.opencode;
          };
          overlay = config.flake.overlays.opencode;
        };
      };

      # The development shell of the application, declared in TOML.
      devshells.opencode = inputs.devshell.lib.importTOML ./devshell.toml;
    };

  flake = {
    overlays.opencode = import ./nix/overlay.nix;

    # OpenCode is a program of the user, and Home Manager writes its
    # configuration only when the program is enabled, so the NixOS module can
    # do no more than adding the overlay.
    nixosModules.opencode = {
      nixpkgs.overlays = [ config.flake.overlays.opencode ];
    };

    homeModules.opencode = import ./nix/modules/default.nix;
  };
}
