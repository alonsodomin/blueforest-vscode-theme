# SPDX-License-Identifier: MPL-2.0
#
# Adds the BlueForest theme for Neovim to a nixpkgs instance.
#
# `pkgs.neovim` is deliberately left untouched: the theme is a plugin of its
# own, so that applying the overlay does not replace the Neovim of a
# configuration that does not want the theme.
final: _prev: {
  blueforest-neovim-theme = import ./theme.nix {
    inherit (final) lib;
    pkgs = final;
  };
}
