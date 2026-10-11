# Contributing to Kit-GO

Kit-GO is a small, opinionated set of files and practices. It is maintained by
one person, so please read this first to set expectations.

## What is welcome
- **Issues**: a bug (a rule that does not work as written, a script that fails on
  your platform), or an idea. Use the issue forms. Include your OS, git version
  and the Kit version (`KIT-VERSION`).
- **Real-world findings**: the best input is "I adopted this on a real project and
  this broke or confused me". That is how most of `LESSONS-LEARNED.md` was written.
- **Pull requests**: welcome for small, focused fixes (typos, a wrong command, a
  failing check on a platform). For anything larger, open an issue first so we
  agree on the direction before you spend time.

## What to expect
- No support SLA and no guaranteed response time. Issues are read; replies are
  best effort.
- Pull requests are reviewed when the maintainer has time. A merge is the
  maintainer's decision, made by a human.
- This is a governance kit: changes to rules or to the Tier 2 file list get the
  most scrutiny, and may be declined even when well made.

## How the Kit is maintained (so your PR fits)
Read `KIT-MAINTENANCE-SOP.md`. In short: every change needs a semantic version bump
(`KIT-VERSION`), a real `CHANGELOG.md` entry that says why, and a passing test run.

Run the test suite before you open a pull request:

    bash tests/kit-go/run.sh

It needs bash 3.2 or newer, git 2.28 or newer and standard coreutils. Checks that
cannot run on your machine are reported as skipped, never as passes.

## Licence and sign-off (DCO)
The Kit is licensed Apache-2.0 (see `LICENSE`). Every commit in a pull request must
carry a `Signed-off-by:` line (use `git commit -s`). The sign-off certifies the
Developer Certificate of Origin 1.1 (https://developercertificate.org/): you wrote
the change, or you otherwise have the right to submit it under Apache-2.0. Pull
requests with commits that lack a sign-off will not be merged.

## Security
Do not open a public issue for a security problem. See `SECURITY.md`.
