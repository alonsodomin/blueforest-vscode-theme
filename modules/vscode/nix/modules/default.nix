# SPDX-License-Identifier: MPL-2.0
#
# Makes `pkgs.blueforest-theme` available to the consumer's configuration.
#
# The module deliberately does not touch `programs.vscodium`: which editor
# installs the theme, and whether it is installed at all, stays the
# consumer's decision. For example:
#
#   programs.vscodium.profiles.default.extensions = [
#     pkgs.blueforest-theme
#   ];
{
  ...
}:
{
  nixpkgs.overlays = [ (import ../overlay.nix) ];
}
