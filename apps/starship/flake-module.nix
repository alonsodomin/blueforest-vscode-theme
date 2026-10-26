# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest preset for Starship, as a flake-parts module.
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
      # The nixpkgs instance of the application. The preset and the wrapper
      # are built with the overlaid nixpkgs.
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ config.flake.overlays.starship ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      preset = pkgs.blueforest-starship-preset;
      wrapper = pkgs.blueforest-starship;

      # The preset of the repository.
      source = ./themes/blueforest.toml;
    in
    {
      packages = {
        blueforest-starship-preset = preset;
        blueforest-starship = wrapper;
      };

      checks = {
        # The preset of the package is the preset of the repository.
        starship-preset = import ./nix/checks/preset.nix {
          inherit pkgs preset source;
        };

        # Starship parses and renders the preset.
        starship-render = import ./nix/checks/render.nix {
          inherit pkgs preset;
        };

        # The wrapper is Starship with the preset bundled.
        starship-wrapper = import ./nix/checks/wrapper.nix {
          inherit pkgs wrapper source;
        };

        # The modules add the overlay of the application.
        starship-module = import ./nix/checks/module.nix {
          inherit lib;
          pkgs = basePkgs;
          modules = {
            nixos = config.flake.nixosModules.starship;
            home = config.flake.homeModules.starship;
          };
          overlay = config.flake.overlays.starship;
        };
      };

      # The development shell of the application, declared in TOML.
      devshells.starship = inputs.devshell.lib.importTOML ./devshell.toml;
    };

  flake = {
    overlays.starship = import ./nix/overlay.nix;

    nixosModules.starship = {
      nixpkgs.overlays = [ config.flake.overlays.starship ];
    };

    homeModules.starship = {
      nixpkgs.overlays = [ config.flake.overlays.starship ];
    };
  };
}
