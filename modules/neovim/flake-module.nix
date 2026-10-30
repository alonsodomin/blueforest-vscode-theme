# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Neovim, as a flake-parts module.
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
        overlays = [ config.flake.overlays.neovim ];
      };

      # The unoverlaid nixpkgs, used to evaluate the modules without applying
      # the overlay twice.
      basePkgs = import inputs.nixpkgs { inherit system; };

      theme = pkgs.blueforest-neovim-theme;

      # The files of the repository that the package carries.
      sources = {
        colorscheme = ./themes/blueforest.lua;
        lualine = ./themes/lualine-blueforest.lua;
      };
    in
    {
      packages.blueforest-neovim-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository, and both
        # Neovim and lualine read it.
        neovim-theme = import ./nix/checks/theme.nix {
          inherit
            pkgs
            theme
            sources
            ;
          lualine = pkgs.vimPlugins.lualine-nvim;
        };

        # The configuration documented in the README installs the theme where
        # Neovim reads it from.
        neovim-configuration = import ./nix/checks/configuration.nix {
          inherit pkgs;
          homeManager = inputs.home-manager;
          module = config.flake.homeModules.neovim;
        };

        # The modules add the overlay of the application.
        neovim-module = import ./nix/checks/module.nix {
          inherit lib;
          pkgs = basePkgs;
          modules = {
            nixos = config.flake.nixosModules.neovim;
          };
          overlay = config.flake.overlays.neovim;
        };
      };

      # The development shell of the application, declared in TOML.
      devshells.neovim = inputs.devshell.lib.importTOML ./devshell.toml;
    };

  flake = {
    overlays.neovim = import ./nix/overlay.nix;

    # Neovim reads the configuration of the user, and there is no system-wide
    # directory it reads, so the NixOS module can do no more than adding the
    # overlay.
    nixosModules.neovim = {
      nixpkgs.overlays = [ config.flake.overlays.neovim ];
    };

    homeModules.neovim = import ./nix/modules/default.nix;
  };
}
