# SPDX-License-Identifier: MPL-2.0
#
# Checks that the modules of the application add the overlay of the theme.
#
# The NixOS module does no more than adding the overlay: Neovim reads the
# configuration of the user, and there is no system-wide directory it reads.
#
# The Home Manager module of the application is covered by the configuration
# check, which evaluates it against Home Manager and sees the theme land where
# Neovim reads a colourscheme from.
{
  lib,
  pkgs,
  modules,
  overlay,
}:
let
  consumerModule =
    { lib, ... }:
    {
      options.nixpkgs.overlays = lib.mkOption {
        type = lib.types.listOf lib.types.unspecified;
        default = [ ];
      };
    };

  evaluated = lib.evalModules {
    modules = [
      consumerModule
      modules.nixos
    ];
  };

  overlays = evaluated.config.nixpkgs.overlays;

  # The overlay of the application, applied to the nixpkgs of the check.
  applied = overlay pkgs pkgs;

  result = builtins.toJSON {
    nixos = {
      overlayCount = builtins.length overlays;
      overlaysAreFunctions = builtins.all builtins.isFunction overlays;
    };
    overlay = {
      hasTheme = applied ? blueforest-neovim-theme;
      # The overlay leaves the Neovim of nixpkgs alone, so that a
      # configuration that does not want the theme keeps the one it has.
      leavesNeovimAlone = !(applied ? neovim);
    };
  };
in
pkgs.runCommand "blueforest-neovim-module-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;
  }
  ''
    echo "$result" | jq -e '
      .nixos.overlayCount > 0
      and .nixos.overlaysAreFunctions
      and .overlay.hasTheme
      and .overlay.leavesNeovimAlone
    ' >/dev/null
    touch $out
  ''
