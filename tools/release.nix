# The release helper of the repository.
#
# tools/release.sh picks the application that is being released and hands it
# over to the script of that application. The wrapper only supplies a
# hermetic PATH with the tools the script needs.
{ pkgs }:
pkgs.writeShellApplication {
  name = "release";
  text = ''exec ${./release.sh} "$@"'';
  inheritPath = false;
  runtimeInputs = [
    pkgs.bash
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
