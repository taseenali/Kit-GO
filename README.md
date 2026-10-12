# Kit-GO — the AI Agent Governance Kit

> **Kit-GO is open source (Apache-2.0).** This is the latest working version, usable as it is; updates are published here as new releases. Issues and ideas are welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md). To report a security concern, see [SECURITY.md](./SECURITY.md). Release authenticity: [PROVENANCE.md](./PROVENANCE.md).
>
> **Heads-up: Kit-GO works best with Claude.** It was built and tested with Claude Code (auto-loaded `CLAUDE.md`, the Kit-GO slash commands, subagents and git worktrees for speed mode). The rules are plain files and git/GitHub mechanisms, so other agents can follow them, but nothing here has been tested outside Claude Code. [REFERENCE-SETUP.md](./REFERENCE-SETUP.md) says exactly what that means, what you need, and how the maintainer uses the Kit on a real project.

A portable, drop-in set of files and practices for starting **any** new
project — especially one where AI agents will do real, ongoing work in the
codebase alongside (or instead of) a human developer — with the same
version-control hygiene, review discipline, and written behavioral bounds
that this kit's own first real-world use proved out.

This is not theory. Every file here, every rule, and every entry in
[LESSONS-LEARNED.md](./LESSONS-LEARNED.md) was extracted from a real
project after actually setting it up, hitting real
constraints, and fixing them for real — not written speculatively. Where a
constraint turned out to be platform-specific (a paid-plan limit, a
Windows PATH quirk), that's recorded as a real thing to check, not silently
assumed away.

## Why this exists

Handing a codebase to an AI agent — one session, many sessions,
eventually multiple agents or people — without written rules is how you
get a force-push to `main`, a committed secret, or a "fixed" bug that
regresses six weeks later because nothing forced a test to exist for it.
The pattern here isn't about distrust of any particular agent; it's the
same reason a human team writes down its own conventions instead of
re-deriving them from scratch on every PR.

## What's in here

