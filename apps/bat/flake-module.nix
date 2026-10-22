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

      # The theme of the repository.
      source = ./themes/BlueForest.tmTheme;
    in
    {
      packages.blueforest-bat-theme = theme;

      checks = {
        # The theme of the package is the theme of the repository.
        bat-theme = import ./nix/checks/theme.nix {
          inherit pkgs theme source;
        };

        # The theme is installed in the configuration directory of the user.
        bat-theme-home = import ./nix/checks/home.nix {
          inherit pkgs theme source;
        };

        # The theme is installed in the system-wide configuration directory.
        bat-theme-nixos = import ./nix/checks/nixos.nix {
          inherit pkgs theme source;
        };
      };
    };
}
