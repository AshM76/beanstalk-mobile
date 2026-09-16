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
- **Generated once** when the contest concludes, **stored on the contest**, and
  served read-only. Never regenerated per view (cost + determinism).

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
- **Privacy:** the group recap never calls a kid out for a *loss*. Names appear
  only for positive callouts, and only if we decide to (default: anonymize).

## 2. The generation call

- **Endpoint:** `POST /api/contests/:id/recap/generate` (admin/internal, or
  auto-fired from `concludeContest`). **Idempotent** — if a recap exists, return
  it; regenerate only with an explicit `force`.
- **Integration:** reuse `ai.js`'s Anthropic call + `aiUsageService` metering.
- **Structured output:** request the recap as JSON via `output_config.format`
  (a schema, below) so the app renders sections instead of parsing prose.
- **Prompt caching:** the system prompt (Cash voice + safety) and schema are
  stable → cache them; only the per-contest INPUT varies.
- **Model:** a **config knob** (`RECAP_MODEL`). The recap is one-shot per
  concluded contest, not latency-sensitive, and quality matters, so step up from
  the advisor's Haiku:
  - **`claude-sonnet-5`** — recommended default (strong narrative, mid cost).
  - `claude-haiku-4-5` — cheapest; matches the existing advisor if volume spikes.
  - `claude-opus-5` — premium, if we want the very best copy.
  Pick per budget; easy to change since it's one call.

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

- Store the recap JSON + `generated_at` + `model` **on the contest** (new field
  / small table). `concludeContest` fires generation once; failures are
  non-fatal (a contest can conclude without a recap and get one later).
- `GET /api/contests/:id/recap` returns the stored recap (404 until generated).

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

## Open questions

- **Auto vs. admin-triggered generation** — fire on conclude automatically, or
  let an admin review/regenerate first? (Lean: auto, with an admin `force`.)
- **Name positive callouts?** Default anonymize; opt-in to name the best trade?
- **Model + budget** — `claude-sonnet-5` default vs. Haiku for volume; confirm
  once we see contest cadence.
- **Personal recap timing** — generated with the group recap for everyone, or
  lazily per kid on first open? (Lazy is cheaper if few kids return.)
