#!/usr/bin/env bash
#
# Interactive release helper for the Blueforest theme.
#
#   1. ask for the next version and validate it against Open VSX
#   2. ask for the changelog entry
#   3. ask for a commit message (default: "Release <version>")
#   4. bump package.json and add a CHANGELOG.md section
#   5. commit and push
#   6. ask whether to trigger the CI release workflow
#
# Press Enter with an empty value at any prompt to abort. The commit message
# prompt is the exception: an empty value accepts the offered default.

set -euo pipefail

root="${PRJ_ROOT:-$PWD}"
cd "$root"

OVSX_API="https://open-vsx.org/api"
WORKFLOW="release.yml"
PUBLISH_MS=true
PUBLISH_OVSX=true
PUBLISH_GH=true

# Published state, filled in by fetch_published.
PUBLISHED_VERSION=""
PUBLISHED_AT=""

# --------------------------------------------------------------------------
# helpers
# --------------------------------------------------------------------------

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

changelog_has() {
	grep -q "^## $1 - " CHANGELOG.md
}

show_diff() {
	printf '\nChanges to be committed:\n'
	git --no-pager diff --stat -- package.json CHANGELOG.md
	git --no-pager diff -- package.json CHANGELOG.md
}

# --------------------------------------------------------------------------
# preflight
# --------------------------------------------------------------------------

printf '\nBlueforest release helper\n'
printf '=========================\n'

for tool in git curl jq gh; do
	require "$tool"
done

[ -f package.json ] || die "package.json not found in $root"
[ -f CHANGELOG.md ] || die "CHANGELOG.md not found in $root"
[ -f "$root/.github/workflows/$WORKFLOW" ] ||
	die "workflow not found: .github/workflows/$WORKFLOW"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
	die "not a git repository: $root"

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "HEAD" ]; then
	die "detached HEAD; check out a branch before releasing"
fi

if [ -n "$(git status --porcelain)" ]; then
	printf '\nNote: the working tree has uncommitted changes.\n'
	printf '      Only package.json and CHANGELOG.md will be committed.\n'
fi

if ! gh auth status >/dev/null 2>&1; then
	printf '\nWarning: gh is not authenticated, so the CI workflow cannot be triggered.\n'
	printf '         Run "gh auth login" first.\n'
fi

publisher=$(jq -r '.publisher' package.json)
name=$(jq -r '.name' package.json)
local_version=$(jq -r '.version' package.json)

fetch_published "$publisher" "$name" ||
	die "could not read the published version from open-vsx.org"

printf '\nExtension:    %s/%s\n' "$publisher" "$name"
printf 'Branch:       %s\n' "$branch"
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
		printf 'Must be newer than the published version %s.\n' "$PUBLISHED_VERSION"
		continue
	fi
	# Equal to package.json is allowed so an interrupted release can be re-run.
	if [ "$version" != "$local_version" ] && ! version_gt "$version" "$local_version"; then
		printf 'Must be newer than the version in package.json (%s).\n' "$local_version"
		continue
	fi
	break
done

# --------------------------------------------------------------------------
# 2. changelog
# --------------------------------------------------------------------------

printf '\nEnter the changelog for %s, one bullet per line.\n' "$version"
printf 'Finish with an empty line. Press Enter alone on the first line to abort.\n'
printf '\n  - Improved syntax highlighting for TypeScript\n'
printf '  - Fixed bracket colour in the dark theme\n\n'

bullets=()
while IFS= read -r line; do
	if [ -z "$line" ]; then
		break
	fi
	bullets+=("- $line")
done

if [ "${#bullets[@]}" -eq 0 ]; then
	abort
fi

# --------------------------------------------------------------------------
# 3. commit message
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
# 4. apply changes
# --------------------------------------------------------------------------

if [ "$local_version" = "$version" ] && changelog_has "$version"; then
	printf '\n%s is already prepared in package.json and CHANGELOG.md.\n' "$version"
	printf 'Skipping the file edits and going straight to push.\n'
else
	if changelog_has "$version"; then
		die "CHANGELOG.md already has a section for $version"
	fi

	tmp=$(mktemp)
	jq --indent 2 --arg v "$version" '.version = $v' package.json >"$tmp"
	mv "$tmp" package.json

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
	' CHANGELOG.md >"$merged"
	mv "$merged" CHANGELOG.md
	rm -f "$section"

	show_diff
	git add package.json CHANGELOG.md
fi

# --------------------------------------------------------------------------
# 5. commit and push
# --------------------------------------------------------------------------

if git diff --cached --quiet; then
	printf '\nNothing staged to commit.\n'
else
	git commit -m "$commit_message"
fi

git push

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

gh workflow run "$WORKFLOW" --ref "$branch" \
	-f "publishMS=$PUBLISH_MS" \
	-f "publishOVSX=$PUBLISH_OVSX" \
	-f "publishGH=$PUBLISH_GH"

repo_url=$(gh repo view --json url --jq .url)
printf '\nTriggered. Watch the run at:\n  %s/actions/workflows/%s\n' \
	"$repo_url" "$WORKFLOW"
