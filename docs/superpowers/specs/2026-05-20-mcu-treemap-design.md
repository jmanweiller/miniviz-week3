# Miniviz Week 3 — MCU Treemap Design Spec

**Date:** 2026-05-20
**Contest:** Fabric Community Miniviz May, Week 3 (treemap)
**Goal:** Build a contest-winning Power BI report using a single native treemap visual.

## Concept

**Title:** *What Matters Most at the Box Office: 17 Years of the MCU*

A single hero treemap showing every theatrical Marvel Cinematic Universe film, grouped by Phase, sized by worldwide box office, and colored by Rotten Tomatoes critic score. One tooltip page provides per-film depth.

The story: scale (what audiences spent) vs. quality (what critics scored). Color creates tension against size — some giant tiles glow red, some smaller tiles glow green.

## Scope

- **In:** Theatrical MCU films from Iron Man (2008) through the most recent release as of contest date (~35 films).
- **Out:** Disney+ series, Sony Spider-Man films, character-level breakdowns, multi-page reports.
- **Constraint:** Single native Power BI treemap (no Deneb, no custom visual). Secondary detail lives in a report-page tooltip only.

## Dataset

One row per film. CSV stored at `Data/mcu_films.csv`.

| Column | Type | Purpose |
|---|---|---|
| Title | text | Treemap tile label |
| Phase | text (e.g., "Phase 1") | Treemap group |
| ReleaseDate | date | Tooltip; secondary sort |
| WorldwideBoxOffice | currency (USD) | **Tile size** |
| Budget | currency (USD) | Tooltip |
| RTCriticScore | whole number (0–100) | **Tile color saturation** |
| RTAudienceScore | whole number (0–100) | Tooltip |
| Director | text | Tooltip |
| RuntimeMinutes | whole number | Tooltip |
| PosterUrl | text, data category = Image URL | Tooltip poster |

**Sources:** Wikipedia film pages, Box Office Mojo, Rotten Tomatoes. Data compiled into CSV; values frozen at build time.

**Posters:** Wikipedia thumbnail JPEGs, committed to a `posters/` folder in a public GitHub repo, referenced via `raw.githubusercontent.com` URLs. ~35 small files, contest/personal use.

## Visual configuration

**Native Power BI treemap field wells:**
- Group: `Phase`
- Details: `Title`
- Values: `WorldwideBoxOffice` (sum)
- Color saturation: `RTCriticScore` (average; one row per film, so average = value)

**Color saturation scale:** sequential, low = desaturated/muted red, high = saturated gold or green. Exact palette comes from the report theme (built separately).

## Page layout

Single 16:9 page.

- **Header (top, ~12% height):** Title (large, bold) and one-line subtitle explaining the encoding ("sized by worldwide gross, colored by critical reception").
- **Treemap (left, ~80% width, ~75% height):** the hero.
- **KPI strip (right, ~20% width):** three cards
  - Total worldwide gross across all films
  - Number of films
  - Average RT critic score
- **Color legend (bottom, full width, ~8% height):** horizontal gradient bar with "Rotten 0%" → "Fresh 100%" endpoints.

No slicers, no filters, no extra visuals. Focus on the treemap.

## Tooltip page

Custom report-page tooltip, ~320×420 px, bound to the treemap.

Layout (top to bottom):
- Poster image (native Image visual bound to `PosterUrl`), ~60% of tooltip height
- Film title (bold)
- "Phase X · YYYY" subline
- Divider
- Stats block (label-value pairs):
  - `$X.XXB` gross
  - `$XXXM` budget
  - `XX%` critics
  - `XX%` audience
  - `XXX min · Director Name`

## Theme considerations (handed off to separate Claude Design work)

- Treemap data colors: sequential scale, single hue or muted-to-vibrant. No diverging.
- Phase group header text must be legible against the darkest tile color.
- Tooltip page background should contrast with poster JPEGs (most have black borders).
- Card fonts should match the theme's heading typography.

## Project structure

```
miniviz-week3/
├── Data/
│   └── mcu_films.csv
├── docs/
│   └── superpowers/specs/2026-05-20-mcu-treemap-design.md
├── posters/                    (or in separate GitHub repo)
│   └── *.jpg
└── miniviz_week3.pbip          (built later)
```

## Success criteria

- Treemap renders cleanly with all ~35 films legible at typical viewing size.
- Color saturation visibly differentiates critical hits from misses.
- Tooltip page loads poster + stats on hover within ~1 second.
- Report passes a design review against the contest theme and miniviz spirit (one focused visual, strong story).
- No custom visuals, no Deneb, no R/Python — native treemap only.

## Out of scope (explicit YAGNI)

- Drill-through pages
- Bookmarks or navigation
- Mobile layout
- Animation / what-if parameters
- Disney+ series, Sony films, character data
- Multiple themes / dark-light toggle
