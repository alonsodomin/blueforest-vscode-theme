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

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

abort() {
	printf '\nAborted. Nothing has been changed.\n'
	exit 0
}

die() {
	printf '\nError: %s\n' "$1" >&2
	exit 1
}

require() {
	command -v "$1" >/dev/null 2>&1 || die "missing required program: $1"
}

# MAJOR.MINOR.PATCH, no leading zeros, no pre-release suffix.
is_semver() {
	[[ $1 =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]
}

# True when $1 is strictly greater than $2.
version_gt() {
	local newer="$1" older="$2"
	if [ "$newer" = "$older" ]; then
		return 1
	fi
	[ "$(printf '%s\n%s\n' "$older" "$newer" | sort -V | tail -n1)" = "$newer" ]
}

changelog_has() {
	grep -q "^## $1 - " "$app_dir/CHANGELOG.md"
}

show_diff() {
	printf '\nChanges to be committed:\n'
	git -C "$repo_root" --no-pager diff --stat -- \
		"modules/$app_name/VERSION" "modules/$app_name/CHANGELOG.md"
	git -C "$repo_root" --no-pager diff -- \
		"modules/$app_name/VERSION" "modules/$app_name/CHANGELOG.md"
}

# --------------------------------------------------------------------------
# preflight
# --------------------------------------------------------------------------

printf '\nBlueforest release: Starship\n'
printf '===========================\n'

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

if [ -n "${BLUEFOREST_RELEASE_VERSION:-}" ]; then
	version="$BLUEFOREST_RELEASE_VERSION"
	is_semver "$version" || die "not a MAJOR.MINOR.PATCH version: $version"
	if ! version_gt "$version" "$local_version"; then
		if [ "$version" != "$local_version" ] || ! changelog_has "$version"; then
			die "must be newer than the version in VERSION ($local_version)"
		fi
	fi
else
	while :; do
		printf '\nEnter the next version (%s is the current one).\n' "$local_version"
		printf 'Press Enter alone to abort: '
		if ! IFS= read -r version; then
			abort
		fi
		if [ -z "$version" ]; then
			abort
		fi
		if ! is_semver "$version"; then
			printf 'Not a MAJOR.MINOR.PATCH version: %s\n' "$version"
			continue
		fi
		# Equal to VERSION is allowed so an interrupted release can be re-run.
		if [ "$version" != "$local_version" ] && ! version_gt "$version" "$local_version"; then
			printf 'Must be newer than the version in VERSION (%s).\n' "$local_version"
			continue
		fi
		break
	done
fi

# --------------------------------------------------------------------------
# 2. changelog
# --------------------------------------------------------------------------

printf '\nEnter the changelog for %s, one bullet per line.\n' "$version"
printf 'Finish with an empty line. Press Enter alone on the first line to abort.\n'
printf '\n  Added the BlueForest preset for Starship\n'
printf '  Fixed the colour of the git segment\n\n'

bullets=()
while IFS= read -r line; do
	if [ -z "$line" ]; then
		break
	fi
	# The bullet is written here, so a dash the user typed is dropped.
	bullets+=("- ${line#- }")
done

if [ "${#bullets[@]}" -eq 0 ]; then
	abort
fi

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

	section=$(mktemp)
	{
		printf '## %s - [%s]\n\n' "$version" "$(date +%d-%m-%Y)"
		printf '%s\n' "${bullets[@]}"
		printf '\n'
	} >"$section"

	merged=$(mktemp)
	awk -v sectfile="$section" '
		/^## / && !inserted {
			while ((getline line < sectfile) > 0) print line
			close(sectfile)
			inserted = 1
		}
		{ print }
	' "$app_dir/CHANGELOG.md" >"$merged"
	mv "$merged" "$app_dir/CHANGELOG.md"
	rm -f "$section"

	show_diff
fi

# --------------------------------------------------------------------------
# 4. stage the changes
# --------------------------------------------------------------------------

git -C "$repo_root" add "modules/$app_name/VERSION" "modules/$app_name/CHANGELOG.md"

printf '\n%s is ready for the release.\n' "$version"
