# SPDX-License-Identifier: MPL-2.0
#
# Checks that every application carries the version of the repository.
#
# The applications keep their own copy of it, because a consumer that
# installs a single application only gets that application.
{ pkgs }:
pkgs.runCommand "blueforest-version-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
    src = ../.;
  }
  ''
    cd "$src"

    expected=$(cat VERSION)

    for file in modules/*/VERSION; do
      actual=$(cat "$file")
      if [ "$actual" != "$expected" ]; then
        echo "$file has version $actual, the repository has $expected" >&2
        exit 1
      fi
    done

    for file in modules/*/package.json; do
      actual=$(jq -r '.version' "$file")
      if [ "$actual" != "$expected" ]; then
        echo "$file has version $actual, the repository has $expected" >&2
        exit 1
      fi
    done

    touch $out
  ''
