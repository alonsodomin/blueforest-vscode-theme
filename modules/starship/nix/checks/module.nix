# SPDX-License-Identifier: MPL-2.0
#
# Checks that the modules of the application add the overlay of the theme.
#
# The modules deliberately do not touch `programs.starship`, so the check only
# evaluates the overlay they add.
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

  evaluate =
    module:
    let
      evaluated = lib.evalModules {
        modules = [
          consumerModule
          module
        ];
      };
      overlays = evaluated.config.nixpkgs.overlays;
    in
    {
      overlayCount = builtins.length overlays;
      overlaysAreFunctions = builtins.all builtins.isFunction overlays;
    };

  # The overlay of the application, applied to the nixpkgs of the check.
  applied = overlay pkgs pkgs;

  result = builtins.toJSON {
    nixos = evaluate modules.nixos;
    home = evaluate modules.home;
    overlay = {
      hasPreset = applied ? blueforest-starship-preset;
      hasWrapper = applied ? blueforest-starship;
      # The overlay leaves the Starship of nixpkgs alone, so that a
      # configuration that does not want the theme keeps the one it has.
      leavesStarshipAlone = !(applied ? starship);
    };
  };
in
pkgs.runCommand "blueforest-starship-module-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;
  }
  ''
    echo "$result" | jq -e '
      .nixos.overlayCount > 0 and .nixos.overlaysAreFunctions
      and .home.overlayCount > 0 and .home.overlaysAreFunctions
      and .overlay.hasPreset
      and .overlay.hasWrapper
      and .overlay.leavesStarshipAlone
    ' >/dev/null
    touch $out
  ''
