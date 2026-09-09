# CVGen

Local Ruby pipeline: Markdown + YAML profiles/themes → JSON → Typst → PDF.

## Requirements

- Ruby 3.4.6 (RVM ok)
- Bundler
- Typst CLI (`brew install typst`)

## Setup

```bash
cd /Users/uk/workspace/cvgen
bundle install
```

## Import Markdown + choose template

```bash
# copy any .md into content/ (validates front matter + basics)
bundle exec ruby bin/cv import ~/Desktop/my-cv.md
# or with custom name + interactive build:
bundle exec ruby bin/cv import ~/Desktop/my-cv.md --name my-cv --build
```

Interactive build (asks for content / profile / layout / theme):

```bash
bundle exec ruby bin/cv build
# or
make interactive
```

Non-interactive:

```bash
make cv PROFILE=lead LAYOUT=modern-stack THEME=modern-blue
bundle exec ruby bin/cv build -p lead -l modern-split -t modern-blue -c cv
bundle exec ruby bin/cv build -p lead --fit    # auto-shrink scale to fit max_pages
```

Output: `build/cv-<profile>-<content>.pdf` and `build/resume.json`.

## Adaptive sections

Layouts render a block **only if data exists** in MD/JSON:

- `# Summary` → optional prose
- skills / languages / experience / education → skipped when empty
- left column of `two-column` collapses if no skills/languages

Remove `# Summary` from MD → summary disappears; other blocks stay.

## Adaptive font scale

In `themes/*.yaml`:

```yaml
scale: 1.0   # 0.6 .. 1.4
```

Or at build time:

```bash
bundle exec ruby bin/cv build -p lead --scale 0.9
bundle exec ruby bin/cv build -p lead --fit   # lowers scale until pages ≤ profile.max_pages
```

## Templates (layouts)

| Layout | Theme | Description |
|--------|-------|-------------|
| `classic-sidebar` | `classic-sidebar` | Grey left sidebar (original lead look) |
| `timeline` | `timeline-navy` | Single column, navy timeline + skill badges |
| `sidebar-card` | `sidebar-card` | Dark sidebar card (avatar, quote, languages) |
| `creative-accent` | `creative-accent` | Cream page, blobs, serif name, terracotta |
| `creative-split` | `creative-split` | Dark sidebar + banner + about/experience |
| `elegant-bordered` | `elegant-bordered` | Gold frame, centered header, two columns |
| `modern-gradient` | `modern-gradient` | Purple/blue blobs, pills, projects |
| `portfolio-sidebar` | `portfolio-sidebar` | Main + right sidebar (skills/languages bars) |
| `two-column` | `default` | Simple two-column |
| `modern-stack` | `modern-blue` | Pills + timeline stack |
| `modern-split` | `modern-blue` | Experience full width, skills \| education |

```bash
make layouts
bundle exec ruby bin/cv build -p creative-split -c cv-junior
bundle exec ruby bin/cv build -p elegant-bordered -c cv-junior
bundle exec ruby bin/cv build -p modern-gradient -c cv-junior
bundle exec ruby bin/cv build -p portfolio-sidebar -c cv-junior
```

## Themes

- `default`, `modern-blue`, `classic-sidebar`
- `timeline-navy`, `sidebar-card`, `creative-accent`
- `creative-split`, `elegant-bordered`, `modern-gradient`, `portfolio-sidebar`

Edit YAML for fonts/sizes/colors — same files later for Rails UI.

## Profiles

Profiles choose **layout / theme / filters only** — never name, headline, or other CV text.
All display content comes from the attached Markdown.

```yaml
name: default
layout: modern-stack
theme: modern-blue
max_pages: 2
```

Optional filters: `include.skills`, `exclude`, `max_experience_items`.

## Content format

YAML front matter (`name`, `headline`, `email`, `phones`, `links`, `location`, `quote`, `slogan`, `role_label`) plus `#` sections:

- Summary / Quote (optional prose)
- Essential Skills / Additional Skills / Languages / Interests (bullets)
- Experience / Education / Projects (`##` org, `###` title, dates, URL, bullets)
