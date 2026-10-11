# How we use Kit-GO (reference setup)

This is how the Kit's maintainer runs the Kit on one real project: one human owner
plus AI agents, building an internal web app on free tiers. It shows the Kit in use;
it is an example to adapt, not a prescription. Numbers are from one project and say
so where that matters.

## Works best with Claude

What is true:

- The Kit was built and tested with Claude Code. `CLAUDE.md` is auto-loaded at session
  start, so the very first response already knows the project's rules.
- The Kit-GO slash commands (`templates/commands/kit-go*.md.template`, installed as
  `.claude/commands/`) are Claude Code commands. They are thin wrappers over a
  playbook and a read-only script.
- Speed mode (see below) relies on subagents and git worktrees for parallel work.
  Claude Code provides both.

What is not:

- Nothing here has been tested with another coding agent.
- The rules are plain files plus git and GitHub mechanisms (a pre-push hook, CI, a
  governance gate), so another agent can follow them. Expect to wire its
  context-loading yourself. SETUP-GUIDE.md has the scenario:
  [A different primary AI coding agent](./SETUP-GUIDE.md#a-different-primary-ai-coding-agent-not-claude-code).

## What you need

- git (2.28 or newer to run the Kit's own tests; 2.34 or newer plus OpenSSH 8.1 or newer
  to verify a signed release, see [PROVENANCE.md](./PROVENANCE.md)).
- bash 3.2 or newer. On Windows, Git Bash.
- A GitHub account and the `gh` CLI, logged in as a real person (an agent cannot
  complete that login for you).
- Claude Code, for the best experience (see above).
- Free tier is enough. On a private repo on GitHub's free plan, branch protection is
  not available (LESSONS-LEARNED.md, "GitHub / Git"). The pre-push hook and the
  governance-gate workflow are the compensation, not the same thing.
- On Windows, a freshly installed CLI is not found by an already-open terminal; quit
  and relaunch the terminal (LESSONS-LEARNED.md, "Windows-specific").

## Our setup, in one paragraph and a short list

An internal company-management web app (team, clients, projects, tasks, time),
installable as a PWA. One human owner, several AI agents working at once, one private
repo.

- Stack: Next.js and TypeScript, Supabase (database, auth, storage), Vercel. All on
  free tiers, zero recurring cost.
- GitHub free plan, private repo: no branch protection. `.githooks/pre-push` and the
  governance-gate workflow stand in. The owner merges every Tier 2 change.
- Windows 11, Git Bash and PowerShell.
- CI also runs a keep-alive ping, an hourly health check, a weekly orphan-file sweep
  and a weekly encrypted backup.
- Model classes by role. Example as of 2026-10 only; the Kit never hardcodes names
  (see `templates/MODEL-UTILIZATION-PLAYBOOK.md.template`):

| Role | Class | Example |
|---|---|---|
| Lead / integrator | session default | Sonnet 5.5 |
| Builders (parallel) | mid-tier | Sonnet |
| Security review of backend changes | strongest, fresh context | Opus 5 |
| Review of routine code | fresh mid-tier | Sonnet |
| Mechanical checks | scripts first, cheapest for triage | Haiku |

Cap: no more than about 2 top-class agents at once, because usage limits are real.

## The loop

The same sequence for every change. Speed mode adds the parallelism; the review depth
never drops. Templates: `templates/SPEED-MODE.md.template`,
`templates/AGENT-LEDGER.md.template`, `templates/SPEED-MODE-METRICS.md.template`.

1. Plan first. For parallel work, write a lane plan before any agent starts: disjoint
   file sets, order, risk class, review type, and what the owner must approve or supply.
2. A cheap read-only planner agent stays ahead and keeps the next lane's specs ready.
3. Each builder gets its own git worktree and branch, cut from a freshly fetched
   `origin/main`. One writer per file set. Migrations, generated types and the shared
   docs belong to the lead.
4. Builders commit `wip: ...` after every logical step and push their own branch only.
   Never `main`, never a merge, never a force-push.
5. Risk class comes from paths touched, never self-declared. Backend, auth, CI, hooks,
   scripts and governance files are Full (Tier 2). The highest class governs the PR.
6. Review is independent and fresh: a different context that sees the diff and the claim,
   not the author's reasoning. It must verify for real. Access rules get a live
   access-matrix harness run, and the reviewer must add cases of its own.
7. A drafted migration gets a static review BEFORE it is applied to the live database.
8. CI runs. Type, lint and build gates must be green before a reviewer is asked.
9. The human merges every Tier 2 PR and signs releases. The agent hands over the
   ready-to-run command and stops.
10. At each merge the records are updated: the progress checkpoint, one metrics row, the
    agent ledger, and the dated collaborator-log entry.

If a usage limit hits: finish the in-flight change to a safe state and pause. A required
review is never skipped to save budget. Resume the same agent by id, or relaunch from
the branch's pushed commits.

## What it produced

Measured, one project, from git and the project's own metrics file:

- 80 merged PRs and 2 closed unmerged, 2026-09-22 to 2026-10-11 (from `gh`).
- Before speed mode, 8 PRs (#17 to #24, all fully careful) had 5 blocking findings caught
  before merge. Per-review cost then: about 50k to 90k subagent tokens, 1 to 4 minutes.
- In speed mode, 6 PRs in the recorded rows had a pre-merge finding in the "blocking"
  column. Kinds: a proxy redirect that broke the PWA files, an id-namespace hole in a
  drafted migration, a concurrency race in a last-admin guard, a breaking change after a
  rebase, defects in a test harness found by static review, and a diagnostic that printed
  part of a password.
- Escaped blockers (found after merge): 0 recorded.
- Usage-limit interruptions: 3 recorded. One cut off a reviewer and left 10 orphan test
  users, cleaned afterwards. Two cut off builders and cost nothing, because their work
  was already pushed as WIP commits.
- Live access checks: 184 in the harness and 78 unit tests, as of 2026-10-11.
- A restore drill of the weekly backup passed on 2026-10-11 (all 27 tables matched).

Honest limits:

- One project, a small sample, mostly one subsystem. Averages are anecdotal.
- Wall-clock speedup was NOT measured against a baseline. Only per-review cost and
  counts were recorded. Do not read this as a measured speedup claim.
- The "any secret appears in a prompt, log or checkpoint" revert condition was arguably
  triggered once: the owner pasted a database password into chat (rotated at once).
  The clause is now worded to separate long-lived or broad secrets from deliberate,
  scoped, short-lived tokens that are tracked and revoked.
- The backup's storage-restore path was not exercised end to end (no real attachments yet).

## What went wrong and what we changed

- A stacked PR's base branch was deleted at merge and GitHub auto-closed the PR (#30,
  rebuilt as #31). Now: merge without deleting the base, retarget first.
- A rebase needed a force-push the agent may not do. Now: push a new `-v2` branch name.
- Agents sharing one checkout switched branches under each other. Now: a worktree for
  every agent, and cd to the canonical path first (drive-letter casing broke isolation
  three times).
- A secret was pasted into chat. Now: rotate at once, and prefer flows where the secret
  never transits chat (`gh secret set` from stdin, or a lead-run API call).
- A size check on the backup missed a bad dump (`pg_dump -t` had limited it to one
  table). Now: the gate checks dump content, not size.
- A masked secret leaked a fragment through a failure diagnostic. Now: failure paths
  print a redacted shape, never a fragment.
- A cached pooler credential cost about 2 hours of loops. Now: check pooler state early.

## Start in five steps

1. Read [README.md](./README.md), then [LESSONS-LEARNED.md](./LESSONS-LEARNED.md).
2. Run the discovery pass first (SETUP-GUIDE.md section 0), then copy the templates
   (section 1) and fill the placeholders (section 2).
3. Set up the model playbook (section 6) with the models you actually have.
4. Verify it works for real, not just configured (section 9). In Claude Code run
   `Kit-GO`, `Kit-GO help`, then `Kit-GO guide me`.
5. Optional, once the basics hold: adopt speed mode using the speed-mode templates.

## Where this applies and where it does not

This is one internal web app with one owner. The pieces most likely to carry over are
path-based risk classes, fresh independent review, WIP-push resumability and the records.
A team of many humans, a regulated product or a non-GitHub host needs the other
scenarios in SETUP-GUIDE.md. Treat every number above as one data point.
