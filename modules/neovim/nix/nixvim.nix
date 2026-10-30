# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for Neovim, as a module of nixvim.
#
# The module belongs to the configuration of nixvim, and not to the
# configuration of the system: nixvim builds an instance of nixpkgs of its
# own, so the overlay of the consumer does not reach it, and the theme has to
# be installed among the plugins of nixvim.
#
#   programs.nixvim = {
#     imports = [ blueforest.nixvimModules.neovim ];
#     enable = true;
#   };
{
  lib,
  pkgs,
  ...
}:
{
  # The overlay of the theme, in the nixpkgs of nixvim.
  nixpkgs.overlays = [ (import ./overlay.nix) ];

  # The theme is a plugin of Neovim.
  extraPlugins = [ pkgs.blueforest-neovim-theme ];

  # The colourscheme is selected by its name. The consumer can select
  # another one: this is only the default.
  colorscheme = lib.mkDefault "blueforest";
}
