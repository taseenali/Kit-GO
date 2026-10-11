# Provenance

How to tell that a copy of the AI Agent Governance Kit is an official
release, and exactly which identifying marks the Kit contains.

## Every identifying mark in the Kit

| Mark | Where | Visible? |
|---|---|---|
| Copyright and license | `LICENSE`, `NOTICE` (adopters: `docs/KIT-LICENSE`, `docs/KIT-NOTICE`) | Yes, plain text |
| Credit line | `README.md`; adopters add it to their README only if they choose to | Yes |
| Kit-GO footer | last lines of `sh scripts/kit-go.sh help` output | Yes |
| Version | `KIT-VERSION` (adopters: `docs/KIT-VERSION`) | Yes |
| The Kit's repository name, `taseenali/Kit-GO` | several templates (`AGENT_RULES`, `CLAUDE.md`, `setup-hooks`, `verify-setup`, two workflows), as the Kit's location and as the target of the opt-in issue-notification workflow below | Yes, plain text |
| Release signature | signed tags `vX.Y.Z`, a signed release manifest `RELEASE-MANIFEST.sha256` and its `.sig` (published as release assets, from v2.10.0 on in this repository; see Status) | Yes, public files |
| Signing-key fingerprint | this file and `README.md` (and the maintainer's GitHub signing-key list) | Yes, plain text |

That is all of them. **The Kit contains no hidden identifiers.** It has no
invisible or zero-width characters, no encoded or disguised strings, no
per-copy or per-adopter fingerprints, and no telemetry or phone-home.
Kit-GO's script is read-only and never uses the network. **The one network
call anywhere in the Kit** is the optional
`templates/workflows/kit-issues-notify.yml.template`: it is not wired by
default, needs a token you create yourself, and opens an issue on the Kit's
repository when you choose to enable it. The Kit's own test suite fails the
build if a tracked file contains zero-width, bidirectional-control or other
control characters (including a bare carriage return), a special character
not on an explicit allowlist, a path with unexpected characters, a long
encoded blob (base64, base64url, base32 or hex) not on an explicit exception
list, or trailing whitespace (see `tests/kit-go/run.sh`, section "Consistency:
license, attribution, no covert content"). If you find anything that
contradicts this paragraph, treat it as a security issue and report it to the
maintainer.

## Status

A signing key exists (below). **v2.9.0 was signed in the Kit's original private
repository, over files that differ from this repository's** (the repository name and
some wording changed when the Kit became public). Those signatures do not verify
anything in this repository and are not published here, and no tags were carried
over. **The first release signed in this repository is v2.10.0**: the maintainer
signs its git tag and its release manifest by hand. **v2.8.0 and every earlier tag
are unsigned, and are never signed after the fact.** A release is signed only if
its tag verifies (step 2 below); an unsigned tag is simply unsigned. An agent
never signs and never holds the key.

## Signing key

- Type: SSH Ed25519, used for signing only.
- Fingerprint: `SHA256:Gv9QQaf5A4eph4GS3r8xgiyLCoy4lsHRJdAnIvv7FBE`
- Published in two places. **Check that they match** before you trust anything
  signed with it, and write the fingerprint down (pin it) the first time you
  check, so a later change to either place is noticed. Both places are controlled
  by the same maintainer account, so they guard against a damaged copy, not
  against that account being taken over:
  1. This file and `README.md`.
  2. The maintainer's GitHub account, where the key is registered as a
     *signing* key: `https://api.github.com/users/taseenali/ssh_signing_keys`.
- A key change is announced in `CHANGELOG.md` and, where possible, signed by
  the old key first. A key is never swapped silently.

## How to verify a release

You need git 2.34 or later and OpenSSH 8.1 or later (`ssh-keygen`).

1. **Get the public key from GitHub, not from the download you are checking,**
   and confirm its fingerprint equals the one above:
   ```sh
   curl -s https://api.github.com/users/taseenali/ssh_signing_keys
   ```
   Copy the value of `"key"` (one line starting `ssh-ed25519 AAAA`) into a file
   `kit-key.pub`, then:
   ```sh
   ssh-keygen -lf kit-key.pub
   ```
   The printed `SHA256:...` must equal the fingerprint in this file.
2. **Build the allowed-signers file and check the tag** (in a clone of the
   repository, with the tag fetched; `verify-tag` needs a clean checkout with no
   local edits to the files it reads):
   ```sh
   printf 'kit-maintainer namespaces="git,ai-agent-governance-kit-release" %s\n' "$(cat kit-key.pub)" > allowed_signers
   git -c gpg.ssh.allowedSignersFile=allowed_signers verify-tag vX.Y.Z
   ```
3. **Check the signed manifest yourself, with `ssh-keygen`, not with any script
   from the download.** Download `RELEASE-MANIFEST.sha256` and
   `RELEASE-MANIFEST.sha256.sig` from the GitHub release for that tag, then:
   ```sh
   ssh-keygen -Y verify -f allowed_signers -I kit-maintainer -n ai-agent-governance-kit-release -s RELEASE-MANIFEST.sha256.sig < RELEASE-MANIFEST.sha256
   ```
   It must print `Good "ai-agent-governance-kit-release" signature`.
4. **Compare every file with the signed manifest.** Get the checker from the tag
   whose signature you verified in step 2, never from a loose download:
   ```sh
   git show vX.Y.Z:release/verify-release.sh > verify-release.sh
   sh verify-release.sh RELEASE-MANIFEST.sha256 RELEASE-MANIFEST.sha256.sig allowed_signers path/to/checkout
   ```
   Only CRLF line endings are ignored, so a Windows checkout still matches.
   Exit 0: signature valid and every **listed** file matches (files the manifest
   does not list are printed as `UNLISTED`; the manifest vouches only for what it
   lists). Exit 1: the signature is not valid. Exit 2: signature valid but some
   files differ or are missing. Exit 3: a needed tool is missing, which is **not**
   a pass. Exit 4: wrong usage or a missing input file.

## What a signature proves and doesn't

- A valid signature proves that the holder of the published key
  released exactly these bytes.
- It does not prove the content is correct, safe or right for your
  project. Review Kit changes like any other change.
- A "DIFFERS" result on your own copy usually means a legitimate local
  edit, not tampering.
- Anyone can delete a credit line from their copy; nothing in a text
  file can stop that. What cannot be faked is a signature: a copy
  presented as an official release can be checked against the
  published key.
