# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest theme for OpenCode.
#
# The theme is a JSON file, the format OpenCode 2 reads, and the name of the
# theme is the name of the file: blueforest.
#
# The package carries the theme twice: at its root, so that a consumer can
# read it directly, and in the directory where OpenCode looks for its
# themes, so that a consumer can hand it over to the themes of OpenCode.
{ lib, pkgs }:
let
  # The version of the application, with the newline of the file removed.
  version = lib.removeSuffix "\n" (builtins.readFile ../VERSION);
in
pkgs.runCommand "blueforest-opencode-theme-${version}"
  {
    meta = {
      description = "BlueForest theme for OpenCode";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0, the theme it carries is CC BY 4.0.
      license = [
        lib.licenses.mpl20
        lib.licenses.cc-by-40
      ];
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/opencode/themes
    cp ${../themes/blueforest.json} $out/blueforest.json
    cp ${../themes/blueforest.json} $out/share/opencode/themes/blueforest.json

    # The attribution of the theme travels with the package.
    mkdir -p $out/share/doc/blueforest
    cp ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    cp ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
