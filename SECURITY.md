# Security policy

## Reporting a problem
Please report security concerns **privately**, not in a public issue:

- Use GitHub's **Report a vulnerability** button on this repository's Security tab
  (private vulnerability reporting).

Include what you found, how to reproduce it, and which version (`KIT-VERSION`).
This is a one-maintainer project: replies are best effort and there is no bounty.

## What is in scope
Kit-GO ships scripts and hooks that run on adopters' machines
(`templates/kit-go.sh.template`, the git hooks, the workflow templates) and
a release-signing scheme. Examples of things worth reporting:
- a script or hook that can write outside the project, run unexpected commands,
  leak a secret, or make a network call the documentation says it does not;
- hidden or covert content in a tracked file (the Kit's own tests look for
  zero-width and control characters, encoded blobs and unexpected characters);
- a flaw in the release signing or verification procedure (see `PROVENANCE.md`).

## Verifying a release
Only a release whose git tag and release manifest verify against the published signing
key is an official release. Steps are in `PROVENANCE.md`. A copy that does not verify may
still be fine to read, but treat it as unofficial.

## Not in scope
Mistakes in advice (a rule you disagree with, a limit that changed on a platform) are
ordinary issues, not security reports.
