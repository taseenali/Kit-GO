#!/bin/sh
# Verify a release of the AI Agent Governance Kit, offline.
#
#   sh release/verify-release.sh <manifest> <manifest.sig> <allowed_signers> [dir]
#
# Do NOT run a copy of this script that came from the download you are checking:
# a tampered download could carry a tampered verifier. Either check the signature
# yourself with ssh-keygen (PROVENANCE.md, step 3) or take this script from a tag
# whose signature you have already verified (step 4).
#
#   manifest         RELEASE-MANIFEST.sha256 from the release
#   manifest.sig     its detached SSH signature
#   allowed_signers  a file YOU built from the maintainer's PUBLISHED key (see
#                    PROVENANCE.md) -- never from the download being checked
#   dir              the checkout to compare against the manifest (default: .)
#
# Exit codes:  0 = signature valid AND every LISTED file matches
#              1 = the signature is NOT valid for the allowed signer(s)
#              2 = signature valid, but one or more files DIFFER, are MISSING,
#                  or carry a stray carriage return
#              3 = cannot verify (a required tool is missing): this is NOT a pass
#              4 = usage error
#
# Files in the directory that the manifest does not list are reported as
# UNLISTED (information only: the manifest vouches for what it lists). Read-only,
# offline. A valid signature proves the holder of the key released exactly the
# bytes the manifest lists; it does not prove the content is safe. "DIFFERS" on
# your own copy usually means a legitimate local edit, not tampering.

LC_ALL=C; export LC_ALL

[ $# -ge 3 ] && [ $# -le 4 ] || { echo "usage: verify-release.sh <manifest> <manifest.sig> <allowed_signers> [dir]" >&2; exit 4; }
manifest=$1; sig=$2; allowed=$3; dir=${4:-.}
for f in "$manifest" "$sig" "$allowed"; do
  [ -f "$f" ] || { echo "verify-release: no such file: $f" >&2; exit 4; }
done
[ -d "$dir" ] || { echo "verify-release: no such directory: $dir" >&2; exit 4; }

if ! command -v ssh-keygen >/dev/null 2>&1; then
  echo "CANNOT VERIFY: ssh-keygen (OpenSSH 8.1 or later) is not installed. This is not a pass." >&2; exit 3
fi
hash_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 | cut -d' ' -f1
  elif command -v openssl >/dev/null 2>&1; then openssl dgst -sha256 | sed 's/^.*= *//'
  else return 1
  fi
}
if ! printf x | hash_stdin >/dev/null 2>&1; then
  echo "CANNOT VERIFY: no sha256sum, shasum or openssl. This is not a pass." >&2; exit 3
fi
for t in sed awk; do
  command -v "$t" >/dev/null 2>&1 || { echo "CANNOT VERIFY: $t is not installed. This is not a pass." >&2; exit 3; }
done

# 1. the signature, in the release namespace. Every identity named in
#    allowed_signers is tried (the file is the one YOU built); the first that the
#    signature matches is reported.
ns="ai-agent-governance-kit-release"
identities=$(awk 'NF && $1 !~ /^#/ {print $1}' "$allowed" | sort -u)
[ -n "$identities" ] || { echo "verify-release: no identity found in $allowed" >&2; exit 4; }
signer=""
for id in $identities; do
  if ssh-keygen -Y verify -f "$allowed" -I "$id" -n "$ns" -s "$sig" < "$manifest" >/dev/null 2>&1; then signer=$id; break; fi
done
if [ -z "$signer" ]; then
  echo "SIGNATURE INVALID: the manifest was not signed by a key in $allowed (namespace $ns)." >&2
  exit 1
fi
echo "SIGNATURE OK (identity $signer, namespace $ns)"

mver=$(sed -n 's/^# version: //p' "$manifest" | sed -n '1p')
mcommit=$(sed -n 's/^# commit: //p' "$manifest" | sed -n '1p')
echo "Manifest is for version ${mver:-unknown}, commit ${mcommit:-unknown}."
if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
  head=$(git -C "$dir" rev-parse HEAD 2>/dev/null)
  if [ -n "$head" ] && [ -n "$mcommit" ] && [ "$head" != "$mcommit" ]; then
    echo "NOTE: $dir is at commit $head, not the manifest's commit; differences below may be expected."
  fi
fi

# 2. every listed file. Only the CR of a CRLF ending is ignored (so a Windows
#    checkout matches); a bare CR anywhere changes the hash and is reported.
differs=0
listed=""
while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  h=${line%%  *}; f=${line#*  }
  case "$f" in /*|../*|*/../*|*/..|..) echo "REFUSED unsafe path in manifest: $f" >&2; differs=1; continue ;; esac
  listed="$listed$f
"
  if [ ! -f "$dir/$f" ]; then echo "MISSING $f"; differs=1; continue; fi
  a=$(sed 's/\r$//' < "$dir/$f" | hash_stdin) || { echo "CANNOT VERIFY: hashing failed" >&2; exit 3; }
  if [ "$a" = "$h" ]; then echo "MATCH   $f"; else echo "DIFFERS $f"; differs=1; fi
done < "$manifest"

# 3. files present but not listed (information only; skips .git)
if [ -d "$dir" ]; then
  ( cd "$dir" && find . -path ./.git -prune -o -type f -print 2>/dev/null | sed 's|^\./||' | sort ) | while IFS= read -r p; do
    case "
$listed" in *"
$p
"*) ;; *) echo "UNLISTED $p" ;; esac
  done
fi

if [ "$differs" = 0 ]; then echo "Every LISTED file matches the signed manifest."; exit 0; fi
echo "Signature is valid, but some files differ from the signed manifest (see above)." >&2
exit 2
