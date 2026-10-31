# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest preset for Starship, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
#
# The inputs of the application. Its own flake binds them to the module and
# passes them as a static argument, so that the module does not depend on the
# inputs of the flake that imports it.
#
# The arguments of the module are the ones of the flake that imports it: the
# `inputs` below are the inputs of that flake, so that the packages of the
# application are built with the nixpkgs of the consumer.
{
  appInputs,
}:
{
  config,
  lib,
  inputs,
  ...
}:
{
  # The flake module of Home Manager, which declares `flake.homeModules`. It
  # is imported here, so that the module of the application can be composed
  # with the others without the consumer having to import it.
  #
  # The Home Manager of the consumer is the one to use when it has one: the
  # declaration of the option is then the one of the consumer, and the module
  # system imports it only once.
  imports = [
    (inputs.home-manager or appInputs.home-manager).flakeModules.home-manager
  ];

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
