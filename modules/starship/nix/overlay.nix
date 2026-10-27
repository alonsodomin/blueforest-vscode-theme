# SPDX-License-Identifier: MPL-2.0
#
# Adds the BlueForest preset for Starship to a nixpkgs instance.
#
# `pkgs.starship` is deliberately left untouched: the preset-bundled binary is
# a package of its own, so that applying the overlay does not replace the
# Starship of a configuration that does not want the theme.
final: prev:
let
  preset = import ./preset.nix {
    inherit (final) lib;
    pkgs = final;
  };
in
{
  blueforest-starship-preset = preset;

  blueforest-starship = import ./wrapper.nix {
    pkgs = final;
    starship = prev.starship;
    inherit preset;
  };
}
