#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# The parts of the release of an application that every application shares.
#
# The script of an application sources this file, and the script of the
# repository sources it as well. It holds the prompts, the version and the
# changelog, so that neither of them has to repeat them.
#
# The functions work on the variables of the caller:
#
#   app_dir       the directory of the application
#   app_name      the name of the application
#   local_version the version the application carries now
#   repo_root     the root of the repository
#
# They are declared here, so that the shell does not complain about them.
: "${app_name:=}"
: "${app_dir:=}"
: "${local_version:=}"
: "${repo_root:=}"

# The exit code of an abort. The script of the repository tells it from a
# failure, and stops the release without committing anything.
readonly ABORTED=2

abort() {
	printf '\nAborted. Nothing has been changed.\n'
	exit "$ABORTED"
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

# True when the changelog of the application has a section for the version.
changelog_has() {
	grep -q "^## $1 - " "$app_dir/CHANGELOG.md"
}

# Shows the changes of the files of the application that are about to be
# committed.
show_diff() {
	printf '\nChanges to be committed:\n'
	git -C "$repo_root" --no-pager diff --stat -- "$@"
	git -C "$repo_root" --no-pager diff -- "$@"
}

# The heading of the section of a release.
release_heading() {
	printf '## %s - [%s]\n' "$1" "$(date +%d-%m-%Y)"
}

# Writes the bullets of a section to a file, one per line, and a blank line
# after them.
write_bullets() {
	local file="$1"
	shift

	printf '%s\n' "$@" >"$file"
	printf '\n' >>"$file"
}

# Adds the section of a release to the changelog of the application.
#
# The section goes before the first section of the changelog. When the
# changelog has a pending "Unreleased" section, that section becomes the
# section of the release, and its bullets come before the ones of the release.
add_release_section() {
	local heading="$1" bullets_file="$2"
	local merged

	merged=$(mktemp)
	awk -v heading="$heading" -v bulletsfile="$bullets_file" '
		/^## / && !inserted {
			inserted = 1
			print heading
			print ""

			if ($0 == "## Unreleased") {
				# The pending section becomes the section of the release.
				started = 0
				while ((getline line) > 0) {
					if (line ~ /^## /) {
						print line
						break
					}
					if (!started && line ~ /^[[:space:]]*$/) {
						continue
					}
					started = 1
					print line
				}
				while ((getline line < bulletsfile) > 0) print line
				close(bulletsfile)
				next
			}

			while ((getline line < bulletsfile) > 0) print line
			close(bulletsfile)
		}
		{ print }
	' "$app_dir/CHANGELOG.md" >"$merged"

	mv "$merged" "$app_dir/CHANGELOG.md"
}

# Asks for the version of the release, when the repository does not hand it
# over, and leaves it in $version.
ask_version() {
	if [ -n "${BLUEFOREST_RELEASE_VERSION:-}" ]; then
		version="$BLUEFOREST_RELEASE_VERSION"
		is_semver "$version" || die "not a MAJOR.MINOR.PATCH version: $version"
		if ! version_gt "$version" "$local_version"; then
			if [ "$version" != "$local_version" ] || ! changelog_has "$version"; then
				die "must be newer than the version in VERSION ($local_version)"
			fi
		fi
		return
	fi

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
		# Equal to the current version is allowed, so that an interrupted
		# release can be run again.
		if [ "$version" != "$local_version" ] && ! version_gt "$version" "$local_version"; then
			printf 'Must be newer than the version in VERSION (%s).\n' "$local_version"
			continue
		fi
		break
	done
}

# Asks for the changelog of the release, one bullet per line, and leaves the
# bullets in the array $bullets. The arguments after the version are the
# examples of the bullets.
ask_changelog() {
	local version="$1"
	shift

	printf '\nEnter the changelog for %s, one bullet per line.\n' "$version"
	printf 'Finish with an empty line. Press Enter alone on the first line to abort.\n'
	printf '\n'

	local example
	for example in "$@"; do
		printf '  %s\n' "$example"
	done
	printf '\n'

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
}
