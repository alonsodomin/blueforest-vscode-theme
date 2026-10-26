# SPDX-License-Identifier: MPL-2.0
#
# Checks that Starship parses and renders the preset of the package.
#
# Rendering the prompt exercises the whole preset: a malformed TOML or a value
# Starship cannot read makes Starship report an error. Starship does not fail
# on such an error, so the check reads what it writes to the error stream.
{
  pkgs,
  preset,
}:
pkgs.runCommand "blueforest-starship-render-check"
  {
    nativeBuildInputs = [ pkgs.starship ];
  }
  ''
    export STARSHIP_CONFIG=${preset}/share/starship/presets/blueforest.toml
    export HOME=$TMPDIR
    export TERM=xterm-256color

    # The prompt of a healthy preset is not empty.
    starship prompt >$TMPDIR/prompt
    test -s $TMPDIR/prompt

    # And Starship does not complain about the preset.
    starship prompt 2>$TMPDIR/errors >/dev/null
    test ! -s $TMPDIR/errors

    touch $out
  ''
