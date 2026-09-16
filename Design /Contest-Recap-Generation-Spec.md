# Spec: Cash-Narrated Contest Recap (generation pipeline)

> Status: **Scoping** — design for the next milestone in
> `Contest-Recap-AI-Plan.md`. The benchmark layer (five ghost players) is
> built; this spec is how we turn a **concluded contest** into a Cash-narrated
> recap. Horizon: **Short (< 4 months)**.

## Context

We now have, per concluded contest: every contestant's **trades**, their
**per-contest portfolios**, the **final leaderboard**, and the **ghost
benchmark curves** (Sammy P., Downey Jones, Nadia Q., Rusty, Piggy). This spec
assembles that into a story: *what worked, what didn't, and did anyone beat the
market or the piggy bank* — narrated by Cash, positive and age-appropriate.

**Reuse, don't reinvent.** The app already calls Claude for the Cash advisor:
`beanstalk-api/src/routes/ai.js` posts to the Anthropic Messages API
(`ANTHROPIC_API_KEY`, model `claude-haiku-4-5-20251001`) and meters usage via
`aiUsageService`. The recap generator uses the **same** integration and
metering — it's a new prompt + a new endpoint, not new infrastructure.

## What the recap is

- **Group-first**, one per contest: headline, a few highlights (best trade,
  biggest swing, standout sector), how the market moved during the window, the
  **benchmark scoreboard** (who beat Sammy P.? did anyone beat Piggy?), and one
  or two takeaways.
- **Optional personal mini-recap** per kid: short, private, encouraging.
- **Generated on an admin's action, reviewed, then published** — not served to
  kids until an admin approves it (see *Trigger & review* below). Generated
  once and **stored on the contest**; never regenerated per view.

### Decisions (locked)

- **Trigger:** **admin-reviewed** — an admin generates the recap for a
  concluded contest, reads it, and publishes it; kids see it only once
  published. (Not auto-on-conclude — a human eyeballs tone/content first.)
- **Positive callouts are named:** highlights credit the kid by **display
  name** for *good* moments only (best trade, biggest gain, winner) — **never**
  for a loss, and losses are never pinned to a name.
- **Model:** `claude-sonnet-5` (config knob `RECAP_MODEL`, changeable).

## Architecture

```
concludeContest()  ──►  build recap INPUT (deterministic, no AI)
                         · trades + portfolios + leaderboard + benchmark curves
                         · summarized into a compact, structured payload
                              │
                              ▼
                        Claude (Messages API, reused ai integration)
                         · system prompt = Cash voice + safety rules
                         · structured output → recap JSON
                              │
                              ▼
                        store recap JSON on the contest (generated once)
                              │
                              ▼
        GET /api/contests/:id/recap   ──►  mobile "Recap" screen (Cash reads it)
```

The **input assembly is pure code** (no AI) — it does the math and picks the
facts, so the model only *narrates* verified numbers and can't invent figures.

## 1. Recap INPUT (the data contract handed to Claude)

Assembled server-side from data we already have. Compact and pre-computed so the
model narrates, not calculates:

```jsonc
{
  "contest": { "name", "days", "start", "end", "starting_balance", "player_count" },
  "market_context": {                    // from the ghost curves
    "benchmarks": [ { "name": "Sammy P.", "label": "S&P 500", "return_percent": 6.2 }, … ],
    "best_benchmark": "Nadia Q.", "savings_return_percent": 0.9
  },
  "field": {                             // aggregate, no names singled out negatively
    "median_return_percent": 3.1,
    "share_that_beat_sammy_p": 0.41,     // active-vs-passive, the headline stat
    "share_that_beat_piggy": 0.78
  },
  "highlights": {
    "best_trade": { "symbol", "return_percent", "held_days" },   // anonymized or opt-in named
    "biggest_swing": { "symbol", "swing_percent" },
    "top_sectors": [ { "sector", "avg_return_percent" }, … ],    // from asset_class tags
    "most_popular_symbols": [ "AAPL", "NVDA", … ]
  },
  "winner": { "return_percent", "beat_sammy_p": true },          // rank #1, framed positively
  "personal": {                          // only when generating a personal mini-recap
    "return_percent", "beat_sammy_p", "beat_piggy",
    "best_trade": { "symbol", "return_percent" },
    "lessons_hook": "held through a dip and it recovered"
  }
}
```

Notes:
- **Sectors/strategy** start from the existing `asset_class` tags (migration
  008); richer sector tagging is a later enhancement.
- **Privacy:** the group recap **never** calls a kid out for a *loss*. Positive
  callouts (best trade, biggest gain, winner) **are named** by display name —
  the INPUT carries the name only on those positive fields; loss/negative fields
  stay aggregate and anonymous.

## 2. The generation call

