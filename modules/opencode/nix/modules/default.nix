# SPDX-License-Identifier: MPL-2.0
#
# Makes the BlueForest theme for OpenCode available to the consumer's
# configuration.
#
# The module does not enable OpenCode: the theme is part of the configuration
# of OpenCode, and Home Manager writes that configuration only when the
# program is enabled. A consumer that wants the theme enables the program,
# and the theme comes with it:
#
#   programs.opencode.enable = true;
#
# The module does not touch `programs.opencode.package` either: the OpenCode
# of the consumer is the one it wants.
{
  lib,
  ...
}:
{
  nixpkgs.overlays = [ (import ../overlay.nix) ];

  programs.opencode = {
    # The theme, under the name OpenCode reads the name of the theme from:
    # the name of the file.
    themes.blueforest = lib.mkDefault ../../themes/blueforest.json;

    # The selection of the theme, in the file OpenCode 2 reads at runtime.
    cli.theme = lib.mkDefault {
      name = "blueforest";
      mode = "dark";
    };
  };
}
