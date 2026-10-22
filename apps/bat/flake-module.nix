# The BlueForest theme for bat, as a flake-parts module.
#
# The root flake imports this module through the flake of the application,
# and the flake of the application imports it itself. Both of them therefore
# agree on what the application provides.
{
  config,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    let
      theme = import ./nix/theme.nix {
        inherit lib pkgs;
      };
    in
    {
      packages.blueforest-bat-theme = theme;

      # The theme of the package is the theme of the repository.
      checks.bat-theme = pkgs.runCommand "blueforest-bat-theme-check" { } ''
        cmp ${theme}/share/bat/themes/BlueForest.tmTheme ${./themes/BlueForest.tmTheme}
        touch $out
      '';
    };
}
