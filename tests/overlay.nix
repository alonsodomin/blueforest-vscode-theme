# SPDX-License-Identifier: MPL-2.0
#
# Checks that the overlay of the repository adds the packages of every
# application.
#
# The overlay is the one a consumer applies to a nixpkgs instance, so it is
# checked the way a consumer uses it: applied to a nixpkgs instance, and the
# packages are looked up in the result.
{
  pkgs,
  overlay,
  expected,
}:
let
  # The nixpkgs instance the overlay is applied to.
  base = import pkgs.path {
    system = pkgs.stdenv.hostPlatform.system;
  };

  # The instance the consumer ends up with.
  overlaid = import pkgs.path {
    system = pkgs.stdenv.hostPlatform.system;
    overlays = [ overlay ];
  };
in
pkgs.runCommand "blueforest-overlay-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    result = builtins.toJSON {
      packages = builtins.filter (name: builtins.hasAttr name overlaid) expected;
      # The overlay adds the packages of the applications, and nothing else.
      # The Starship of nixpkgs stays as it is.
      starshipUntouched = overlaid.starship == base.starship;
    };
    expected = builtins.toJSON expected;
  }
  ''
    echo "$result" | jq -e '
      .starshipUntouched
      and (.packages | length) > 0
    ' >/dev/null

    # Every expected package has to be there.
    missing=$(echo "$result" | jq -r --argjson expected "$expected" '
      $expected - .packages | join(" ")
    ')
    if [ -n "$missing" ]; then
      echo "the overlay does not add: $missing" >&2
      exit 1
    fi

    touch $out
  ''
