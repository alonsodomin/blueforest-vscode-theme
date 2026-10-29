# SPDX-License-Identifier: MPL-2.0
#
# Adds the BlueForest theme for OpenCode to a nixpkgs instance.
#
# `pkgs.opencode` is deliberately left untouched: the theme is a file of its
# own, so that applying the overlay does not replace the OpenCode of a
# configuration that does not want the theme.
final: _prev: {
  blueforest-opencode-theme = import ./theme.nix {
    inherit (final) lib;
    pkgs = final;
  };
}
