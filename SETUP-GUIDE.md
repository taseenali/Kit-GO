# Setup Guide

Apply this kit to a new (or existing) project. ~15 minutes for the local
part; a few extra minutes for the GitHub-side settings, which need a human
with repo admin access.

## 0. Before you start — run a real Environment Discovery pass

**Copy `templates/PASS-0-ENVIRONMENT-DISCOVERY.md.template` into your
project and fill it in for real, before copying anything else.** Every
other step in this guide, and most of the templates themselves, were
originally written against one specific project's real answers
(Python/pytest, private GitHub repo on the free plan, solo owner + AI
agent, single repo). Following the rest of this guide on a project with
different answers — a different language/test stack, a different VCS
host or plan tier, more than one repository, or more than one person
committing — will silently carry those original assumptions into a
project they don't fit. This has real consequences, not just cosmetic
ones: e.g. skipping the "is this actually a multi-repo product"
question is exactly what let a real governance gap happen in the
project this kit is drawn from — a rules file that only ever got copied
into one of two repos, invisible to any session rooted in the other
one, until a real incident (see `LESSONS-LEARNED.md`, "Multi-repo /
multi-codebase products") forced the second repo to be set up properly,
after the fact instead of from the start.

Also read [LESSONS-LEARNED.md](./LESSONS-LEARNED.md) in full at least
once — the branch-protection paid-plan limit specifically (Pass 0's §2
covers deciding this for your own project), but the rest of the file is
real, hard-won findings worth having in mind before, not after, setup.

## 1. Copy the templates in

**The list below is the reference project's own answer to Pass 0, not
a universal prescription.** Use Pass 0's own "Output of this pass"
section to decide your real list — which files, adapted how, copied
into how many repos — before treating the list below as anything more
than an example of the shape.

From this kit's root, into your project's root:

```
templates/.gitignore.template              -> .gitignore
templates/.gitattributes.template          -> .gitattributes
templates/AGENT_RULES.md.template           -> .github/AGENT_RULES.md
templates/PULL_REQUEST_TEMPLATE.md.template -> .github/PULL_REQUEST_TEMPLATE.md
templates/CODEOWNERS.template               -> .github/CODEOWNERS
templates/workflows/tests-python.yml.template -> .github/workflows/tests.yml
templates/workflows/governance-gate.yml.template -> .github/workflows/governance-gate.yml
templates/pre-push-hook.template            -> .githooks/pre-push
templates/pre-commit-hook.template          -> .githooks/pre-commit   (optional: same protection one step earlier, at commit time)
templates/OVERRIDE-LOG.md.template          -> .githooks/OVERRIDE-LOG.md
templates/setup-hooks.sh.template           -> scripts/setup-hooks.sh
templates/verify-setup.sh.template          -> scripts/verify-setup.sh
templates/CLAUDE.md.template                -> CLAUDE.md (and/or AGENTS.md)
templates/workflows/collaborator-log-reminder.yml.template -> .github/workflows/collaborator-log-reminder.yml
templates/KIT-ISSUES-LOG.md.template        -> docs/KIT-ISSUES-LOG.md
templates/KIT-GO.md.template                -> docs/KIT-GO.md   (the Kit-GO command playbook; no placeholders, copy verbatim)
templates/kit-go.sh.template                -> scripts/kit-go.sh
templates/commands/kit-go*.md.template      -> .claude/commands/kit-go*.md   (one file per command -- `kit-go-intake` has no wrapper at all: it is maintainer-only, a typed phrase in the Kit's own repo; drop `.template`; Claude Code slash commands -- other agents use the typed phrases in the playbook)
templates/SPEED-MODE.md.template            -> docs/SPEED-MODE.md   (OPTIONAL: parallel-agent playbook; see "Adding speed mode (optional)" below)
templates/AGENT-LEDGER.md.template          -> docs/AGENT-LEDGER.md   (OPTIONAL: only with speed mode; roster and resume recipes, never credentials)
templates/SPEED-MODE-METRICS.md.template    -> docs/SPEED-MODE-METRICS.md   (OPTIONAL: only with speed mode; per-PR record and revert conditions)
KIT-VERSION (this kit's root)               -> docs/KIT-VERSION   (a one-line copy; update it whenever you sync -- it's how Kit-GO knows which version you adopted)
LICENSE (this kit's root)                   -> docs/KIT-LICENSE   (the Kit's terms, Apache-2.0; keep it with the Kit-derived files)
NOTICE (this kit's root)                    -> docs/KIT-NOTICE    (the attribution Apache-2.0 requires redistributors to keep)
PROVENANCE.md (this kit's root)             -> docs/KIT-PROVENANCE.md   (what identifies an official release, and every mark the Kit contains)
```

**Kit-GO** (the playbook, script, and slash commands above) makes the kit
something you can *run* any time: typing `Kit-GO` re-anchors the agent on
the rules and checks the repo's health without changing anything, and
`Kit-GO help` lists the rest. Copy the four Kit-GO items together, not one
at a time -- the playbook is the source of truth, the script is what makes
its checks real, and the slash commands are thin wrappers that stop if the
playbook is missing. After copying, run `sh scripts/kit-go.sh status` once
yourself to see it work. **Add `docs/KIT-GO.md`, `scripts/kit-go.sh` and
`.claude/**` to this project's Tier 2 list** (`AGENT_RULES.md`'s own list
already names them for projects that install Kit-GO): the slash commands
pre-approve running the script, so an edit to any of these must not be
self-merge-able as a "wording tweak".

