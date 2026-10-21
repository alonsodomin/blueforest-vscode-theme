{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "release";

  text = ''exec ${./release.sh} "$@"'';
  inheritPath = false;
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gawk
    pkgs.gnused
    pkgs.gnugrep
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.gh
  ];
}
