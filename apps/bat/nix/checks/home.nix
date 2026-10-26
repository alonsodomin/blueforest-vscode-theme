# SPDX-License-Identifier: MPL-2.0
#
# Checks that the setup hook installs the theme in the configuration
# directory of bat, which is where the user of Home Manager looks for it.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-bat-theme-home-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    config_dir="$TMPDIR/config"

    mkdir -p "$TMPDIR/bin"

    # A stub of id, so that the hook takes the branch of the user whatever
    # the builder is, and a stub of bat, which reports the configuration
    # directory the check gives it.
    cat > "$TMPDIR/bin/id" <<'STUB'
    #!/bin/sh
    echo 1000
    STUB
    cat > "$TMPDIR/bin/bat" <<'STUB'
    #!/bin/sh
    echo "$BAT_CONFIG_DIR"
    STUB
    chmod +x "$TMPDIR/bin"/*

    PATH="$TMPDIR/bin:$PATH" \
      BAT_CONFIG_DIR="$config_dir" \
      out=${theme} \
      bash ${theme}/setup-hook

    test -f "$config_dir/themes/BlueForest.tmTheme"
    cmp "$config_dir/themes/BlueForest.tmTheme" ${source}

    touch $out
  ''