**License, in short.** The Kit is released under the Apache License 2.0
(`LICENSE`), copyright Taseen Ali Mansoor (taseenali), with a `NOTICE` that asks you to
keep a short credit line. Copying the Kit's templates into your project
does not relicense your own code; only the Kit-derived files carry the Kit's
terms. Using the Kit inside your own project needs no extra notice. **If you
redistribute modified Kit files** (publish a fork, ship them to someone),
Apache-2.0 section 4(b) requires a prominent notice that you changed them; a
one-line header such as "Modified from the AI Agent Governance Kit" is
enough, and a filled-in template counts as modified. Keep `docs/KIT-LICENSE`
and `docs/KIT-NOTICE` with the Kit-derived files. **Optional** -- if the Kit helps your project, you can add this
to your README (it is not shipped inside any template, so nothing appears
in your repo unless you put it there):

```markdown
## Governance

Governance by the AI Agent Governance Kit (Kit-GO), by Taseen Ali Mansoor (taseenali).
Rules: .github/AGENT_RULES.md. Run `sh scripts/kit-go.sh help` for the Kit-GO commands.
```

The Kit contains no hidden identifiers; `PROVENANCE.md` lists every mark.
Until you sync to 2.8.0, `kit-go drift` shows `scripts/kit-go.sh` (the new
`help` footer) and `docs/KIT-GO.md` (one added sentence) as `DIFFERS`. That is
accurate and expected; after the sync they read `SAME`.

`templates/COLLABORATOR-LOG.md.template` is **not** in the list above —
it's not a one-time repo file, it's a per-person template each real
collaborator instantiates for themselves. See "A collaborator joining a
project that already has this kit installed," below, for when and how.

(Drop `.template` from every filename. If your project isn't Python, adapt
`tests.yml` to your stack's install+test commands — the structure
[unfiltered triggers (see the comment in the file for why), concurrency group, no-secrets-required test suite] is the
reusable part, not the specific `pip install` line.)

**After copying `pre-push-hook.template`, two things it doesn't do for
you:** `chmod +x .githooks/pre-push`, and `git config core.hooksPath
.githooks` in every clone that should enforce it — hook wiring is a
per-clone git config setting, not something committing the file alone
turns on. **`scripts/setup-hooks.sh` (from `templates/setup-hooks.sh.template`)
does both of these for you, in one command** — run it once yourself
after this copy step, and wire it into whatever command a *future*
collaborator already runs to start working on this project (an npm
`prepare` script, a `make setup` target, a packaging post-install hook —
see the template's own header for concrete per-stack patterns) so a
fresh clone gets the hook wired as a side effect of their normal
onboarding, not a separate step they have to remember from a doc. If
your project spans more than one repository, copy the hook **and** this
script into **each** repo independently rather than relying on one
repo's copy to protect the others — see `LESSONS-LEARNED.md`'s
"Multi-repo / multi-codebase products" section for why a rule (or a
hook) living in only one repo doesn't reach a session rooted in a
sibling repo.

**`templates/pre-commit-hook.template` (optional) catches the same mistake at commit time.** pre-push only fires when you push, so a correct `git checkout main && git pull` followed by an unrelated `git commit` lands a real commit on local `main` that you then have to branch-and-reset out of; this hook rejects that commit outright instead. Same honest limits as pre-push (skippable via `--no-verify`, dark in an unwired clone) plus one of its own: `git merge`/`cherry-pick`/`rebase` don't fire `pre-commit` at all, so it supplements pre-push, never replaces it. Copy it to `.githooks/pre-commit`; `setup-hooks.sh` makes it executable if present, but you must confirm it once by hand, after the repo has at least one commit (an unborn branch is deliberately allowed): `git commit --allow-empty -m test` on `main` should print `pre-commit REJECTED`; if it doesn't, undo with `git reset --soft HEAD~1` and check the wiring.

**`scripts/verify-setup.sh` (from `templates/verify-setup.sh.template`)
is a different thing from `setup-hooks.sh`, deliberately kept
separate** — it only ever reads state, never wires or fixes anything.
Wire it to run *after* `setup-hooks.sh` in the same install step (e.g.
`"prepare": "sh scripts/setup-hooks.sh && sh scripts/verify-setup.sh"`)
so the fuller picture — this kit's own hook plus whatever else you add
to the template's "project-specific checks" section — surfaces
automatically on every fresh install, without needing an agent to
remember to run it. A "verify" step that quietly repairs what it's
checking can never detect real drift; keep the mutating and read-only
scripts separate, always.

**`CLAUDE.md` (from `templates/CLAUDE.md.template`) is what makes an
AI agent actually find `AGENT_RULES.md` without being told to look for
it** — Claude Code (and several other tools) auto-load this filename
(or `AGENTS.md`) at session start. Fill in the placeholders and commit
it at the project root.

**`.github/workflows/collaborator-log-reminder.yml` (from
`templates/workflows/collaborator-log-reminder.yml.template`) is
informational only, like `governance-gate.yml`'s own honest limits on a
repo without branch protection** — it posts a warning annotation if a
PR doesn't touch its author's own `docs/collaborators/<username>.md`,
and never blocks a merge. It checks real file presence in the diff, not
prose or identity, so it works the same regardless of your GitHub
plan or team size.

**`docs/KIT-ISSUES-LOG.md` (from `templates/KIT-ISSUES-LOG.md.template`)
is where a real bug or gap found in this kit itself gets recorded while
working on your actual project, instead of turning into an immediate PR
against the kit's own repository** — see `AGENT_RULES.md`'s "Finding a
bug in the governance kit itself" section for the full rule this file
supports, and this template's own header for what "reaching the kit's
maintainer" actually requires (a manual share by default; an optional,
separately-set-up automation in `templates/workflows/kit-issues-notify.yml.template`
if you want it). Unlike the per-person collaborator logs, this is one
shared file — real kit bugs are rare enough on most projects that
concurrent-edit conflicts aren't a real concern the way daily work logs
are.

