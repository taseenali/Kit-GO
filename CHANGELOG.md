# Changelog

All notable changes to this kit are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning
follows [Semantic Versioning](https://semver.org/) — a breaking change to
a template's structure or an existing rule's meaning bumps the major
version; a new file or a new rule bumps minor; a wording/clarity fix bumps
patch.

Every entry should say *why*, not just *what* — future entries especially,
since the value of this file is being able to trace a rule back to the
real situation that produced it.

PR and issue numbers in older entries (for example #13) refer to the original private
repository; they do not exist in this one.

## [2.11.0] -- 2026-10-11

Speed mode becomes a proper, optional part of the Kit, and the Kit now says
plainly what it is tested with. Why a minor bump: this adds new files (three
templates and a reference-setup document), which this file's own rule says
bumps minor. No existing rule, tier or script changes meaning.

Added:
- `templates/SPEED-MODE.md.template`, `templates/AGENT-LEDGER.md.template`,
  `templates/SPEED-MODE-METRICS.md.template`: an optional way to run several
  agents in parallel without lowering any review tier, with pre-registered
  revert conditions so the claim can be checked rather than assumed.
- `REFERENCE-SETUP.md`: the exact setup the Kit was built and used with, the
  measured results, and the honest limits (no wall-clock speedup was measured).
- A "works best with Claude" notice in the README, with what is and is not
  claimed.
- `SETUP-GUIDE.md`: an optional "Adding speed mode" section.
- `LESSONS-LEARNED.md`: six short lessons from running agents in parallel.
- Consistency checks for the new files in `tests/kit-go/run.sh`.

Changed:
- `templates/AGENT_RULES.md.template` and
  `templates/MODEL-UTILIZATION-PLAYBOOK.md.template` gain a short optional
  pointer to speed mode. Nothing in them is required.

## [2.10.0] -- 2026-10-11

First public release, as **Kit-GO** in its own repository
(`taseenali/Kit-GO`, Apache-2.0). The Kit now lives in a NEW repository with a
clean history (one initial commit); the original private repository is
unchanged and stays private. Why a minor bump: this adds new files (a
contributing guide, a security policy, issue templates), which this file's own
rule says bumps minor; everything else is wording or a repository-name string.

Changed (no behaviour change in any script or template other than the strings
named here):
- Every reference to the original repository's name now points at
  `taseenali/Kit-GO` (README, PROVENANCE, six templates, and the
  `KIT_REPO` value in `templates/workflows/kit-issues-notify.yml.template`).
- Names of the maintainer's internal projects were replaced with generic wording
  ("a downstream project") in the README, CHANGELOG, LESSONS-LEARNED and the
  maintenance SOP. No rule, lesson or version history changed in substance.
- Statements that said THIS repository was private on the free tier
  (README, `.github/workflows/kit-go-tests.yml`) were corrected: they were
  true of the original private repository and are not true here. Advice about
  adopters' private repositories is unchanged.
- README: new title and a short banner (open source, support expectations); the file
  table lists the new files; the signing statement now matches PROVENANCE.md.
- `templates/workflows/kit-issues-notify.yml.template`: header now warns that the
  issue it opens on the (now public) kit repository carries the source repository's
  name and PR link. Behaviour unchanged.
- `CONTRIBUTING.md` requires a DCO sign-off on every commit, which the maintenance
  SOP requires before any outside contribution can be merged.
- A note at the top of this file says old PR numbers refer to the original private
  repository.

Added: `CONTRIBUTING.md`, `SECURITY.md`, `.github/ISSUE_TEMPLATE/` (bug and idea
forms).

Provenance, stated plainly: the v2.9.0 tag and release manifest were signed in
the ORIGINAL private repository over files that differ from this repository's
(the name strings above). Those signatures do not apply to this repository's
files and are not published here, and no tags were carried over. **v2.10.0 is
the first release signed in this repository**, by the maintainer, by hand (see
PROVENANCE.md and the release procedure in KIT-MAINTENANCE-SOP.md). The signing
key and its fingerprint are unchanged.

## [2.9.0] -- 2026-10-02

**Release signing is set up** (the signing key is the maintainer's SSH Ed25519
key, registered as a signing key on their GitHub account; its fingerprint is in
`PROVENANCE.md` and `README.md`). Minor bump: new tools and docs; no template
changes. **The first signed release will be v2.9.0** (that signing happened in the original private repository; see the 2.10.0 entry above for what applies to this repository), signed by hand by the
maintainer after this merges; v2.8.0 and earlier stay unsigned and are never
signed after the fact. An agent never holds or uses the key.

- **`release/make-manifest.sh`** (new, maintainer tool, not copied to projects):
  prints a manifest of every tracked file with its SHA-256 taken with CR bytes
  removed (a Windows checkout hashes like a Linux one), the version and the
  commit; refuses a dirty tree. It never signs and never touches a key or the
  network.
- **`release/verify-release.sh`** (new, for anyone): checks a manifest's SSH
  signature against an allowed-signers file *you* built from the published key,
  then every listed file. Exit codes: 0 valid and all match; 1 signature
  invalid; 2 valid but files differ or are missing; 3 a tool is missing (**not**
  a pass); 4 usage. Read-only, offline.
- **`PROVENANCE.md`** now carries the fingerprint, the two places it is
  published, and the exact verify steps (fetch the key from GitHub, compare the
  fingerprint, build `allowed_signers`, `git verify-tag`, `verify-release.sh`).
  **`KIT-MAINTENANCE-SOP.md`** gains a "Release procedure (human only; an agent
  never signs)".
- **Tests** (new section "Signing and release verification"): the fingerprint
  is well-formed and identical in README and PROVENANCE; no private-key material
  or key-looking file is tracked; and a **real signing round trip with a
  throwaway key generated inside the test's temp dir** (never a real key): sign,
  verify OK; a tampered file -> exit 2 with DIFFERS; a CRLF copy still MATCHes
  but a bare-CR injection does not; the wrong key, the wrong namespace or a
  tampered manifest -> exit 1; a missing listed file -> exit 2; a missing input
  file -> exit 4; an absent `ssh-keygen` (other tools present) -> exit 3;
  unlisted files are reported; `make-manifest.sh` refuses a dirty tree, refuses
  bare CR / symlinks, is deterministic, and the literal SOP step 1 command works;
  `verify-release.sh` leaves the tree byte-identical.
- **Review fixes (independent review of the first commit found 9 issues):** the
  SOP step no longer fails on its own output file; the verify steps no longer run
  the verifier from the download under test (signature checked directly with
  `ssh-keygen`, checker taken from the verified tag); only CRLF (not any CR) is
  ignored; manifest version/commit are shown; every identity in `allowed_signers`
  is tried; `make-manifest.sh` fails loudly instead of skipping odd files; the
  "two independent places" claim is reworded honestly. These fix commits have
  not had their own independent review.

**Limits, stated plainly.** A signature proves the holder of the key released
exactly those bytes; it does not prove the content is safe. Nothing stops
someone deleting the credit line from their copy. Until the maintainer signs
v2.9.0, nothing is signed.

## [2.8.0] -- 2026-10-02

**The Kit now has stated license terms.** Until now it had no LICENSE, no
NOTICE and no copyright line anywhere, so adopters copied files with no
stated permission. This release adds them, as the maintainer decided:
copyright holder **Taseen Ali Mansoor (taseenali)**, personally (an earlier plan named a company; the maintainer chose to keep it simple and hold it personally); license **Apache License 2.0** with a
NOTICE; signing, when it starts, with an SSH Ed25519 key. Minor bump: new
files and two new SOP rules; no existing template changes meaning.

- **`LICENSE`** (new): the unmodified Apache-2.0 text, byte-identical to the
  published one (SHA-256 `cfc7749b...3d30`, enforced by a test). The holder
  name lives in NOTICE, as Apache intends.
- **`NOTICE`** (new, kept to the required notices, as Apache practice is):
  the copyright line, a "developed by" line, the license pointer, and a
  statement that the license grants no rights in the names "AI Agent
  Governance Kit" / "Kit-GO" (Apache-2.0 section 6). No trademark
  *registration* is claimed (that needs legal advice). The *requested* credit
  line lives in the README, not in NOTICE, so downstream projects do not copy
  claims that go stale. No URL and no key fingerprint yet: the repo is
  private and no key exists; they arrive with signing.
- **`PROVENANCE.md`** (new): an inventory of **every** identifying mark in
  the Kit, all visible (LICENSE, NOTICE, the README credit, the `kit-go help`
  footer, `KIT-VERSION`, and the Kit's repository name
  `taseenali/Kit-GO` that already appeared in six templates),
  and an explicit statement that the Kit contains no hidden identifiers and no
  telemetry. A review caught that an earlier draft also claimed "no network
  calls": the optional `kit-issues-notify` workflow (not wired by default,
  needs your own token) does call the network, and the inventory missed the
  repository name. Both are now stated. Signing status: not started.
- **README** (License, "Using the Kit? Show it", Official releases and
  verification), **SETUP-GUIDE** (copy list: `LICENSE` -> `docs/KIT-LICENSE`,
  `NOTICE` -> `docs/KIT-NOTICE`, `PROVENANCE.md` ->
  `docs/KIT-PROVENANCE.md`; an optional README snippet adopters may add; and
  an accurate note on Apache-2.0 section 4(b): using the Kit inside your own
  project needs no notice, but if you *redistribute* modified Kit files you
  need a prominent change notice -- an earlier draft wrongly said git history
  is enough).
- **`KIT-MAINTENANCE-SOP.md`**: two new rules -- no external contribution is
  merged before contribution terms (DCO/CLA) exist; and the Kit never
  contains hidden, encoded or undisclosed marks.
- **`kit-go help`** gains a three-line license/provenance footer (`help`
  only, static ASCII, no version, no URL, nothing in `status`/`snapshot`/
  `drift`). Until an adopter syncs to 2.8.0, `kit-go drift` shows
  `scripts/kit-go.sh` (the footer) and `docs/KIT-GO.md` (one sentence) as
  `DIFFERS`; that is accurate, and after the sync they read `SAME`.
