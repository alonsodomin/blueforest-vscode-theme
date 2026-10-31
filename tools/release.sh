#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
#
# Release helper for the BlueForest themes.
#
#   release.sh <app>   release one application, e.g. "vscode"
#   release.sh all     release every application
#
# The application specific part of the release lives in tools/lib/<app>.sh:
# it checks the published version, asks for the changelog and updates the
# files of the application. This script picks the applications, asks for the
# version they all share, and then commits, pushes and triggers the release
# workflow of the repository.
#
# Press Enter with an empty value at any prompt to abort. The commit message
# prompt is the exception: an empty value accepts the offered default.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
	printf '\nError: not a git repository.\n' >&2
	exit 1
fi

lib_dir="$repo_root/tools/lib"
version_file="$repo_root/VERSION"
workflow="release.yml"

# shellcheck source=tools/lib/common.sh
source "$lib_dir/common.sh"

PUBLISH_MS=true
PUBLISH_OVSX=true
PUBLISH_GH=true

# The applications of this repository are the scripts in tools/lib.
applications=()
for script in "$lib_dir"/*.sh; do
	[ -e "$script" ] || continue
	[ "$(basename "$script")" = "common.sh" ] && continue
	applications+=("$(basename "$script" .sh)")
done

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

usage() {
	printf 'Usage: %s <app>|all\n\n' "$(basename "$0")"
	printf 'Applications: %s\n' "${applications[*]:-none}"
}

# The abort of the repository is its own: the release stops, and the exit code
# says that nothing happened.
abort() {
	printf '\nAborted. Nothing has been changed.\n'
	exit 0
}

# Used at the final prompt, where the release is already committed and pushed.
skip_trigger() {
	printf '\nSkipped the CI trigger. %s is committed and pushed to %s.\n' \
		"$version" "$branch"
	printf 'Start the Release workflow from the Actions tab when you are ready.\n'
	exit 0
}

# The workflow input that selects an application.
workflow_input() {
	case "$1" in
	vscode) printf 'publishVSCode\n' ;;
	bat) printf 'publishBat\n' ;;
	neovim) printf 'publishNeovim\n' ;;
	starship) printf 'publishStarship\n' ;;
	opencode) printf 'publishOpencode\n' ;;
	*) printf 'publish%s\n' "$1" ;;
	esac
}

# --------------------------------------------------------------------------
# 1. the applications to release
# --------------------------------------------------------------------------

printf '\nBlueforest release\n'
printf '===================\n'

target="${1:-}"
case "$target" in
all)
	if [ "${#applications[@]}" -eq 0 ]; then
		die "there are no applications to release"
	fi
	selected=("${applications[@]}")
	;;
"")
	usage
	exit 1
	;;
*)
	if [ ! -f "$lib_dir/$target.sh" ]; then
		die "unknown application: $target"
	fi
	selected=("$target")
	;;
esac

for tool in git curl jq gh; do
	require "$tool"
done

[ -f "$version_file" ] || die "version file not found: $version_file"
[ -f "$repo_root/.github/workflows/$workflow" ] ||
	die "workflow not found: .github/workflows/$workflow"

branch=$(git -C "$repo_root" rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then
	die "detached HEAD; check out a branch before releasing"
fi

if [ -n "$(git -C "$repo_root" status --porcelain)" ]; then
	printf '\nNote: the working tree has uncommitted changes.\n'
	printf '      Only the files of the release will be committed.\n'
fi

if ! gh auth status >/dev/null 2>&1; then
	# Hard stop: the version is committed and pushed before the trigger runs,
	# so starting without a working gh would discover the problem far too late.
	die "gh is not authenticated, so the CI workflow could not be triggered. Run: gh auth login"
fi

current_version="$(cat "$version_file")"

printf '\nBranch:        %s\n' "$branch"
printf 'Current version: %s\n' "$current_version"
printf 'Applications:  %s\n' "${selected[*]}"

# --------------------------------------------------------------------------
# 2. the version every application shares
# --------------------------------------------------------------------------

if [ -n "${BLUEFOREST_RELEASE_VERSION:-}" ]; then
	version="$BLUEFOREST_RELEASE_VERSION"
	is_semver "$version" || die "not a MAJOR.MINOR.PATCH version: $version"
	version_gt "$version" "$current_version" ||
		die "must be newer than the current version ($current_version)"
else
	while :; do
		printf '\nEnter the next version (%s is the current one).\n' "$current_version"
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
		if ! version_gt "$version" "$current_version"; then
			printf 'Must be newer than the current version (%s).\n' "$current_version"
			continue
		fi
		break
	done
fi

# --------------------------------------------------------------------------
# 3. the applications
# --------------------------------------------------------------------------

for app in "${selected[@]}"; do
	printf '\n==> %s\n\n' "$app"

	# The script of the application exits with 2 when the user aborts, and
	# with anything else than 0 when it fails.
	status=0
	BLUEFOREST_RELEASE_VERSION="$version" "$lib_dir/$app.sh" || status=$?

	if [ "$status" -eq 2 ]; then
		# The user aborted: the release stops here, and nothing is
		# committed nor pushed.
		printf '\nAborted. Nothing has been committed and nothing has been pushed.\n'
		exit 0
	elif [ "$status" -ne 0 ]; then
		die "the release of $app failed"
	fi
done

# The applications that have no release script of their own still carry the
# version of the repository: the version of their package comes from it, and
# the check of the repository makes sure that every application agrees with
# the version of the repository.
for app_dir in "$repo_root"/modules/*/; do
	app=$(basename "$app_dir")
	app_dir="${app_dir%/}"
	app_version_file="$app_dir/VERSION"

	if [ ! -f "$app_version_file" ]; then
		continue
	fi

	if [ -f "$lib_dir/$app.sh" ]; then
		# The script of the application took care of it.
		continue
	fi

	if [ "$(cat "$app_version_file")" = "$version" ]; then
		continue
	fi

	printf '\n==> %s\n\n' "$app"

	ask_changelog "$version" \
		"The version of the application follows the version of the repository"

	printf '%s\n' "$version" >"$app_version_file"

	bullets_file=$(mktemp)
	write_bullets "$bullets_file" "${bullets[@]}"
	add_release_section "$(release_heading "$version")" "$bullets_file"
	rm -f "$bullets_file"

	git -C "$repo_root" add "modules/$app/VERSION" "modules/$app/CHANGELOG.md"
