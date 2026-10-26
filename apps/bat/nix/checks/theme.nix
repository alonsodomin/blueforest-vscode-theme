# SPDX-License-Identifier: MPL-2.0
#
# Checks that the theme of the package is the theme of the repository.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-bat-theme-check" { } ''
  cmp ${theme}/share/bat/themes/BlueForest.tmTheme ${source}
  touch $out
''
