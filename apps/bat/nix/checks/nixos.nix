# SPDX-License-Identifier: MPL-2.0
#
# Checks that the setup hook installs the theme in the system-wide
# configuration directory of bat, which is where the activation of a NixOS
# system puts it.
#
# The check cannot write to /etc, so the directories and the copy are
# recorded instead of being made.
{
  pkgs,
  theme,
  source,
}:
pkgs.runCommand "blueforest-bat-theme-nixos-check"
  {
    nativeBuildInputs = [ pkgs.coreutils ];
  }
  ''
    log="$TMPDIR/install.log"

    mkdir -p "$TMPDIR/bin"

    # A stub of id, so that the hook believes it runs as root.
    cat > "$TMPDIR/bin/id" <<'STUB'
    #!/bin/sh
    echo 0
    STUB

    # A stub of bat, so that the hook finds it.
    cat > "$TMPDIR/bin/bat" <<'STUB'
    #!/bin/sh
    echo "$BAT_CONFIG_DIR"
    STUB

    # Stubs of mkdir and cp, so that the check sees where the theme would
    # be installed without installing it.
    cat > "$TMPDIR/bin/mkdir" <<'STUB'
    #!/bin/sh
    echo "mkdir $*" >> "$BAT_INSTALL_LOG"
    STUB
    cat > "$TMPDIR/bin/cp" <<'STUB'
    #!/bin/sh
    echo "cp $*" >> "$BAT_INSTALL_LOG"
    STUB

    chmod +x "$TMPDIR/bin"/*

    PATH="$TMPDIR/bin:$PATH" \
      BAT_CONFIG_DIR="$TMPDIR/config" \
      BAT_INSTALL_LOG="$log" \
      out=${theme} \
      bash ${theme}/setup-hook

    grep -q "/etc/bat/themes" "$log"

    touch $out
  ''
