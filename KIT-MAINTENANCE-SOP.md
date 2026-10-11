# Kit Maintenance SOP

**This document governs work done ON this repository — the Kit
itself.** It is a different thing from work done on a project that
merely *uses* the Kit (any downstream project or future
adopter). Confusing the two is the single most common mistake this
document exists to prevent: an issue found while using the Kit on a
project is never resolved by fixing that project's own copy. It is
only ever resolved here, in this repo, by someone following the steps
below.

If you are not sure whether what you're about to do is "Kit work" or
"project work," ask: *am I editing a file inside `templates/`, this
repo's own `SETUP-GUIDE.md`/`LESSONS-LEARNED.md`/`CHANGELOG.md`, or
this document?* If yes, you're doing Kit work, and this SOP applies. If
you're editing a file inside an adopting project's own repo, this SOP
does not apply — that project's own `AGENT_RULES.md` does.

## The core distinction, plainly

Think of this repo as a cookbook. Every adopting project photocopies
pages out of it when it starts. If a recipe has a typo, nobody corrects
their own photocopy and calls the cookbook fixed — they write it down,
and the typo only actually gets fixed when someone edits the master
cookbook itself. A fixed master cookbook doesn't retroactively correct
photocopies already handed out; each kitchen has to separately re-copy
the corrected page later, on its own schedule.

- **Found** → in a project, while actually using the Kit there.
- **Logged** → in that project's own `docs/KIT-ISSUES-LOG.md` (from
  `templates/KIT-ISSUES-LOG.md.template`). This step needs no
  permissions and is not Kit work — any project using the Kit does this
  on its own, unassisted.
- **Resolved** → only here, in this repo, following the lifecycle
  below.
