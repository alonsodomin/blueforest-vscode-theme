# SPDX-License-Identifier: MPL-2.0
#
# Adds the BlueForest prompt for sbt to a nixpkgs instance.
#
# `pkgs.sbt` is deliberately left untouched: the prompt is a pair of
# configuration files, not a replacement for sbt, so that applying the overlay
# does not change the sbt of a configuration that does not want the prompt.
final: _prev: {
  blueforest-sbt-prompt = import ./package.nix {
    inherit (final) lib;
    pkgs = final;
  };
}
