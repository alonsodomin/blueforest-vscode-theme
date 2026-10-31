# SPDX-License-Identifier: MPL-2.0
#
# The BlueForest prompt for sbt.
#
# The package carries the two .sbt files: the declaration of the sbt-prompt
# plugin and the selection of its BlueforestTheme. It does not carry the
# prompt itself, which is defined upstream at
# https://github.com/alonsodomin/sbt-prompt.
#
# The files mirror the layout of the global configuration of sbt, so that a
# consumer can wire them by hand:
#
#   share/sbt/plugins/sbt-prompt.sbt
#   share/sbt/blueforest-prompt.sbt
{ lib, pkgs }:
let
  # The version of the application, with the newline of the file removed.
  version = lib.removeSuffix "\n" (builtins.readFile ../VERSION);
in
pkgs.runCommand "blueforest-sbt-prompt-${version}"
  {
    meta = {
      description = "BlueForest prompt for sbt";
      homepage = "https://github.com/alonsodomin/blueforest-theme";
      # The packaging is MPL-2.0. The prompt itself is the one of the
      # sbt-prompt plugin, which is MIT.
      license = lib.licenses.mpl20;
      platforms = lib.platforms.all;
    };
  }
  ''
    mkdir -p $out/share/sbt/plugins

    install -m644 ${../config/sbt-prompt.sbt} $out/share/sbt/plugins/sbt-prompt.sbt
    install -m644 ${../config/blueforest-prompt.sbt} $out/share/sbt/blueforest-prompt.sbt

    # The attribution of the prompt travels with the package.
    mkdir -p $out/share/doc/blueforest
    install -m644 ${../NOTICE.md} $out/share/doc/blueforest/NOTICE.md
    install -m644 ${../LICENSE} $out/share/doc/blueforest/LICENSE
  ''