## 2. Fill in the placeholders

Every template file uses bare `{{ALL_CAPS_PLACEHOLDER}}` markers (no `$`
prefix) — search for `{{` across the copied files and fill each one in.
**Two exceptions:**
- `tests.yml`, once copied, contains real GitHub Actions expression
  syntax (`${{ github.workflow }}`, `${{ github.ref }}` in the
  `concurrency` block) — those have a `$` before the braces and are NOT
  placeholders; leave them exactly as they are.
- `docs/KIT-ISSUES-LOG.md`'s own "Entry format" block (below its one
  real one-time placeholder, `{{PROJECT_NAME}}`) contains several more
  `{{...}}` markers that are filled in fresh each time a new entry gets
  added, not once at setup — see that file's own note at the same spot,
  and don't fill those in now.

- `{{OWNER_GITHUB_HANDLE}}` — in `CODEOWNERS` and cross-referenced in
  `AGENT_RULES.md`
- `{{PROJECT_NAME}}` — in `AGENT_RULES.md`, `CLAUDE.md`, and
  `docs/KIT-ISSUES-LOG.md` (if copied — see step 1)
- `{{DATA_DIR}}` — the path(s) that hold generated/scraped/large data that
  must never be committed (only fill this in if it applies — not every
  project has one)
- `{{SECRETS_PATH}}` — in `.gitignore`: a commented-out example line for
  a nested `.env` (e.g. inside an `app/` subdirectory) that the bare
  `.env` pattern above it doesn't automatically cover in every git
  version/config. Uncomment and fill in if this project actually has
  secrets nested below the repo root; leave it commented out otherwise
- `{{LOAD_BEARING_LOGIC_DESCRIPTION}}` — in `AGENT_RULES.md`'s Tier 2
  section: name the specific piece(s) of your codebase where a subtle bug
  is expensive (a pricing engine, an auth check, a data-correction rule —
  whatever it is for this project). Leave it generic only if nothing like
  that exists yet.
- `{{ATTRIBUTION_LINE}}` — the commit/PR trailer convention for whichever
  AI system is doing the committing (e.g. `Co-Authored-By: <model> <email>`)
- `{{PROJECT_SPECIFIC_CONTEXT}}` — in `CLAUDE.md`: replace the whole
  placeholder line and its explanatory comment with this project's own
  real context (not left in as filler — a placeholder committed
  verbatim reads as real, empty guidance to a future agent, not as an
  obviously-unfinished section)
- `{{ANSWER_ARCHIVE_LOCATION}}` — in `AGENT_RULES.md`'s Definition of
  Done: name where a substantive user question/decision actually gets
  archived on this project, if it does at all (leave the item generic,
  not deleted, if this project has no such archive yet)
- `{{CODE_DIR}}`, `{{PYTHON_VERSION}}` — in `tests.yml` (from
  `templates/workflows/tests-python.yml.template`): the real path to
  your source tree and the Python version your project targets. Fill
  these in before this file is ever committed or pushed — left as bare
  `{{...}}` markers, `{{CODE_DIR}}` in particular breaks this file as
  YAML (it parses as an invalid flow-mapping key), not just as an
  unfilled placeholder

## 3. Add the cross-reference

In your project's own root `README.md` or `AGENTS.md` (or create one), add
near the top:

```markdown
**Before touching git in this repo, read [.github/AGENT_RULES.md](./.github/AGENT_RULES.md).**
```

This is the single highest-value line in the whole setup — it's what makes
a new agent actually find the rules instead of improvising.

## 4. Run Stage 0 before any Phase 1 code exists

