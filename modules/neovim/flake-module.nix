# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Neovim, as a flake-parts module.
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

      # The check that nixvim reads the theme. It builds an editor, so it is
      # only run on purpose.
      nixvimCheck = import ./nix/checks/nixvim.nix {
        inherit pkgs;
        nixvim = appInputs.nixvim;
        module = config.flake.nixvimModules.neovim;
      };
    in
    {
      packages = {
        blueforest-neovim-theme = theme;

        # The check that nixvim reads the theme. It builds an editor, so it is
        # kept out of `nix flake check`, but it is a package of its own and can
        # be built on demand:
        # nix build .#neovim-nixvim-check
        neovim-nixvim-check = nixvimCheck;
      };

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
          homeManager = appInputs.home-manager;
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
      }
      // (
        if builtins.getEnv "BLUEFOREST_NEOVIM_NIXVIM_CHECK" == "1" then
          {
            neovim-nixvim = nixvimCheck;
          }
        else
          {
          }
      );
    };

  flake = {
    overlays.neovim = import ./nix/overlay.nix;

    # The module of the theme for nixvim. It belongs to the configuration of
    # nixvim, so it is imported into it:
    #
    #   programs.nixvim = {
    #     imports = [ blueforest.nixvimModules.neovim ];
    #   };
    nixvimModules.neovim = import ./nix/nixvim.nix;

    # Neovim reads the configuration of the user, and there is no system-wide
    # directory it reads, so the NixOS module can do no more than adding the
    # overlay.
    nixosModules.neovim = {
      nixpkgs.overlays = [ config.flake.overlays.neovim ];
    };

    homeModules.neovim = import ./nix/modules/default.nix;
  };
}
