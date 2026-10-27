# SPDX-License-Identifier: MPL-2.0
#
# Checks that the wrapper is Starship with the preset of the repository.
{
  pkgs,
  wrapper,
  source,
}:
pkgs.runCommand "blueforest-starship-wrapper-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    test -x ${wrapper}/bin/starship
    cmp ${wrapper}/share/starship/presets/blueforest.toml ${source}

    export STARSHIP_CONFIG=${wrapper}/share/starship/presets/blueforest.toml
    export HOME=$TMPDIR
    export TERM=xterm-256color

    ${wrapper}/bin/starship prompt >$TMPDIR/prompt
    test -s $TMPDIR/prompt

    ${wrapper}/bin/starship prompt 2>$TMPDIR/errors >/dev/null
    test ! -s $TMPDIR/errors

    touch $out
  ''
