// Portfolio sidebar — banner flush top-right, compact one-page layout.
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let accent = colors.accent
#let muted = colors.muted
#let timeline-c = colors.at("timeline", default: accent)
#let all-skills = cv.essential_skills + cv.additional_skills
#let pill-bg = colors.at("pill_bg", default: "#dbeafe")
#let pill-fg = colors.at("pill_text", default: accent)
#let page-m = mm(sp.page_margin_mm)
#let banner-w = mm(sp.at("banner_width_mm", default: 82))
#let banner-h = mm(sp.at("banner_height_mm", default: 48))

#let short-url(url) = {
  url.replace("https://", "").replace("http://", "")
}

#let lang-level(text) = {
  let lower = lower(text)
  if lower.contains("native") { 1.0 }
  else if lower.contains("c2") { 0.95 }
  else if lower.contains("c1") { 0.85 }
  else if lower.contains("b2") { 0.72 }
  else if lower.contains("b1") { 0.58 }
  else if lower.contains("a2") { 0.42 }
  else if lower.contains("a1") { 0.28 }
  else { 0.5 }
}
#let lang-name(text) = {
  let parts = text.split(" - ")
  if parts.len() < 2 { parts = text.split(" — ") }
  if parts.len() >= 1 { parts.at(0).trim() } else { text }
}
#let lang-code(text) = {
  let parts = text.split(" - ")
  if parts.len() < 2 { parts = text.split(" — ") }
  if parts.len() >= 2 { parts.at(1).trim() } else { "" }
}

#set page(
  paper: "a4",
  margin: page-m,
  fill: rgb(colors.at("page_bg", default: "#ffffff")),
  background: place(right + top, box(
    width: banner-w,
    height: banner-h,
    clip: true,
    image("../assets/portfolio-banner.jpg", width: banner-w, height: banner-h, fit: "cover"),
  )),
)
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.42em, spacing: 0.45em)

#let section-title(icon, title) = {
  block(above: pt(sp.section_gap_pt), below: 5pt)[
    #grid(columns: (14pt, 1fr), column-gutter: 5pt,
      box(width: 13pt, height: 13pt, radius: 6.5pt, fill: rgb(pill-bg),
        align(center + horizon, text(size: 7pt, fill: rgb(accent), icon))),
      text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(accent), upper(title)),
    )
    #v(2pt)
    #line(length: 100%, stroke: 0.5pt + rgb(colors.rule))
  ]
}

#let skill-pills(items) = {
  block[
    #set par(leading: 0.95em, spacing: 0.95em)
    #items.map(item => box(
      fill: rgb(pill-bg), inset: (x: 5pt, y: 2.5pt), radius: 2pt,
      text(size: pt(s.small) - 0.5pt, fill: rgb(pill-fg), item-text(item)),
    )).join(h(3pt))
  ]
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt))[
    #grid(columns: (20%, 1fr), column-gutter: 6pt,
      text(size: pt(s.small), weight: "bold", fill: rgb(accent), dates),
      block(inset: (left: 10pt, top: 1pt), stroke: (left: 1.3pt + rgb(timeline-c)), body),
    )
  ]
}

// Header: text left, reserved space under flush banner
#grid(
  columns: (1fr, banner-w - page-m),
  column-gutter: 8pt,
  {
    stack(spacing: 5pt,
      text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(accent), cv.basics.name),
      if "headline" in cv.basics and cv.basics.headline != "" {
        text(size: pt(s.headline), fill: rgb(muted), cv.basics.headline)
      },
    )
    if "summary" in cv and cv.summary != "" {
      v(5pt)
      text(size: pt(s.small), cv.summary)
    }
  },
  // keep clear of banner; height matches visible banner under top margin
  block(height: calc.max(banner-h - page-m, 20mm), width: 100%, []),
)

#v(4pt)

#grid(
  columns: (sp.left_column_ratio * 1fr, (1 - sp.left_column_ratio) * 1fr),
  column-gutter: mm(sp.column_gutter_mm),
  {
    if present(cv.experience) {
      section-title("💼", "Experience")
      for entry in cv.experience {
        timeline-row(entry.dates, {
          stack(spacing: 2.5pt,
            text(weight: "bold", size: pt(s.body), entry.title),
            if entry.organization != "" { text(size: pt(s.small), fill: rgb(muted), entry.organization) },
            if "highlights" in entry and entry.highlights.len() > 0 {
              block(above: 1pt)[
                #for h in entry.highlights {
                  text(size: pt(s.small), fill: rgb(accent), [• ])
                  text(size: pt(s.small), item-text(h))
                  linebreak()
                }
              ]
            },
          )
        })
      }
    }

    if present(cv.projects) {
      section-title("📁", "Projects")
      for entry in cv.projects {
        block(below: 5pt)[
          #text(weight: "bold", size: pt(s.body), entry.organization)
          #if "url" in entry and entry.url != "" {
            h(6pt)
            text(size: pt(s.small) - 0.5pt, fill: rgb(accent), short-url(entry.url))
          }
          #if entry.title != "" {
            v(2pt)
            text(size: pt(s.small), fill: rgb(muted), entry.title)
          }
        ]
      }
    }

    if present(cv.education) {
      section-title("🎓", "Education")
      for entry in cv.education {
        block(below: 5pt)[
          #grid(columns: (20%, 1fr), column-gutter: 6pt,
            text(size: pt(s.small), weight: "bold", fill: rgb(accent), entry.dates),
            {
              let title = if entry.title != "" { entry.title } else { entry.organization }
              stack(spacing: 2pt,
                text(weight: "bold", size: pt(s.body), title),
                if entry.title != "" and entry.organization != "" {
                  text(size: pt(s.small), fill: rgb(muted), entry.organization)
                },
              )
            },
          )
        ]
      }
    }
  },
  {
    section-title("☎", "Contact")
    if "email" in cv.basics and cv.basics.email != "" {
      block(spacing: 3pt)[#text(size: pt(s.contact))[✉ #cv.basics.email]]
    }
    if "phones" in cv.basics {
      for phone in cv.basics.phones {
        block(spacing: 3pt)[#text(size: pt(s.contact))[☎ #phone.number]]
      }
    }
    if "location" in cv.basics and cv.basics.location != "" {
      block(spacing: 3pt)[#text(size: pt(s.contact))[⌖ #cv.basics.location]]
    }
    if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary { link.at("label", default: "") } else { str(link) }
        if label != "" { block(spacing: 3pt)[#text(size: pt(s.contact))[🔗 #label]] }
      }
    }

    if present(all-skills) {
      section-title("⚙", "Skills")
      skill-pills(all-skills)
    }

    if present(cv.languages) {
      section-title("🗣", "Languages")
      for lang in cv.languages {
        let raw = item-text(lang)
        block(below: 5pt)[
          #grid(columns: (1fr, auto),
            text(size: pt(s.small), lang-name(raw)),
            text(size: pt(s.small), fill: rgb(muted), lang-code(raw)),
          )
          #v(2pt)
          #box(width: 100%, height: 4pt, fill: rgb(colors.at("bar_track", default: "#e2e8f0")), radius: 1pt)[
            #place(left + horizon, box(
              width: 100% * lang-level(raw),
              height: 4pt,
              fill: rgb(colors.at("bar_fill", default: accent)),
              radius: 1pt,
            ))
          ]
        ]
      }
    }
  },
)
