# Direct-push-to-protected-branch override log

Every real use of `ALLOW_DIRECT_MAIN_PUSH="<reason>"` (see `.githooks/pre-push`)
appends a row here automatically. This file exists so an override has a
durable, diffable record beyond one shell's scrollback -- the hook
appends to your working tree during the push that used the override, so
the entry can only be committed and pushed afterward, in your *next*
push, not the one that triggered it (a real inconsistency between this
header and the hook's own comments, found by an adversarial review pass,
2026-09-22 -- the hook's comments already said "next push" correctly).

No entries yet.