| File | Purpose |
|---|---|
| [SETUP-GUIDE.md](./SETUP-GUIDE.md) | Step-by-step: apply this kit to a brand-new project, today — plus real, distinct guidance for a dozen other adoption shapes (an ongoing project, a collaborator joining, a kit upgrade, multi-repo, team growth, a non-GitHub host, and more) |
| [LESSONS-LEARNED.md](./LESSONS-LEARNED.md) | Real, hard-won findings worth knowing *before* you set anything up — not generic advice |
| [CASE-STUDY-FOR-BEGINNERS.md](./CASE-STUDY-FOR-BEGINNERS.md) | A plain-English companion for a non-technical reader — what this kit's rules actually look like in motion, told through real events from the project this kit was extracted from |
| [CHANGELOG.md](./CHANGELOG.md) | Every version of this kit, what changed and why — this kit is itself maintained, not a one-time snapshot |
| `templates/.gitignore.template` | Secrets, generated/data directories, language/OS cruft — generalized, with placeholders to fill in |
| `templates/.gitattributes.template` | Pins `.githooks/**` to LF so the pre-push hook can't silently fail to execute on a CRLF-corrupted checkout |
| `templates/PASS-0-ENVIRONMENT-DISCOVERY.md.template` | **Run this first.** A real discovery pass — stack, VCS host/plan, repo count, team shape, deployment status — so the rest of this kit gets adapted to *your* project's real answers instead of silently inheriting the reference project's (Python, GitHub free-tier, solo owner, single repo) |
| `templates/STAGE-0-RESEARCH-ENRICHMENT.md.template` | A one-time gate before any Phase 1 code on a new product/direction — product, scope, architecture, UI/UX vision (elicited from the human, not assumed), legal (informational, never blocking), data/security |
| `templates/AGENT_RULES.md.template` | The core of this kit — binding behavioral rules for any agent (human or AI) working in the repo, including a 3-tier review-rigor policy and the Stage 0 gate pointer |
| `templates/OPEN-RESEARCH-QUEUE.md.template` | A live registry for open research questions, checked at the start of any bigger pass so a stalled thread is never permanently "exhausted" |
| `templates/MODEL-UTILIZATION-PLAYBOOK.md.template` | A project-wide framework for which AI model handles which task — tied to the same review-rigor tiers, with an explicit "never hardcode a model name" principle and an absolute floor on which models may ever verify a finding or make a judgment call |
| `templates/PULL_REQUEST_TEMPLATE.md.template` | PR template with a "change tier" field that makes the review policy visible per-PR, not just written down and ignored |
| `templates/CODEOWNERS.template` | Human-in-the-loop backstop — every PR needs a real owner's review |
| `templates/pre-push-hook.template` + `templates/OVERRIDE-LOG.md.template` | Mechanical, git-native enforcement of "no direct push to main" that doesn't depend on an agent remembering a written rule — with an auditable, typed-reason override for genuine exceptions |
| `templates/pre-commit-hook.template` | Optional commit-time companion to pre-push — refuses a `git commit` while `main`/`master` is checked out, so an absent-minded commit right after `git checkout main && git pull` never lands in the first place. Same honest limits as pre-push, plus `git merge`/`cherry-pick`/`rebase` don't fire it, so it supplements pre-push rather than replacing it |
| `templates/setup-hooks.sh.template` | One command that wires the pre-push hook into a fresh clone (`core.hooksPath`, executable bit) and verifies it actually rejects a synthetic push-to-main event — meant to be triggered by whatever command a new collaborator already runs to start working (an npm `prepare` script, `make setup`, etc.), so hook-wiring is never a separate step someone has to remember from a doc |
| `templates/verify-setup.sh.template` | The read-only companion to `setup-hooks.sh` — checks whether the hook (and any project-specific tooling you add to its own extension point) is actually working right now, without ever wiring or fixing anything itself. Kept deliberately separate: a "verify" step that quietly repairs what it's checking can never detect real drift |
| `templates/CLAUDE.md.template` | Makes an AI agent actually find `AGENT_RULES.md` without being told to — Claude Code (and other tools converging on the same convention) auto-load `CLAUDE.md`/`AGENTS.md` at session start; this kit's whole approach depends on that file actually getting read |
| `templates/COLLABORATOR-LOG.md.template` | Per-person (not shared) dated work log — one file per collaborator avoids the merge conflicts a single shared log causes under concurrent work, and gives a signed, personal account of what was done and why beyond what a PR description captures |
| `templates/workflows/collaborator-log-reminder.yml.template` | Informational-only reminder (never blocks merge) if a PR doesn't touch its author's own collaborator log — checks real file presence in the diff, not prose or identity, so it works the same on any repo size or GitHub plan |
| `LICENSE`, `NOTICE`, `PROVENANCE.md` | The Kit's terms (Apache License 2.0), the attribution Apache-2.0 requires redistributors to keep, and a plain list of every identifying mark the Kit contains (all visible; no hidden identifiers or telemetry; the only network call is an optional, not-wired-by-default workflow). Adopters copy them to `docs/KIT-LICENSE`, `docs/KIT-NOTICE`, `docs/KIT-PROVENANCE.md` |
| [CONTRIBUTING.md](./CONTRIBUTING.md) + [SECURITY.md](./SECURITY.md) | How to contribute (issues, small pull requests, DCO sign-off) and how to report a security concern privately |
| [REFERENCE-SETUP.md](./REFERENCE-SETUP.md) | Short and exact: why Kit-GO works best with Claude, what you need to start, and how the maintainer actually uses the Kit on one real project (the loop, the numbers with their limits, what went wrong) |
| `templates/SPEED-MODE.md.template` + `templates/AGENT-LEDGER.md.template` + `templates/SPEED-MODE-METRICS.md.template` | **Optional speed mode:** run parallel AI-agent work fast without lowering review rigor. Guardrails that are never lowered, path-based risk classes, plan-before-parallel lanes, save-as-you-go resumability, a ledger and honest metrics with pre-registered revert conditions |
| `release/make-manifest.sh` + `release/verify-release.sh` | Maintainer and verifier tools for signed releases: build the manifest, and verify a tag plus manifest against the published key (see PROVENANCE.md) |
| `templates/KIT-GO.md.template` + `templates/kit-go.sh.template` + `templates/commands/kit-go*.md.template` | **Kit-GO**: the kit as something you run, not just copy. The bare command `Kit-GO` re-anchors an agent on the project's rules and checks repo health (read-only, safe any time); `Kit-GO help`, `guide`, `guide me`, `log`, `sync` cover the rest. A playbook (single source of truth), a testable read-only script, and thin Claude Code slash-command wrappers; verified by `tests/kit-go/run.sh` |
| `templates/KIT-ISSUES-LOG.md.template` | Shared (not per-person) log for real bugs/friction found in this kit itself while working on a downstream project — supports the "record it, don't fix it in passing" rule in `AGENT_RULES.md`, so fixing this kit stays a deliberate, separate unit of work |
| `templates/workflows/kit-issues-notify.yml.template` | Optional, not wired by default — a cross-repo notification (a link only, never the entry's own text) to this kit's maintainer when a downstream project's `KIT-ISSUES-LOG.md` changes. Requires a real, scoped Personal Access Token as a deliberate setup step; the assumed default without it is sharing the log manually |
| `templates/workflows/tests-python.yml.template` | A GitHub Actions CI template (Python/pytest) — the pattern generalizes to other stacks, notes included |
| `templates/workflows/governance-gate.yml.template` | The server-side backstop for what the pre-push hook structurally can't stop (`--no-verify`, a disabled hook, a change made on the platform's web UI) — detects a `main` commit with no associated PR and fails loudly |

