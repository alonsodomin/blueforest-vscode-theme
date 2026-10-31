# SPDX-License-Identifier: MPL-2.0

{
  description = "BlueForest themes for many tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # nixvim, for the check that reads the theme of Neovim. The repository
    # owns the pin of it, so that the check of the application is not at the
    # mercy of the release cycle of nixvim.
    nixvim.url = "github:nix-community/nixvim";

    # The applications of the repository. Every one of them is a flake of
    # its own, and the root flake composes the module it publishes.
    #
    # Adding an application is a matter of adding a directory and a line
    # here.
    vscode = {
      url = "path:./modules/vscode";

      # The repository pins the inputs of its applications, so that every
      # application is built with the same nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    bat = {
      url = "path:./modules/bat";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    starship = {
      url = "path:./modules/starship";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    opencode = {
      url = "path:./modules/opencode";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    sbt = {
      url = "path:./modules/sbt";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
    };

    neovim = {
      url = "path:./modules/neovim";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.nixvim.follows = "nixvim";
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
          inputs.starship.flakeModule
          inputs.opencode.flakeModule
          inputs.sbt.flakeModule
          inputs.neovim.flakeModule
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        flake = {
          # The overlays of every application, applied like nixpkgs
          # applies them.
          overlays.default = lib.composeManyExtensions [
            config.flake.overlays.vscode
            config.flake.overlays.starship
            config.flake.overlays.opencode
            config.flake.overlays.sbt
            config.flake.overlays.neovim
          ];

          flakeModules = {
            bat = inputs.bat.flakeModule;
            starship = inputs.starship.flakeModule;
            vscode = inputs.vscode.flakeModule;
            opencode = inputs.opencode.flakeModule;
            sbt = inputs.sbt.flakeModule;
            neovim = inputs.neovim.flakeModule;
            default = {
              imports = [
                inputs.bat.flakeModule
                inputs.starship.flakeModule
                inputs.vscode.flakeModule
                inputs.opencode.flakeModule
                inputs.sbt.flakeModule
                inputs.neovim.flakeModule
              ];
            };
          };

          nixosModules.default = {
            imports = [
              config.flake.nixosModules.vscode
              config.flake.nixosModules.starship
              config.flake.nixosModules.opencode
              config.flake.nixosModules.neovim
            ];
          };

          homeModules.default = {
            imports = [
              config.flake.homeModules.vscode
              config.flake.homeModules.starship
              config.flake.homeModules.opencode
              config.flake.homeModules.sbt
              config.flake.homeModules.neovim
            ];
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

            # Fails if the overlay of the repository does not add the
            # packages of every application.
            checks.overlay = import ./tests/overlay.nix {
              inherit pkgs;
              overlay = config.flake.overlays.default;
              expected = [
                "blueforest-vscode-theme"
                "blueforest-starship-preset"
                "blueforest-starship"
                "blueforest-opencode-theme"
                "blueforest-sbt-prompt"
                "blueforest-neovim-theme"
              ];
            };
          };
      }
    );
}
