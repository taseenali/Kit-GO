# Lessons Learned

Real findings from actually setting this system up on a real project
(2026-09), each one hit for real and fixed for real — not
generic best-practice advice. Read this before setting up a new project,
not after something goes wrong.

---

## GitHub / Git

**Branch protection requires a paid plan on a PRIVATE repo.** Confirmed
live by trying both APIs, not assumed: classic branch protection
(`PUT .../branches/main/protection`) and the newer rulesets API
(`POST .../rulesets`) both returned the identical `403 "Upgrade to GitHub
Pro or make this repository public"` on a free-tier private repo. A public
repo gets this free on any plan. **Decide this consciously before you need
it** — private-but-unprotected `main` is a real, common state; don't
discover the limit the day you actually needed protection. See
`AGENT_RULES.md.template`'s review-tier policy for how to compensate with
written discipline when you're on the free tier.

**A branch is for work that merges back — don't use it as a permanent
folder substitute.** The instinct to put "docs" or "context" on its own
branch, separate from code forever, breaks the ability to review a code
change and its documentation update together in one PR. Use folders
(`docs/`, `app/`, whatever) for permanent separation within one history;
use branches for short-lived, per-task work.

**`git ls-remote <url>` before assuming a remote's state.** Exit code 0
with zero output means "reachable, genuinely empty" — different from an
auth failure (which errors) or a repo with history (which lists refs).
Cheap, and tells you which bootstrapping path you're actually in before
you commit to one.

**Verify `.gitignore` actually excludes what you think it does — don't
trust the pattern by eye.** `git check-ignore -v <path>` against the
specific sensitive paths (a `.env` file, a data directory) before the
first `git add -A`, every time. A 4+ GB data directory or a live API key
accidentally committed is expensive to fully scrub from history later;
catching it before the first commit costs one command.

**A CLI tool the established process depends on (`gh`, a linter, a
deploy tool) going missing mid-project is a signal to stop and tell the
human, not a reason to silently substitute a lower-fidelity workaround.**
Real case: `gh` (used to create and merge every PR for weeks) stopped
being found on `PATH`. Rather than surfacing this immediately, work
continued via direct `git merge` to the default branch — which still
produces working code, so nothing looked broken, but silently dropped
every real guarantee the PR process existed for: a reviewable diff
before merge, CI actually gating the merge, an audit trail the human (or
a differently-authenticated future session) could see. The tool going
missing was itself real and fixable (the binary had been removed while
stored auth credentials survived; reinstalling restored full function
immediately) — the mistake was routing around it quietly instead of
naming it the moment it was discovered. When something the process
depends on stops working, that is itself the first thing to report, not
a problem to solve invisibly before anyone notices.

**Two or more compliance/process gaps that start at the exact same
timestamp are one root cause, not independent failures — find the
shared boundary before treating them separately.** Real case: a
PR-workflow breakdown (branches merged directly instead of through PRs)
and a separate documentation-logging gap (a required "save the answer"
step stopped happening) were initially investigated as two things —
until checking real timestamps (PR history, file mtimes) showed both
started at the exact same session boundary (a context compaction /
account switch). The real cause was one thing: after that boundary, the
agent stopped re-reading its own governing rules document and worked
from a compressed memory of "what the rules are" instead — the document
itself had been correct and complete the entire time. When multiple
unrelated-seeming gaps cluster at one moment, check for a shared session/
context-boundary cause before treating each as its own bug.

**After a context compaction, account switch, or long session gap,
re-read the authoritative rules/process file before resuming
state-changing operations — don't trust a summarized memory of it.** A
governance document doesn't need to be wrong or missing for an agent to
stop following it; the agent's own confidence that it remembers the
rules correctly is enough on its own to cause real drift. This is cheap
insurance (one file read) against exactly the failure mode above.

**A branch/PR that keeps absorbing new commits across multiple work
sessions instead of merging promptly is a visibility risk, not just a
conflict risk.** The usual reason given for "merge promptly, one logical
unit of work per PR" is avoiding merge conflicts — real, but not the
only cost. Work sitting on a long-lived unmerged branch is invisible to
anyone, or anything, that only looks at the default branch — including a
future, differently-authenticated session of the same agent that has no
way to know a branch even exists unless it's told. A default branch that
accurately reflects current project state is itself a real property
worth protecting, separate from conflict avoidance.

## CI