## The core idea, in one paragraph

Separate concerns by **folder, not branch** (a branch is for work that
merges back; permanently splitting docs from the code they describe
breaks reviewing them together). Make `main` as protected as your GitHub
plan actually allows, and if it doesn't allow real enforcement, say so
explicitly in writing rather than implying protection that isn't there.
Scale review rigor to what's actually at stake — a typo fix and a schema
migration are not the same risk, and pretending otherwise either slows
down harmless changes or rubber-stamps dangerous ones. Verify things are
real, not just configured — every claim in this kit ("CI runs," "the
gitignore works") was checked with an actual command, not assumed.

## Using this kit

See [SETUP-GUIDE.md](./SETUP-GUIDE.md) — its own step 1 has the real,
current file-by-file copy list (destinations vary: `.github/`,
`.githooks/`, `scripts/`, and the project root all get real files, not
everything goes to one folder). Short version: copy the templates,
dropping the `.template` suffix, fill in the placeholders, commit, and
read `LESSONS-LEARNED.md` before you push anything.

## Keeping this kit current

This kit is meant to keep improving as real projects using it turn up new,
real findings — not to be written once and left static. See
[CHANGELOG.md](./CHANGELOG.md) for how updates are recorded (Keep a
Changelog format, semantic versioning) and add an entry there, with a real
reason, whenever something genuinely reusable gets learned or built
elsewhere and belongs here too.

**A downstream project finding a bug in this kit doesn't mean an
immediate PR against this repo, though.** `templates/KIT-ISSUES-LOG.md.template`
and `AGENT_RULES.md.template`'s "Finding a bug in the governance kit
itself" section set up the actual, current process: record it on the
downstream project's own copy of that log, and let fixing this repo be
its own separate, deliberate unit of work — done here, by the maintainer,
on a real cadence — rather than something that happens as an incidental
side effect of whatever unrelated task turned the bug up.

## How changes to this kit's own repo get merged

This repo prescribes a 3-tier review policy to every project that adopts
it, but has never held itself to any tier of it as a standing
requirement — a real fresh + adversarial pass has happened here before,
more than once (see `CHANGELOG.md`'s v1.14.0, v1.18.0, and v1.20.0
entries), but only when someone happened to ask for it that time, not
because anything made it the default. The three merges immediately
before this one (#13/#14/#15, PR numbers in the original private repository) got single-agent self-review only, and
nothing would have caught that drift, because there was no standing rule
to have lapsed from. That gap is closed as of 2026-09-23. From here on,
a change to this repo requires both of the
following, every time, with no exception for a change that looks small,
obviously correct, or docs-only:

- **A fresh + adversarial review pass** — this repo's own standing
  choice of `AGENT_RULES.md.template`'s "Local multi-pass review"
  mechanism, which that section itself describes as the *fallback* for a
  downstream Tier 2 change when a deeper/multi-agent review service is
  genuinely unavailable, not the primary, required-by-default mechanism
  Tier 2 actually calls for. This repo adopts the fallback as its own
  everyday standard rather than the stronger default, a deliberate,
  named substitution, not an unstated one: the pass that authored the
  change, plus a second pass on a genuinely different model (not the
  same model re-reading its own work) actively trying to find
  contradictions, incorrect claims, broken cross-references, or
  something that looks like enforcement but isn't — not just checking
  the diff reads cleanly.
- **The maintainer's own explicit, in-the-moment sign-off before
  merge, and a human runs the merge itself.** An agent never executes
  the merge here — by any mechanism (`gh pr merge`, auto-merge, a direct
  API call, a browser tool, delegating to another tool or subagent, or
  landing the change on `main` some other way) — regardless of how clean
  the review passes came back, and **even if told "merge it" or "go
  ahead."** Informal sign-off language approves the *decision*; it does
  not authorize the *agent* to carry it out. The agent's last action on
  a change here is a risk summary and the ready-to-run command (pinned to
  the reviewed commit: `gh pr merge <number> --match-head-commit <sha>`); the
  human runs it, and the agent pushes nothing to the branch after
  sign-off — any new commit, including a branch update or rebase, voids it. (This exact phrase — "an agent does not self-merge" —
  was previously ambiguous between those two readings and caused the
  same real incident independently on two downstream projects, and a third
  time on this repo's own PR that first introduced this rule.) This can't be a real GitHub
  branch-protection setting: a solo admin can always bypass a required-review
  setting, and can't approve their own PR through the normal review mechanism
  anyway — so *required-review* enforcement specifically has no mechanical
  version here in principle. (Separately, on a free-tier *private* repo branch
  protection isn't available at all — confirmed directly in this kit's original
  private repository: `branches/main/protection` and `/rulesets` both returned
  403.) This is agent discipline, stated plainly as such, not a platform
  guarantee.

**Said plainly, not smoothed over: this repo dogfoods almost none of its
own templates today.** There's no `.github/CODEOWNERS`, no
`.github/PULL_REQUEST_TEMPLATE.md`, and no CI workflow here at all — the
one exception is `.githooks/pre-push`, a real, currently-correct copy of
`templates/pre-push-hook.template` (previously an out-of-sync copy,
missing a comment the template had gained since — fixed as part of this
same review). But having the file present isn't the same as it doing
anything: `core.hooksPath` isn't set in a fresh clone of this repo, so
the hook isn't actually wired, and this repo's own pushes aren't
mechanically protected by it. The sign-off and review requirements above
are the first piece of this repo holding itself to anything it
prescribes to others; wiring the hook for real and adding the other
templates is separate, not-yet-done work, not something this section
should be read as already covering.

## License

The AI Agent Governance Kit is released under the Apache License 2.0. See
[LICENSE](./LICENSE) and [NOTICE](./NOTICE). Copyright 2026 Taseen Ali Mansoor (taseenali).

Copying the Kit's templates into your project does not relicense your own
code. Only the Kit-derived files carry the Kit's terms.

**Credits.** Created and maintained by Taseen Ali Mansoor (taseenali). Portions were
written with the assistance of AI (Claude, by Anthropic), under the
maintainer's direction and review; the commit history marks AI-assisted
commits with a `Co-Authored-By` trailer.

## Using the Kit? Show it

If the Kit or Kit-GO helps your project, add one line to your README. It tells
contributors and agents where your rules come from, and it helps other teams
find the Kit:

```markdown
Governance by the AI Agent Governance Kit (Kit-GO), by Taseen Ali Mansoor (taseenali).
```

This is a request, not a license condition.

## Official releases and verification

The first release signed in this repository is v2.10.0 (v2.9.0 was signed only in
the original private repository and does not apply here); v2.8.0 and earlier are
unsigned. Official
releases are signed git tags plus a signed release manifest. Signing-key
fingerprint (SSH Ed25519):

    SHA256:Gv9QQaf5A4eph4GS3r8xgiyLCoy4lsHRJdAnIvv7FBE

It is also listed on the maintainer's GitHub signing-key page; check that both
match. [PROVENANCE.md](./PROVENANCE.md) has the exact verification steps, and
[CHANGELOG.md](./CHANGELOG.md) is the record of changes.
PROVENANCE.md also lists every identifying mark the Kit contains (all
visible; there are no hidden identifiers or telemetry, and the only network
call anywhere is an optional workflow that is not wired by default).

"AI Agent Governance Kit" and "Kit-GO" are names of this project by
Taseen Ali Mansoor (taseenali). A fork or modified copy is welcome under the license but should not
present itself as the official Kit. The license grants no rights in the
names (Apache-2.0, section 6); see NOTICE.