Copy `templates/STAGE-0-RESEARCH-ENRICHMENT.md.template` to
`STAGE-0-RESEARCH-ENRICHMENT.md` at the project root and work through it —
product, scope, architecture, developer UX, legal (informational only,
never blocking), UI/UX vision (ask the human directly, don't assume), and
data/security. This applies to a genuinely new project or product
direction, not routine feature work. Two things not to get wrong:

- Legal findings get recorded honestly but never block the sign-off or
  Phase 1 code — only the live execution of a specifically gated action
  waits on a real answer.
- A missing external account/endpoint (payment processor, messaging API,
  whatever this project needs) never blocks the sign-off either — build
  against a pluggable interface, connect the real thing later.

Get the human's explicit, recorded sign-off before writing Phase 1 code —
silence isn't sign-off. Commit the completed file; it's the historical
record — see below for what happens after it's signed off, not while
you're still filling it out.

## 5. Set up the Open Research Queue

Copy `templates/OPEN-RESEARCH-QUEUE.md.template` to
`docs/OPEN-RESEARCH-QUEUE.md` (or your project's equivalent docs root).
Check it at the start of any pass sized beyond a small fix — a stalled
research thread gets a fresh attempt with a new angle, never written off
as permanently "exhausted." Empty is fine to start; the habit of checking
it is the actual point, not having content in it on day one.

## 6. Set up the Model Utilization Playbook

Copy `templates/MODEL-UTILIZATION-PLAYBOOK.md.template` to
`docs/MODEL-UTILIZATION-PLAYBOOK.md` and fill in `{{DEFAULT_MODEL}}`,
`{{DEEP_REVIEW_MODEL}}`, `{{FAST_CHEAP_MODEL}}` for whatever models are
actually available in this environment. Leave the "Confirmed how" column
honest — most rows will say "not yet used on a real task" until they
are; don't invent a result to fill the cell. This is what
`AGENT_RULES.md`'s "Local multi-pass review" section (the ultra/deeper-
review fallback) points to for the general framework it's one instance
of.

## 7. Initialize and push

```bash
git init
git branch -M main
# Verify the gitignore actually works before trusting it:
git add -A -n   # dry run -- check nothing under {{DATA_DIR}} or *.env appears
git check-ignore -v <a real secret/data path>   # confirm explicitly
git add -A
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```

This first push goes straight to `main` unprotected — that's expected and
fine, there's no prior commit to compare a PR against yet. Everything after
this point goes through a branch + PR.

## 8. GitHub-side settings (needs a human, repo admin)

- Set repo visibility (private/public) — matches the decision from step 0.
- If on a plan that supports it: turn on branch protection on `main`
  (require PR, require the CI check, require ≥1 approval, block
  force-push/deletion). If not: this is the moment to make peace with
  relying on `AGENT_RULES.md` as written policy, and flag it explicitly
  wherever else claims "main is protected."
- Confirm `gh auth status` if using the `gh` CLI for any of the above —
  auth is tied to a real human GitHub account and can't be completed by an
  agent on someone else's behalf.

## 9. Verify it's real, not just configured

Don't trust the setup until you've seen it work:

1. Make one small, genuinely real change (any path triggers
   `tests.yml`; not a throwaway "test commit" — pick something worth fixing anyway).
2. Push it on a branch, open a real PR.
3. Confirm the Actions run actually triggers and passes
   (`gh run view --log`, look for real test output).
4. Merge it, confirm the branch gets cleaned up, confirm `main` is what you
   expect afterward.
5. **If you wired the `pre-push` hook**: run `scripts/setup-hooks.sh`
   (if you copied it in step 1) — it wires `core.hooksPath`, and its own
   last step feeds the hook a synthetic push-to-main event over stdin
   and confirms `pre-push REJECTED` comes back, all without a real push
   to anything. Prefer this over an actual `git push origin HEAD:main`
   test: that exact command is indistinguishable, to an AI coding
   agent's own safety tooling, from the real dangerous action the hook
   exists to prevent, and can get auto-blocked before it ever reaches
   the hook (a real thing that happened while building this kit,
   2026-09-22) — the synthetic-stdin approach verifies the same logic
   without touching the network at all. If you do run a real push
   anyway: on a scratch branch, `git push origin HEAD:main` should print
   `pre-push REJECTED`. Either way, a missing or unwired hook fails
   *silently* (the push just succeeds like normal) — `git config --get
   core.hooksPath` must print `.githooks` if something still seems off.
6. **If you added `governance-gate.yml`**: confirm it actually ran on
   the push from step 4 (`gh run list --workflow=governance-gate.yml`)
   and reported success for that PR-merge commit. Don't take its
   presence in the repo as proof it fires — same reasoning as step 5.
7. **Going forward, not just at initial setup**: `sh scripts/verify-setup.sh`
   (if you copied `templates/verify-setup.sh.template` in step 1) is the
   read-only, run-any-time version of step 5's check — safe to run
   whenever something feels off, since unlike `setup-hooks.sh` it never
   changes anything, it only reports. It's also where any project-specific
   tooling beyond this kit (a second policy/governance layer, a required
   API key, another language's dependency install) gets its own check
   added to the template's "project-specific checks" section — extend
   it there rather than inventing a separate, competing verification
   doc, so there's one real place that answers "is this project's whole
   setup actually working right now," not two that can drift apart.

If any of that doesn't work the way this guide implies it should, that's a
real finding — add it to your own project's docs, and consider whether it
belongs back in this kit's `LESSONS-LEARNED.md` too.

## 10. Going forward

Follow the review-tier policy in `AGENT_RULES.md` for every subsequent
change. Branch naming: `feat/…`, `fix/…`, `docs/…`, `chore/…` — short-lived,
deleted after merge.

## Beyond a brand-new project — other real setup scenarios

Steps 0–10 above are written for one shape: a genuinely new, empty
project. This kit gets adopted in other shapes too, each with real
differences worth naming explicitly rather than silently assuming the
greenfield steps apply unchanged.

### A collaborator joining a project that already has this kit installed

The steps above already produce this outcome as a side effect, but it's
worth naming as its own scenario since it's the most common one after
initial setup: clone the repo, run whatever your stack's normal install
step is (`npm install`, etc. — whatever step 1's `setup-hooks.sh`/
`verify-setup.sh` got wired into). That's it, if setup was done right —
no separate governance-specific onboarding step should be needed. If it
*is* needed (the project's install step doesn't auto-wire the hook),
that's worth fixing in the project's own setup rather than treated as a
one-off manual step every new collaborator has to be told about
separately.

**One real manual step, if this project uses per-person collaborator
logs:** copy `templates/COLLABORATOR-LOG.md.template` to
`docs/collaborators/<your-real-GitHub-username>.md`, fill in the
`{{GITHUB_USERNAME}}` placeholders, and add your first dated entry on
your first real PR. This is deliberately not automated the way hook-
wiring is — it needs your real username, which nothing can guess for
you — but `collaborator-log-reminder.yml` (if the project copied it)
will post a reminder on your first PR if you forget.

### Installing this kit on an ongoing/existing project

Real, load-bearing differences from the greenfield flow — skipping any
of these silently carries a greenfield assumption into a project it
doesn't fit:

- **Stage 0 does not re-run for the existing product.** Its own
  applicability rule already says so ("a brand-new project, or a
  genuinely new product/feature direction... not routine feature work on
  an already-cleared product") — an ongoing project's product, scope,
  and architecture are usually already settled. Pass 0 (environment
  discovery) still runs — its answers will genuinely differ from a
  fresh project's (real production status, real team size, real existing
  CI), and those real answers matter more here, not less.
- **Calibrate the Tier system to the project's real, current maturity —
  not the template's lenient solo-owner default.** `AGENT_RULES.md.template`'s
  Tier 1 self-merge authority and its "Maturity triggers" list are
  calibrated for a solo owner with nothing in production yet. An ongoing
  project has very likely already tripped several of those triggers
  (real deployment, real users, more than one contributor) — start the
  calibration where the project actually is, don't inherit the
  template's starting defaults and wait for a trigger that already fired
  before this kit existed.
- **Wiring the pre-push hook changes team behavior immediately, for
  everyone, the moment it's wired** — not just for whoever set it up. If
  direct pushes to the default branch are currently normal practice on
  the team, that's a real workflow change that needs a named
  communication step to existing collaborators, not a silent file drop
  that surprises someone mid-task.
- **Merge into existing `CODEOWNERS`/CI, never overwrite wholesale.** An
  ongoing project likely already has real owners and a real test
  workflow; treat this kit's templates as things to merge into what
  exists, the same care `SETUP-GUIDE.md` step 1 already asks for the
  reference project's own file list.

### Upgrading an already-adopted project to a newer version of this kit

This kit has real version history (see `CHANGELOG.md`) and no adopter
should have to redo setup from scratch to pick up a later release. Until
a more automated path exists, the honest current process:
1. Check `CHANGELOG.md` for every version between the adopter's current
   one (if it's not tracked anywhere, treat it as unknown and diff
   against the earliest entry) and the latest, reading each entry's real
   *why*, not just its *what*.
2. Two different cases, handled differently — don't apply one process to
   both: for each template the adopting project **already has a copy
   of** that changed upstream, diff the adopter's copy against the new
   template version (most drift will be the adopter's own
   project-specific fill-ins, which a raw file replace would destroy;
   merge deliberately, file by file). For a template that's **entirely
   new** in the target version (the adopting project has no existing
   copy at all — check `templates/` against what the project actually
   has, don't assume "changed" means "already exists"), there's nothing
   to diff against; copy it in fresh the same way step 1 does for a
   brand-new project.
3. Treat this as a real change to `AGENT_RULES.md`-adjacent files in the
   adopting project — it very likely triggers that project's own Tier 2
   rule (see the "No exception" clause), since it changes the rules
   documents themselves. Run it through that project's own review
   process, don't special-case a kit upgrade as exempt from the rules it's
   updating.

### A product that spans more than one repository

Install this kit's files independently, in full, in each repository — do
not designate one repo "primary" and the others "satellites" with a
lighter copy. `LESSONS-LEARNED.md`'s "Multi-repo / multi-codebase
products" section names the underlying reason: a polyrepo product is one
system, and an AI coding session's auto-loaded `CLAUDE.md`/`AGENTS.md`
is anchored to whichever repo it actually started in — it is not
re-scanned just because a session's work crosses into a different
repo mid-task. A thin governance copy in repo B, on the theory that
"the real rules live in repo A," is invisible to any session that starts
in B.

Two things genuinely need to be shared rather than independently
maintained per repo, and one thing genuinely should not be:
- **Shared, deliberately:** the Tier definitions and maturity-trigger
  calibration in `AGENT_RULES.md` should reflect the product's real,
  combined state (team size, production status), not each repo's
  individual history — a repo that's seen one commit this month is not
  "less mature" than its sibling if they ship together as one product.
  Keep the wording in sync by treating one repo's `AGENT_RULES.md` as the
  source and deliberately copying changes to the others (there is no
  automated sync mechanism for this yet — see the version-upgrade section
  above for the same limitation applied kit-wide).
- **Shared, deliberately:** a single `docs/collaborators/<username>.md`
  convention and Open Research Queue *concept*, even if each repo keeps
  its own physical files — a contributor's work log split arbitrarily
  by which repo happened to receive today's commits is less useful than
  one that reads as a coherent account of what they did.
- **Not shared, deliberately:** the actual git hook wiring
  (`.githooks/pre-push`, `core.hooksPath`) and CI workflows. These are
  genuinely per-repository — each repo has its own default branch, its
  own history, its own Actions runners — and a shared/symlinked copy
  would only reintroduce the kind of cross-repo coupling this kit's
  hooks are meant to avoid.

If the repos integrate over a real runtime API contract, that integration
design is a separate, orthogonal decision from repo count and from this
kit's setup — don't let adopting this kit become an occasion to also
relitigate whether the repos should be consolidated into one.

### Team growth: solo owner to first hire

This is the single most consequential Maturity Trigger in
`AGENT_RULES.md.template`'s list ("A second human... joins"), and the
one most likely to be missed, because nothing forces a re-read of that
section on the day it actually happens. Two things must happen together,
not sequentially:

1. **Recalibrate the Tier system's self-merge authority before the new
   collaborator's first PR, not after.** Tier 1's self-merge default is
   explicitly calibrated to "a solo, synchronous, full-context
   situation" (see the Maturity Triggers section) — that calibration
   stops being true the moment a second person is reviewing or merging
   code they didn't write the full context for. Decide, in
   `AGENT_RULES.md` itself (not informally, not "we both just know"),
   what changes: does Tier 1 still self-merge, or does it now need the
   other person's review too? Write the answer down before the first PR
   under the new arrangement, not retroactively after a disagreement.
2. **Only now does it become worth building real mechanical detection of
   who merged a Tier 2 PR** (a `merged_by`-vs-author check). Building it
   earlier, on a solo project, was independently flagged by both a fresh
   and an adversarial review pass as a check that can structurally never
   turn red (author, merger, and sole owner are always the same login) —
   see `LESSONS-LEARNED.md`'s "second-human self-merge" entry. A second
   real human is what makes this check meaningful for the first time; set
   it up now, not before.

Give the new collaborator their own `docs/collaborators/<username>.md`
from the template (see "A collaborator joining a project" above) and
walk them through `PASS-0-ENVIRONMENT-DISCOVERY.md`'s §4 question about
agent GitHub identity for their own setup — a second person very often
means a second, now genuinely distinct, agent credential question where
the original solo setup may have had none.

### Multiple humans, each running their own AI agent, working concurrently

This is now the common case for any team past one person, not an edge
case — "a different developer reviewed it" is, in practice, frequently
"a different AI session, with different context, reviewed it" (see
`AGENT_RULES.md.template`'s `What "review by someone other than the
author" actually buys you` section). What this kit does and doesn't
handle for that situation:

- **Handled:** the Tier system and push-protection hook are per-repo
  mechanical state, not per-agent — every concurrent session sees the
  same `core.hooksPath` wiring and the same `AGENT_RULES.md`, so there is
  no risk of two agents operating under two different rule sets simply
  because they're different sessions.
- **Not handled, and not helped by anything (real limitation, not
  smoothed over):** two agents picking a sequential identifier — a doc
  index, a version number, a pass number — at close to the same time can
  both check "what's next," both correctly see the same free slot, and
  still collide, because the check and the eventual write aren't atomic
  across sessions. `LESSONS-LEARNED.md`'s "Multi-agent coordination"
  section names this directly and recommends against trying to prevent
  it with a live coordination check (expensive, and still racy across an
  isolated worktree vs. the branch it came from); treat a collision as
  cheap to detect and fix after the fact — rename, fix cross-references —
  the same way a merge conflict gets resolved, not as a process failure.
- **Also not handled:** two agents both starting from a stale local
  `main` and independently opening PRs whose diffs overlap more than
  either author intended — a real, reproduced failure on a project using
  this kit (a branch created against an already-stale local `main`
  ended up including an already-merged PR's entire content). The fix
  there was rebasing onto real `origin/main` before trusting a diff, and
  that fix generalizes: always re-fetch and rebase onto the latest
  remote default branch immediately before opening a PR, especially when
  you know someone else has been merging
  concurrently.

### A different VCS host (GitLab, Bitbucket, Azure DevOps, self-hosted Gitea, etc.)

This kit's core mechanism — the `.githooks/pre-push` hook plus
`core.hooksPath` — is pure git, not GitHub-specific, and works identically
on any host. What genuinely is GitHub-specific, and needs a real
host-native equivalent rather than a direct port, is anything built on
`gh` or the GitHub Actions/REST API:

- `governance-gate.yml` and `collaborator-log-reminder.yml` are GitHub
  Actions workflow files. Port the *intent* (a PR-association check on
  pushes to the default branch; a reminder comment when a PR's changed
  files don't include the author's collaborator log) to the target
  host's own CI syntax and API — GitLab CI (`.gitlab-ci.yml` +the GitLab
  API), Bitbucket Pipelines, Azure Pipelines, or a Gitea Action. Don't
  assume the YAML translates almost as-is; each host's default shell
  behavior, secret-scoping model, and PR/MR event payload shape differ
  enough that a naive port risks reintroducing bugs this kit already
  found and fixed once (see the `bash -e {0}` default-shell finding in
  `CHANGELOG.md` — verify the target host's own equivalent default
  before assuming it matches).
- `.github/CODEOWNERS` and `.github/PULL_REQUEST_TEMPLATE.md` have direct
  equivalents on every major host (GitLab has `CODEOWNERS` support and
  merge request templates; Bitbucket and Azure DevOps have their own
  reviewer-default and template mechanisms) — move the same content, in
  the host's own expected location and syntax.
- Anywhere this kit's own docs say "PR," read it as "PR or MR" depending
  on host vocabulary — this is a wording difference, not a mechanism
  difference.

The Tier system, `AGENT_RULES.md`, `STAGE-0`/`PASS-0`, collaborator logs,
and the Open Research Queue are all plain files with no GitHub dependency
at all and need no adaptation.

### A different primary AI coding agent (not Claude Code)

`CLAUDE.md` is Claude Code's specific auto-load convention; it is not
what makes any of this kit's actual mechanisms work. The hook, the Tier
system, and the CI workflows are enforced by git and GitHub Actions
regardless of which AI tool a human is driving. What changes with a
different agent is only the auto-loaded-context step:

- Check whether the other tool has its own auto-loaded project-context
  convention (for example, a different tool's own root-level convention
  file) and put this kit's rules there too, or reference `AGENT_RULES.md`
  from it — the goal is that the tool's very first response in a new
  session already knows this project's Tier rules exist, the same way
  `CLAUDE.md` achieves that for Claude Code.
- If the other tool has no such auto-load convention at all, the rules
  still exist and are still mechanically enforced by the hook and CI —
  but nothing will proactively remind a session to read them, which is a
  real, not cosmetic, gap. Say so explicitly in that project's own setup
  notes rather than silently assuming parity with the Claude-Code-driven
  experience this kit was originally built and tested against.
- `AGENTS.md` (the more tool-agnostic convention some other tools already
  respect) is explicitly supported as an alternative or companion to
  `CLAUDE.md` — see `verify-setup.sh.template`'s "CLAUDE.md / AGENTS.md
  in sync" check, which already treats either as acceptable and only
  warns (never fails) if both exist and drift apart.

### Reviving a dormant project

Treat a long gap in activity as its own real state, not as either
"basically new" or "basically ongoing" — the honest process borrows from
both of the sections above and adds one step neither needs:

1. Run the kit-version upgrade process above first, unconditionally — a
   dormant project's copy of this kit (if it has one) is very likely
   several versions behind, and every other step below should happen
   against the current templates, not stale ones.
2. Re-run Pass 0 (environment discovery) in full, even if it was done
   before. Its answers are about the project's *current* real state
   (who's actually still active, what's actually still deployed, what
   actually still passes CI) — a dormant project's true answers to these
   questions have almost certainly drifted since they were last recorded,
   more than an actively-worked project's would over the same calendar
   time.
3. Do not re-run Stage 0 (product/scope research) by default — dormancy
   alone doesn't reopen product decisions that were already cleared,
   per Stage 0's own applicability rule. If the reason for reviving the
   project *is* a real pivot in product direction, that's a new Stage 0
   trigger on its own merits, not a consequence of the gap in time.
4. Explicitly re-verify the push-protection hook and CI are still
   actually wired, not just present as files — a dormant repo is exactly
   the situation where a host platform's own defaults (branch protection
   settings, Actions being disabled after long inactivity on some plans)
   may have silently changed underneath unchanged files. Run
   `scripts/verify-setup.sh` and don't trust the file tree's mere
   existence as evidence of working enforcement.
5. Read the full `docs/OPEN-RESEARCH-QUEUE.md` and every collaborator log
   before writing any new code — a dormant project's queued research
   items and unfinished threads are exactly the context most likely to
   be silently dropped by whoever (human or agent) picks the project back
   up, precisely because there's no one still "in their head" about it.

### Retiring or removing this kit from a project

This kit does not currently have a scripted "uninstall" — removal is a
manual, and honestly under-exercised, path. At minimum:
1. Unset the hook wiring deliberately (`git config --unset
   core.hooksPath`) rather than just deleting `.githooks/` — an unset
   config pointing at a now-missing directory can behave differently
   across git versions than never having been set, and this hasn't been
   verified across versions.
2. Remove or archive (don't silently delete) `AGENT_RULES.md`, the
   `STAGE-0`/`PASS-0` docs, collaborator logs, and the Open Research
   Queue — these documents are a real record of decisions and their
   *why*, independent of whether the enforcement mechanism around them
   stays active. Archiving preserves that record for anyone who later
   asks "why does this code work this way"; deleting it destroys
   information this kit exists to preserve.
3. Say so explicitly, in the project's own `README.md` or `CHANGELOG.md`,
   including the real reason — "the kit's process overhead stopped being
   worth it at our current scale" is a legitimate, honest reason and is
   more useful to a future reader than silence or a vague "cleanup"
   commit message.
4. If retirement is really a *downgrade* (keeping this kit's hook and
   Tier docs but dropping some other, separate governance layer this
   project also happens to run, or vice versa), that's not full
   retirement — treat it as a scoped change to `AGENT_RULES.md` under
   this project's own Tier 2 rule, the same as any other rules-file
   edit, not as an exception to it.

### Bot- or CI-authored contributions

Already substantively handled — see `AGENT_RULES.md.template`'s "Bot/CI-
authored PRs" section, which applies the same canonical Tier list to
bot authors as to humans, with no special carve-out. There is nothing
additional to set up for this scenario specifically; if a project adds a
bot account (a dependency-update bot, a scheduled-job account, a second
AI agent with its own distinct GitHub login), that account's PRs are
governed by the same rules everyone else's are, and
`collaborator-log-reminder.yml.template` already exempts bot-authored PRs
from the log-file reminder (`github.event.pull_request.user.type !=
'Bot'`) rather than requiring a bot to maintain a human-style work log.

### A contractor or other temporary collaborator

The mechanisms above (Tier calibration, collaborator logs, hook wiring)
don't distinguish "permanent team member" from "temporary" — that
distinction lives entirely in the human process around GitHub repository
access, which this kit doesn't manage and shouldn't be assumed to. Two
things worth doing deliberately rather than by default:
- Still create a real `docs/collaborators/<username>.md` for a
  contractor's engagement, even if short — the log's value (letting
  other collaborators reconstruct what was done and why) doesn't scale
  with tenure, and a short, well-signed log from a two-week contractor
  is more useful to whoever maintains the code afterward than no record
  at all.
- When access ends, remove the person from the repository/organization
  through the host's own access-control settings (this is a real,
  security-relevant action outside this kit's scope, not a governance-doc
  edit) — don't rely on `CODEOWNERS` or the Tier system as an access
  boundary; they govern review/merge process for people who already have
  write access, not who has it in the first place.

### Adding speed mode (optional)

Speed mode is a way of running several AI agents in parallel without
lowering rigor: the speed comes from parallelism and planning, never from
skipping a review. It is opt-in and adds guardrails; it never relaxes the
tiers. The evidence for it is one project, so treat it as a practice to
measure, not a proven default.

**Prerequisites.** The Tier policy in `AGENT_RULES.md` and the pre-push
hook are already adopted and verified (steps 1, 2 and 9 above). Speed mode
sits on top of them; without them its guardrails have nothing to stand on.

**Steps.**
1. Copy `templates/SPEED-MODE.md.template`, `AGENT-LEDGER.md.template` and
   `SPEED-MODE-METRICS.md.template` to `docs/` (drop `.template`).
2. Fill in the placeholders. In `SPEED-MODE.md`: `{{PROJECT_NAME}}` and the
   three risk-class path lists (`{{FULL_RISK_PATHS}}`,
   `{{STANDARD_RISK_PATHS}}`, `{{LIGHT_RISK_PATHS}}`). Derive them from
   your own Tier 2 list: everything on it is Full. The lane-plan row in
   section 6 is a template to copy per plan; leave it as it is. In
   `AGENT-LEDGER.md`, fill the roster as agents launch. In
   `SPEED-MODE-METRICS.md`, **choose the revert-condition numbers
   (`{{MIN_NET_SAVING_PERCENT}}`, `{{N_PRS}}`) before the first
   speed-mode PR**, and add the per-PR rows as they merge.
3. Add the pointer: keep the optional "Speed mode" section in
   `AGENT_RULES.md` (it is in the template) and add `docs/SPEED-MODE.md`
   to the project's Tier 2 list, since weakening its guardrails weakens
   the rules.
4. Cross-reference `docs/MODEL-UTILIZATION-PLAYBOOK.md` for which concrete
   model fills each model class.

**Verify.** Search the copied files for `{{`: the only survivors should be
the lane-plan and roster rows meant to be copied per use. Confirm the
pre-push hook still blocks a direct push to the default branch. Run a
first small parallel task through the lane plan and check that each agent
used its own worktree and branch and that the branch history shows
`wip:` commits.