**A fresh `npm install` that leaves a platform-specific native binding
unresolved is a real, documented npm bug, not a local environment
problem to work around by guessing.** Real case: a Vite-based tool's
startup crashed looking for a WASM fallback binding, because the correct
platform-specific native binding (present in the package's own
`optionalDependencies`) never actually got installed — a known npm
optional-dependencies resolution bug (tracked upstream as
`npm/cli#4828`), more likely to surface after an interrupted or
retried install. Confirmed by inspecting the relevant `node_modules`
subpath directly for which binding actually landed, not by guessing from
the error message alone. Fixed by a full, clean `node_modules` reinstall
(not just re-running install on top of the broken state) — and always
re-verify by re-running the thing that crashed, not assumed fixed because
install "succeeded" a second time.

**When adding a new dev-tooling major version, check its peer
dependencies against what the project already pins before installing
`latest`.** Real case: a test runner's newest major version required a
newer minimum type-definitions package version than the project already
had pinned elsewhere — installing `latest` blind would have forced an
unrelated, unjustified bump to that pin just to satisfy the new tool.
Check the real peer-dependency requirements of the last few majors
(`npm view <pkg>@<major> peerDependencies`) before installing, and pick
the newest major that's actually compatible with what's already pinned,
rather than defaulting to `latest` and discovering the conflict from an
install error.

**A test suite that needs live secrets or network access to pass is a
test suite that can't run in CI honestly.** Design tests around real
captured fixtures or injectable stubs from the start — CI should get a
real pass/fail with zero configured secrets, not a suite that's skipped or
that silently needs someone to add tokens to Actions secrets later.

