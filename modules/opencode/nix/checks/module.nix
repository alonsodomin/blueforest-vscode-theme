# SPDX-License-Identifier: MPL-2.0
#
# Checks that the modules of the application add the overlay of the theme.
#
# The modules do not enable OpenCode, so the check only evaluates the overlay
# they add and the options they set.
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

      # Stubs of the options that the module of Home Manager provides. They
      # mirror the contracts documented in the README: the themes of OpenCode
      # are a set of themes, and its settings are a set of settings.
      options.programs.opencode = lib.mkOption {
        type = lib.types.submodule {
          options = {
            themes = lib.mkOption {
              type = lib.types.attrsOf lib.types.unspecified;
              default = { };
            };

            cli = lib.mkOption {
              type = lib.types.attrsOf lib.types.unspecified;
              default = { };
            };
          };
        };
        default = { };
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
      hasTheme = applied ? blueforest-opencode-theme;
      # The overlay leaves the OpenCode of nixpkgs alone, so that a
      # configuration that does not want the theme keeps the one it has.
      leavesOpencodeAlone = !(applied ? opencode);
    };
  };
in
pkgs.runCommand "blueforest-opencode-module-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    inherit result;
  }
  ''
    echo "$result" | jq -e '
      .nixos.overlayCount > 0 and .nixos.overlaysAreFunctions
      and .home.overlayCount > 0 and .home.overlaysAreFunctions
      and .overlay.hasTheme
      and .overlay.leavesOpencodeAlone
    ' >/dev/null
    touch $out
  ''
