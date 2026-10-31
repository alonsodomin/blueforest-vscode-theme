#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The Starship part of the Blueforest release.
#
#   1. ask for the next version, when the repository does not hand it over
#   2. ask for the changelog entry
#   3. bump VERSION and add a CHANGELOG.md section
#   4. stage the files that changed
#
# Every application of the repository shares one version, so the release
# script of the repository hands it over in BLUEFOREST_RELEASE_VERSION.
# Without it, the version is asked for here.
#
# Press Enter with an empty value at any prompt to abort.

set -euo pipefail

app_name="starship"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/modules/$app_name"

# shellcheck source=tools/lib/common.sh
source "$repo_root/tools/lib/common.sh"

# --------------------------------------------------------------------------
# preflight
# --------------------------------------------------------------------------

printf '\nBlueforest release: Starship\n'
printf '============================\n'

require git

[ -f "$app_dir/VERSION" ] || die "VERSION not found in $app_dir"
[ -f "$app_dir/CHANGELOG.md" ] || die "CHANGELOG.md not found in $app_dir"

git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
	die "not a git repository: $repo_root"

local_version=$(cat "$app_dir/VERSION")

printf '\nApplication:   %s\n' "$app_name"
printf 'Local version: %s\n' "$local_version"

# --------------------------------------------------------------------------
# 1. version
# --------------------------------------------------------------------------

ask_version

# --------------------------------------------------------------------------
# 2. changelog
# --------------------------------------------------------------------------

ask_changelog "$version" \
	"Added the BlueForest preset for Starship" \
	"Fixed the colour of the git segment"

# --------------------------------------------------------------------------
# 3. apply changes
# --------------------------------------------------------------------------

if [ "$local_version" = "$version" ] && changelog_has "$version"; then
	printf '\n%s is already prepared in VERSION and CHANGELOG.md.\n' "$version"
	printf 'Skipping the file edits and going straight to the commit.\n'
else
	if changelog_has "$version"; then
		die "CHANGELOG.md already has a section for $version"
	fi

	printf '%s\n' "$version" >"$app_dir/VERSION"

	bullets_file=$(mktemp)
	write_bullets "$bullets_file" "${bullets[@]}"
	add_release_section "$(release_heading "$version")" "$bullets_file"
	rm -f "$bullets_file"

	show_diff "modules/$app_name/VERSION" "modules/$app_name/CHANGELOG.md"
fi

# --------------------------------------------------------------------------
# 4. stage the changes
# --------------------------------------------------------------------------

git -C "$repo_root" add "modules/$app_name/VERSION" "modules/$app_name/CHANGELOG.md"

printf '\n%s is ready for the release.\n' "$version"
