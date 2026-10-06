#!/usr/bin/env bash
# Usage: release-scope.sh <tag> <tag-glob> <path>...
#
# Fails if nothing under <path>... has changed since the previous full release
# matching <tag-glob>, otherwise writes the commits touching <path>... into a
# marked section of the release notes. The rest of the release body is kept,
# apart from any notes added by GitHub's "Generate release notes" button, which
# list changes from every part of the repository.
set -euo pipefail

tag="$1"
glob="$2"
shift 2
paths=("$@")

start_marker="<!-- release-scope:start -->"
end_marker="<!-- release-scope:end -->"

# Compare against the previous full release, so that promoting a pre-release
# (or tagging a further pre-release) is not treated as an empty release.
if prev=$(git describe --tags --abbrev=0 --match "${glob}" --exclude "${glob}-*" "${tag}^" 2>/dev/null); then
  if git diff --quiet "${prev}" "${tag}" -- "${paths[@]}"; then
    echo "::error::Nothing under ${paths[*]} has changed since ${prev}. Delete this release, or release a commit that contains changes."
    exit 1
  fi
  range="${prev}..${tag}"
  heading="## Changes since ${prev}"
else
  range="${tag}"
  heading="## Changes"
fi

section="${start_marker}
${heading}

$(git log --no-merges --format='- %s (%h)' "${range}" -- "${paths[@]}")
${end_marker}"

if [ -n "${ACT:-}" ]; then
  echo "${section}"
  exit 0
fi

body=$(gh release view "${tag}" --json body --jq .body)
body=$(tr -d '\r' <<< "${body}" | awk -v start="${start_marker}" -v end="${end_marker}" '
  $0 == start { section = 1; next }
  $0 == end { section = 0; next }
  /^## What.s Changed/ { generated = 1; next }
  generated && /^\*\*Full Changelog\*\*/ { generated = 0; next }
  !section && !generated { print }
' | cat -s)

notes_file=$(mktemp)
if [ -n "${body//[[:space:]]/}" ]; then
  printf '%s\n\n%s\n' "${body}" "${section}" > "${notes_file}"
else
  printf '%s\n' "${section}" > "${notes_file}"
fi
gh release edit "${tag}" --notes-file "${notes_file}"
