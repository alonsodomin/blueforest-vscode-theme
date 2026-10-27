# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest preset for Starship.
#
# The preset is a TOML file, the format Starship reads, and the name of the
# preset is the name of the file: blueforest.
#
# The package carries the preset twice: at its root, so that a consumer can
# read it directly, and in the directory where Starship looks for its presets,
# so that the wrapper of the overlay can bundle it like a shipped preset.
{ lib, pkgs }:
let
  # The version of the application, with the newline of the file removed.
  version = lib.removeSuffix "\n" (builtins.readFile ../VERSION);
in
pkgs.runCommand "blueforest-starship-preset-${version}"
  {
    meta = {
      description = "BlueForest preset for Starship";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0, the preset it carries is CC BY 4.0.
      license = [
        lib.licenses.mpl20
        lib.licenses.cc-by-40
      ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/starship/presets
    cp ${../themes/blueforest.toml} $out/blueforest.toml
    cp ${../themes/blueforest.toml} $out/share/starship/presets/blueforest.toml

    # The attribution of the preset travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
