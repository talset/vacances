# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Travel planning documents for a South Korea trip (18 days, late September / early October). The primary document is `coree/planning.md` — a day-by-day itinerary with inline images. Supporting scripts handle image downloading and optimization.

## Scripts

### Add images from URLs

Paste a raw image URL into `coree/planning.md`, then run:

```bash
./update-images.sh --md coree/planning.md --dir coree/imgs
```

The script downloads the image into `coree/imgs/`, then replaces the bare URL in the markdown with `![alt](imgs/filename.jpg)`. Requires `curl`.

### Resize/optimize images

```bash
./resize-images.sh coree/imgs              # resize to max 600px wide, convert to JPEG
./resize-images.sh coree/imgs --dry-run    # preview without changes
./resize-images.sh coree/imgs --width 800 --quality 80
```

Originals are backed up to `coree/imgs/originals/` (git-ignored). Requires `imagemagick`.

## Export planning to other formats

Requires `pandoc` (and `texlive-xetex` for PDF):

```bash
# PDF
pandoc coree/planning.md -o coree/planning.pdf \
  --pdf-engine=xelatex -V geometry:margin=2cm -V fontsize=11pt \
  -V mainfont="DejaVu Sans" --toc --toc-depth=2 -V colorlinks=true

# DOCX
pandoc coree/planning.md -o coree/planning.docx --toc --toc-depth=2

# HTML
pandoc coree/planning.md -o coree/planning.html --standalone --toc --toc-depth=2 \
  --metadata title="Planning Corée du Sud – 18 jours"
```

PDF requires `xelatex` for Unicode/emoji support. Use `Noto Sans` if `DejaVu Sans` is unavailable.

## Skills (coree/ subdirectory)

Five travel-specific skills are registered under `coree/.claude/skills/` and available when working in that directory:

| Skill | When to use |
|---|---|
| `korean-transit-route` | Subway/bus/walking directions between two places in Korea (ODsay + Kakao geocoding) |
| `kakao-map` | Place search, address↔coordinates, car routing via Kakao |
| `ktx-booking` | Search, reserve, and cancel KTX/Korail train tickets |
| `express-bus-booking` | 고속버스 (KOBUS) timetable lookup and seat reservation |
| `flight-ticket-search` | Flight candidate search and price comparison via Google Flights |

Use these skills (via `/skill-name` or the Skill tool) instead of ad-hoc web searches when the user asks about getting around Korea or booking transport.

## Korean text in the planning

Whenever Korean characters (한글) appear in `coree/planning.md`, always pair them with a readable French or romanized equivalent. Format: `Nom lisible (한국어)` — never write Korean alone without context. This applies to all place names, station names, bus stops, dish names, etc.

Examples:
- ✅ `Terminal de bus de Sokcho (속초버스터미널)`
- ✅ `Ligne 4 (사호선)`
- ✅ `Sogong Park – entrée du parc (설악산소공원)`
- ❌ `속초버스터미널` alone with no French/romanized label

## Gitignore

`coree/imgs/originals/` and generated output files (`planning.docx`, `planning.md` at root if stale) are git-ignored. Check `.gitignore` before committing new files.
