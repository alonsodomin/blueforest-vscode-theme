# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest themes for many tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # The applications of the repository. Every one of them is a flake of
    # its own, and the root flake composes the module it publishes.
    #
    # Adding an application is a matter of adding a directory and a line
    # here.
    vscode = {
      url = "path:./apps/vscode";

      # The repository pins the inputs of its applications, so that every
      # application is built with the same nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.devshell.follows = "devshell";
      inputs.home-manager.follows = "home-manager";
    };

    bat = {
      url = "path:./apps/bat";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        lib,
        inputs,
        ...
      }:
      {
        imports = [
          # The options that the modules below declare.
          inputs.devshell.flakeModule
          inputs.home-manager.flakeModules.home-manager
          inputs.treefmt-nix.flakeModule

          # The modules the applications publish.
          inputs.vscode.flakeModule
          inputs.bat.flakeModule
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          # The overlays of every application, applied like nixpkgs
          # applies them.
          overlays.default =
            let
              compose =
                overlays: final: prev:
                lib.foldl' (acc: overlay: overlay acc) prev (lib.reverseList overlays);
            in
            compose [ config.flake.overlays.vscode ];

          nixosModules.default = {
            imports = [ config.flake.nixosModules.vscode ];
          };

          homeModules.default = {
            imports = [ config.flake.homeModules.vscode ];
          };
        };

        perSystem =
          {
            pkgs,
            ...
          }:
          let
            release = import ./tools/release.nix { inherit pkgs; };
          in
          {
            # The development shell of the repository, declared in TOML.
            devshells.default = inputs.devshell.lib.importTOML ./devshell.toml;

            # The formatting of the repository. The formatter and the check
            # that verifies it come with the module.
            treefmt.imports = [ ./treefmt.nix ];

            # Fails if an application carries a version of its own.
            checks.version = import ./tests/version.nix { inherit pkgs; };

            apps.release = {
              type = "app";
              program = "${release}/bin/release";
              meta.description = "Interactive release helper";
            };
          };
      }
    );
}