- **Trigger & review (admin-reviewed):**
  - `POST /api/contests/:id/recap/generate` (admin only) generates the recap and
    stores it as **`draft`** (idempotent — returns the existing one unless
    `force`). This is where the admin reads it.
  - `POST /api/contests/:id/recap/publish` (admin only) flips it to
    **`published`**.
  - The public `GET /api/contests/:id/recap` returns a recap **only when
    published** (404 otherwise), so kids never see an unreviewed draft.
- **Integration:** reuse `ai.js`'s Anthropic call + `aiUsageService` metering.
- **Structured output:** request the recap as JSON via `output_config.format`
  (a schema, below) so the app renders sections instead of parsing prose.
- **Prompt caching:** the system prompt (Cash voice + safety) and schema are
  stable → cache them; only the per-contest INPUT varies.
- **Model:** `claude-sonnet-5` — strong narrative at mid cost, right for a
  one-shot, quality-sensitive recap. Kept behind a `RECAP_MODEL` config knob so
  it's a one-line change to `claude-haiku-4-5` (cheapest, matches the advisor)
  or `claude-opus-5` (premium) if budget/volume warrants.

### Recap OUTPUT schema (what the app renders)

```jsonc
{
  "headline": "The market had a wild month — and a few of you rode it well!",
  "market_recap": "…what the indices did, in Cash's voice…",
  "highlights": [ { "emoji": "🚀", "title": "…", "body": "…" }, … ],
  "benchmark_scoreboard": {              // pulled straight from INPUT, not invented
    "line": "41% of you beat Sammy P., and 78% beat Piggy!",
    "beat_market_share": 0.41, "beat_savings_share": 0.78
  },
  "lessons": [ "…one or two positive, growth-framed takeaways…" ],
  "cash_signoff": "…encouraging close…"
}
```

Every number in the output must come from the INPUT (the prompt instructs the
model to use only provided figures). A light server-side check can reject a
recap whose scoreboard shares don't match the INPUT before storing it.

## 3. Storage & serving

- Store the recap JSON + `status` (`draft` | `published`) + `generated_at` +
  `published_at` + `model` **on the contest** (new field / small table).
  Generation is admin-triggered (not auto on conclude); a contest can sit
  concluded-without-a-recap indefinitely.
- `GET /api/contests/:id/recap` returns the recap **only when `published`**
  (404 otherwise). Admins read the `draft` via the generate response / an admin
  view before publishing.

## 4. Mobile rendering

- A **Recap** entry on a concluded contest (a tab or a card on Details) — Cash
  presents the story: headline, market recap, highlight cards, the benchmark
  scoreboard (great spot to reuse the ghost colors/avatars), lessons, sign-off.
- The **personal mini-recap** shows for a kid who was in the contest.
- Reuses the existing Cash art + bubble components.

## Cost & safety guardrails

- **Generate once, cache, store** — never per view. One low-volume call per
  concluded contest.
- **Kid-safe tone** enforced in the system prompt: encouraging, never shaming,
  never singling a kid out for a loss, age-appropriate.
- **Not investment advice** — teach concepts and what *happened*; no
  forward-looking picks or predictions. Especially for the active-vs-passive
  line: report the result, don't advise.
- **No invented numbers** — model narrates the INPUT only; server sanity-checks
  the key figures before storing.
- **Small-sample honesty** — for a tiny or very short contest, the prompt says
  "still early!" rather than over-claiming a trend.

## Phases / first concrete steps

1. **INPUT builder** (pure code): from a concluded contest, assemble the INPUT
   payload above. Unit-testable with no AI. *This is the first PR.*
2. **Generator**: wire the reused Anthropic call + structured output + the Cash
   system prompt; store the recap on the contest; `GET …/recap`. Fire it from
   `concludeContest` (idempotent).
3. **Mobile Recap screen**: render the group recap; reuse ghost colors for the
   scoreboard.
4. **Personal mini-recap**: add the `personal` INPUT branch + a per-kid view.
5. Later: richer sector tagging, cross-contest history, the active-vs-passive
   scorecard (its own plan-doc line).

## Resolved

- **Trigger:** admin-reviewed — generate → review → publish. ✅
- **Callouts:** positive callouts named by display name; losses stay
  aggregate/anonymous. ✅
- **Model:** `claude-sonnet-5` (behind `RECAP_MODEL`). ✅

## Open questions

- **Personal recap timing** — generate the personal mini-recap for everyone
  alongside the group recap, or lazily per kid on first open? (Lazy is cheaper
  if few kids return; but with admin review, eager keeps everything reviewable
  in one pass. Lean: eager, generated + reviewed with the group recap.)
- **Admin review surface** — reuse the web contest-manager (a "Recap" panel with
  Generate / Preview / Publish), or a lighter internal view first?
