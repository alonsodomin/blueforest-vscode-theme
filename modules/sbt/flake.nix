# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest prompt for sbt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        imports = [
          # The options that the modules below declare.
          inputs.flake-parts.flakeModules.flakeModules
          inputs.devshell.flakeModule
          inputs.home-manager.flakeModules.home-manager

          # The module of the application, imported here and published
          # below, for the root flake.
          ./flake-module.nix
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        # The module of the application, for the root flake.
        flake.flakeModules.default = ./flake-module.nix;

        # The application exposes its own outputs under the usual names as
        # well.
        flake = {
          overlays.default = final: prev: config.flake.overlays.sbt final prev;
          homeModules.default = {
            imports = [ config.flake.homeModules.sbt ];
          };
        };
      }
    );
}
