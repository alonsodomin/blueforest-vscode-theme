# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest preset for Starship";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        lib,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;

        # The module of the application. The inputs of the application are
        # bound to it, so that it does not depend on the inputs of the flake
        # that imports it.
        flakeModules.default = importApply ./flake-module.nix { appInputs = inputs; };
      in
      {
        imports = [
          # The options that the modules below declare.
          inputs.flake-parts.flakeModules.flakeModules
          inputs.home-manager.flakeModules.home-manager

          # The module of the application, imported here and published
          # below, for the root flake.
          flakeModules.default
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          # The module of the application, for the root flake.
          inherit flakeModules;

          # The application exposes its own outputs under the usual names as
          # well.
          overlays.default = final: prev: config.flake.overlays.starship final prev;
          nixosModules.default = {
            imports = [ config.flake.nixosModules.starship ];
          };
          homeModules.default = {
            imports = [ config.flake.homeModules.starship ];
          };
        };
      }
    );
}
