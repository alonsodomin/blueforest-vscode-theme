#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The VS Code part of the Blueforest release.
#
#   1. ask for the next version and validate it against Open VSX
#   2. ask for the changelog entry
#   3. bump package.json and add a CHANGELOG.md section
#   4. stage the files that changed
#
# Every application of the repository shares one version, so the release
# script of the repository hands it over in BLUEFOREST_RELEASE_VERSION.
# Without it, the version is asked for here.
#
# Press Enter with an empty value at any prompt to abort.

set -euo pipefail

app_name="vscode"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
app_dir="$repo_root/modules/$app_name"

# shellcheck source=tools/lib/common.sh
source "$repo_root/tools/lib/common.sh"

OVSX_API="https://open-vsx.org/api"

# Published state, filled in by fetch_published.
PUBLISHED_VERSION=""
PUBLISHED_AT=""

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

# Sets PUBLISHED_VERSION and PUBLISHED_AT from open-vsx.org.
fetch_published() {
	local publisher="$1" name="$2" response status body
	response=$(curl -sS --max-time 30 -w $'\n%{http_code}' \
		"${OVSX_API}/${publisher}/${name}") || return 1
	status=${response##*$'\n'}
	body=${response%$'\n'*}
	case $status in
	200)
		PUBLISHED_VERSION=$(printf '%s' "$body" | jq -r '.version // empty')
		PUBLISHED_AT=$(printf '%s' "$body" | jq -r '.timestamp // "unknown"')
		;;
	404)
		PUBLISHED_VERSION=""
		PUBLISHED_AT=""
		;;
	*)
		printf 'open-vsx.org returned HTTP %s for %s/%s\n' \
			"$status" "$publisher" "$name" >&2
		return 1
		;;
	esac
}

# --------------------------------------------------------------------------
# preflight
# --------------------------------------------------------------------------

printf '\nBlueforest release: VS Code\n'
printf '==========================\n'

for tool in git curl jq; do
	require "$tool"
done

[ -f "$app_dir/package.json" ] || die "package.json not found in $app_dir"
[ -f "$app_dir/CHANGELOG.md" ] || die "CHANGELOG.md not found in $app_dir"

git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
	die "not a git repository: $repo_root"

publisher=$(jq -r '.publisher' "$app_dir/package.json")
name=$(jq -r '.name' "$app_dir/package.json")
local_version=$(jq -r '.version' "$app_dir/package.json")

fetch_published "$publisher" "$name" ||
	die "could not read the published version from open-vsx.org"

printf '\nExtension:     %s/%s\n' "$publisher" "$name"
printf 'Local version: %s\n' "$local_version"
if [ -n "$PUBLISHED_VERSION" ]; then
	printf 'Open VSX:      %s (published %s)\n' \
		"$PUBLISHED_VERSION" "$PUBLISHED_AT"
else
	printf 'Open VSX:      not published yet\n'
fi

# --------------------------------------------------------------------------
# 1. version
# --------------------------------------------------------------------------

if [ -n "${BLUEFOREST_RELEASE_VERSION:-}" ]; then
	version="$BLUEFOREST_RELEASE_VERSION"
	is_semver "$version" || die "not a MAJOR.MINOR.PATCH version: $version"
	if [ -n "$PUBLISHED_VERSION" ] && ! version_gt "$version" "$PUBLISHED_VERSION"; then
		die "must be newer than the published version $PUBLISHED_VERSION"
	fi
else
	if [ -n "$PUBLISHED_VERSION" ] && [ "$local_version" != "$PUBLISHED_VERSION" ]; then
		printf '\nHeads up: package.json (%s) and Open VSX (%s) disagree.\n' \
			"$local_version" "$PUBLISHED_VERSION"
	fi

	while :; do
		printf '\nEnter the next version (%s is published).\n' \
			"${PUBLISHED_VERSION:-none}"
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
		if [ -n "$PUBLISHED_VERSION" ] && ! version_gt "$version" "$PUBLISHED_VERSION"; then
			printf 'Must be newer than the published version (%s).\n' "$PUBLISHED_VERSION"
			continue
		fi
		# Equal to package.json is allowed so an interrupted release can be re-run.
		if [ "$version" != "$local_version" ] && ! version_gt "$version" "$local_version"; then
			printf 'Must be newer than the version in package.json (%s).\n' "$local_version"
			continue
		fi
		break
	done
fi

# --------------------------------------------------------------------------
# 2. changelog
# --------------------------------------------------------------------------

ask_changelog "$version" \
	"Improved syntax highlighting for TypeScript" \
	"Fixed bracket colour in the dark theme"

# --------------------------------------------------------------------------
# 3. apply changes
# --------------------------------------------------------------------------

if [ "$local_version" = "$version" ] && changelog_has "$version"; then
	printf '\n%s is already prepared in package.json and CHANGELOG.md.\n' "$version"
	printf 'Skipping the file edits and going straight to the commit.\n'
else
	if changelog_has "$version"; then
		die "CHANGELOG.md already has a section for $version"
	fi

	tmp=$(mktemp)
	jq --indent 2 --arg v "$version" '.version = $v' \
		"$app_dir/package.json" >"$tmp"
	mv "$tmp" "$app_dir/package.json"

	bullets_file=$(mktemp)
	write_bullets "$bullets_file" "${bullets[@]}"
	add_release_section "$(release_heading "$version")" "$bullets_file"
	rm -f "$bullets_file"

	show_diff "modules/$app_name/package.json" "modules/$app_name/CHANGELOG.md"
fi

# --------------------------------------------------------------------------
# 4. stage the changes
# --------------------------------------------------------------------------

git -C "$repo_root" add "modules/$app_name/package.json" "modules/$app_name/CHANGELOG.md"

printf '\n%s is ready for the release.\n' "$version"