done

# The version is shared, so it lives in one place. The applications keep a
# copy of it, and the check of the repository makes sure they agree.
printf '%s\n' "$version" >"$version_file"

# --------------------------------------------------------------------------
# 4. commit message
# --------------------------------------------------------------------------

default_message="Release $version"
printf '\nCommit message [%s]: ' "$default_message"
if ! IFS= read -r commit_message; then
	commit_message=""
fi
if [ -z "$commit_message" ]; then
	commit_message="$default_message"
fi

# --------------------------------------------------------------------------
# 5. commit and push
# --------------------------------------------------------------------------

git -C "$repo_root" add VERSION

if git -C "$repo_root" diff --cached --quiet; then
	printf '\nNothing staged to commit.\n'
else
	git -C "$repo_root" commit -m "$commit_message"
fi

git -C "$repo_root" push

# --------------------------------------------------------------------------
# 6. trigger
# --------------------------------------------------------------------------

printf '\n%s has been pushed to %s.\n' "$version" "$branch"

while :; do
	printf '\nTrigger the CI release workflow now?\n'
	printf 'It will publish to the Marketplace (%s), Open VSX (%s) and GitHub (%s).\n' \
		"$PUBLISH_MS" "$PUBLISH_OVSX" "$PUBLISH_GH"
	printf 'Type the whole word "yes" to continue, Enter alone to skip: '
	if ! IFS= read -r answer; then
		answer=""
	fi
	if [ "$answer" = "yes" ]; then
		break
	fi
	if [ -z "$answer" ]; then
		skip_trigger
	fi
	printf 'Please type the whole word "yes", or press Enter alone to skip.\n'
done

trigger_args=()
for app in "${selected[@]}"; do
	trigger_args+=(-f "$(workflow_input "$app")=true")
done

gh workflow run "$workflow" --ref "$branch" \
	-f "publishMS=$PUBLISH_MS" \
	-f "publishOVSX=$PUBLISH_OVSX" \
	-f "publishGH=$PUBLISH_GH" \
	"${trigger_args[@]}"

repo_url=$(gh repo view --json url --jq .url)
printf '\nTriggered. Watch the run at:\n  %s/actions/workflows/%s\n' \
	"$repo_url" "$workflow"
