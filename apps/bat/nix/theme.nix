# The BlueForest theme for bat.
#
# The theme is a TextMate file, the format bat reads, and the name of the
# theme is the name of the file: BlueForest.
#
# The setup hook puts the theme where bat looks for it: the system-wide
# configuration directory when it runs as root, which is what the activation
# of a NixOS system does, and the configuration directory of the user
# otherwise, which is what Home Manager does in the session of the user.
{ lib, pkgs }:
let
  # The version of the application, with the newline of the file removed.
  version = lib.removeSuffix "\n" (builtins.readFile ../VERSION);
in
pkgs.runCommand "blueforest-bat-theme-${version}" { } ''
  rm -f $out
  mkdir -p $out/share/bat/themes
  cp ${../themes/BlueForest.tmTheme} $out/share/bat/themes/BlueForest.tmTheme

  cat > $out/setup-hook <<'HOOK'
    # The theme goes where bat looks for it, and bat has to be there to say
    # where that is.
    if ! command -v bat >/dev/null 2>&1; then
      echo "bat is not installed, so the BlueForest theme is not installed either." >&2
      exit 0
    fi

    if [ "$(id -u)" = "0" ]; then
      # The activation of a NixOS system runs as root, and the system-wide
      # configuration of bat lives in /etc/bat.
      config_dir="/etc/bat"
    else
      config_dir="$(bat --config-dir)"
    fi

    mkdir -p "$config_dir/themes"
    cp -f "$out/share/bat/themes/BlueForest.tmTheme" "$config_dir/themes/BlueForest.tmTheme"
  HOOK
''
