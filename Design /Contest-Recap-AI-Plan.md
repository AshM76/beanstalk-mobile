# Plan: AI Contest Recap & Cross-Contest Learning for Beanstalk

> Status: **Vision / backlog** — not yet scheduled. This captures the goal and a
> phased roadmap so we can build toward it deliberately. Horizons are tagged
> **Short (< 4 months) · Mid (4–12 months) · Long (12+ months)**.

## Context & Goal

Today a contest ends with a leaderboard and a winner. That tells kids *who* won,
not *why* — and the "why" is where the learning is.

The goal is to use AI to **investigate the results of a finished contest and tell
the story of what worked and what didn't**, so every contest becomes a learning
opportunity for everyone who played in it — not just the winners.

We already have visibility into every trade each contestant made (buys, sells,
timing, symbols, prices — see *Data we already have* below), so we can
reconstruct the full arc of a contest and narrate it.

**Guiding principles**
- **Cash is the narrator and educator.** The recap is told in Cash's voice —
  friendly, curious, and teaching as it goes (reusing the existing Cash advisor
  tone and infrastructure).
- **Positive and growth-framed.** Err on the side of opportunity and learning,
  never harshness. We highlight what *worked* and reframe what didn't as "here's
  what the market was doing / here's an idea to try next time" — we do **not**
  single kids out for "mistakes."
- **Group-first, personal-optional.** The main recap is about *the contest* (best
  trades, biggest swings, standout sectors) without calling individuals out. Each
  kid can *also* open a short, private, encouraging recap of *their own* contest.
- **Learn the meta-lesson over time.** The deepest goal is longitudinal: across
  many contests and months/years, kids should internalize that **the same
  strategy doesn't always win** — winning sectors, strategies, and investments
  *move*, because markets are variable and cyclical.
- **Ground it against "just leaving it alone."** Compare active trading to simply
  parking money in broad indices/ETFs (and even a savings account). Honestly ask:
  was moving money around actually better than buy-and-hold?

## Learning outcomes we want a kid to walk away with

1. **Short term:** what happened in *this* contest — which trades/strategies paid
   off, which sectors ran, what the market did during the window.
2. **Variability & cycles:** the winning approach changes contest to contest;
   there's no single "cheat code."
3. **Active vs. passive:** a grounded, data-backed sense of whether frequent
   trading beat simply holding an index — most of the time, for most people.
4. **Compounding perspective:** as their contest history grows, a broader view of
   what has and hasn't worked across months and years.

## Ghost Benchmark Players

To make "what if you'd just left the money alone?" concrete and *visible*, each
contest runs alongside a set of **ghost players** — synthetic participants who
buy-and-hold a benchmark for the contest's date window, starting from the same
starting balance. They appear right on the leaderboard so kids can see, live,
whether they're beating "the market."

| Ghost Player   | Tracks                                   | Teaches                          |
| -------------- | ---------------------------------------- | -------------------------------- |
| **Downey Jones** | Dow Jones Industrial Average (30 big, established companies) | blue-chip / "steady giants"      |
| **Sammy P.**     | S&P 500 (the 500 largest US companies)   | "the whole market" default        |
| **Nadia Q.**     | NASDAQ-100 (tech-heavy)                  | growth & tech swings              |
| **Rusty**        | Russell 2000 (small companies)           | small-cap risk & reward           |
| **Piggy**        | Money left in a savings account          | the "do nothing" baseline         |

*Names are placeholders and easy to change.* **Piggy** is the quietly important
one: it frames whether *any* investing beat doing nothing, and anchors the
active-vs-passive lesson.

Implementation sketch: represent each ghost as a read-only contest participant
whose portfolio value at time *t* = `starting_balance × (benchmark_tᵗ /
benchmark_t₀)` (Piggy uses a flat/near-flat savings rate). No trades, just a
priced curve over the contest window. Requires a benchmark price history feed
(index ETFs `DIA` / `SPY` / `QQQ` / `IWM` are trackable via the existing
Alpaca quote service; store daily closes over the window).

## The Active-vs-Passive Scorecard

Across a kid's contest history, keep a running tally: **how often did their active
trading beat the benchmarks (and Piggy)?** This is the single strongest
long-term metric — it turns the abstract "buy-and-hold usually wins" lesson into
*their own* track record, and it's a great hook to bring them back after each
contest.

