# FileStore track

OpenRune-FileStore (dev.or2 filesystem, definition, filestore, tools, displee: the cache library and the packing tools,
cs2 packing among them): the fork AlexPerrin/OpenRune-FileStore of OpenRune/OpenRune-FileStore, clone
`~/src/OpenRune-FileStore` (remote `origin` = upstream, `fork` = the fork). The server consumes a published FileStore
version; a FileStore change is live once its gate passes at its head, and goes upstream as a PR after the user's yes.
`hd` is `python3 ~/osrs-harness/hd.py`; the track script is `tools/track.sh <verb> <slug>`; the evidence dir is `evidence/<slug>/`.
Upstream's own `tools/` Gradle module (`tools/build.gradle.kts`, `tools/src/`) shares the directory with these files on
the tools branch; a change edits that module on its dev ref like any other.

## Branches on the fork
`main` mirrors upstream. `dev/<slug>` is the dev's ref, the only one a dev pushes; the change's head is its tip.
`content/<slug>` and `fix/<slug>` are the public PR branches, moved only by the harness after the user's yes.
`local/harness` holds these tools.

## Rules for upstream (re-read AGENTS.md, CONTRIBUTING.md, the PR template, any CI workflow and the README on upstream
`main` every run; the contract records the blob shas of those that exist: upstream has none of the first four now)
- One change per PR, off current upstream `main`, never stacked. Check upstream first (gh pr list on
  OpenRune/OpenRune-FileStore with --search, and the issues). Theirs wins.
- The library is published (`buildNumber` in `build.gradle.kts`) and consumed by the server: a change keeps every existing
  public signature and file format working, unless the PR states the break and the server change it needs.
- A PR is ready only when every reported defect is fixed in it; nothing is promised for a later PR.
- Updates are new commits on the PR branch (merge `main` in, never force-push); the description is never replaced.
- Subjects `feat:`/`fix:`. No new KDoc or explanatory comments; nothing public for a test.
- Upstream texts never link a fork PR; never open a PR, issue or comment on the fork.

## The dev
Your clone `~/src/OpenRune-FileStore/.worktrees/<slug>` on `dev/<slug>`. Commit; `tools/track.sh build <slug>` assembles
every module of T in the build copy (JDK 17, the wrapper's Gradle); `tools/track.sh log <slug> <pattern>` reads its log.
The track brings nothing up: a row proves the change through its build and its unit tests; a proof in game is the row of
the server change that uses it.
Write `pr-title.txt`, `pr-body.md`, `pr-comment.md` (names the head). Push `dev/<slug>` to `fork`, then `hd handover
<slug>`. `hd ask <slug> "..."` when a decision is not yours; `hd show <slug>` first, always.

## The reviewer
Never writes the code it checks. Judges every contract row from the gated build and the diff; a text-only failure is
fixed in the evidence dir and the row marked pass.

## Never
Push any ref but yours; open or edit PRs; connect to Jagex; stop a process you did not start.

## Seed rows
Rows the contract starts from (a row tagged `upstream` judges the upstream PR and seeds only a change that opens one; `check:` rows run with SLUG, HEAD, T, TCOMMIT, BASE, CLONE, BUILD, EVIDENCE in the env).
- claims | every PR claim, file, test name and ticked box is true of the exact head | judge: pr-text
- no-deferral | no Not-done list, no unticked item, no open ask; every reported defect fixed in this PR | judge: pr-text | upstream
- net-change | on an existing PR, pr-comment.md covers only the commits since the PR's live head | judge: pr-text | upstream
- one-change | one feature, nothing unrelated, no open upstream PR for the same change, Depends stated | judge: pr-text | upstream
- compat | existing public signatures and file formats work as before, or the PR states the break and the server change it needs | judge: qa-server
- style | no added comments or KDoc, no unjustified test, nothing public for a test | judge: qa-server
- evidence | pr-title.txt, pr-body.md, pr-comment.md present and non-empty | check: tools/track.sh evidence
- subject | commit subjects after the base start with feat: or fix:; no Claude-Session trailer | check: tools/track.sh commits | upstream
- tests | every module's unit tests pass at T | gate: tools/track.sh tests
