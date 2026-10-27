# SPDX-License-Identifier: MPL-2.0
#
# Checks that the packaged preset is the preset of the repository.
{
  pkgs,
  preset,
  source,
}:
pkgs.runCommand "blueforest-starship-preset-check" { } ''
  cmp ${preset}/blueforest.toml ${source}
  cmp ${preset}/share/starship/presets/blueforest.toml ${source}
  touch $out
''