## Phased Roadmap

### Short (< 4 months) — Per-contest recap
- **Cash's Contest Recap**: an AI-generated, group-level story of a *finished*
  contest — best trades, biggest swings, standout sectors, what the market did
  during the window, and a takeaway or two. Positive, teaching tone.
- **Personal mini-recap**: a short, private, encouraging summary of *your* contest
  (what you did well, one idea to explore next time).
- **Ghost benchmarks on the leaderboard** (at least Sammy P. + Piggy to start):
  show whether players beat "the market" and beat "doing nothing."
- Reachable from a contest you were in, so you can go back and learn from it.

### Mid (4–12 months) — Benchmarks & the scorecard
- **Full ghost roster** (all five) on every contest, live during the contest, not
  just at the end.
- **Active-vs-passive scorecard** per kid across their contests.
- **Sector/strategy tagging** of trades so recaps can say "energy ran this month"
  or "the winners leaned into small caps," and start to compare across contests.
- Begin storing per-contest **market-context snapshots** (what the indices did)
  for later longitudinal comparison.

### Long (12+ months) — Cross-contest, longitudinal learning
- **Cross-contest story**: as a kid accumulates contests across months/years,
  Cash shows how the *winning* strategies, sectors, and investments **moved** —
  reinforcing variability and market cycles.
- **Cohort & seasonal patterns**: what tended to work in different market regimes
  (with heavy care to teach *variability*, never to imply a repeatable formula).
- **The big honest answer, over time**: across many contests, did actively moving
  money around beat simply holding an index? Show the evidence.

## Data we already have vs. what we'd need

**Already have (server-side):**
- Every contestant's **trades** — buy/sell, symbol, quantity, price, timestamp —
  tied to their **per-contest portfolio** (`contest_participant.portfolio_snapshot_id`
  → the contest portfolio and its transaction history).
- **Positions** with purchase price, current price, and unrealized gain/loss.
- **Leaderboard** computation (portfolio value over the contest, per age group).
- An **AI advisor pipeline** already in the app (Cash), which the recap generator
  can reuse rather than building from scratch.
- **Asset-class tags** on positions (migration 008) — a starting point for
  sector/strategy analysis.

**Would need to add:**
- **Benchmark price history** for the ghost players over each contest's window
  (index ETF daily closes via the existing quote service; a savings-rate constant
  for Piggy).
- A **ghost-participant** concept in the contest/leaderboard model (read-only,
  priced curve, no trades).
- A **recap generation** step: assemble a contest's trade timeline + benchmark
  curves into a structured summary, then have Cash (an LLM) narrate it. Recaps
  should be generated once at contest conclusion and cached, not per view.
- **Cross-contest aggregation** per user (the scorecard + longitudinal history).
- **Sector/strategy classification** of holdings beyond the current asset-class tag.

## Open questions / things to get right
- **Tone & safety for kids:** recaps must stay encouraging and age-appropriate;
  never shame, never imply guaranteed outcomes, and frame everything as learning.
  Group recaps must not embarrass any individual.
- **Not investment advice:** especially for the active-vs-passive findings, be
  careful to teach *concepts and history*, not to make forward-looking
  recommendations.
- **Benchmark fairness:** align the ghost curves to each contest's exact start/end
  and starting balance so comparisons are apples-to-apples.
- **Cost & caching:** generate AI recaps once per concluded contest and store
  them; don't regenerate on every open.
- **Small-sample honesty:** early on, a kid has only one or two contests — the
  scorecard should say "still early!" rather than over-claim a trend.

## First concrete steps (when scheduled)
1. Confirm the backend exposes a **per-contest trade timeline** for a concluded
   contest (endpoint + shape).
2. Prototype **one ghost player** (Sammy P. / S&P 500) as a priced curve on a
   test contest's leaderboard — proves the benchmark data path end to end.
3. Draft the **recap data contract**: the structured summary (top trades, swings,
   sectors, benchmark deltas) that gets handed to Cash to narrate.
4. Generate a first **Cash group recap** from a real concluded contest and
   pressure-test the tone.
5. Add **Piggy** + the personal mini-recap; then expand the ghost roster and the
   scorecard.