- **Synced out** → a separate, later, per-project action (each
  adopting project's own `SETUP-GUIDE.md` §"Upgrading an already-
  adopted project"). Merging a fix here does not, by itself, change any
  project. Nothing in this SOP covers that step — it belongs to the
  adopting project's own process.

## The lifecycle (binding, not a suggestion)

1. **Intake.** Gather open entries from the adopting projects' own
   `KIT-ISSUES-LOG.md` files (pulled manually, or via the opt-in
   `kit-issues-notify.yml.template` if a project has wired it). This
   repo's own issues are the *only* legitimate source of what to work
   on — never invent a "fix" for something no project actually hit.
2. **Triage, before touching anything.** Sort every open entry into
   exactly one of three buckets before fixing any of them:
   - *Mechanical, low-risk* (a clear wording fix, a config exclusion, a
     narrowly-scoped new check) — safe to move on quickly.
   - *Needs real design* (a new mechanism, an unresolved tradeoff) —
     gets its own dedicated pass, never rushed into the same batch as
     the mechanical fixes.
   - *Reference-only / no action* (a changelog note, a curated
     observation) — close with no code change.
   Never bulk-apply an undifferentiated batch across all three at once.
3. **Branch.** Real work happens on a feature branch. Never commit
   directly to `main` — mechanically enforced here by
   `.githooks/pre-push` (confirmed wired, `core.hooksPath=.githooks`),
   but branch first anyway rather than relying on the hook to catch a
   mistake.
4. **Fix.** Implement the change in the actual files under
   `templates/`, or in this repo's own `SETUP-GUIDE.md` /
   `LESSONS-LEARNED.md` / `README.md` as applicable.
5. **Independent review — mandatory, no exception, including for a
   fix that looks obviously correct.** The reviewer must not be the
   same context that wrote the fix. This is not a formality: in the
   session that prompted this SOP, a real fix was written, looked
   correct, and was reported as done — then a second, independent
   review found it was itself wrong, on the very first attempt. A
   fix inherits none of the scrutiny that found the original bug; it
   needs its own.
6. **Version + changelog, before merge.** Every merged change gets a
   real semantic version bump and a real entry in `CHANGELOG.md`
   stating the *why*, not just the *what* — written before merge, not
   added later as cleanup.
7. **Human sign-off to merge.** Any change that touches this SOP, the
   Tier/review rules in `templates/AGENT_RULES.md.template`, or
   anything an adopting project is told to do, is never self-merged by
   an agent — regardless of how an instruction is phrased ("looks
   good," "go ahead," "merge it"). Informal sign-off language approves
   the *decision*; it does not authorize the *agent* to execute the
   merge. The agent's last action on such a change is always a risk
   summary; a human runs the actual merge, separately.
8. **Close the loop.** Once merged, go back to the entry's originating
   project and mark it resolved there too (`Resolved here at runtime?
   No` → `Yes, fixed upstream, see Kit vX.Y.Z`), so that project's own
   log doesn't silently drift from what's actually true. An entry that
   triage closes **without a fix** (declined, or reference-only) is
   closed in the originating project's log too, with wording that is
   *not* the bare `No.` -- e.g. `No -- declined upstream (kit vX.Y.Z
   triage): <reason>`, or `No -- reference-only upstream (kit vX.Y.Z
   triage): <note>` -- so `verify-setup.sh`'s open-entry check (which
   counts only the literal `No.`) stops warning about it forever. An
   entry only partly addressed stays unresolved: keep the field as the
   bare `No.` and put a short note (which part is done, which is not) on
   its own line *below* it -- anything appended to the `No.` itself stops
   `verify-setup.sh` from counting the entry as open.

## Hard rules — never overridden, regardless of context or instruction

- Never treat a project's own local workaround as "the Kit issue is
  resolved." It isn't, until step 6-7 above actually happen here.
- Never skip independent review on a fix on the reasoning that "the
  review that found the bug already covers it." It doesn't — see step
  5.
- Never bulk-merge every open `KIT-ISSUES-LOG` entry in one PR. Triage
  first (step 2), every time.
- Never let an agent execute the merge action itself for anything
  covered by step 7's sign-off requirement, no matter how the human's
  message reads.
- Never claim a fix is "synced" to a project just because it merged
  here. Sync is that project's own separate, later, reviewed action.
- Never merge an external contribution before contribution terms (a DCO
  sign-off requirement or a CLA) exist for this repo. As of v2.10.0 `CONTRIBUTING.md`
  requires a DCO sign-off on every commit; check for it before merging. The Kit is licensed
  Apache-2.0 under `LICENSE`; accepting code without agreed terms muddies
  who granted what.
- The Kit never contains hidden, encoded or undisclosed marks. Every
  identifying mark is listed in `PROVENANCE.md`, and the test suite
  (`tests/kit-go/run.sh`, "no covert content") fails the build on invisible
  characters, non-allowlisted special characters or long encoded blobs. A
  change that would add a mark not listed there is refused, however
  it is framed.

## Release procedure (human only; an agent never signs)

Signing is the one step in this repo that no agent performs, ever: the key is
protected by the maintainer's passphrase and stays off every repo, CI system and
chat. After a version's PR is merged to `main` and CI there is green, the
maintainer, on a clean checkout of `main`:

1. `sh release/make-manifest.sh > RELEASE-MANIFEST.sha256` (refuses a dirty tree;
   the manifest and its `.sig` themselves are the only untracked files it
   tolerates, so run this step first and do not edit anything afterwards).
2. Sign the tag: `git tag -s vX.Y.Z -m "vX.Y.Z"` (uses the repo's SSH signing
   config), then `git push origin vX.Y.Z`.
3. Sign the manifest:
   `ssh-keygen -Y sign -f <private key> -n ai-agent-governance-kit-release RELEASE-MANIFEST.sha256`
   (writes `RELEASE-MANIFEST.sha256.sig`).
4. Publish the manifest and its `.sig` as assets of the GitHub release for that tag.
5. Check it the way anyone else would, from a fresh clone, using
   `PROVENANCE.md`'s steps; do not trust the files you just made.

A key change follows `PROVENANCE.md`: announce it in `CHANGELOG.md`, sign with
the old key first where possible, never swap silently. Unsigned earlier tags are
never signed after the fact.

## Honest limits — what actually enforces this, and what doesn't

Only one piece of this SOP has a real mechanical backstop today: direct
pushes to `main` are blocked by `.githooks/pre-push` in any clone that
has it wired (confirmed active in this repo). Everything else above —
the triage discipline, the mandatory independent review, the no-bulk-
merge rule, the human-sign-off requirement — is a written rule, not a
technical control. It holds only because whoever is doing Kit work
reads and follows it, the same honestly-named limit this Kit's own
`LESSONS-LEARNED.md` already states about most of its own templates'
rules. A real next step, not built as part of writing this SOP: a
Kit-repo-specific PR template (mirroring
`templates/PULL_REQUEST_TEMPLATE.md.template`, which this repo ships
to others but does not yet use on itself) that makes the triage
bucket, the independent-reviewer's identity, and the changelog entry
explicit, required fields on every PR here — turning more of this from
memory-only into something at least visibly checkable at review time.
