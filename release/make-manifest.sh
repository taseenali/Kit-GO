#!/bin/sh
# Maintainer tool (not copied into projects): print a release manifest for the
# CURRENT commit of the Kit -- one SHA-256 per tracked file, taken with the CR
# of every CRLF line ending removed so a Windows (CRLF) checkout hashes the same
# as a Linux one. A file containing a BARE carriage return (a CR not followed by
# LF) is refused: a bare CR is a line break to Python and YAML, so stripping it
# would let someone change what a file does and still match the manifest.
#
#   sh release/make-manifest.sh > RELEASE-MANIFEST.sha256
#
# The maintainer then signs that file by hand with their own key (see the
# "Release procedure" in KIT-MAINTENANCE-SOP.md); this script never signs, never
# reads a key, and never touches the network. It only READS the repository.
# It refuses a dirty tree (a manifest of files that are not the committed ones
# would not describe the commit it names); the one exception is the manifest and
# its signature themselves, which the shell creates before this script runs.
# Anything it cannot hash faithfully (a symlink, a submodule, a name git has to
# quote) is a hard failure, never a silent omission, and nothing is printed
# unless the whole manifest succeeded.

LC_ALL=C; export LC_ALL

root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "make-manifest: not inside a git repository" >&2; exit 2; }
cd "$root" || exit 2

dirty=$(git status --porcelain 2>/dev/null | grep -vE '^\?\? RELEASE-MANIFEST\.sha256(\.sig)?$')
if [ -n "$dirty" ]; then
  echo "make-manifest: the working tree is not clean; commit or stash first so the manifest describes the commit it names" >&2
  exit 2
fi

hash_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 | cut -d' ' -f1
  elif command -v openssl >/dev/null 2>&1; then openssl dgst -sha256 | sed 's/^.*= *//'
  else return 1
  fi
}
if ! printf x | hash_stdin >/dev/null 2>&1; then
  echo "make-manifest: no sha256sum, shasum or openssl found" >&2; exit 3
fi
# true (exit 0) when the file has a CR that is not part of a CRLF line ending
has_bare_cr() { awk '{ sub(/\r$/, ""); if (index($0, "\r")) f = 1 } END { exit f ? 0 : 1 }' "$1"; }

version=$(tr -d '\r' < KIT-VERSION 2>/dev/null | sed -n '1p')
commit=$(git rev-parse HEAD)

# every tracked entry must be a plain file with a name git does not need to quote
bad=$(git ls-files -s | awk '$1 != "100644" && $1 != "100755" { print }' | head -1)
if [ -n "$bad" ]; then
  echo "make-manifest: a tracked entry is not a regular file (symlink, submodule or similar): $bad" >&2; exit 3
fi
if git -c core.quotePath=false ls-files | grep -q '^"'; then
  echo "make-manifest: a tracked path needs quoting by git (it contains an unusual character); refusing rather than omitting it" >&2; exit 3
fi

body=""
list=$(git -c core.quotePath=false ls-files | sort)
OLDIFS=$IFS; IFS='
'
for f in $list; do
  IFS=$OLDIFS
  [ -f "$f" ] || { echo "make-manifest: tracked file is missing from the working tree: $f" >&2; exit 3; }
  if has_bare_cr "$f"; then echo "make-manifest: $f contains a bare carriage return (a CR not followed by LF); refusing" >&2; exit 3; fi
  h=$(tr -d '\r' < "$f" | hash_stdin) || { echo "make-manifest: hashing failed for $f" >&2; exit 3; }
  body="$body$h  $f
"
  IFS='
'
done
IFS=$OLDIFS
[ -n "$body" ] || { echo "make-manifest: no tracked files found" >&2; exit 3; }

echo "# AI Agent Governance Kit release manifest"
echo "# version: ${version:-unknown}"
echo "# commit: $commit"
echo "# format: <sha256 of the file with the CR of CRLF line endings removed>  <path>"
printf '%s' "$body"