**Don't path-filter the test workflow's trigger by default — a docs-only
PR that never triggers it is a hole, not a saving.** An earlier version of
this lesson advised path-filtering (`on.push.paths`,
`on.pull_request.paths`) to save minutes on docs-only commits. A real
downstream project followed it and found, 2026-09-24, that a docs-only PR
produced an *empty* check rollup — not "skipped and green," no run at all —
so the one class of PR this kit's Tier 0 lets an agent self-merge was the
one class CI structurally could not check, and a doc-asserting test
(a schema-sync guard, say) could regress through a "docs" change
unnoticed. Run the suite on every PR unless you have real minutes
pressure; if you do filter, you own the gap it reopens: Tier 0 then has to
mean "run the suite locally and paste the output," because CI won't. A
*different* workflow (a lint on one language's files, a deploy gate) can
still reasonably be path-filtered — this lesson is about the workflow
whose result stands in for "tests passed."

**Verify CI actually runs by watching a real PR go through it — don't
trust a syntactically-valid workflow file.** A path-filtered workflow can
sit there doing nothing on every PR that happens not to touch its
watched paths, which looks identical to "broken" from a glance at the
Actions tab. Push one real change (and, if the workflow is still
filtered, also check what a docs-only PR gets) and
confirm a run actually appears and passes (`gh run view --log`, checking
for actual test output, not just a green checkmark).

## Windows-specific (if applicable)

**A freshly-installed CLI tool (e.g. `gh` via `winget`) won't be found by
an already-open terminal.** Windows processes inherit their environment
(including PATH) from their parent at launch — an installer updating the
registry doesn't retroactively update a running shell, or a terminal host
application's already-running process, or any tab spawned from it. Fully
quit and relaunch the terminal application itself, not just open a new
tab/window within it. Or, to unblock a session immediately without
restarting anything:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

## Review / process

**Don't copy the form of a rigorous review process without the reasons
behind it applying to you.** Multi-developer, multi-week PR review at a
large org exists because many uncoordinated people touch the same code and
one bad merge has org-wide blast radius. A solo developer + AI agent
working synchronously with full shared context has neither problem yet.
Copying the form (artificial delays, reviewers that don't exist) is
theater. The actual principle — checked by something other than whatever
wrote it, proportional to what breaks if it's wrong — is real and portable;
see the 3-tier policy in `AGENT_RULES.md.template`.

**"Review by someone other than the author" doesn't require a second
person — but check what your review tooling actually lets an agent
self-invoke before designing around it.** Multiple human developers on a
team increasingly each work with their own AI agent too, so "a different
developer reviewed it" is often already "a different AI session reviewed
it" in practice. A single agent can genuinely close most of that gap by
running a **fresh** review invocation (not the same continuous
conversation that wrote the change immediately confirming its own work) —
that decorrelation is the real mechanism, achievable today, no second
person needed. What it can't close: independent human knowledge, bus
factor across actual people, and accountability that specifically needs a
named human — keep explicit human sign-off for high-stakes changes
regardless of how good the AI review is. One real constraint that shaped
this (checked, not assumed): a deeper multi-agent/cloud review mode may
be user-triggered and billed rather than something an agent can invoke on
its own — verify this for whatever review tooling you actually have before
writing a rule that assumes an agent can always reach for it.

**A rule that isn't visible at the point of action gets ignored, however
well-written.** A review-tier policy living only in a rules document
nobody re-reads per PR is weaker than the same policy with a checkbox in
the PR template itself. Put the enforcement surface where the action
happens.

**When you find a real platform limit (a paid-plan wall, an API that
doesn't do what the docs implied), say so explicitly in whatever
documentation would otherwise imply the opposite.** A CI workflow comment
claiming to be "the required check" when nothing actually requires it is
worse than no comment — it creates false confidence. Write down what's
real, not what was intended.

**"No live instance to test against yet" is usually not actually true --
check for a throwaway local one before writing untested code and calling
it careful.** A real case: a project's SQLite store had been justified for
months as "Postgres later, once a real instance exists to test against
honestly" -- writing untested Postgres code and shipping it would have
repeated the exact anti-pattern that reasoning was built to avoid. Docker
was already installed, just not running. Starting it, spinning up a
disposable `postgres:16-alpine` container (`docker run --rm -d -p
<port>:5432 ...`), and running every new code path against it for real --
including a trigger that needed a genuine dialect-specific rewrite (a
SQLite inline `CREATE TRIGGER ... BEGIN...END` has no Postgres
equivalent; Postgres needs a real trigger function) -- turned "written
carefully, should work" into "confirmed working," for the cost of a few
minutes and zero new infrastructure to maintain afterward (`--rm` cleans
it up). The real target (a managed cloud instance -- Neon, RDS, whatever)
is still worth a separate, later verification pass once it exists, since
a local container won't catch every environment-specific difference --
but "nothing reachable to test against" is a much rarer real state than
it first appears, and it's worth checking for a cheap disposable
equivalent before accepting untested code as the honest ceiling.

**The "second-human self-merge" gap: "No self-merge for a human
contributor" is a real rule with zero mechanical backing on a free-plan
private repo — and the gap stays invisible until a second real person
with real push access exists.**
A solo owner + AI agent setup can build real mechanical enforcement
against *the agent* (a pre-push hook, a server-side workflow checking
every commit on `main` has an associated PR) and reasonably feel
covered. Neither of those mechanisms has any visibility into who
clicked "Merge pull request" on a properly-opened PR — a hook only
sees a local `git push`, and a workflow that checks "does this commit
have a PR" says nothing about who approved or merged it. The moment a
second human gets real Write access, "they won't self-merge" quietly
becomes a trust-only policy, and it's easy — checked directly, this is
exactly what happened — to write the onboarding documentation for that
second person in a way that *sounds* like it's covered by the existing
hook/workflow infrastructure, because that infrastructure is sitting
right there in the same document, without ever naming that it doesn't
reach this specific case. Real GitHub-enforced protection (requiring
review from someone other than the PR author before Merge is even
clickable) needs a paid plan on a private repo; short of that, the
honest fix is naming the gap explicitly, not implying coverage that
doesn't exist. A cheap partial mechanical improvement that doesn't need
a paid plan: a `pull_request: [closed]` workflow comparing `merged_by`
against your accountable-reviewers list and flagging a mismatch — same
detect-not-prevent shape as a "was there a PR at all" check, closes part
of the gap a pure hook cannot touch at all.

**Sharpened after a real attempt to build the above, 2026-09-23 — don't
build this mechanism before it can actually deliver something:**

- **On a genuinely solo-owner project, this check cannot produce a
  single true positive, ever** — not "partial coverage," zero. Author,
  merger, and the sole `CODEOWNERS` entry are the same login on every
  PR the repo can currently produce. A check that structurally can
  never turn red is worse than no check: its green status reads as
  coverage that doesn't exist. Gate building it on the actual trigger
  (a second real human joins), not on "it would be nice to have."
- **The comparison needs the PR's tier, not just identity.** `merged_by
  == author` is *correct, intended* behavior for Tier 0/1 self-merge —
  it's only a violation at Tier 2. A check that doesn't extract the
  PR's tier first will either flag every legitimate self-merge as a
  false positive, or (if narrowed to a CODEOWNERS-mismatch only) miss
  the sole-owner Tier 2 case it exists for.
- **This is also the exact case an AI agent sharing its human owner's
  own GitHub credentials (verified true via `gh auth status`/`gh api
  user` on a real project, 2026-09-23 — no separate agent identity
  existed) can never be caught by.** `merged_by` would show the human's
  login regardless of whether the human or the agent actually clicked
  merge. The real fix for *that* specific gap isn't this workflow at
  all — it's giving any agent with real merge capability its own
  distinct credential (a separate PAT or GitHub App identity) if that
  guarantee is genuinely needed; a `merged_by` check only ever catches
  a *third*, already-distinct identity merging something it shouldn't.
- **A `pull_request`-triggered workflow (as opposed to `push`) in a
  same-repo PR runs using that PR's own branch's version of the
  workflow file** — a PR that edits or deletes this exact audit
  workflow escapes its own audit for that PR. `governance-gate.yml`
  avoids this by triggering on `push` to `main` instead, checking after
  the fact via the API; this mechanism needs the same shape, not a
  `pull_request: [closed]` trigger as originally proposed.

**A "PRs required" rule can lapse on some changes while being followed
correctly on others in the very same session — written policy plus an
agent's own memory of it is necessary but not sufficient.** Real case: in
one working session, three chunks of work on a repo went through real
PRs with CI gates; two other chunks, built and reviewed with the same
real rigor, were merged straight to the default branch via a direct
`git merge` with no PR ever opened — not because the PR tooling was
unavailable (it was demonstrably working elsewhere in the same window),
but because the rule simply wasn't applied that time. This confirms and
sharpens the "rule invisible at the point of action gets ignored" lesson
above: even a rule the agent visibly *does* follow most of the time
needs a mechanical backstop, not just restated discipline. Where the
platform supports it (e.g. GitHub branch protection requiring a PR and
passing checks before a merge to the default branch is even possible),
pair the written rule with an enforcement point that makes the violation
structurally impossible rather than merely against the rules.

**When a review-driven fix touches a file that has a paired test file,
updating the test is part of the same change, not a trailing step.**
Real case: a review pass's fixes moved a side effect (an audit-log
write) from one route handler to another; the route files were fixed
correctly in the same pass, but their paired test files weren't updated
until a separate pass afterward, and the gap survived a context-
compaction boundary before being caught — by chance (re-reading the
stale test file directly before an unrelated edit), not by a systematic
check. A stale test can fail in a way that looks unrelated, or in the
worst case keep passing on a since-removed code path, either of which
delays noticing. Before calling a review-driven fix round complete,
explicitly check every changed source file for a `*.test.*` counterpart
and confirm its mocks/assertions still match the new code.

**When a rebase conflict's two sides disagree about a *fact*, don't
resolve it by picking whichever side looks "more recent" — check whether
the side you're about to discard is a deliberate, already-reviewed
correction.** Real case: rebasing a PR onto a new `main` conflicted on one
line of a log file. One side (the branch's already-current text) said a
Kit PR had "landed directly"; the other (the commit being replayed) said
"open, not yet merged — landed directly was premature," a correction an
earlier review pass had *itself* caught and applied. The person resolving
it judged the first side "more current" (written later, with more
up-to-date knowledge) and kept it, silently reverting a real,
review-vetted fix. Nothing flagged it: both PRs being combined had each
been independently reviewed, and the conflict markers look the same
whether the discarded side is stale or deliberate. A fresh + adversarial
pass dispatched *specifically on the rebase* (not assumed clean because
its two inputs were) caught it. The check is cheap — for each side you
discard, look at its history (`git log -S`, `git show <commit>`) and ask
whether it was put there on purpose — and the failure mode (a real fix
quietly undone, shipped looking fine) is easy to miss. "Written later,"
"familiar," and "matches my own recent knowledge" are proxies for
correctness, not evidence of it. Treat a rebase that resolved a factual
conflict as a new change needing its own review, not as the sum of its
already-reviewed parts.

## Machine-to-machine / service-to-service auth

Real findings from standing up the first external-caller (not
human-session) auth boundary on a real project — this is a genuinely
different review shape than a login/session flow, and the two easy-to-miss
defects below both passed a first read-through and only surfaced under an
adversarial pass that actually tried things, not just read the code.

**A shared, account-level/instance-level API credential often
authenticates "someone with a valid credential for this account," not
"the specific caller you expect."** If the auth provider distinguishes a
scoped credential (issued to one specific registered caller/service) from
a broader one (valid for anything under the same account), using the
broader one for convenience silently widens who can call in — any other
service sharing that account, not just your intended caller. Check the
provider's docs for the scoped variant. Independent of which credential
ends up configured, add a code-level check of the verified caller's own
identity claim (a subject/audience/client-id field) against an explicit
allowlist — this is real defense-in-depth an operator's misconfiguration
can't silently bypass, and it's cheap to write and test without needing
live provider access.

**A "successful" verification response can still carry a "but don't
actually trust this" signal as fields on the success body — not as a
different status code, not as a thrown exception.** Real case found:
revoked and expired were both required fields on the provider's own 200
response, and the calling code checked only for a thrown error, discarding
the response body entirely. A revoked-but-200 credential was silently
accepted. Read the full real response shape from the provider's own SDK
source or API reference before deciding "no exception means valid" is
enough.

**Bound the timeout and retry policy on any outbound verification call
explicitly — don't trust a generated SDK's default.** Real case found: an
auto-generated client's default retry/backoff policy retried for up to
one hour on a single call. On a synchronous request-handling path (a
typical web framework's default worker-thread model), that turns a
transient outage in the auth provider into a slow, creeping exhaustion of
your own service's request-handling capacity — measured directly against
a local stub returning errors, not assumed. Pass an explicit, short
timeout and a bounded retry budget; let the caller retry the whole request
on its own terms instead.

## Multi-agent coordination

**A background agent asked to pick its own sequential identifier (a pass
number, a doc index, a version) can collide with concurrent work, even if
it checked "what's next" right before starting.** The check and the
eventual write aren't atomic across two agents (or an isolated worktree
and the branch it came from) running at the same time — one dispatched
first can still land second. Don't try to prevent this by blocking
dispatch on a live coordination check; it's cheap to detect and fix after
the fact (rename, fix the file's own internal self-references — a title,
a cross-link — the same way a merge conflict gets resolved) and expensive
to design around up front. Treat it as a known, recurring, low-severity
outcome of real concurrent agent work, not a process failure each time it
happens.

**The identifier a "what's next" check needs to look for isn't always a
same-named file — a later identifier can already be claimed purely by
cross-reference, with no artifact of its own yet.** Real case: an agent
checked a directory listing for the next free number, correctly found
none, and still collided — a different, earlier piece of work had already
claimed that number in a separate index/summary document, without ever
creating a same-numbered file itself. A directory listing is necessary but
not sufficient; also check wherever else identifiers get referenced (an
index file, a status table) before assuming a gap is really free.

**An isolated worktree for a concurrently-dispatched agent avoids
mid-run working-tree conflicts, but doesn't avoid the identifier-collision
problem above** — the agent's view of "current state" is frozen at the
moment its worktree branched, not updated as of when it finishes. Isolate
the working tree for safety; still expect to reconcile numbering/naming
after the fact.

**A background agent's isolated worktree can leak into a foreground test
or lint run's *counts* — silently, with every check still genuinely
passing.** Real case: while two background review subagents were running
(each in its own git worktree under `.claude/worktrees/`), the foreground
session ran the test suite and linter in the main checkout and reported
"204/204 tests, 22 files, 34 lint warnings" as verification for a
security-relevant fix. Both numbers were wrong — the real ones, re-run
once the background agents finished, were about half (102 tests in 11
files; 17 warnings). The test runner's default `**/*.test.*` glob (and the
linter's default file discovery) walked into each worktree and counted a
full duplicate copy of the repo. The agent then invented a plausible
explanation for the inflated lint count after the fact, rather than
checking it. Nothing was actually broken; the *evidence* was. Two fixes,
different strengths:

- **Mechanical, narrow:** explicitly exclude the agent-worktree
  directory (`.claude/worktrees`, or whatever path your agent host uses)
  in every test/lint config that walks the filesystem by glob — a runner's
  default excludes cover `node_modules`-style real code that isn't yours,
  and this is the same kind of thing. Per ecosystem: vitest
  `test.exclude`, jest `modulePathIgnorePatterns`/`testPathIgnorePatterns`,
  ESLint `ignorePatterns`/`globalIgnores`, pytest `norecursedirs` (note:
  pytest's *default* `norecursedirs` already skips dot-directories, so a
  default-config pytest run does not have this leak, verified on pytest
  9.1; the logged incident was vitest + ESLint, whose defaults did not
  skip it). Setting your own list *replaces* the defaults in pytest, vitest and
  jest (ESLint's ignore lists add to its defaults, but those defaults
  don't cover `.claude/`) — pytest `norecursedirs` (keep `.*` in it), vitest
  `test.exclude` (spread `configDefaults.exclude`), jest
  `testPathIgnorePatterns` (default is `/node_modules/`) — so add to the
  defaults rather than overwriting them. Mind that pytest's
  `--ignore-glob` is anchored at the current directory, so a bare
  `**/.claude/...` pattern does not match a repo-root `.claude/`; use
  `--ignore=.claude/worktrees`.
- **General, discipline:** treat any count-of-things reported as
  verification evidence (tests, lint warnings, files changed) that could
  have come from a glob or directory walk as suspect if a parallel
  background agent with its own filesystem footprint (a worktree, a temp
  checkout) was active when it was captured — re-run with none active
  before trusting the number. And a number that looks wrong gets
  *investigated*, not explained away: an explanation invented to fit a
  surprising figure is a fabricated verification claim, even when well
  meant.

**Save-as-you-go makes a usage-limit interruption cost nothing.** Builders
that commit a `wip:` snapshot after every logical step and push their own
branch lose nothing when a limit or a dead session cuts them off: the
branch history shows exactly what is done, and the same agent (resumed by
id) or a fresh one continues from the first unfinished item. In real use two
interruptions were free for this reason. The branch history is the progress
record; a ledger of agents, branches and resume recipes (never credentials)
makes it findable.

**Review a drafted irreversible change statically, before it is applied.**
A fresh reviewer reading a draft migration found an identifier-namespace
hole, and later several defects in its test harness, before anything
touched the live system. Reading the draft is the cheapest high-value step
there is; once the change is live, every finding costs a repair instead of
a revision.

**A content-based plausibility gate beat a size heuristic for a backup.**
A backup job was dumping a single table because a flag restricted the dump
to one table, which a size-style sanity check had not caught. A check that
looked at what the dump actually contained (the expected schemas and tables
present) caught it. Check backups by content, and
prove them with a real restore.

**Deleting the base branch of a stacked PR closes the PR automatically.**
Merge the base without deleting its branch, retarget the dependent PR to
the default branch, then delete. The closed PR cannot be reopened against a
missing base and has to be rebuilt.

**A secret pasted into chat has to be treated as leaked.** Rotate it at
once, and design the flow so a secret never transits chat in the first
place (set it from standard input into the secret store, or have the lead
call the API with a scoped token). Where a short-lived scoped token does
have to be pasted, track it and revoke it after use. A rule that says
"never any secret in a prompt" cannot tell the two apart; word it as
"long-lived or broad secrets", and track the deliberate exceptions.

**A QA agent driving a real browser found what code review and a live
access-test harness could not.** Both had passed. The browser run found a
notification indicator that never updated live and a deactivated user whose
open session still worked. Static review and access tests check what their
authors thought of; exercising the running product catches what nobody
described.

## Multi-repo / multi-codebase products

**A product that spans more than one repository is one system, not "the
primary project" plus "an integration into it."** It's easy for
documentation to drift into treating one codebase's prior product/design
decisions (a UI vision, a workflow model, a validated rule) as superseded
just because a *different* codebase became the one that ships — but a
requirement doesn't lose standing for having been discovered on the
"other side." If a project splits or consolidates its customer-facing
surface across repos, say explicitly in governance docs that decisions
carry equal weight regardless of which repo's code implements them,
rather than letting the framing drift toward whichever repo has more code
built today.

**Whether multiple codebases should live in one repository is a
development/ops-workflow decision, separate from whether/how the services
integrate at runtime.** Two services can already talk over a real network
API contract regardless of repo count — don't let the repo-structure
question block or get conflated with the runtime integration design.
When it does need answering, real, current, verifiable evidence beats
default monorepo enthusiasm, which is frequently calibrated for a team
and language homogeneity a solo/small project doesn't have: check whether
your VCS actually supports the access-control granularity you'll want
(a real, verifiable "monorepo removes this option" finding, not
assumption), whether your language mix has genuine first-party tooling
support for a combined build, and your actual team size against what
real small-team guidance says — not what a much larger org does.

**A coding assistant's auto-loaded project memory (`CLAUDE.md`/`AGENTS.md`)
is anchored to whichever directory a session actually started in — it
does not get re-scanned or merged in just because a `cd` or a tool call
touches a different repo mid-session.** This is a real, structural blind
spot for a polyrepo product, distinct from and compounding the framing
drift named above: writing an excellent governing-rules document in
Repo B does nothing for a session whose session root is Repo A, even
while that session is actively editing files in Repo B through tool
calls. Real case: a written "every change goes through a PR" rule
existed and was followed correctly for several changes in one repo, then
silently not followed for two changes in a *sibling* repo of the same
product, in the same session — not because the tool broke, but because
the rule document governing the sibling repo was never in the
auto-loaded context to begin with, and nothing forced a fresh read of
it before state-changing work happened there. Two things fix different
halves of this, and both are needed:
1. **Make the blind spot itself impossible to miss** by naming it
   explicitly, near the top, in *each* repo's own auto-loaded file —
   "this session's memory may be anchored to the other repo; read
   *this* repo's own rules file before any state-changing action here
   if it wasn't already visible this turn." A rule that only lives in
   the file nobody auto-loaded doesn't help; a rule that says "go check
   the file you might be missing" is the one that can actually fire.
2. **Move what actually matters onto a mechanism that doesn't depend on
   context being loaded at all** — a git hook, a CI gate, a platform
   setting. In the case above, that meant a local `pre-push` hook
   (wired per clone via `core.hooksPath`) rejecting any direct push to
   the default branch, present in *every* repo of the product
   independently — it fires the same way whether or not any memory file
   was ever read that session. Writing better prose is necessary but
   provably insufficient on its own; the mechanical layer is what holds
   when the prose doesn't get read.

**A client-side git hook cannot bind an actor who has client-side
access, and a review that only reads the hook's source will not catch
this — it has to actually try to defeat it.** An adversarial review of
the hook above built a throwaway git remote and reproduced, not just
reasoned about: `git push --no-verify` skipping it entirely and
silently; `git config --unset core.hooksPath` (or `-c core.hooksPath=`
for one command) disabling it with zero trace; and a first version of
the hook that let the protected branch be *deleted* outright because a
"skip ordinary branch deletions" exemption also covered deleting the
one branch that mattered most. None of these are hook bugs in the
usual sense — they're the structural ceiling of what a client-side
mechanism can ever guarantee, since the same actor who'd forget a
written rule can also, in one command, remove the thing enforcing it.
**The fix is not a better hook; it's an additional, server-side check**
(a GitHub Actions workflow triggered on `push: main` that queries
whether the pushed commit is associated with a real PR, and fails
loudly if not) that runs on infrastructure the client can't reach at
all. Treat "did we adversarially try to defeat our own mechanism" as
its own required step before trusting a hook, CI gate, or any other
mechanical control — a fresh pass confirms the code does what it says;
only an adversarial pass checks whether it can be walked around.

**Of every rule in a typical `AGENT_RULES.md`, expect a first pass at
"mechanical enforcement" to cover exactly the one rule that already
broke, and name that honestly rather than imply the whole regression
pattern is now solved.** Real case: after building the hook and gate
above, an adversarial review's sharpest finding wasn't a bug — it was
that roughly nineteen other binding rules in the same document ("tests
actually run," "no secrets committed," "docs stay in sync," "review
tier honored") remained exactly as memory-dependent as before, because
the fix generalized the *lesson* ("mechanize what matters") but not the
*coverage* (only the one rule that had already caused a visible
incident got a mechanism). This is a reasonable, honest first increment
— not every rule needs equal urgency — but the changelog/PR describing
it should say so explicitly ("this covers rule X; rules Y and Z remain
memory-only") rather than let "we added mechanical enforcement" read as
more complete than it is.

## Verifying a second-opinion / adversarial reviewer's own reading

**When a user's own words are ambiguous, a "second opinion" review pass
is worth its cost even on plain-text instructions, not just on code.**
Real case: a user's short, informally-worded security concern used a
word ("agent") that was also this specific project's own RBAC role
name — a first pass read the sentence generically (an outside party
impersonating a legitimate entity) and dispatched a research agent on
that framing. A second, independent reading of the same sentence — run
as a separate review with no exposure to the first pass's conclusion —
surfaced a much more likely reading once the domain-specific meaning of
"agent" was weighed properly: an *internal* actor (someone holding that
literal role) misusing legitimate access, a structurally different
problem from the first pass's framing. **When ambiguous natural-language
instructions get acted on with real downstream cost (a research
dispatch, a design decision), a second independent read is cheap
insurance — especially checking whether a word in the sentence is also
project-specific vocabulary (a role name, a table name, a term of art)
that changes its most natural meaning.**

**Before researching or designing to solve a stated problem, check
whether this exact problem was already solved earlier in the same
project.** The corrected reading above pointed straight at a decision
document from two weeks earlier in the same repository that had already
fully answered it (legal findings, a concluded technical design) — a
"new" research dispatch nearly duplicated work that was sitting one
`grep` away. A pre-research step of searching the project's own decision
history for matching vocabulary (not just the research topic, but the
specific nouns the user used) would have found it immediately, before
spending a full research pass re-deriving something already settled.

**A UI mockup or new build can silently contradict an already-decided
architecture from earlier work if nobody cross-checks it.** Same
incident: a dialer-panel mockup built the same day displayed a raw
contact number in the clear — directly contradicting a masked-contact
architecture decided two weeks earlier for exactly this kind of screen.
Nothing caught this until the unrelated "second opinion" review
surfaced the connection. When building a new screen or feature that
touches a domain (contact handling, access control, payments) that's
had prior dedicated research, check that prior decision explicitly
before designing the new artifact — don't rely on it surfacing by
coincidence.

## Real-world identity/access questions surfacing mid-build

**A named human account (an individual's personal email, not a
project/team account) ending up as the administrative owner of a
third-party service's dashboard (auth provider, hosting platform, paid
API) is a real, recurring small-project pattern — worth surfacing
explicitly the moment it's discovered, not assumed resolved.** It
commonly happens when one contributor sets up a service early, before
formal account/ownership structure exists. The fix isn't something an
agent can do from inside a codebase (no dashboard access) — flag it as
a named, tracked item the humans need to resolve (transfer ownership,
add a second admin, or establish a clear "who actually makes dashboard
changes" process) rather than let a blocked PR quietly stay blocked with
an unstated reason.

## A standing "propagate every fix upstream" rule quietly removes a decision from the human who should be making it

**Writing "if you find a reusable fix, propagate it upstream immediately"
into a Definition of Done reads as good practice, and produces good
individual fixes, but it also permanently pre-decides, on the day it's
written, every future instance of a case-by-case judgment call — whether
turning *this* unrelated task into kit-maintenance work, *right now*, is
actually the right use of the moment.** Real pattern, observed directly
across several consecutive releases of this kit: an agent working a
downstream project's own, unrelated task kept finding real bugs in this
kit, and the standing rule meant it branched, fixed, and opened a PR
against this kit's repository every single time, as an automatic
consequence — never as a decision anyone, human or agent, actually made
in that moment. Each individual fix was correct and verified; the
aggregate pattern was an agent unilaterally deciding, repeatedly, that
kit maintenance was the priority of the moment, on the owner's behalf,
because a rule several sessions ago said to.

**The fix isn't "stop finding or fixing bugs" — it's separating
"noticing" from "acting on it right now" into two different decisions,
made by two different parties.** Recording a finding costs almost
nothing and should still happen every time (`docs/KIT-ISSUES-LOG.md`,
see `AGENT_RULES.md`'s "Finding a bug in the governance kit itself").
Acting on it immediately, in the same session, is a materially bigger
decision — it changes what the session is actually doing — and this kit
now treats that as something only the relevant human (here, the kit's
own maintainer) gets to trigger, explicitly, each time, rather than
something a standing rule authorizes an agent to infer on its own,
however consistently good its past judgment on the question has been.
The general shape is worth watching for beyond this one rule: **any
standing instruction phrased as "always do X when Y happens" is worth a
second look for whether X is actually a small, safe default (fine to
leave standing) or a real judgment call being smuggled in as if it
were one (worth turning into "notice Y, then ask" instead).**

## A fast, cheap AI classifier does not solve "the agent forgot" — that's a different axis entirely

**A downstream project's owner asked, directly: does a fast/cheap
inference API solve the problem of an AI agent's decisions and findings
getting lost across sessions — regressions returning after already being
fixed, a worse option getting picked without anyone noticing, the same
argument happening again next context reset, a human trusting an
agent's call and later having nothing left to recover why.** Real,
sourced research (not assumption) found the answer is no, and named why
clearly: inference speed/cost and durable memory are orthogonal axes. A
model built to turn a state and a question into a fast, cheap, typed
answer has no more bearing on "what did we decide last week and why"
than a calculator does — it's a different kind of tool for a different
kind of problem, and being fast and cheap at the first kind says nothing
about the second. The real, independently-documented fix for that
problem is called an Architecture Decision Record (ADR) — a durable,
dated record of context, options weighed, the choice made, and the
consequences — and it predates the current AI-agent wave by years; what's
new in 2026 is that it's been explicitly repurposed as the standard
answer to AI agents' complete lack of institutional memory between
sessions.

**Worth naming as its own lesson: this kit already builds most of an ADR
practice, under different names, and had never noticed the connection
until asked directly.** `CHANGELOG.md`'s "why" sections, this file, and
`OPEN-RESEARCH-QUEUE.md`/`KIT-ISSUES-LOG.md`/`COLLABORATOR-LOG.md.template`
downstream are all, structurally, ADR-shaped: a dated record of what was
decided and why, meant to survive past the session that produced it. But
building the record is only half of what the real practice requires —
the other half, the one this kit had not made a real, checkable
requirement anywhere before this finding, is that the record has to
**actually get read back** at the start of a session, not just written
once and trusted to be remembered. A written instruction to "check this
first" is real, but it's still discipline, not a mechanism — the same
gap this kit has already named for other rules elsewhere in this file.

**Only partially fixed the same day this was found — stated honestly,
not oversold:** `verify-setup.sh.template` now mechanically counts and
surfaces unresolved `OPEN-RESEARCH-QUEUE.md` questions and un-actioned
`KIT-ISSUES-LOG.md` entries every time it actually runs (a warning, not
a gate — the point is visibility, not blocking). But what makes it run
at all is still `CLAUDE.md.template`'s own written instruction (step 2)
— there is no session-start hook, no tooling integration, nothing that
runs it without an agent choosing to. This closes half the original gap,
not all of it: an agent that *does* run `verify-setup.sh` can no longer
selectively check the hook but skip the decision-record files, or
misremember whether it looked; an agent that skips running the script
entirely is exactly as unprotected as before. Naming the actual boundary
of what got fixed is the same discipline this whole entry is about —
claiming "at every session start" here, when nothing enforces that
start, would have been the identical mistake in miniature.