- **Tests** (`tests/kit-go/run.sh`, new section "Consistency: license,
  attribution, no covert content"): LICENSE verbatim (hash) and no
  leftover draft banners; the holder string is the same in NOTICE, README and
  the footer; the footer is in `help` and not in `snapshot`/`status`; and a
  **covert-content guard** over every tracked file: it fails on invalid
  UTF-8, control characters (and a *bare* carriage return, which can hide
  earlier text in a terminal), zero-width/invisible characters, bidirectional
  controls, variation selectors, tag characters, private-use characters,
  look-alike spaces, any special character not on an explicit allowlist, a
  tracked path with characters outside `[A-Za-z0-9._/-]` or that is not a
  regular file, a long base64, base64url, base32 or hex blob not on an
  explicit exception list, and trailing whitespace -- over **every** tracked
  file (a review found the first version silently skipped paths with spaces or
  non-ASCII characters, and only scanned blobs in some files). The guard has a self-test that inserts each kind of covert
  content into a temporary copy of a template and fails if the guard does not
  flag it.

**What this does not do, stated plainly.** It does not hide anything, and it
does not claim to stop copying: a text credit can be deleted. It credits the
AI assistance openly (NOTICE and README) but does not settle copyright in
AI-assisted portions -- that is legally unsettled, and the notices say
"to the extent the law allows"; legal advice is still worth getting, as is
advice on trademarking "Kit-GO". If the holder ever becomes a company, an IP
assignment from the maintainer to it is needed first. No release is signed
yet.

## [2.7.0] -- 2026-10-02

**Kit-GO: the kit as something you run.** New command set so an agent (or
human) can re-anchor on a project's rules, check its health, get guidance,
record a Kit issue, and plan an upgrade at any time -- instead of the kit
being a one-time copy-in that silently drifts. Minor bump: all additions;
no existing template changes meaning except one Tier 2 list extension
(below). Requested by the maintainer as the closure of the v2.4-2.6
maintenance pass, with an explicit requirement for a full test and
adversarial-review suite *before* any project syncs it.

- **`templates/KIT-GO.md.template`** (-> `docs/KIT-GO.md`): the command
  playbook and single source of truth. Seven commands: `kit-go` (the bare
  command: refresh/health check/re-anchor), `kit-go-help`, `kit-go-guide`
  (quick, any stage), `kit-go-guide-me` (personalized to the project's
  stage), `kit-go-log` (record a Kit bug or idea), `kit-go-sync` (plan an
  upgrade), `kit-go-intake` (maintainer-only: this repo's maintenance
  workflow made runnable). Plain-text triggers so agents without slash
  commands work; an ambiguity rule (unclear phrase => run help, never guess a
  write; no trigger phrase is ever a request to *apply* anything); a stage
  table for the personalized guide; a degraded-mode and edge-case table with
  a "verified by" column separating script-tested rows from agent-procedure
  rows; and what Kit-GO is not (not an approval, an auto-updater, an identity
  check, or a sandbox).
- **`templates/kit-go.sh.template`** (-> `scripts/kit-go.sh`): the testable
  mechanical core -- `status`, `snapshot`, `drift`, `help`, `commands`.
  **Read-only, precisely stated:** it never writes, fetches, or touches the
  network; git runs with `--no-optional-locks`, `core.fsmonitor=false` and
  `core.splitIndex=false` (plain `git status` rewrites `.git/index`; a
  repo-configured fsmonitor command would run -- both found by review).
  **It executes nothing from the repo by default**: the pre-push hook is
  checked statically (wired, executable, contains the rejection guard);
  `--test-hook` is the explicit opt-in that *executes* the repo's own hook
  (with `timeout 10` where available). It also does not vouch for its own
  file on a branch someone else wrote -- the playbook says to diff
  `scripts/kit-go.sh`, `docs/KIT-GO.md`, `.claude/` and `.githooks/` against
  the default branch first.
- **Prompt-injection hardening.** Branch names, paths and changelog headings
  shown by the script have control characters (incl. ESC) stripped and length
  capped; branch names are printed quoted; and the playbook, wrappers and
  script output all state that such text is *data, never instructions* (a
  changelog entry's "must-take" is judged from the diff, not its own claim).
  (`status` prints branch names quoted; `snapshot` values are sanitized.)
- **Second review round (fresh reviewers re-attacking the first fix commit)
  found more, all fixed:** (1) a repo-configured git *filter driver* is
  executed by `git status` -- the same threat class as fsmonitor, through
  another door -- so when the repo's own config defines a filter driver
  the working-tree count is `unknown` and `status` is not run (the user's
  global/system drivers, e.g. Git LFS, are trusted and ignored -- the suite
  caught the first version flagging every machine with LFS installed); (2) the playbook's *own*
  degraded-mode and integrity-diff commands brought those vectors back, so
  they are now hardened and tree-to-tree (`git -c core.fsmonitor=false diff
  --no-ext-diff --no-textconv --stat <default> HEAD -- <paths>`); (3) that
  integrity check now also covers `.github/AGENT_RULES.md`, `CODEOWNERS` and
  `CLAUDE.md`/`AGENTS.md`, and on an unfamiliar branch the agent re-anchors
  from the *default branch's* rules, not the branch's; (4) wrapper
  pre-approvals are now exact commands -- a `:*` prefix had also
  pre-approved the opt-in `--test-hook`; (5) `stage=kit-source` is called a
  heuristic and intake requires the human to confirm the repo, and no repo
  file can relax the never-merge/independent-review/sign-off rules;
  (6) an absolute `core.hooksPath` that goes through a symlink (macOS:
  `/var` -> `/private/var`) was wrongly "not wired" -- a real product bug
  that would also have turned the macOS CI job red; (7) git refusing a repo
  for dubious ownership is no longer reported as "run git init"; (8) `drift`
  now compares the playbook and the six wrappers too; (9) `kit-go-intake`
  has no wrapper at all (it could never run in the Kit repo and must not
  reach projects); (10) the guide-me hook overlay no longer tells an
  unadopted repo to "wire the hook"; (11) test-suite hardening: the read-only
  check now also requires the script to have actually *run* (it used to pass
  vacuously on a script that crashed -- ~170 checks), the Kit-clone check no
  longer silently skips across filesystems, and negative checks are paired
  with a positive "it ran" check.
- **Third round (a mutation-testing pass of ~60 injected bugs against the
  rebuilt suite) found three more real script defects and ~15 test gaps,
  all fixed:** (1) a *committed* `.gitattributes` line selecting a filter
  (Git LFS ships in Git for Windows' SYSTEM config, so this is common) made
  `git status` run git-lfs, which writes hooks, config and objects into
  `.git` -- git is now told to read attributes from the empty tree
  (`GIT_ATTR_SOURCE`, git >= 2.41, plus `attr.tree`, git >= 2.43; a first
  draft said 2.40/2.42, wrong per git's release notes, found by review),
  and below git 2.41 the working-tree count is skipped; SHA-256 repos use
  their own empty-tree id; a filter selected in `.git/info/attributes` (not
  replaced by that override) also makes the count `unknown`; and because
  in-tree attributes are now ignored, a repo with a `.gitattributes` words
  its count as "appear changed" (end-of-line/encoding conversions can show
  phantom changes -- run `git status` to confirm) and `snapshot` reports
  `attributes_ignored=yes`; (2) a failing `git status` (corrupt index) printed "OK
  working tree clean" -- it is now `unknown` with a WARN; (3)
  `status.showUntrackedFiles=no` in repo config hid new files -- status is
  run with `--untracked-files=normal`. New tests: global filter + committed
  attributes, corrupt index, hidden untracked files, each Kit-repo marker
  file individually, KIT-VERSION/CHANGELOG mismatch, empty onboarding file,
  absent playbook, placeholders outside AGENT_RULES, overlong and
  control-character headings/paths, git-version shims (2.40.1 skips, 2.41.0
  counts, an Apple-style version string parses), a SHA-256 repo, and a
  static guard on the script text. **Honest corrections inside this round:**
  the first version of that guard was red (it matched a hint message) and
  my "fix" for it never actually applied -- I only tested the regex in
  isolation, not the file -- until a reviewer caught it; the rewritten guard
  is token-based: every git call must go through `gitq` with a first-word
  subcommand in rev-parse/symbolic-ref/config(--get only)/status/worktree
  (list only), checked per call (so `a || b` can't hide a second call); every
  remaining `>` must be exactly `>/dev/null` or `>&N`; no file-writing
  command word, in-place editor or interpreter; bare `git` only as `git
  --version`. One function scans both the real script and 25 injected bad
  lines (`echo hi>f`, `gitq -C . add`, `command git add`, `sed -i's/a/b/'`,
  ...), so the guard and its self-test cannot drift apart. It is a
  tripwire, not proof (a write hidden behind a variable, `eval` or an exotic
  interpreter could still evade it); the tree-hash read-only tests are the
  real proof. A fourth review round also found that a trusted GLOBAL
  attributes file (git's XDG default, or `core.attributesFile` spelled `~/..`)
  still ran a filter -- both are now checked, with positive controls -- and
  that the "Apple-style version" test was vacuous (a parse failure gave the
  same `unknown`); it now uses a >= 2.41 string and expects a real count, and
  the version-shim test proves the script actually resolved the shim via
  PATH. **A fifth, final review then found two more real holes, fixed
  here:** (a) the guard let `gitq config <key> <value> --get` through --
  git stops parsing options at the first non-option, so that is a *set* (it
  really wrote `.git/config`); the guard now requires the first non-option
  word after `config` to be `--get`/`--get-regexp`; (b) detecting attribute
  sources one by one kept missing cases (a relative `core.attributesFile`
  run from a subdirectory, the system attributes file, a FIFO), so they are
  now *neutralized* instead -- `core.attributesFile=/dev/null` and
  `GIT_ATTR_NOSYSTEM=1` on every git call -- which supersedes the XDG/`~`
  detection of the previous round (those cases now give a real count and the
  filter still does not run). Also added to the guard: `find`, `eval`,
  `xargs`, `nohup`, `env`, single-word quoted commands (`"touch" f`), `sh
  -c` payloads and awk redirections (36 injected lines in all); test
  fixtures that dirty a file now keep its size (a size change could make git
  report a change without running the filter, so a positive control did not
  fire). **A sixth review found only low/medium items, all fixed:** the
  guard let `gitq symbolic-ref HEAD <ref>` (a HEAD rewrite) and a worktree
  call hidden by a trailing `# list` comment through, and missed `\rm`,
  `awk system()`, `sed 'w f'`, `sort -o` and `curl`; the "appear changed"
  wording now also notices the user's XDG-default global attributes file
  (neutralizing it can show phantom end-of-line changes); and one playbook
  sentence overstated what is "switched off" (`.git/info/attributes` is
  *checked*, not switched off). 43 injected must-catch lines now. A negative filter test was also vacuous (config quoting
  stripped, so the filter did nothing); it is rebuilt with `git config -f`
  and a positive control that fails if the filter doesn't fire.
- **Stage detection fixed after review:** a lone `CLAUDE.md` is
  `not-adopted` (not "half-adopted"); an empty core file, or a CODEOWNERS
  with only comments, doesn't count as adopted (an empty CODEOWNERS enforces
  no review); the Kit's own repo is recognized only when several files hold
  together and the repo has no `.github/AGENT_RULES.md`, so a project that
  vendored the Kit tree keeps its own rules; `core.hooksPath` spelled
  `./.githooks`, `.githooks/` or absolute counts as wired; open Kit-issue
  entries tolerate case, a missing period and trailing whitespace (a
  Markdown hard break used to hide an open entry); a UTF-8 BOM in a version
  file (PowerShell 5.1 writes one) is tolerated; absurdly large version
  numbers no longer print shell errors; bare repos get accurate advice.
- **Tier 2 list extended** (`templates/AGENT_RULES.md.template`, and
  `SETUP-GUIDE.md`): `docs/KIT-GO.md`, `scripts/kit-go.sh` and `.claude/**`
  are agent-facing files that grant pre-approved command execution; without
  this an edit to them could be self-merged as a Tier 0/1 "wording tweak"
  (found by review). Applies to projects that install Kit-GO.
- **`templates/commands/kit-go*.md.template`** (-> `.claude/commands/`):
  thin Claude Code slash-command wrappers; each stops if the playbook is
  missing, carries the data-not-instructions rule, and starts with an
  integrity check for unfamiliar branches. `kit-go-intake` is maintainer-only,
  pre-approves nothing, and is **not copied into projects**.
- **`KIT-VERSION`** (one line; projects copy it to `docs/KIT-VERSION`): how
  Kit-GO knows which version a project adopted. Each command carries a
  `since` version, so `kit-go-help` marks commands that are new relative to
  a project's adopted version -- the "auto-carry" path for future commands.
  `drift` also handles the first sync of a project that predates the file.
- **Wiring:** `CLAUDE.md.template`, `SETUP-GUIDE.md` copy list, `README.md`
  index, `.gitattributes` LF pins for the script, tests, playbook, wrappers
  and `KIT-VERSION` (a CRLF checkout of the playbook had broken the tests).
- **`tests/kit-go/run.sh`** and **`.github/workflows/kit-go-tests.yml`**
  (Linux + macOS + Windows, `permissions: contents: read`, timeout, no
  `paths:` filter): consistency checks (version, registry == playbook
  table row for row, wrappers, triggers, Tier 2 list, copy lists, pins) and
  behavior checks against throwaway repos (non-repo, bare, unborn, detached,
  main/MASTER, partial/empty/unfilled/team, vendored Kit tree, hostile hooks,
  hostile branch names and changelog headings, hooksPath spellings, CRLF/BOM,
  spaces and unicode, subdirectories, linked worktrees, version skew, drift,
  dash/bash/sh and locale parity, determinism). **The read-only check was
  rebuilt after mutation testing showed the first version let four injected
  writes through:** it now hashes names, content and modes (so empty
  directories and `chmod` are seen), asserts no mtime changed, points `HOME`
  and `TMPDIR` at empty directories that must stay empty, runs each case on a
  fresh repo (a write is only detectable the first time it happens in a
  directory), and includes a stale-index case. Checks that cannot run on a
  machine are counted as **skipped and listed**, never recorded as passes.

Known limits, stated plainly: Kit-GO's agent-facing procedures (writing a
guide, recording a log entry, triage) are written instructions an agent
follows, not mechanically enforced -- only the script is executed-tested, and
the edge-case table says which is which. A Kit adopted in a subdirectory of a
bigger repo is not detected. `--test-hook` runs repo code and its timeout is
not a sandbox. busybox `sh` and macOS were reviewed by reasoning/emulation,
not run, until CI runs them. Nothing here has been synced to a project yet.

## [2.6.1] -- 2026-10-01

`KIT-MAINTENANCE-SOP.md` step 8 now says how to close an entry that triage
declines or marks reference-only (wording that is not the bare `No.`, so
`verify-setup.sh` stops counting it) and how to handle a partly addressed
entry (stays open with a note). Gap found by an independent review of
v2.6.0, which added the same wording to `KIT-ISSUES-LOG.md.template` but
did not touch the SOP, which was still unmerged on that branch. Wording only: patch.

## [2.6.0] -- 2026-10-01

Docs, lessons and guidance, from the same downstream `KIT-ISSUES-LOG`
intake as v2.4.0/v2.5.0, triaged "mechanical, low-risk" per the kit
maintenance SOP (PR #19, not yet merged when this entry was written). Minor
bump: new guidance and one new rule-coverage item, no template restructuring.

- **Reusable-idea coverage added to the "record, don't fix in passing"
  rule** (`AGENT_RULES.md.template`'s kit-bug section and Definition-of-Done
  bullet, `KIT-ISSUES-LOG.md.template`'s header/rule/entry-format,
  `PULL_REQUEST_TEMPLATE.md.template`'s reminder). The rule only ever said
  "bug, gap, or friction," and the DoD bullet it replaced in v2.0.0 had
  explicitly covered "a reusable process or lesson" -- so the new bullet
  was *narrower* than what it replaced. A downstream project already
  broadened its own copy. **Judgment call, flagged:** this widens what the
  log is *for*, not just its phrasing. Adopted, with two deliberate
  departures from a verbatim port: the section **heading is unchanged**
  (four files cite it by exact text, and a downstream copy synced
  piecemeal would otherwise dangle), and the idea-coverage is added in
  the body. An idea is still triaged under the SOP's existing buckets
  (most will be "needs real design"), so this doesn't create a fast path
  for ideas into the kit.
- **`KIT-ISSUES-LOG.md.template`: malformed nested placeholder fixed.**
  The "Workaround used here" field had a `{{PROJECT_NAME}}` token inside its
  own `{{...}}` placeholder, mixing a one-time setup value into a per-entry
  block with nothing saying it was different from its neighbors. Now plain
  text ("this project").
- **Collaborator-identity warning** in `AGENT_RULES.md.template` (the
  second-human maturity trigger), `PASS-0-ENVIRONMENT-DISCOVERY.md.template`
  (team shape) and `COLLABORATOR-LOG.md.template`: session-context fields
  like `userEmail`, a git `user.email`, or an OS username are not
  reliable signals of *who* is working -- a real session read a changed
  `userEmail` as a second contributor joining and wrongly triggered the
  maturity review; it was the same person on a different local account.
  Real signals: a PR/review by the person's own GitHub account, or the
  human saying so. **A mechanism that asks for identity at session start
  is *not* included** -- that is new design work, deliberately out of
  scope for this pass. Review caught that "a commit" is not a real
  signal either (author metadata comes from the same local `user.email`),
  so the guidance names the authenticated actor of a PR/review, and only
  where no agent shares the login.
- **Declined-entry wording** added to `KIT-ISSUES-LOG.md.template`: ideas
  will often be declined, and a bare `No.` keeps `verify-setup.sh`
  warning forever; a declined entry now uses `No -- declined upstream ...`.
- **`LESSONS-LEARNED.md` -- rebase-conflict lesson** (Review / process):
  don't resolve a factual conflict by picking the "more recent" side without
  checking whether the discarded side is a deliberate, already-reviewed
  correction. A real review-vetted fix was silently reverted this way.
- **`LESSONS-LEARNED.md` -- agent-worktree count leakage** (Multi-agent
  coordination) + a comment in `templates/workflows/tests-python.yml.template`.
  Real case: a background
  agent's worktree doubled a foreground test and lint count while every
  check still genuinely passed, and the wrong numbers were reported as
  verification. **Honest scope of the template change:** none
  in behavior. pytest's default `norecursedirs` already skips
  dot-directories and `pytest tests/` is already scoped, so this template
  was never exposed (verified). An `--ignore-glob` flag added in an early
  draft was removed after review showed it silently never matched a
  repo-root `.claude/` and so only gave false comfort. The logged incident was vitest and
  ESLint, which this kit ships no config for, so those get guidance in the
  lesson, not a template. The general discipline ("distrust any
  count-of-things evidence captured while a parallel background agent was
  active") is the part that carries over.

## [2.5.0] -- 2026-10-01

Git-hook and setup-script fixes from two downstream projects'
`docs/KIT-ISSUES-LOG.md` entries, triaged "mechanical, low-risk" per
`KIT-MAINTENANCE-SOP.md`. Touches `.githooks/**`, which this repo's own
Tier 2 list treats as load-bearing -- reviewed accordingly.

- **`templates/pre-push-hook.template` (and this repo's own installed
  `.githooks/pre-push`, which carried the identical flaw): the
  `ALLOW_DIRECT_MAIN_PUSH` check no longer accepts non-reasons.** The old
  `[ -n ... ] && != "1"` test let `0`, `false`, `no`, `On` and a padded
  `" 0 "` all pass as a typed reason -- a real guardrail bypass, confirmed
  by execution downstream. Now trims whitespace and rejects empty, `1`,
  `0`, and any true/false/yes/no/on/off spelling (case-insensitive).
  Ported from the stricter version a downstream project already ran;
  re-verified here by executing every listed value against the template.
  Behavior change: an adopter who used `ALLOW_DIRECT_MAIN_PUSH=true` as a
  habit now gets a rejection and has to type a real reason.
- **New `templates/pre-commit-hook.template`** (optional; also
  `.gitattributes` LF pin, `setup-hooks.sh.template` chmod/executable
  check, `SETUP-GUIDE.md` copy-list entry). Refuses `git commit` while
  `main`/`master` is checked out, mirroring pre-push at commit time. *Why:*
  a real incident -- a correct `git checkout main && git pull` followed by
  an unrelated commit landed directly on local `main`; only a lucky manual
  check caught it before pre-push would have. Same honest limits as
  pre-push (`--no-verify`, unwired clone), **plus its own, documented in
  the hook and guide**: `git merge`, `cherry-pick`, and `rebase` don't
  fire `pre-commit` (verified for merge and cherry-pick on a throwaway
  repo), so it supplements pre-push rather than replacing it. Allows the
  very first commit in a new repo and detached HEAD. Override is
  `ALLOW_DIRECT_MAIN_COMMIT="<reason>"` with identical validation, logged
  to the same `OVERRIDE-LOG.md`. `setup-hooks.sh`'s synthetic self-test
  does **not** exercise it (it depends on the real checked-out branch) --
  a one-time manual check is documented instead.
- **`templates/OVERRIDE-LOG.md.template` header: same-push -> next-push.**
  It said to commit the override log "in the same push that used the
  override," which is impossible -- the hook appends to the working tree
  during that very push -- while the hook's own comments said "next
  push." Corrected wording ported verbatim from the downstream project
  that already fixed it. This repo's own `.githooks/OVERRIDE-LOG.md`
  header fixed to match.
- **`templates/verify-setup.sh.template`: the "not inside a git
  repository" skip message printed twice** (two checks each had their own
  copy of the same guard). Now a single guard around both; the message
  now reads "checks skipped." Verified from a non-git directory and
  inside a repo with both log files present (counts unchanged).
- **Found by this release's own independent review, fixed before merge:**
  (a) the new pre-commit hook compared `git symbolic-ref --short`, which
  prints `heads/main` whenever a tag named `main` exists -- a `git tag
  main` silently disabled the hook; it now compares the full
  `refs/heads/<name>` ref (pre-push was never affected). (b) Both hooks'
  override validation flattens newlines/tabs *before* trimming and logs the
  flattened value: `sed` trims per line, so a value starting with a newline
  followed by `0` validated as a real reason, and a multi-line value could
  forge extra `OVERRIDE-LOG.md` rows. **This departs from a verbatim port**
  of the downstream pre-push validation, which has the same gap -- worth
  back-porting there. (c) The documented "does the hook work" manual check
  would silently pass on a fresh repo (an unborn branch is deliberately
  allowed) and leave a stray commit; docs now say to run it after the first
  commit and how to undo it. (d) Comment accuracy: the hook allows any
  unborn/orphan branch, not just a new repo's first commit; `git revert`
  also doesn't fire it. (e) `templates/pre-commit-hook.template` is now
  committed executable (matches `pre-push-hook.template`), and the
  README's file index lists it. A second review round then found and fixed:
  (f) on case-insensitive filesystems `git checkout MAIN` bypassed the exact
  ref comparison -- it is now case-insensitive (also blocks a distinct
  `Main` branch on Linux, an accepted trade); (g) `user.name` was still
  logged raw and could forge a log row, now flattened too; (h) the
  override message/header told you to commit the log "in your next commit,"
  which on `main` the hook itself rejects -- now "from a branch"; (i) docs
  now say a *conflicted* merge/cherry-pick finished with `git commit` IS
  caught.

## [2.4.0] -- 2026-10-01

Tier/merge-rule wording and CI fixes, from two downstream projects'
`docs/KIT-ISSUES-LOG.md` entries (from three separate sessions), triaged as "mechanical, low-risk" per the kit maintenance SOP
(PR #19, not yet merged when this entry was written). Each item below is
a real incident, not a hypothetical. **Version note, a judgment call:**
this file's own policy says a change to an existing rule's *meaning* is a
major bump. Tier 0's unconditional test run, "never self-merged" meaning
"never executes the merge," and the new part-5 requirement are rule
tightenings, but each moves toward what the rule was already meant to say
(the incidents were agents *reading* the old wording the permissive way),
and the CI change only removes a filter from the test workflow template
(a behavior change for adopters who re-copy it, listed below); no section
or template is restructured; so this is released as minor.
Adopters only see any of it by re-copying templates -- nothing changes in
an adopted project on its own. The maintainer may reasonably choose 3.0.0
instead at sign-off.

- **Tier 0 no longer says "tests run if applicable"** --
  `templates/AGENT_RULES.md.template`. "If applicable" had been read as
  "not applicable" for a PR labeled docs-only, and the suite was skipped
  before self-merge. Now: the full suite runs unconditionally. *Why:* a
  "docs-only" label is exactly the framing a change that quietly touches
  code hides behind, and a real project had tests asserting on doc
  content.
- **`templates/workflows/tests-python.yml.template` drops its `paths:`
  filter.** Root cause under the wording problem above: a docs-only PR
  never triggered the workflow at all (empty check rollup, not
  "skipped"), so CI structurally could not catch it. Behavior change for
  adopters: tests now run on every PR/push to `main`. `LESSONS-LEARNED.md`'s
  old "Scope CI to the paths that actually need it" lesson advised the
  filter and is rewritten to say the opposite; `SETUP-GUIDE.md` §1 and §9
  and `PASS-0-ENVIRONMENT-DISCOVERY.md.template` no longer describe
  "trigger paths" / "CI-watched paths" as part of the workflow. A project
  that wants its filter back owns the gap and must run the suite locally
  for Tier 0.
- **Tier 2 protocol: a fresh review applies to each fix commit**, not just
  the original change. A real Tier 2 PR had its review findings fixed and
  was presented as ready on the strength of the review that found them;
  the fix itself had never been independently checked.
- **"Never self-merged by an agent" now spells out what it means**
  (`AGENT_RULES.md.template` new section; `PULL_REQUEST_TEMPLATE.md.template`'s
  Tier 2 checkbox; this repo's `README.md` merge-policy section). The
  short phrase was ambiguous between "the agent may not merge even with
  sign-off" and "the agent may merge once the human says yes," and caused
  the same real incident independently on two downstream projects, and a third
  time on this repo's own PR that first introduced the rule. Now: the agent never executes
  the merge by any mechanism, including after "merge it." States the
  honest limit: this is discipline, not a mechanical control -- a
  `merged_by` check can't distinguish agent from human under a shared
  credential. **No mechanical check added in this version**; see the PR
  description for the recommendation.
- **Risk summary gains a required "If challenged -- what I'd still need
  to check" part**, in `AGENT_RULES.md.template` (new "Risk summary --
  required format" section, plus a Tier 0/1 self-merge precondition) and
  `PULL_REQUEST_TEMPLATE.md.template`. In a real session the human asking
  "are you sure it's safe?" twice surfaced real gaps the agent's own
  checklist-complete summary hadn't. The section's *output* is checkable
  even though the self-interrogation behind it isn't; stated as such.
  Scoped to: first presentation, each fix commit, immediately pre-self-
  merge. The wider "before presenting *anything* as done" scope that one
  log entry proposes is a design question and is not included.
- **Found by this release's own independent review, fixed before merge:**
  Tier 1's "fresh review reports zero findings" now says *final head
  commit, including fix commits* (the same fix-commit gap the Tier 2 fix-commit item above closes
  for Tier 2); the Tier 2 handover command now pins
  `--match-head-commit <reviewed-sha>` and the agent pushes nothing after
  sign-off, so a commit added after sign-off can't ride into the human's
  merge unreviewed; the Tier 2 definition paragraph and Definition of Done
  now reference the five-part risk summary and the hand-the-command-over
  rule instead of the old three-part summary; `CODEOWNERS.template` and
  `PASS-0-ENVIRONMENT-DISCOVERY.md.template`, which cite the bare
  "never self-merged" phrase, now point at the full explanation; for Tier
  0/1, part 5 of the summary alone is required (not the whole five-part
  format). Later review rounds also tightened: a branch update or rebase
  onto the base voids sign-off; for Tier 2 the whole summary is
  re-presented after a fix, not just part 5; and this repo's own README
  merge policy carries the same `--match-head-commit` pin and
  no-push-after-sign-off rule.

## [2.3.0] — 2026-09-24

New lesson in `LESSONS-LEARNED.md` §"Review / process": a real SQLite ->
Postgres migration, written to be tested "later once a real instance
exists," was instead verified for real against a throwaway local Docker
`postgres:16-alpine` container before being called done -- including a
trigger needing a genuine Postgres-native rewrite. Extracted as a general
lesson since "nothing to test against yet" is a much rarer real state
than it first appears, and a disposable local instance of the same
technology is usually cheap and available.

**Process note on how this entry landed**: this repo's own v2.0.0 default
says a finding like this from unrelated downstream work should be
recorded in the downstream project's own `docs/KIT-ISSUES-LOG.md`, not
auto-PR'd here. This is the one explicit exception that rule itself
carves out -- the maintainer's own, in-the-moment call to land it
directly instead -- exercised here deliberately, not decided by an agent
on its own. Also recorded in the downstream project's own `docs/KIT-ISSUES-LOG.md`,
noting the exception was used, per that same rule's own bookkeeping
requirement.

**Renumbered from this branch's original v2.1.0** to v2.3.0 while
rebuilding this branch onto a fresh `origin/main` -- v2.1.0 and v2.2.0
both landed upstream (#16, #18) from other work while this branch sat
open, the same stale-branch-base pattern already hit and fixed twice
before in a downstream repo this session. No content change,
version number only.

## [2.2.0] — 2026-09-24

- **`templates/verify-setup.sh.template`** — new "Governance kit:
  unresolved decision records" check. Mechanically counts and surfaces
  open `docs/OPEN-RESEARCH-QUEUE.md` questions and un-actioned
  `docs/KIT-ISSUES-LOG.md` entries every time the script runs, as a
  warning (never a hard failure — having open items is normal, not
  broken). **Not "at every session start"** — an adversarial pass caught
  an earlier draft of this entry claiming that; nothing in this kit
  triggers the script at session start, only `CLAUDE.md.template`'s own
  written instruction does, so whether it runs at all remains exactly as
  much discipline as before this check existed. Grep-based, deliberately
  not a real markdown parser; documented in-file exactly where its
  precision breaks down (both an undercount and, for the research-queue
  half specifically, a real overcount case) rather than claiming more
  accuracy than it has. Also fixed, across two review rounds: an
  unnecessary `|| echo 0` fallback that corrupted the count on the
  healthy zero-matches case (`grep -c` always prints a number regardless
  of exit status, so the fallback appended a spurious second `"0"` —
  it happened to still resolve to the right branch by accident, not by
  design); the `KIT-ISSUES-LOG.md` half was keyed to a literal wording
  (`No.`, bare period) the kit never actually told anyone to write
  anywhere, so it would have silently undercounted real unresolved
  entries on every real downstream copy — fixed by making
  `KIT-ISSUES-LOG.md.template` itself prescribe that exact wording
  instead of leaving it to guesswork; and a false "not present" message
  when run outside a git repository entirely (a different condition,
  now reported as such).
- **`templates/CLAUDE.md.template`** — new step 4 in "What to do at the
  start of a session": check `docs/OPEN-RESEARCH-QUEUE.md` before real
  work regardless of whether `verify-setup.sh` actually warned about it
  (a missing warning could mean the script never ran, doesn't exist yet,
  or its check is inert for a project using a non-standard docs root —
  none of those mean "nothing's open," an adversarial pass caught the
  first draft implying otherwise). A warning about `KIT-ISSUES-LOG.md`
  entries is different in kind, not just urgency: those are deferred
  items for the kit maintainer's own later attention, informational only.
- **`templates/AGENT_RULES.md.template`** — new Definition of Done item:
  a mixed batch of findings/requests gets triaged explicitly (what's
  already fine, what's actionable, what's deliberately deferred) in the
  response itself, in a way a reader could check without re-deriving
  it — not acted on as one undifferentiated pile. An adversarial pass
  caught two real problems with the first draft: it required naming the
  categories *and* organizing the whole response a specific way under
  the same "small, safe default" justification, when only the naming is
  actually that small — split so only the categorization is the checked
  gate, with response structure left as guidance, not a second
  requirement; and it cited "this document's own test for that
  elsewhere," which doesn't resolve for a downstream reader (the real
  test lives in this kit's own `LESSONS-LEARNED.md`, a kit-repo file no
  downstream copy of `AGENT_RULES.md` has locally) — fixed by restating
  the test inline instead of pointing at a file the reader can't open.
- **`LESSONS-LEARNED.md`** — new entry: a fast/cheap AI classifier
  (researched concretely: TypeSafe's Jev) does not address an AI agent's
  lack of durable memory across sessions — they're orthogonal problems
  (inference speed/cost vs. institutional memory), and the real,
  independently-documented fix (an Architecture Decision Record) is
  something this kit already builds most of, under different names,
  without previously making "read it back" a real, checkable
  requirement anywhere.

### Why
A downstream project's owner asked directly whether a fast/cheap
inference API could solve AI-agent decision amnesia (regressions
returning, a worse option chosen unflagged, decisions re-litigated every
context reset, a human's trust in an undocumented call with nothing left
to recover why). Real, sourced research answered no, and pointed at what
does: Architecture Decision Records, read back at the start of a
session. This kit already had the *writing* half of that practice
(`CHANGELOG.md`'s own "why" convention, `OPEN-RESEARCH-QUEUE.md`,
`KIT-ISSUES-LOG.md`) but had never made the *reading-back* half a real,
mechanical requirement — exactly the same "written policy, not a
platform guarantee" gap this kit has already named for other rules,
found here by asking the question directly rather than assuming the
existing files were sufficient on their own.

The same conversation surfaced a second, separate observation worth its
own Definition of Done item: the owner had just been handed several
distinct findings and requests in one batch, and noted that how they'd
been prioritized and separated (confirmed fine, actionable, or
deliberately deferred) should itself become a standing practice, not a
one-off. Added as its
own item rather than folded into the ADR/read-back one above — a
different failure mode (an agent silently deciding what's worth acting
on, in how it structures a response) from the one the rest of this
release addresses (a written record existing but never being read back).

## [2.1.0] — 2026-09-23

**New rule: this repo's own merges now require a fresh + adversarial
review pass and the maintainer's explicit, in-the-moment sign-off** —
see `README.md`'s new "How changes to this kit's own repo get merged"
section. This is the first time this repo has held itself, as a
standing requirement, to any tier of the review policy it prescribes to
downstream adopters — not the first time a fresh + adversarial pass ever
happened here (real ones exist earlier in this kit's own history: see
v1.14.0, v1.18.0, v1.20.0 below); it's that nothing before now made it
the default, so it lapsed for the three merges immediately preceding
this one (#13/#14/#15) without anyone deciding it should. States plainly
why this can't be real GitHub branch protection (private/free-tier repo;
even public, a solo admin can always bypass a required review) and,
separately, that this repo dogfoods almost none of its own templates
today — no `.github/CODEOWNERS`, no PR template, no CI, and its one real
installed copy, `.githooks/pre-push`, exists and (as of this fix round)
matches its own template, but isn't wired via `core.hooksPath` in a
fresh clone. Closing that fuller dogfooding gap is separate, not-yet-done
work, not something this rule should be read as covering.

**The first adversarial pass run under this new rule, on this same
change plus the three merges (#13/#14/#15) that preceded the rule,
found 12 confirmed bugs and 3 plausible issues — all fixed here:**

- `templates/PULL_REQUEST_TEMPLATE.md.template` still had a checkbox
  instructing the exact behavior v2.0.0 reversed ("This kit's own
  upstream copy updated too...") and a stale 3-item Tier 2 list (the
  canonical list has been 6 items since v1.22.0) — neither file was
  touched by either release that changed the thing it describes. Fixed:
  the checkbox now matches the record-in-`KIT-ISSUES-LOG.md` policy, and
  the Tier 2 line points at the canonical list instead of repeating a
  stale copy of it.
- `templates/AGENT_RULES.md.template`'s Bot/CI-authored PRs section
  claimed, in the same sentence, not to restate the canonical Tier 2
  file list — while restating it verbatim. The v1.22.0 entry's claimed
  fix for exactly this ("having the Bot rule reference that list instead
  of restating it") was never actually made. Fixed: now a genuine
  cross-reference to the list's one real definition.
- `LESSONS-LEARNED.md`'s "second-human self-merge" entry was cited by
  name in four other files; that exact string didn't exist anywhere in
  the file (it was an unnamed bolded lead-in). Fixed by naming it inline
  so the citations resolve, rather than editing four separate pointers.
- `SETUP-GUIDE.md` cited a "PR #2 branch-pollution incident this kit's
  own history records (see `CHANGELOG.md`)" — no such entry exists; the
  real incident happened on a downstream project, not in this kit's own
  history. Fixed to describe the failure shape without a false pointer.
- `SETUP-GUIDE.md` leaked a downstream-project-specific term
  ("Microsoft-toolkit layer") into generic kit guidance — never defined
  anywhere else in the kit. Genericized.
- `.gitattributes`'s LF-pinning glob (`templates/*.sh.template`) never
  matched `templates/pre-push-hook.template` (no `.sh` in the name) —
  the single template this whole file exists to protect. Reproduced on
  a fresh Windows clone: a real CRLF shebang. Fixed with an explicit
  second pattern for that file.
- The workflow-file LF-pinning rule added to this repo's own
  `.gitattributes` in v1.23.0 was never ported to
  `templates/.gitattributes.template` — adopters got no protection
  against the identical risk this repo pinned for itself. Ported, using
  the adopter's real post-copy path (`.github/workflows/*.yml`).
- The same `.gitattributes` change had no v1.23.0 CHANGELOG bullet at
  all, despite shipping in that release. Added retroactively.
- `templates/KIT-ISSUES-LOG.md.template`'s per-entry placeholders
  (`{{DATE}}`, etc.) had no carve-out from `SETUP-GUIDE.md`'s "fill in
  every `{{ }}` at setup" sweep, unlike the structurally identical
  per-person collaborator-log template (which is simply excluded from
  the copy list). Fixed: a note in the template distinguishing per-entry
  fill-ins from one-time setup placeholders, and a second stated
  exception in `SETUP-GUIDE.md` step 2.
- `{{ANSWER_ARCHIVE_LOCATION}}` (a real one-time placeholder in
  `AGENT_RULES.md`'s Definition of Done), `{{CODE_DIR}}`, and
  `{{PYTHON_VERSION}}` (both in `tests.yml`) were all three absent
  entirely from step 2's placeholder list, not partially covered — all
  three now listed explicitly — and
  `templates/workflows/tests-python.yml.template`'s `{{CODE_DIR}}`
  placeholder itself is now quoted (`working-directory: "{{CODE_DIR}}"`),
  fixing a real, independently-confirmed bug where the unquoted form
  parses as an invalid YAML flow-mapping key even before anyone fills
  the placeholder in.
- One cross-reference (`SETUP-GUIDE.md` → `AGENT_RULES.md.template`'s
  `What "review by someone other than the author" actually buys you`
  section) had mismatched inner quote marks against the real heading
  text — cosmetic, but a real grep miss. Fixed to match verbatim.
- (Plausible, addressed rather than left open) This entry's own README
  section claimed no mechanical enforcement is available "even in
  principle" without naming how little of its own template set this
  repo installs on itself — see the dogfooding-gap paragraph added to
  that section. Also reworded the "same mechanism as Tier 2" framing:
  the local multi-pass pattern is Tier 2's documented *fallback*, and
  this repo adopting it as an everyday standard is a deliberate
  substitution that should be named as one, not implied to be identical
  to Tier 2's actual default (a required deeper/multi-agent review).

**A second adversarial pass, run on the fix commit above before this PR
was ever merged, found 6 further confirmed bugs in the fixes
themselves — a real instance of exactly the risk of fixing several
things fast in one pass. All fixed here too, before merge:**

- The bullet above documenting the quote-mismatch fix (#12)
  *reintroduced the same mismatch* in its own description, even though
  the real `SETUP-GUIDE.md` fix was correct — fixed the changelog text
  to match the actual (correct) fix.
- This entry's own "Why" section, and README's new section, both claimed
  "every prior merge here was single-agent self-review" as an absolute —
  false: this kit's own history has real fresh + adversarial passes
  (v1.14.0, v1.18.0, v1.20.0). Narrowed to what's actually true: no
  *standing rule* ever required it, and the three merges immediately
  before this one (#13/#14/#15) got none, but it did happen before, ad
  hoc.
- The new README dogfooding paragraph contradicted itself within three
  lines — claimed "installs none of its own templates" then immediately
  described the one it does install (`.githooks/pre-push`, a real,
  if drifted, copy of `templates/pre-push-hook.template`). Fixed the
  wording, and fixed the actual drift too: the installed copy was
  missing a 5-line comment the template had gained since — re-synced.
- `templates/.gitattributes.template`'s new workflow-file LF rule was
  ported from this kit's own `.gitattributes` without also porting the
  equivalent for `scripts/*.sh` (the copied-out, really-executed
  `setup-hooks.sh`/`verify-setup.sh`) — same CRLF risk, left open in the
  very file this commit edited. Added.
- `PULL_REQUEST_TEMPLATE.md.template`'s Tier 2 line was rewritten twice
  before it actually stopped restating the list: the first rewrite
  claimed to "point at the canonical list instead of repeating it" while
  still naming all 6 items verbatim; the second rewrite replaced that
  with a hedged paraphrase that still named the same categories, just
  less precisely. Now it's a pure pointer with no enumeration at all —
  "check there, not here — that's the one real copy, kept in exactly one
  place on purpose" — the same drift-risk pattern findings #1/#2 removed
  from every other file finally removed here too.
- `KIT-ISSUES-LOG.md.template`'s new placeholder-carve-out note used the
  literal string `{{PROJECT_NAME}}` inside a sentence explaining that
  placeholders get swept and replaced at setup — a real setup-time
  find-and-replace of `{{PROJECT_NAME}}` would rewrite that exact
  sentence into nonsense. Reworded to describe the placeholder without
  spelling it out literally.

Minor/plausible items from the same pass, also addressed: a rule's
dated comment was off by one day (2026-09-22, not -23); "half-covered"
should have read "absent entirely" for two placeholders; `{{SECRETS_PATH}}`
(a real placeholder in `.gitignore.template`) was still missing from
`SETUP-GUIDE.md`'s list; and adding an `eol=lf` rule to an
already-tracked file doesn't retroactively fix an existing clone's
working tree without `git add --renormalize .` — now noted in
`.gitattributes` itself, and actually run against this repo's own clone.

### Why
The maintainer asked, directly: does the mandatory-sign-off change just
shipped actually hold up, and was a real second-model pass ever run on
this repo's own recent merges (#13/#14/#15). The honest answer to that
specific question was no — those three were single-agent self-review
only. That's narrower than "every merge in this repo's history": real
fresh + adversarial passes exist earlier in this kit's own history (see
v1.14.0, v1.18.0, v1.20.0) — the practice existed, then lapsed for the
three most recent merges without anyone deciding it should. Running the
first real adversarial pass immediately, on the very change that
reintroduces the requirement, is what surfaced all of the above: several
genuine bugs the earlier, unreviewed merges had shipped, none of them
individually large, all of them exactly the class of thing a second,
decorrelated reader catches that the same reader re-checking their own
work does not.

## [2.0.0] — 2026-09-23

**Breaking change to an existing rule's meaning:** reverses this kit's
own long-standing default of propagating any real fix found on a
downstream project immediately back into this kit's own repository.

- **New: `templates/KIT-ISSUES-LOG.md.template`** — a single, shared
  (not per-person) log for a real bug, gap, or bit of friction found in
  this kit itself while working on a downstream project's own,
  unrelated task. Records the finding, any workaround used, and whether
  it was resolved at runtime (and by whom) — without requiring a PR
  against this repo as a side effect of unrelated work.
- **New: `templates/workflows/kit-issues-notify.yml.template`** —
  optional, not wired anywhere by default. A cross-repo notification
  (a link to the PR that changed the log, never the entry's own text —
  see the file's header for the public/private trust-boundary reasoning)
  to this kit's maintainer, gated behind a real, separately-created,
  narrowly-scoped Personal Access Token. Degrades to a silent warning,
  never a failure, if that token isn't set — the assumed default without
  it is sharing the log with the maintainer manually.
- **Changed: `templates/AGENT_RULES.md.template`** — new "Finding a bug
  in the governance kit itself" section states the actual rule: record
  in `docs/KIT-ISSUES-LOG.md` by default; a real-time fix landed
  directly in this kit's own repository is only ever the kit
  maintainer's explicit, in-the-moment call — never something an agent
  decides on its own the situation warrants, even in a session the
  maintainer is otherwise directing. Also names the mechanical reality
  underneath the policy: anyone other than the maintainer almost
  certainly lacks push access to this repo anyway, so for them the
  rule is close to a hard fact, not just discipline.
- **Changed: `templates/AGENT_RULES.md.template`'s Definition of Done**
  — the "This kit stays current" checklist item, which previously told
  every agent on every downstream project to propagate a reusable
  finding upstream in the same task, is replaced with "A kit bug is
  recorded, not fixed in passing," matching the new default above. This
  is the actual breaking change: the old item's instruction and the new
  one's are opposites for the common case (a bug found while doing
  something else), not just a wording refinement of the same rule.
- **Changed: `SETUP-GUIDE.md`, `README.md`** — updated file-copy list
  and file table for both new templates; `README.md`'s "Keeping this kit
  current" section now distinguishes the maintainer's own, ongoing
  process of incorporating real findings from what a downstream agent
  should do in the moment it finds one.

**Edge cases closed before this shipped, found by asking "are any of
these claims absolute, and does every workflow actually hold":**
- The rule didn't say what to do if `docs/KIT-ISSUES-LOG.md` doesn't
  exist yet on a given project — fixed: create it from the template
  first, then record.
- Nothing required the agent to actually tell the human an entry was
  recorded — a silent write to a file nobody's told to check is barely
  better than not recording it. Fixed: `AGENT_RULES.md.template` now
  requires saying so in the same conversation turn.
- The rule didn't say the scope excludes a session working directly in
  the kit's own repository (a maintenance session fixing the kit is not
  "unrelated work" the rule was ever meant to defer). Made explicit.
- Nothing said what to do if a non-maintainer collaborator directly asks
  for the real-time exception. Fixed: decline and record-and-defer
  regardless of being asked — the exception is the maintainer's call to
  make, not anyone else's to request on their behalf.
- The "almost certainly lacks push access" mechanical backstop was
  stated without noting it's contingent on the kit repo's current
  single-maintainer status, not a permanent property. Now says so
  explicitly.
- `kit-issues-notify.yml.template` is GitHub-to-GitHub only, with no
  said equivalent for a downstream project on another VCS host, and
  "wired up" was never the same claim as "actually reaching the
  maintainer" (a rotted token or disabled Actions run degrades silently,
  in a log the maintainer never sees). Both now stated plainly in the
  file's own header and cross-referenced from `KIT-ISSUES-LOG.md.template`.

### Why
This kit's own last several releases (v1.20.0 through v1.23.0) were each
produced by exactly the pattern this entry now changes: an agent working
on an unrelated downstream task found a real bug in this kit, and — per
the old Definition of Done — immediately branched, fixed, and PR'd
against this repository as part of that same session, every time. That
produced genuinely good fixes, but the downstream project's owner never
actually got a chance to decide, case by case, whether turning unrelated
work into kit maintenance was the right call *at that moment* — the old
rule made that decision permanently and unconditionally, for every future
instance, the day it was written. Explicit owner instruction, 2026-09-23:
treat fixing this kit as its own deliberate, separate unit of work; record
findings as they come up; let a real-time exception be a real decision,
made by the kit's maintainer, each time — not an agent's own inference
about what's "obviously" warranted, however good its judgment has been so
far.

## [1.23.0] — 2026-09-23

- **`SETUP-GUIDE.md`** — added the nine remaining real-world adoption
  scenarios beyond the three already documented ("collaborator joining,"
  "installing mid-way," "upgrading"): a multi-repo product, solo-owner
  team growth to a first hire, multiple humans each running their own AI
  agent concurrently, a non-GitHub VCS host, a non-Claude-Code primary
  agent, reviving a dormant project, retiring the kit, bot/CI accounts
  (a short pointer — already substantively solved by the existing
  Bot/CI-authored PRs rule), and a contractor/temporary collaborator.
  Each cross-references the existing mechanism or lesson it builds on
  (`LESSONS-LEARNED.md`'s multi-repo and multi-agent sections, the
  Maturity Triggers list, the Bot/CI rule) rather than duplicating it, so
  the guidance can't silently drift out of sync with the mechanism it
  describes.

### Why
Kept from the same standing goal that produced the first three scenario
sections: this kit should have something honest to say about every real
shape adoption takes, not just the greenfield case it was originally
written against — "cater all use cases, leave no [one] behind."

- **`templates/workflows/collaborator-log-reminder.yml.template`** — the
  `gh api` call still used the pre-adversarial-review, broken form
  (`changed_files=$(gh api ...)` then a separate `api_exit=$?` line) even
  though a downstream adopter's own copy of this same file had already
  been corrected: GitHub Actions runs every `run:` step with no explicit
  `shell:` as `bash -e {0}`, with errexit on by default *regardless* of
  whether the script itself declares `set -e` — a fact this kit's own
  v1.21.1 entry (removing an explicit `set -e` line) got wrong, believing
  that removal alone disabled errexit. Under the real default, a plain
  `var=$(failing_cmd)` assignment still aborts the whole step before
  `api_exit=$?` ever runs, silently reintroducing the exact hard-failure
  bug v1.21.1 thought it had fixed. Fixed to the form that's actually
  exempt from errexit: `changed_files=$(gh api ...) && api_exit=0 ||
  api_exit=$?` — the failing command is not the last one evaluated in an
  AND-OR list, which `bash -e` does not treat as a triggering failure.

- **`templates/workflows/governance-gate.yml.template`** — while checking
  the above fix against this file for the same failure shape, found
  something worse: this template is, and apparently has been for some
  time, **invalid YAML** — reproduced directly (`python -c "import yaml;
  yaml.safe_load(open(...))"` raised "could not find expected ':'" at the
  under-indented line). It shipped with the exact literal-multi-line-
  string-in-a-`run: |`-block bug this kit's own file header already
  warns about in prose: a `--body "..."` argument spanning several
  physical lines, one of which (the start of the second paragraph) sits
  at column 0, below the block scalar's own indentation, which ends the
  block right there and corrupts the surrounding YAML. The corrected,
  `printf`-based version of this exact file — already written, tested,
  and shipped on a downstream adopter's own copy — was never ported back
  here either. Fixed by porting that corrected version in, genericized
  (removed adopter-specific narrative like a specific repo's own
  confirmed `default_branch` value), and additionally restoring the
  `master`-branch coverage, the `delete`-event handling (a separate job
  that flags a protected branch's deletion for human confirmation), and
  the `pull-requests: read` permission and `BRANCH` env var the adopter's
  copy had added — this template had fallen behind on more than just the
  YAML bug. Re-verified after the fix: valid YAML (`yaml.safe_load`
  succeeds), and the two embedded shell scripts pass `bash -n` and were
  each run standalone against a stubbed `gh` to confirm the constructed
  issue body renders correctly, including the apostrophe in "platform's
  web UI" that the escaped-printf form has to handle correctly to avoid
  reintroducing a quoting bug while fixing a YAML one.

- **`.gitattributes`** — pinned `templates/workflows/*.yml.template` to
  LF, extending the existing `templates/*.sh.template` rule to a file
  class with the same CRLF-corrupts-an-embedded-script risk (this bullet
  itself was missing from this entry until an adversarial review of a
  later release caught the omission — the change shipped in this
  version, the record of it didn't).

### Why
Found while writing this release's `SETUP-GUIDE.md` additions: a planned
cross-reference from the new "different VCS host" section to "the
`bash -e {0}` default-shell finding in CHANGELOG.md" turned up no such
entry, because the real fix — made and verified on a downstream adopter's
own copy of this file — had never been ported back here, breaking this
kit's own Definition-of-Done practice of propagating every real fix
upstream the same day it's found. Checking the sibling workflow template
for the same failure shape, rather than assuming it was fine, is what
surfaced the second, more serious gap — a template that doesn't parse at
all is a stronger case for "verify the mechanism actually works before
trusting it's fine," the same lesson this kit's own `verify-setup.sh`
header names, applied here to the kit's own templates rather than to a
downstream project's copy of them.

## [1.22.0] — 2026-09-23

Real gaps found by an adversarial (Opus) deeper-review pass on a
downstream adopter's own sync of recent kit changes, ported back here:

- **`templates/AGENT_RULES.md.template`** — the "Bot/CI-authored PRs"
  rule (v1.20.0) made `.github/workflows/**` Tier 2 *for bots only*,
  contradicting its own opening line ("the exact same Tier rules as any
  other author") and the canonical Tier 2 list, which didn't include
  workflow files at all. Real inconsistency: a human editing a workflow
  file was Tier 1, an identical bot PR was Tier 2. Fixed by adding
  `.github/workflows/**` and `.githooks/**` (a project's own CI and
  git-native enforcement — at least as load-bearing as `CODEOWNERS`) to
  the canonical Tier 2 list itself, applying to every author, and
  having the Bot rule reference that list instead of restating it (the
  restatement is exactly what let the two copies disagree in the first
  place).
- **`templates/verify-setup.sh.template`** — didn't track warnings
  separately from hard failures, so a real run with WARNING lines still
  printed "All checks passed" — a skimming reader sees success despite
  this script's own header arguing at length that "a check that can't
  fail isn't a check." Fixed: a `warnings` counter, summary line now
  says "Passed, with N warning(s)" when applicable. Also added an
  explicit comment for whoever extends the "project-specific checks"
  section: use `$repo_root`-relative paths, never cwd-relative ones —
  a downstream adopter's own additions to that exact section used bare
  relative paths and silently gave wrong answers when run from a
  subdirectory, found by the same review pass.

### Why
A downstream adopter ported recent kit changes into their own project,
then ran that PR through a fresh + adversarial review pair as required
for a Tier 2 change. The adversarial pass caught real inconsistencies in
content this kit itself shipped, not just the adopter's own additions —
propagated back here the same day, per this kit's own Definition-of-Done
practice, rather than left as a gap only the one downstream copy fixed.

## [1.21.1] — 2026-09-23

Three real bugs in `templates/workflows/collaborator-log-reminder.yml.template`
(v1.21.0), found by a fresh review pass on a downstream adopter's copy
minutes after adoption:

- The `gh api` call ran under `set -e` with no error handling, so a
  transient API failure (rate limit, brief outage) hard-failed the
  whole job instead of degrading gracefully — exactly the "exit code
  implies a guarantee it can't back" mistake this workflow's own header
  comment says must never happen. Fixed: the call now runs outside
  `set -e`, its exit code is checked explicitly, and a real failure
  produces an informational warning + a clean exit instead of a red X.
- The file-presence check used `grep -qF` (substring match), which
  false-positives on an unrelated file whose path merely *contains* the
  expected string (`docs/collaborators/AUTHOR.md.bak`, a nested path,
  etc.), silently suppressing the reminder even when the real log
  wasn't touched. Fixed to `grep -qFx` (exact whole-line match).
- (Downstream-only, not in this template, but recorded for completeness:
  the adopter's own `CLAUDE.md` claimed `package.json`'s `prepare`
  script ran both `setup-hooks.sh` and `verify-setup.sh`, when it only
  ran the former — fixed on the adopter's side by actually chaining
  both, matching what `SETUP-GUIDE.md` already recommends.)

## [1.21.0] — 2026-09-23

New `templates/COLLABORATOR-LOG.md.template` (per-person, not shared —
avoids the merge-conflict problem a single shared log causes under
concurrent work) and `templates/workflows/collaborator-log-reminder.yml.template`
(informational nudge, never blocks merge, checks real file presence in
the diff rather than prose or identity).

Requested directly: each person working on a project should keep their
own signed record of what they did and why, so a reviewer or another
collaborator can get in sync with anyone's work without reconstructing
it from git history alone. Designed to avoid repeating today's earlier
mistakes on this exact category of problem: the reminder mechanism
checks whether `docs/collaborators/<PR-author-username>.md` appears in
the PR's changed-files list (verified against a real PR via `gh api
.../pulls/{n}/files`) — unlike the checkbox-completeness gate rejected
earlier today, this doesn't parse reworded prose; unlike the
`merged_by` audit deferred earlier today, it doesn't depend on comparing
GitHub identities, so it isn't affected by the shared-credential gap a
solo owner + agent setup has. Bot-authored PRs are exempted, verified
via the real `user.type` field (confirmed "Bot" for a real bot account,
"User" for a real human one, via the GitHub API) rather than assumed.

The template's own text states the same shared-identity limitation as
elsewhere in this kit: if an AI agent works under its owner's own
GitHub credentials, an entry's *content* (naming who/what actually did
the work) is the only place that distinction can survive — no mechanism
can verify it.

## [1.20.0] — 2026-09-23

Requested directly: "enforce everything properly, without missing
anything." The honest answer, checked first rather than assumed: most
of this kit's Definition-of-Done items have zero mechanical enforcement
today — only push-protection and hook-wiring do — and the *shape* of
mechanism this kit has been building all day (a CI workflow) fails in a
specific, recurring way on a project with no branch protection, no
test-running CI, and one owner: it produces a check that looks like
enforcement but is structurally unable to catch anything. A full plan to
mechanize everything was drafted, then put through the same fresh +
adversarial review pair this kit's own process requires for real code —
both passes independently found that 3 of 6 proposed mechanisms had
exactly this defect (a checkbox-completeness gate that can't block
merge without branch protection and inverts self-attestation items into
ritual; a `merged_by` self-merge audit that would be structurally unable
to produce a true positive on a solo-owner project, and vulnerable to a
PR neutering its own audit via a `pull_request` trigger instead of
`push`; a bot-PR carve-out that contradicted this kit's own Tier 0
definition and opened a real supply-chain hole). Built the honest
version instead:

- **Added, real:** `templates/PULL_REQUEST_TEMPLATE.md.template` now
  surfaces all 5 previously-invisible Definition-of-Done items as
  checkboxes, explicitly labeled as visibility, not a verification gate
  — the same honesty the rest of this release applies to itself.
- **Added, real:** `templates/AGENT_RULES.md.template` gets an explicit
  "Bot/CI-authored PRs" rule — no special Tier-0 carve-out for bots;
  same Tier rules as any other author, based on diff content, closing
  a previously-undefined case without opening the supply-chain hole the
  rejected draft would have.
- **Added, real:** `templates/STAGE-0-RESEARCH-ENRICHMENT.md.template`
  gets a third standing exception (prior-art/comparable-project
  research, scoped narrowly to that sub-check, not all of Dimension 3
  — the narrow scoping is itself a fix for a self-contradiction the
  first draft had) and `templates/OPEN-RESEARCH-QUEUE.md.template`
  gets a matching process note. This closes a real, verified gap: no
  form of "check what similar projects found" existed anywhere in this
  kit before today.
- **Added, real:** `templates/PASS-0-ENVIRONMENT-DISCOVERY.md.template`
  §4 now asks whether any AI agent with merge/push capability has its
  own distinct credential or shares a human's — checked directly on a
  real project during this work (`gh auth status`/`gh api user`) and
  found to be shared, with no separate agent identity at all. This is
  load-bearing: it means a future `merged_by`-based check can never
  distinguish an agent self-merge from the human's own click on that
  project, no matter how well built.
- **Sharpened, not repeated:** `LESSONS-LEARNED.md`'s "second-human
  self-merge" entry (1.19.0) gets four real additions from actually
  trying to build the mechanism it proposed: it can't produce a true
  positive on a solo-owner project (not "partial coverage," zero); it
  needs the PR's tier to interpret `merged_by == author` correctly
  (that's *correct* behavior at Tier 0/1); the shared-agent-identity
  gap it can never close; and the `pull_request`-vs-`push` trigger
  choice that determines whether a PR can neuter its own audit.
- **Deliberately not built:** the checkbox-completeness CI gate and the
  `merged_by` self-merge-audit workflow themselves. Both are named,
  real, designed-in-principle, and explicitly deferred to the actual
  conditions that would let them deliver a real guarantee instead of a
  fake-looking one — not silently dropped, not built anyway to look
  complete.

### Why
Two review passes on the plan (not the code — this kit's own process,
applied one level up, before implementation started) found that four of
six proposed mechanisms were "add a workflow" as the default answer to
"make this enforced," producing the same defect class already caught
four times earlier today in this exact project (an invalid-YAML gate
that silently never ran, a verify script that repaired what it checked,
a fallback that swallowed real failures, a chmod check that didn't
exercise git's real code path). The lesson generalized here: a
mechanism that cannot actually deliver what its name claims is worse
than no mechanism, because its green status reads as coverage that
doesn't exist — this kit's own `LESSONS-LEARNED.md` already says this
about `agt`-style vendor checks; today it was this kit's own draft work
that needed the same standard applied to itself.

## [1.19.2] — 2026-09-23

Follow-up to 1.19.1's chmod-verification fix, found by a fresh review of
that very fix minutes after it merged: the new explicit `[ ! -x ... ]`
re-check was a narrower, second mechanism sitting alongside a self-test
that still couldn't detect the same failure class on its own, because
that self-test invoked the hook via `sh "$hooks_dir/pre-push"` — which
runs the script's content regardless of its executable bit, not the
same code path git itself uses (a direct exec, relying on the shebang
and requiring `+x`). Two checks for the same concern that could drift
apart is itself a real risk (the exact "propagate lessons back"
inconsistency 1.17.1 and 1.18.0 both already had to fix once each).

Fixed in both `templates/setup-hooks.sh.template` and
`templates/verify-setup.sh.template`: the self-test now invokes the
hook directly (no `sh` in front), making it the authoritative check for
"can git actually run this" rather than a second, narrower one. The
explicit `-x` check stays too, deliberately — it gives a clearer,
specific diagnostic message ("chmod ran but didn't take effect") before
the self-test would eventually fail for the same reason with a more
generic message. Verified end to end against a real downstream
project's real hook: full success path still reports OK, and the
self-test now genuinely exercises the same invocation model git does.

## [1.19.1] — 2026-09-23

Real bug in `templates/setup-hooks.sh.template`, found by a fresh review
pass run against a downstream project's copy of this script (misdirected
at the time — it was meant to review something else — but the finding
was real regardless, so it's fixed here rather than discarded for having
arrived by accident): `chmod +x "$hooks_dir/pre-push" 2>/dev/null ||
true` silently swallows a real chmod failure (a mounted volume that
doesn't preserve Unix permissions, a restrictive ACL), and the
self-test immediately after invokes the hook via `sh
"$hooks_dir/pre-push"` — which runs the script's content regardless of
its executable bit, not the same code path git itself uses (a direct
exec, which Unix refuses without `+x`). So this script could report
"OK: hook is real and active" on a hook `git push` would silently skip
entirely. Fixed with an explicit `[ ! -x ... ]` re-check immediately
after the chmod, failing loudly if it didn't actually take effect.
Verified the underlying claim empirically (a file with `chmod -x`
applied is still invoked successfully via `sh file` but correctly
refused via direct execution) — though ironically not reproducible as
an actual chmod *failure* on the Windows/NTFS machine this was found
on, since NTFS doesn't meaningfully enforce the executable-bit
distinction Linux/Mac do, which is precisely why this had gone
unnoticed until now.

Also documented, not fixed (a deliberate tradeoff, not an oversight):
wiring this into an npm `prepare` script means it also runs in
non-git-clone contexts (a deployment artifact, a Docker layer-caching
build stage) where it will now hard-fail the whole install. Recorded in
the script's own header as the correct behavior (fail loud, don't mask
a broken clone with `|| true`) with the real mitigation named
(`--ignore-scripts` for a project's actual non-git install path,
handled deliberately there rather than weakened here for every
context).

## [1.19.0] — 2026-09-23

New lesson in `LESSONS-LEARNED.md` §"Review / process": onboarding a
second real human contributor (Write access) to a solo-owner,
AI-agent-governed repo on a free-plan private GitHub repo revealed that
"no self-merge for a human contributor" had zero mechanical backing —
the existing pre-push hook and PR-existence-checking workflow, built for
a different failure mode (an agent forgetting to open a PR), have no
visibility into who clicks "Merge" on a properly-opened one. The
onboarding documentation for the new contributor initially implied that
gap was covered by the existing infrastructure, without ever naming that
it wasn't — caught by an adversarial review pass. Extracted as a general
lesson since "the rule that governs the agent doesn't automatically
extend to a second human, and it's easy to write onboarding docs that
imply it does" is portable beyond this one project.

(Originally authored as "1.17.0" on 2026-09-21, before this kit advanced
through 1.17.0/1.17.1/1.18.0 on a different branch — renumbered to
1.19.0 during merge, 2026-09-23, to keep version history sequential; no
content changed from the original.)

## [1.18.0] — 2026-09-23

New `templates/CLAUDE.md.template` and `templates/verify-setup.sh.template`,
plus new SETUP-GUIDE.md sections for three onboarding scenarios this kit
never documented, found by directly using the kit on a real second
project and asking, on purpose, "how
would each different kind of person get a complete, correct setup right
now" rather than waiting for a real incident to surface the gap.

- **`templates/CLAUDE.md.template`** — this kit's entire model depends on
  an agent actually reading `AGENT_RULES.md`, but nothing before this
  version made that happen automatically. Claude Code and other tools
  auto-load `CLAUDE.md`/`AGENTS.md` at session start; this template is
  what points that auto-load at the real rules and at
  `verify-setup.sh`. Added to `AGENT_RULES.md.template`'s Tier 2
  file list (alongside `AGENT_RULES.md`, `CODEOWNERS`,
  `MODEL-UTILIZATION-PLAYBOOK.md`) — same reasoning as the playbook:
  whatever an agent auto-loads governs every task in the project, so a
  corrupted edit to it is exactly as load-bearing.
- **`templates/verify-setup.sh.template`** — a read-only companion to
  `setup-hooks.sh`, deliberately kept as a separate file. A first draft
  had `verify-setup.sh` simply delegate to `setup-hooks.sh` — both a
  fresh and an adversarial review pass, run on that draft before it
  shipped, independently caught that this makes "verify" silently
  *repair* the exact drift it's supposed to detect (`setup-hooks.sh`
  mutates `core.hooksPath` and the executable bit before its own
  self-test), then report success — the same failure shape as a vendor
  "compliance verify" tool that checks package importability instead of
  real behavior and reports 100% passed regardless. Rewritten to only
  ever read state. Ships with an explicit "project-specific checks"
  extension point instead of trying to anticipate every adopter's own
  additional tooling.
- `SETUP-GUIDE.md` — three new named scenarios beyond the greenfield
  walkthrough: **a collaborator joining an already-set-up project**
  (mostly a non-event if setup was done right — named explicitly
  anyway, since "mostly a non-event" is itself worth confirming rather
  than assuming), **installing this kit on an ongoing/existing
  project** (Stage 0 doesn't re-run; Tier calibration must start at the
  project's real current maturity, not the template's solo-owner
  default; the hook change needs a named communication step to an
  existing team; merge into existing CODEOWNERS/CI, never overwrite),
  and **upgrading an already-adopted project to a newer kit version**
  (genuinely undocumented before this — the honest current process is a
  real diff-and-merge per file, run through the adopting project's own
  Tier 2 rule since it changes that project's own rules documents).
  Step 9 ("Verify it's real") now points at `verify-setup.sh` as the
  run-any-time version of its own step 5, and names it as the one real
  place project-specific tooling checks belong, instead of inviting a
  second, competing verification doc per project.
- Two small propagation fixes, found the same way: the "coupled to
  literal wording" comment added to a downstream copy of
  `setup-hooks.sh`/`pre-push` during an earlier adversarial pass never
  made it back into this kit's own templates — ported now, closing a
  real gap in this kit's own "propagate lessons back" practice
  (`AGENT_RULES.md.template`'s own Definition of Done checklist).

### Why
Directly asked, on the second real project this kit has now been used
on: does every kind of person who might touch this project — the one
starting it, a collaborator joining later, someone installing this kit
partway through an existing codebase — actually get a complete, correct
setup, or does some of that still depend on a person reading the right
doc at the right moment and remembering to act on it? The honest answer
was no on all three counts, for different reasons each time, and this
release is the fix for the three real gaps that answer found — not a
speculative expansion, and deliberately scoped smaller after two review
passes both concluded an earlier draft was heavier than the actual gap
warranted.

## [1.17.1] — 2026-09-22

Two real bugs in `templates/setup-hooks.sh.template` (v1.17.0), found by
a fresh review pass while wiring it into a real downstream project minutes after adoption:

- The synthetic push-to-main test wasn't isolated from an ambient
  `ALLOW_DIRECT_MAIN_PUSH` in the calling shell (left exported from a
  real earlier override, or set in a profile) — it would take the
  override branch instead of the reject branch, reporting a false
  "setup failed" AND appending a bogus, fake-sha entry to
  `OVERRIDE-LOG.md` claiming a real override happened. Fixed: the
  synthetic test now runs in a subshell with that variable explicitly
  unset first.
- The "hook not found" error message pointed to "SETUP-GUIDE.md step
  1" — correct for this kit's own repo, but a dead reference the
  moment this template is copied into any consuming project (which
  doesn't get its own copy of this kit's `SETUP-GUIDE.md` — that file
  isn't part of the copy list). Fixed to name the full upstream
  reference (`taseenali/Kit-GO`'s `SETUP-GUIDE.md`)
  and say plainly that the copy won't have a local one.

## [1.17.0] — 2026-09-22

New `templates/setup-hooks.sh.template`, requested by an adopter after noticing a real onboarding gap:
this kit's own fix for "a written rule can be forgotten" (the pre-push
hook + governance-gate pairing) itself depended on a written
instruction — `git config core.hooksPath .githooks` — that a new
collaborator on a fresh clone could just as easily forget, since
nothing about `git clone` wires it automatically. The new script does
in one command what `SETUP-GUIDE.md` previously described as two
manual steps (`chmod +x`, `git config core.hooksPath`), and its own
last step verifies the wiring actually worked by feeding the hook a
synthetic push-to-main event over stdin rather than trusting that
setting the config succeeded.

That synthetic-event approach isn't just a preference: while building
this, a real attempt to verify the hook with an actual
`git push origin HEAD:main` test was auto-blocked by an AI coding
agent's own safety tooling, which read that exact command as
indistinguishable from the dangerous action the hook exists to
prevent — a real, reproducible finding, not a hypothetical. The
synthetic-stdin method verifies identical hook logic without ever
touching the network, so it isn't subject to that same block.

- `SETUP-GUIDE.md` step 1's copy list now includes this file (copied to
  `scripts/setup-hooks.sh`), with guidance on wiring it into whatever
  command a project's stack already runs on first install (an npm
  `prepare` script, `make setup`, a packaging post-install hook — no
  single mechanism covers every stack, so the script's own header
  documents the pattern per stack instead of assuming one).
- `SETUP-GUIDE.md` step 9's verification section now recommends the
  script's synthetic-event check as the default way to confirm the
  hook is real, with the real-push method demoted to a fallback and
  its own risk (the auto-block above) noted explicitly.
- `README.md`'s file table updated with a pointer to the new template.

## [1.16.0] — 2026-09-18

New `CASE-STUDY-FOR-BEGINNERS.md`, requested directly by the owner for a
specific real reader: a non-technical person with real business instincts
who wants to understand how AI-led development actually works. Every
other file in this kit is written for a technical reader (a human
developer or another AI agent) — this is the first plain-English
companion piece, translating the same real events this kit's own rules
were extracted from (the review-tier discipline, the mechanical
"vault door" push protection, the living-documents paper trail) into
business analogies, with two real Mermaid diagrams (the standard work
loop, and one full real example traced end to end) and a glossary. Two
real incidents (a crashed review recovered from a git checkpoint; a
background task's edit landing on the wrong branch, untangled without
loss) are included deliberately rather than omitted, since a case study
that only shows success isn't a credible one.

- `README.md`'s file table updated with a pointer to it.

## [1.15.0] — 2026-09-18

New `templates/PASS-0-ENVIRONMENT-DISCOVERY.md.template`, requested
directly by the owner: every step in `SETUP-GUIDE.md` and most of this
kit's templates were originally written against one specific project's
real answers (Python/pytest, private GitHub repo on the free plan,
solo owner + AI agent, single repo) — a new adopter with different
answers (different stack, different VCS host/plan, more than one repo,
more than one person committing) would silently inherit assumptions
that don't fit them. Pass 0 is a real, fillable discovery document
covering stack/test tooling, VCS host and plan tier, repo count and
structure, team shape, and deployment status — each section states
plainly what it determines about the rest of setup (which CI template
variant, whether platform branch protection or the hook+gate mechanism
is primary, whether templates need copying into more than one repo,
how the Tier system's self-merge authority should be calibrated).

- `SETUP-GUIDE.md`'s "0. Before you start" now points here first, and
  "1. Copy the templates in" is explicitly framed as the *reference
  project's own answer* to Pass 0, not a universal prescription.
- `README.md`'s file table updated with Pass 0 and the two files from
  v1.14.0 that were missing from it (`pre-push-hook.template` +
  `OVERRIDE-LOG.md.template`, `governance-gate.yml.template`).

## [1.14.0] — 2026-09-17

New reusable templates and a first-class lesson from directly fixing
the recurrence found in v1.13.0 — then, per the owner's own explicit
instruction ("multi agent passes run to make sure everything's safe
and sound"), a real fresh + adversarial review of this fix itself
before treating it as done. The owner asked for a durable solution —
not another document restating the rule — to a named regression
pattern: rule-following degrades as context grows/compacts, and it's
worse for a multi-repo product where a session's auto-loaded memory is
anchored to one repo and never reaches a sibling repo's own rules file,
however well-written. The adversarial pass earned its keep: it built a
throwaway git remote and actually reproduced several real bypasses in
the first version of this fix rather than reasoning about them —
findings folded in below, not left as a separate follow-up.

- New `templates/pre-push-hook.template` — a git hook rejecting a
  direct push OR deletion of `main`/`master` from any clone that has it
  wired, with a deliberate override (`ALLOW_DIRECT_MAIN_PUSH="<real
  reason>"` — a bare `=1` is rejected) logged to a new
  `templates/OVERRIDE-LOG.md.template` for a durable, diffable record
  beyond one shell's scrollback. **Revised after the adversarial
  pass reproduced two real bugs in the first version**: it originally
  let the protected branch be *deleted* outright (an exemption meant
  for ordinary branch deletions wrongly covered this too — deleting
  `main` is a bigger deal than pushing to it, not a lesser one), and
  the override had no durable record at all, just an ephemeral stderr
  line. The hook's own comments now state its honest limits plainly —
  it does not stop `--no-verify`, `core.hooksPath` being unset, the
  hook file being deleted, or a change made directly on the platform's
  web UI — instead of implying more than a client-side hook can
  structurally deliver.
- New `templates/workflows/governance-gate.yml.template` — the
  server-side backstop for exactly the gaps above: a GitHub Actions
  workflow, triggered on every push to `main`, that queries whether the
  pushed commit is associated with a real merged PR and fails loudly
  (opening an issue) if not. Added specifically because the adversarial
  review's verdict was that a client-side hook alone "cannot bind an
  actor on the client" — this runs on the platform's own infrastructure
  instead, so it can't be silently disabled by anything that happens on
  a developer's machine. Verified against real historical commits in
  the repo that produced this fix: correctly flagged the two commits
  that actually bypassed the PR requirement, correctly passed a normal
  PR-merge commit.
- New `templates/.gitattributes.template` — pins `.githooks/**` to LF
  line endings; a CRLF-corrupted hook fails to execute in a way
  indistinguishable from the hook simply not being wired at all.
- `AGENT_RULES.md.template`'s "never push directly to main" rule now
  points to the hook and the gate as the recommended pairing when
  platform-level branch protection isn't available.
- `SETUP-GUIDE.md` covers copying and wiring all of the above,
  including the multi-repo case explicitly (copy and wire independently
  in *each* repo of a polyrepo product), and a real "prove it fires"
  verification step for both the hook and the gate — presence in the
  repo is not proof either one is actually active.
- New `LESSONS-LEARNED.md` entry under "Multi-repo / multi-codebase
  products": a coding assistant's auto-loaded project memory is
  anchored to the session's actual working directory, not every
  directory a session's tool calls touch — so a governing-rules
  document written in Repo B does nothing for a session rooted in Repo
  A while it edits Repo B through tool calls. Two paired fixes named
  explicitly: make the blind spot itself unmissable in each repo's own
  auto-loaded file, and move what actually matters onto a mechanism
  (a git hook, a CI gate) that doesn't depend on context being loaded
  at all.
- **Named honestly, not solved by this release**: of roughly twenty
  binding rules across a typical `AGENT_RULES.md`, this release gives a
  mechanism to exactly one ("don't push directly to main"). The
  adversarial review's sharpest finding: everything else — no secrets
  committed, tests actually run, docs stay in sync, review tier honored
  — remains exactly as memory-dependent as before. Real follow-up
  candidates it named, not yet built: a pre-commit secret-scan hook,
  and extending `governance-gate.yml` toward checking substance (tests
  green, no secrets) rather than only "a PR existed."

## [1.13.0] — 2026-09-17

Two new lessons from a targeted gap-check across two live projects,
requested directly by the owner ("is there anything we're falling short
on... anything we could be overlooking") rather than surfaced by an
incident. Verified against real repository state (`gh pr list`, `git
log`), not assumed.

- **A written "PRs required before merge" rule needs a mechanical
  enforcement point, not just policy + agent memory — even a working
  process lapses on some fraction of changes while working correctly on
  others in the same session.** Real case: in the same working session,
  three chunks of work on one repo went through real PRs with CI gates
  (`gh pr create` → checks → `gh pr merge`), while two other chunks —
  built and reviewed with the same real rigor (local Tier 2 fresh +
  adversarial passes, mutation testing) — were merged straight to the
  default branch via direct `git merge`, with no PR ever opened on
  GitHub at all. This was not the earlier-diagnosed cause (the `gh`
  binary missing) — the tool was demonstrably available and used
  correctly elsewhere in the very same window. The fix that earlier
  incident produced (re-read the rules file after a context boundary)
  is necessary but not sufficient on its own: it depends on the agent
  remembering to apply a written rule on every single change, which is
  exactly the failure mode being guarded against. Where the platform
  supports it, pair the written rule with branch protection (require a
  PR + passing checks before a merge to the default branch is even
  possible) so the rule holds even when an agent's own discipline
  doesn't that one time.
- **When a Tier 2 review's fixes touch a source file that has a paired
  test file, updating that test file is part of the same atomic change
  — not a follow-up step that can trail behind.** Real case: a review
  pass's fixes moved a function call from one route file to another;
  the route files were fixed correctly, but the paired test files
  weren't updated in the same pass, and the gap survived across a
  context-compaction boundary before being caught (by chance, re-reading
  a test file directly before editing it, not by a systematic check).
  Before considering a review-driven fix round complete, explicitly
  checklist every changed source file against whether it has a `*.test.*`
  counterpart, and confirm that counterpart's mocks/assertions still
  match the new code — don't rely on the test suite simply failing loud
  enough to catch it (a stale mock for a removed dependency can still
  produce a misleading pass or an unrelated-looking failure).

## [1.12.0] — 2026-09-17

Four new lessons from a real, same-day process-breakdown audit: a
previously-working `gh` CLI silently went missing and work continued via
direct git merges instead of the established PR flow, and a required
"save the answer" logging step stopped happening — both starting at the
exact same session boundary (a context compaction / account switch), not
two unrelated bugs. Root cause: the agent stopped re-reading its own
governing rules document after that boundary and worked from a
compressed memory of it instead — the document itself was correct the
whole time.

- A CLI tool the process depends on going missing is itself the thing to
  report immediately, not a problem to route around quietly.
- Multiple compliance gaps clustering at one exact timestamp point to
  one shared cause (a session/context boundary), not independent bugs —
  check timestamps before investigating each separately.
- Re-read the authoritative rules file after any compaction/account
  switch/long gap before resuming state-changing work — don't trust a
  summarized memory of "what the rules are."
- A long-lived branch/PR is a visibility risk, not just a conflict
  risk — work invisible on the default branch is invisible to any
  future session, human or agent, that only looks there.

## [1.11.0] — 2026-09-17

Three new lessons from a session where a background research agent
misread an ambiguous, informally-worded user instruction, a second
independent review caught it, and the corrected reading pointed at a
decision already made weeks earlier that a new mockup had silently
contradicted:

- **Verifying a second-opinion / adversarial reviewer's own reading**:
  a second independent read of ambiguous natural-language instructions
  is cheap insurance before acting with real downstream cost — especially
  checking whether a word in the sentence doubles as project-specific
  vocabulary that changes its natural meaning; search the project's own
  decision history for matching vocabulary before researching a "new"
  problem, since it may already be solved; cross-check new build work
  against prior decisions in the same domain before assuming nothing
  conflicts.
- **Real-world identity/access questions surfacing mid-build**: a named
  individual's personal account ending up as a third-party service's
  administrative owner is a real, recurring small-project pattern —
  flag it explicitly as a tracked human item the moment it's discovered,
  don't let a blocked PR sit with an unstated reason.

## [1.10.0] — 2026-09-16

### Added
- `LESSONS-LEARNED.md`, "CI" — two new real findings from standing up a
  test/CI scaffold on a real project for the first time:
  - A fresh install that leaves a platform-specific native binding
    unresolved is a known, documented npm bug (upstream `npm/cli#4828`),
    not a local problem to guess at — confirm by inspecting the relevant
    `node_modules` subpath directly, fix with a full clean reinstall, and
    re-verify by re-running whatever crashed rather than assuming success
    from a clean install exit code.
  - Check a new dev-tool major version's real peer-dependency
    requirements against what the project already pins before installing
    `latest` — a newer major can force an unrelated, unjustified bump to
    an existing pin (`@types/node`, a runtime version, etc.) elsewhere in
    the project.

### Why
Both hit for real the same day, standing up a test harness on a
zero-test-infra codebase. The npm/native-binding bug in particular cost
real debugging time before the actual (simple) fix was found — worth
recording so it's recognized immediately next time, not re-diagnosed
from scratch.

## [1.9.1] — 2026-09-16

### Changed
- `LESSONS-LEARNED.md`, "Multi-agent coordination" — sharpened the
  identifier-collision lesson with a real sub-case: a collision can happen
  even when a directory listing shows the target number genuinely free,
  because the number was already claimed by a cross-reference in a
  different index/summary document, with no same-named file of its own
  yet. Check wherever identifiers get referenced, not just the directory.

### Why
Hit again the same day as v1.9.0's original entry, in a different shape:
the earlier lesson assumed the collision would always be against a
same-named file a listing would catch. This time a listing came back
clean and the collision happened anyway, against a plain cross-reference.
Worth recording as its own real variant rather than folding silently into
the existing bullet, since "check the directory" alone is now known to be
an incomplete fix.

## [1.9.0] — 2026-09-16

### Added
- `LESSONS-LEARNED.md` — three new sections, each from a real finding on
  the origin project, written generically for reuse:
  - **Machine-to-machine / service-to-service auth** — a shared
    account-level credential often authenticates "someone valid for this
    account," not "the specific caller you expect" (use a scoped
    credential where the provider offers one, and add a code-level
    identity-claim allowlist as defense-in-depth regardless); a
    "successful" verification response can still carry a
    revoked/expired/disabled signal as fields on the success body, not
    just as a thrown exception — check the real response shape, don't
    assume no-exception means valid; bound the timeout/retry policy on
    any outbound verification call explicitly, since a generated SDK's
    default can retry for far longer than a synchronous request-handling
    path can safely hold a worker thread.
  - **Multi-agent coordination** — a background agent choosing its own
    sequential identifier (a pass number, a doc index) can collide with
    concurrent work even after checking "what's next" at dispatch time,
    since the check and the eventual write aren't atomic across agents;
    treat it as cheap to detect and fix after landing, not something to
    design elaborate coordination around up front.
  - **Multi-repo / multi-codebase products** — a product spanning more
    than one repository is one system, not "the primary project" plus
    "an integration into it"; a requirement or design decision doesn't
    lose standing for being discovered in whichever repo isn't shipping
    the UI today. Separately: whether multiple codebases should live in
    one repository is a development/ops-workflow decision, independent
    of the runtime integration design — settle the latter first, and
    answer the former with real, verifiable evidence (VCS access-control
    granularity, actual language-tooling support, real team size against
    real small-team guidance) rather than default monorepo enthusiasm
    calibrated for a much larger org.

### Why
All three found the same day on the origin project, each the kind of
thing that reads as obvious in hindsight but survived a first
implementation and a first read-through review regardless. The
machine-to-machine findings in particular only surfaced under an
adversarial review pass that actually exercised the code (a local stub,
a mutation test, a real exception-hierarchy trace) rather than reading it
— worth calling out as its own evidence for why the adversarial-pass
mechanism (see "Review / process" below) earns its cost on exactly this
kind of boundary.

## [1.8.0] — 2026-09-15

### Added
- `templates/MODEL-UTILIZATION-PLAYBOOK.md.template` — a new, optional
  `{{MANUAL_ONLY_MODEL}}` table row and a matching "Hard boundaries" rule
  for a project that has a model class which must never be auto-dispatched
  by an agent, only invoked by a human's manual switch for that one task,
  and only when genuinely suited to it. Explicitly distinct from "not yet
  characterized" (which is a research gap that closes with use) — a
  manual-only model stays manual-only even once well-characterized;
  characterization only ever informs what a human might switch it to.

### Why
Found on the origin project the same day as v1.7.0: a real model in that
environment (Fable) needed exactly this rule, and the existing template
had no place to express "never autonomous, always human-gated" as
distinct from "no data yet, don't guess." Most projects won't have a
model like this — the row and rule are written to be deleted when they
don't apply — but the pattern (a model that stays permanently
human-gated, independent of how well it gets characterized) is real and
reusable, so it belongs in the template rather than left implicit.

## [1.7.0] — 2026-09-15

### Added
- `templates/MODEL-UTILIZATION-PLAYBOOK.md.template` — a project-wide
  framework for which AI model handles which task, tied to the same
  review-rigor tiers the local multi-pass fallback already uses. Core
  principle: both under-provisioning (a pass not genuinely decorrelated
  from whatever reviewed the work already) and over-provisioning
  (escalating past what a task's real stakes need, spending real finite
  budget) are treated as real failure modes. Generalizes the
  relative-difference principle (never hardcode a model name) as a
  project-wide rule, and sets an absolute floor on which model classes
  may ever verify a finding or make a judgment call — deliberately
  stated as absolute, not relative to the session default, since a
  relative floor silently disappears if the default itself becomes a
  fast/cheap model.
- `templates/AGENT_RULES.md.template` — the playbook is now itself in
  the Tier 2 file-triggered list (alongside `AGENT_RULES.md` and
  `CODEOWNERS`) and cross-referenced from the "Local multi-pass review"
  section as that section's general framework.
- `SETUP-GUIDE.md` — new steps 5 and 6 (Open Research Queue, Model
  Utilization Playbook). Also closes a real pre-existing gap: the Open
  Research Queue template (added in an earlier version) had never
  actually been given a setup step at all.

### Fixed
- `templates/PULL_REQUEST_TEMPLATE.md.template` and the Definition of
  Done checklist item in `AGENT_RULES.md.template` were both missing the
  "and the human has confirmed that" qualifier on ultra/deeper-review
  unavailability that the rest of the v1.6.x fallback work already
  carried — a real propagation gap from the prior patch releases, found
  while adding the playbook's own cross-references and fixed the same
  day rather than left for a future release to notice.

### Why
On this kit's origin project, building the playbook and testing it
against itself (a fresh pass, then a full adversarial pass on a
genuinely different model) found 9 further real issues beyond the 8 the
fallback itself had already caught one version earlier — including the
playbook briefly contradicting its own core "never hardcode a model
name" rule in its own summary table, and a direct self-contradiction
about which budget pool different models draw from. Two rounds, two
pieces of new governance content, 17 total issues neither same-model
pass would have caught alone — the clearest evidence yet for why this
kit's own review-rigor tiers exist.

## [1.6.2] — 2026-09-15

### Fixed
- `templates/AGENT_RULES.md.template` — an adversarial Opus review pass
  (this kit's origin project's own first real use of the v1.6.0 fallback)
  found 6 further real gaps in the fallback beyond the 3 fixed in 1.6.1:
  (1) internal step references inside the fallback's own numbered list
  collided with the outer approval protocol's identically-numbered steps;
  (2) step 3 hardcoded "a genuinely different model" as a fixed choice
  rather than a property relative to whatever ran step 1, risking two
  passes on the same model if the calling session already used the
  "default" choice, and a fabricated-model claim in the risk summary;
  (3) the fallback let an agent unilaterally decide the deeper-review
  tool was "unavailable" and proceed, with the human only notified after
  the fact rather than asked — added an explicit confirmation
  requirement before the fallback starts; (4) the waiver's scope was
  stated three different, inconsistent ways across the document
  (tool-only vs. entirely vs. both) — unified to "waiving means both, not
  one"; (5) a table row's justification for "No" (same underlying model
  regardless of invocations) was invalidated by the fallback's own
  cross-model premise — reworded to the actually-load-bearing reason
  ("not a human," not "same model"); (6) the table's column header and a
  closing line both mischaracterized the two-model fallback as a
  "single-agent" approach — added a footnote and reworded.

### Why
This is the real value the v1.6.0 fallback was built to capture: a
genuinely different model reviewing the same diff found real problems a
same-model pass had already cleared. Worth recording plainly as
validation of the fallback's own premise, not just as another bugfix
entry.

## [1.6.1] — 2026-09-15

### Fixed
- `templates/AGENT_RULES.md.template` — 3 real self-consistency gaps a
  fresh review pass found in the v1.6.0 fallback, same day: the "tell the
  human before switching models" step was numbered *after* the step that
  describes running the model switch; the primary Tier 2 definition still
  described only two outcomes (deeper review runs, or a human waiver) and
  never mentioned the new fallback as a legitimate third; the Definition
  of Done's Tier 2 checklist item still said only "deeper review," not
  naming the fallback as an acceptable substitute when genuinely
  unavailable.

### Why
Found by the same fresh `code-review` discipline this document requires
of every other change, applied to itself the same day it shipped. Worth
a same-day patch for the same reason 1.4.1/1.5.1 were: an internal
contradiction in a governance document is worse than an incomplete one,
since it actively misleads a reader who trusts it.

## [1.6.0] — 2026-09-15

### Added
- `templates/AGENT_RULES.md.template` — a new "Local multi-pass review"
  fallback for Tier 2's deeper-review step: when a deeper/multi-agent
  review mode is genuinely unavailable (billing exhausted, a connector
  broken) and the human doesn't want to pay to unblock it, the fresh
  review pass gets one additional adversarial pass on a genuinely
  different model instead. Real decorrelation (a different model, not
  the same model re-prompted) rather than a downgrade dressed up as
  equivalent. The risk summary must label it "local multi-pass fallback,"
  never presented as the real thing. Any model switch must be announced
  to the human beforehand with a one-line reason — never silent, per an
  explicit condition set when this was designed.
- `templates/PULL_REQUEST_TEMPLATE.md.template` — Tier 2 checkbox
  mentions the fallback.

### Why
On this kit's origin project, `/code-review ultra`'s usage credits ran
out mid-project with no top-up planned — a real gap in the existing
protocol, which only had "ultra runs" or "human waives it," no path for
"unavailable, but real review still matters." Asked directly whether the
environment could approximate ultra's value locally; the honest answer
led here: same-model re-prompting doesn't add real decorrelation, but a
second pass on a genuinely different model does, which is the one
substitution actually worth making when the real tool isn't an option.

## [1.5.1] — 2026-09-15

### Fixed
- `templates/AGENT_RULES.md.template` — `.github/CODEOWNERS` was missing
  from the Tier 2 list and the "no exception" clamp, so an agent could
  have self-merged a change to CODEOWNERS itself (the file that defines
  who Tier 2 sign-off goes to) under Tier 0/1. Added explicitly to both
  places. The self-merge preconditions list had an "after merging" action
  folded in as a 4th precondition, contradicting its own "before" header
  — moved into a separate paragraph. The Tier 2 ultra waiver had no
  stated bound, letting "required by default" quietly become "recommended"
  through routine waiving — now explicit: PR-specific, stated each time,
  never a standing policy, with routine waiving itself flagged as a
  signal to revisit the boundary.
- `templates/CODEOWNERS.template` — same self-reference gap; now states
  explicitly that it's in its own Tier 2 list.
- `templates/PULL_REQUEST_TEMPLATE.md.template` — Tier 2 checkbox synced
  to include legal-compliance-adjacent behavior and CODEOWNERS; Tier 0/1
  wording clarified for the "CI never triggers for these paths" case;
  waiver's bounded nature surfaced instead of only living in AGENT_RULES.md.

### Why
Found by `/code-review ultra` on this kit's origin project's own v1.4.0
PR (a real multi-agent review pass, not a fresh single-agent one) — the
same review pass that shipped Tier 1 self-merge and mandatory Tier 2
`ultra` had, itself, three real internal-consistency gaps. Worth a
same-day patch for the same reason 1.4.1 was: a governance document with
a self-referential gap in its own accountability chain (who can
self-merge a change to who Tier 2 sign-off goes to) is worse than one
that's merely incomplete.

## [1.5.0] — 2026-09-15

### Added
- `templates/STAGE-0-RESEARCH-ENRICHMENT.md.template` — a one-time gate
  run before any Phase 1 (first real, load-bearing) code on a new project
  or a genuinely new product/feature direction. Seven dimensions (Product,
  Project & Scope, Architecture & Code, Developer/Practitioner UX,
  Legal/Compliance, UI/UX Vision, Data & Security), each with an explicit
  status and findings, ending in a real human sign-off statement — not a
  formality to click past. Two standing exceptions baked in from the
  start: legal/compliance findings are informational and never block the
  gate or Phase 1 code (only the live execution of a specifically gated
  action waits on a real answer); a missing external account/endpoint
  never blocks either (build against a pluggable interface, connect the
  real thing later). UI/UX Vision is explicitly *elicited from the
  human*, not researched or assumed — it's the one dimension where the
  answer lives in the human's head.
- `templates/AGENT_RULES.md.template` — new "Stage 0" section near the
  top, pointing any new agent at the gate before it starts writing code.
- `SETUP-GUIDE.md` — new step 4 (Stage 0), existing steps renumbered.

### Why
Asked directly, on this kit's origin project, whether onboarding a new
project through this system enforced a full-scale research phase (product,
legal, architecture, even UI) before a single line of code, with the
human answering questions along the way. The honest answer at the time
was no — the origin project's own research-heavy history (its real Pass
12 sign-off gate before Phase 1 code) was a one-time project decision,
never generalized into this kit, and even that project's own history had
a real gap: UI/UX vision was never elicited at all. This formalizes the
pattern properly, including catching the same gap it fixed — a mandatory,
interactive UI/UX Vision dimension that doesn't let itself be skipped the
way it was the first time.

## [1.4.1] — 2026-09-15

### Fixed
- `templates/CODEOWNERS.template` — fixed a real self-contradiction a
  fresh review pass caught on this kit's origin project's own v1.4.0 PR:
  the unconditional "every PR needs a review from an owner" comment
  directly contradicted the same-day Tier 0/1 self-merge authority. Now
  states Tier 2 (not every PR) is what owner review actually gates.
- `templates/AGENT_RULES.md.template` — added an explicit line that a PR
  touching `AGENT_RULES.md` itself is Tier 2 unconditionally, regardless
  of how its own commit message frames it (the same review pass found
  this wasn't said outright, only implied by the Tier 2 list). Tightened
  the self-merge CI precondition — "CI is green for that PR's changed
  paths" was true even when CI never triggered at all for those paths;
  now requires the suite to have actually run, via CI or locally.

### Why
These three gaps were found by a fresh `code-review` pass run on the
v1.4.0 change itself, on the origin project, the same day it shipped —
each is documented in more detail in that project's own Pass 35 doc.
Worth a same-day patch release rather than folding into the next feature
release: a governance document with an internal contradiction or an
unstated exception is worse than one that's merely incomplete, since it
actively misleads a future reader who trusts it.

## [1.4.0] — 2026-09-15

### Changed
- `templates/AGENT_RULES.md.template` — Tier 1 is now explicitly
  **self-merged by the agent** once its fresh review pass is clean and
  CI is green, no human click required; Tier 2's deeper/multi-agent
  review is now **required by default**, not merely recommended, and the
  human's sign-off is backed by an agent-written risk summary instead of
  a raw diff. Added three new subsections: "Self-merge preconditions and
  transparency," "Tier re-evaluation" (a PR's tier is its final diff
  content, not its opening intent; default to the higher tier when
  ambiguous), and "Maturity triggers" — an explicit, editable list of
  events (production deployment, a second collaborator joining, data
  scope expanding, a hire, a first real transaction) that require
  revisiting this whole policy rather than assuming it's calibrated
  correctly forever.
- `templates/PULL_REQUEST_TEMPLATE.md.template` — tier checklist wording
  updated to match.

### Why
On this kit's origin project, the user pointed out directly: they had
been clicking "approve" on Tier 2 PRs without actually reviewing them —
which meant the human-sign-off safeguard was pure theater, not a real
check. The instinct was to have another agent do the approving instead;
the correct fix turned out to be narrower and more honest: Tier 1 never
actually needed a human click in the first place (only Tier 2 did) — the
agent had just been asking for one anyway, out of excess caution. Making
Tier 1 self-merge explicit removes the empty-approval-click problem for
the large majority of changes correctly, while Tier 2's human step stays
real (now backed by a mandatory deeper review and an actual risk summary
instead of a raw diff) specifically because that's the one thing no
amount of additional AI review can substitute for — accountability that
requires a named human. The "Maturity triggers" section exists because
this calibration is explicitly provisional: right for a solo-owner,
pre-production project, and wrong the moment any of its listed conditions
change.

## [1.3.0] — 2026-09-15

### Added
- `templates/OPEN-RESEARCH-QUEUE.md.template` — a live registry for open
  research questions, with a required entry shape (question, status,
  real attempt history, what would move it forward, an optional
  deep-research handoff prompt) and process notes on language discipline
  ("open, narrowed" vs. "exhausted") and when a Perplexity-style prompt is
  and isn't the right tool.
- `templates/AGENT_RULES.md.template` — new Definition-of-Done checklist
  item: check the open research queue before any pass sized beyond a
  small fix.

### Why
On this kit's origin project, a stalled research question (a real,
confirmed data discrepancy between two government data sources) got
written up once as "exhausted" and then never revisited — nothing pulled
it back into view for a future pass. The user's direct instruction: never
treat a stalled thread as permanently closed, and research should stay
ahead of the build, not reactive to it. The fix that actually worked
wasn't "try to remember better" — it was a file that gets checked as a
matter of process. Generalized here the same day it was built and proven
on the origin project (a fresh attempt using new angles, on the same day
the queue was created, genuinely narrowed the question further).

## [1.2.0] — 2026-09-14

### Added
- `templates/AGENT_RULES.md.template` — new "Definition of Done — every
  standing practice, every time" section: a starter checklist that
  elevates a project's unwritten habits (an answer archive, a docs-sync
  ritual, memory/durable-guidance capture, propagating lessons back into
  this kit) to the same binding status as the git/secrets/testing rules
  already in the template. Ships with `{{ANSWER_ARCHIVE_LOCATION}}` and
  `{{GOVERNANCE_KIT_LOCATION}}` placeholders and is explicitly meant to be
  edited per project, not used as-is.

### Why
On this kit's origin project, a real gap slipped through: a large batch of
substantive work got reported as complete, but one of the project's own
established practices (archiving a user-requested answer) was skipped for
it — caught only because the user asked directly whether context was being
kept in sync. The user's instruction generalized past that one practice:
once something becomes a real, repeated practice on a project, it should
be checked every time with the same seriousness as an actual task
execution, not left as an implicit habit that depends on staying top of
mind. This section is the reusable form of that fix — a place for a
project's unwritten practices to graduate into a checked list before they
cause the same kind of miss somewhere else.

## [1.1.0] — 2026-09-14

### Changed
- `templates/AGENT_RULES.md.template` — Tier 1's "independent review" is
  now precisely defined as a **fresh** review invocation (not the same
  continuous conversation that wrote the change confirming its own work)
  — this is the actual mechanism that closes anchoring bias, not a
  formality. Tier 2 now has the agent explicitly *recommend* a deeper/
  multi-agent review mode to the user rather than assume it can self-
  invoke one — real constraint checked (not assumed) on this kit's origin
  project: a cloud multi-agent review mode there is confirmed
  user-triggered and billed, an agent cannot launch it itself. Added a
  table naming exactly what "review by someone other than the author"
  provides and which parts a single fresh agent pass can and can't reach,
  so the policy doesn't oversell or undersell AI review.
- `templates/PULL_REQUEST_TEMPLATE.md.template` — tier checklist wording
  updated to match.

### Why
User feedback on the 1.0.x version's Tier 2 language ("missing until a
second person joins") pointed out that many real teams already have every
developer working with their own AI agent — so treating "solo project" as
an unconditional excuse for weaker review undersells what's actually
achievable today. Asked directly to engineer the single-agent setup to
reach the same quality bar wherever genuinely possible, and be honest
about where it structurally can't.

## [1.0.1] — 2026-09-14

### Fixed
- `SETUP-GUIDE.md` — clarified that `${{ github.workflow }}` /
  `${{ github.ref }}` in `tests-python.yml.template` (real GitHub Actions
  expression syntax, note the `$` prefix) are NOT `{{PLACEHOLDER}}`
  markers to fill in, despite looking similar to a blind `{{` search.
  Found by re-reviewing the kit immediately after the 1.0.0 release, before
  anyone had actually hit it — the kind of thing worth catching on a
  second look rather than waiting for a real user to trip on it.

## [1.0.0] — 2026-09-14

Initial extraction. Everything below was built, used for real, and
verified on a live data-ingestion project before
being generalized into this standalone kit — not written speculatively.

### Added
- `templates/.gitignore.template` — secrets + generated-data exclusion
  pattern, verified with `git check-ignore -v` before first use, not just
  assumed correct.
- `templates/AGENT_RULES.md.template` — binding rules for any agent (human
  or AI): git-operation limits, secrets/data handling, code-quality/honesty
  requirements, scope discipline, attribution, and a 3-tier review-rigor
  policy (Tier 0 docs-only / Tier 1 real code needs independent review /
  Tier 2 load-bearing changes need explicit human sign-off and may sit
  unresolved rather than merge on a deadline).
- `templates/PULL_REQUEST_TEMPLATE.md.template` — makes the review-tier
  policy visible per-PR via a checklist, not just a paragraph in a rules
  doc nobody re-reads.
- `templates/CODEOWNERS.template` — human-in-the-loop backstop for any
  agent-opened PR.
- `templates/workflows/tests-python.yml.template` — path-scoped,
  concurrency-guarded CI workflow; explicitly documents whether it's
  GitHub-enforced (plan-dependent) rather than implying protection that
  might not exist.
- `LESSONS-LEARNED.md` — real, dated findings: the private-repo
  branch-protection paid-plan limit (confirmed via both the classic and
  rulesets APIs returning the same 403), the Windows PATH/stale-terminal
  issue after installing a new CLI tool, the branch-vs-folder separation
  principle, and the "verify it's real, don't trust configuration" habit
  applied to CI and gitignore both.
- `SETUP-GUIDE.md` — step-by-step application of this kit to a new project.
- `README.md` — what this is and why.

### Notes for future maintainers
- This kit is meant to grow from real use, not from anticipating needs in
  the abstract. Before adding something new, ask: did this come from an
  actual situation on an actual project, or is it a guess at what might be
  useful? Prefer the former; if it's the latter, say so in the entry.
- Placeholders (`{{LIKE_THIS}}`) are deliberate — resist the urge to make
  them "smarter" defaults that quietly do the wrong thing on a project
  they weren't written for.
