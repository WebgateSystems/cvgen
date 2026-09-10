# CVGen

[![CI](https://img.shields.io/github/actions/workflow/status/WebgateSystems/cvgen/ci.yml?branch=main&event=push&label=CI)](https://github.com/WebgateSystems/cvgen/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-0.2.0-blue.svg)](https://github.com/WebgateSystems/cvgen)
[![Gem Version](https://img.shields.io/gem/v/cvgen.svg)](https://rubygems.org/gems/cvgen)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE)
[![Ruby](https://img.shields.io/badge/ruby-3.3%20%7C%203.4%20%7C%204.0-red.svg)](https://www.ruby-lang.org/)

Markdown + YAML profiles/themes → JSON → [Typst](https://typst.app/) → PDF.

Ruby library and CLI for CV-as-code. Designed to be reused from a Rails UX layer.

**Home:** [github.com/WebgateSystems/cvgen](https://github.com/WebgateSystems/cvgen)  
**License:** [GPL-3.0-or-later](./LICENSE)

## Requirements

- Ruby `>= 3.3` (CI: 3.3, 3.4, 4.0)
- Bundler
- Typst CLI (`brew install typst` or see [Typst releases](https://github.com/typst/typst/releases))

## Install as a gem

### From GitHub (recommended while unpublished)

```ruby
# Gemfile
gem "cvgen", github: "WebgateSystems/cvgen"
```

```bash
bundle install
```

### Path gem (local development)

```ruby
# Gemfile
gem "cvgen", path: "../cvgen"
```

### After publish to RubyGems

```ruby
gem "cvgen", "~> 0.2"
```

```bash
gem install cvgen
```

## Use from Ruby (Rails, scripts, jobs)

```ruby
require "cvgen"

result = Cvgen::Builder.new(
  profile_name: "default",          # profiles/*.yaml inside the gem
  content_path: "/path/to/cv.md",   # or content_name: with a project root
  layout: "creative-split",         # optional override
  theme_name: "creative-split",     # optional override
  scale: 0.95,                      # optional
  fit: false                        # optional: shrink scale to max_pages
).build!

result[:pdf]   # Pathname to PDF
result[:json]  # Pathname to resume.json
result[:pages] # approximate page count
```

Catalog helpers:

```ruby
root = Cvgen::ROOT
Cvgen::Catalog.layouts(root)
Cvgen::Catalog.themes(root)
Cvgen::Catalog.profiles(root)
```

Layouts, themes, and profiles ship with the gem under `Cvgen::ROOT`.

Import + validate Markdown:

```ruby
Cvgen::Importer.new(root: Rails.root).import!("~/Desktop/my-cv.md", name: "my-cv")
content = Cvgen::Parser.parse(path)
Cvgen::Schema.validate_content!(content)
```

## CLI

From an app that depends on the gem:

```bash
bundle exec cv version
bundle exec cv list-layouts
bundle exec cv list-themes
bundle exec cv list-profiles
bundle exec cv import ~/Desktop/my-cv.md --name my-cv
bundle exec cv build -p default -l modern-stack -t modern-blue -c my-cv
bundle exec cv build -p default --fit
bundle exec cv validate -c my-cv -p default
```

`--root` points at a project directory that has `content/`, and optionally local `profiles/`, `themes/`, `layouts/` overrides (defaults to the gem root).

## Develop this repository

```bash
git clone https://github.com/WebgateSystems/cvgen.git
cd cvgen
bundle install
bundle exec rake          # RSpec + RuboCop
bundle exec rspec         # tests (+ SimpleCov → coverage/)
bundle exec rubocop
```

Example Markdown: [`examples/cv-junior.md`](./examples/cv-junior.md).

Local content lives in `content/` (gitignored). Copy a sample to start:

```bash
mkdir -p content
cp examples/cv-junior.md content/cv.md
bundle exec cv build -p default -c cv
```

Interactive build:

```bash
bundle exec cv build
# or
make interactive
```

Non-interactive:

```bash
make cv PROFILE=lead LAYOUT=modern-stack THEME=modern-blue
bundle exec cv build -p lead -l modern-split -t modern-blue -c cv
```

Output: `build/cv-<profile>-<content>.pdf` and `build/resume.json`.

## Adaptive sections

Layouts render a block **only if data exists** in MD/JSON:

- `# Summary` → optional prose
- skills / languages / experience / education → skipped when empty
- left column of `two-column` collapses if no skills/languages

## Adaptive font scale

In `themes/*.yaml`:

```yaml
scale: 1.0   # 0.6 .. 1.4
```

Or at build time:

```bash
bundle exec cv build -p lead --scale 0.9
bundle exec cv build -p lead --fit
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

## Themes

- `default`, `modern-blue`, `classic-sidebar`
- `timeline-navy`, `sidebar-card`, `creative-accent`
- `creative-split`, `elegant-bordered`, `modern-gradient`, `portfolio-sidebar`

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

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs on push/PR:

- RSpec on Ruby 3.3 / 3.4 / 4.0
- RuboCop
- Typst installed for PDF integration examples
- SimpleCov HTML report uploaded as a CI artifact (Ruby 4.0 job)

## License

This project is licensed under the [GNU General Public License v3.0 or later](./LICENSE).
