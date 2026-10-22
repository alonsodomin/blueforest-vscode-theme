# Adds the BlueForest theme to a nixpkgs instance as `blueforest-theme`.
#
# The extension is built with the overlaid nixpkgs, so it always matches the
# VS Code version of the editor it is installed into.
final: _prev: {
  blueforest-theme = import ./extension.nix { pkgs = final; };
}
