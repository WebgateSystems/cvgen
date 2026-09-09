// 10. Creative Split — dark sidebar + banner + about/experience/education.
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let sidebar-w = mm(sp.at("sidebar_width_mm", default: 70))
#let page-pad = mm(sp.page_margin_mm)
#let all-skills = cv.essential_skills + cv.additional_skills
#let sidebar-bg = colors.at("sidebar_bg", default: "#3d4f46")
#let sidebar-fg = colors.at("sidebar_text", default: "#ffffff")
#let muted = colors.muted
#let accent = colors.accent
#let timeline-c = colors.at("timeline", default: "#94a3b8")

#let initials(name) = {
  let parts = name.split(" ").filter(w => w != "")
  if parts.len() == 0 { "?" } else { upper(parts.map(w => w.slice(0, 1)).join("")) }
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
  margin: 0mm,
  fill: rgb(colors.at("page_bg", default: "#ffffff")),
  background: place(left + top, rect(width: sidebar-w, height: 100%, fill: rgb(sidebar-bg))),
)
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.52em, spacing: 0.6em)

#let main-heading(icon, title) = {
  block(above: pt(sp.section_gap_pt), below: 8pt)[
    #grid(
      columns: (16pt, 1fr),
      column-gutter: 6pt,
      align(horizon, text(size: pt(s.section), fill: rgb(accent), icon)),
      text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(accent), upper(title)),
    )
  ]
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 3pt)[
    #grid(
      columns: (22%, 1fr),
      column-gutter: 10pt,
      text(size: pt(s.small), weight: "bold", fill: rgb(muted), dates),
      block(inset: (left: 14pt, top: 1pt), stroke: (left: 1.5pt + rgb(timeline-c)), body),
    )
  ]
}

#grid(
  columns: (sidebar-w, 1fr),
  column-gutter: 0pt,
  block(width: 100%, inset: (x: page-pad * 0.65, y: page-pad))[
    #set text(fill: rgb(sidebar-fg))
    #align(center)[
      #box(
        width: 54pt, height: 54pt, radius: 27pt,
        fill: rgb("#ffffff"),
        align(center + horizon, text(size: 15pt, weight: "bold", fill: rgb(sidebar-bg), initials(cv.basics.name))),
      )
      #v(10pt)
      #text(font: t.fonts.heading, size: pt(s.name), weight: "bold", cv.basics.name)
      #if "headline" in cv.basics and cv.basics.headline != "" {
        v(6pt)
        text(size: pt(s.headline), fill: rgb(colors.at("sidebar_muted", default: "#a8b5ad")), cv.basics.headline)
      }
    ]
    #v(12pt)
    #line(length: 100%, stroke: 0.6pt + rgb(sidebar-fg).transparentize(65%))
    #v(10pt)
    #set text(size: pt(s.contact))
    #if "phones" in cv.basics {
      for phone in cv.basics.phones { block(spacing: 5pt)[☎ (#phone.label) #phone.number] }
    }
    #if "email" in cv.basics and cv.basics.email != "" { block(spacing: 5pt)[✉ #cv.basics.email] }
    #if "location" in cv.basics and cv.basics.location != "" { block(spacing: 5pt)[⌖ #cv.basics.location] }
    #if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary { link.at("label", default: link.at("url", default: "")) } else { str(link) }
        if label != "" { block(spacing: 5pt)[🔗 #label] }
      }
    }

    #if present(all-skills) {
      v(14pt)
      text(size: pt(s.section), weight: "bold", upper("Skills"))
      v(8pt)
      for item in all-skills {
        block(spacing: 4pt)[#text(size: pt(s.small), item-text(item))]
      }
    }

    #if present(cv.languages) {
      v(14pt)
      text(size: pt(s.section), weight: "bold", upper("Languages"))
      v(8pt)
      for lang in cv.languages {
        let raw = item-text(lang)
        block(below: 7pt)[
          #grid(columns: (1fr, auto),
            text(size: pt(s.small), lang-name(raw)),
            text(size: pt(s.small), fill: rgb(colors.at("sidebar_muted", default: "#a8b5ad")), lang-code(raw)),
          )
          #v(3pt)
          #box(width: 100%, height: 5pt, fill: rgb(colors.at("bar_track", default: "#2a3630")), radius: 1pt)[
            #place(left + horizon, box(
              width: 100% * lang-level(raw),
              height: 5pt,
              fill: rgb(colors.at("bar_fill", default: "#ffffff")),
              radius: 1pt,
            ))
          ]
        ]
      }
    }
  ],
  block(width: 100%, inset: (left: 0pt, right: 0pt, top: 0pt, bottom: page-pad))[
    // Banner — full bleed to right page edge
    #block(width: 100%, height: 36mm, fill: rgb(colors.at("banner_bg", default: "#4b5563")), clip: true)[
      // abstract shapes (no mountains / slogan)
      #place(left + bottom, dx: 10pt, dy: -6pt, ellipse(
        width: 70pt, height: 34pt,
        fill: rgb("#374151").transparentize(15%),
      ))
      #place(left + bottom, dx: 48pt, dy: -2pt, ellipse(
        width: 55pt, height: 42pt,
        fill: rgb("#1f2937").transparentize(20%),
      ))
      #place(center + bottom, dx: -20pt, dy: 4pt, rect(
        width: 90pt, height: 22pt, radius: 11pt,
        fill: rgb("#4b5563").lighten(12%),
      ))
      #place(right + top, dx: -18pt, dy: 8pt, ellipse(
        width: 48pt, height: 48pt,
        fill: rgb("#6b7280").transparentize(35%),
      ))
      #place(right + bottom, dx: -40pt, dy: -4pt, ellipse(
        width: 64pt, height: 28pt,
        fill: rgb("#1f2937").transparentize(25%),
      ))
    ]

    #block(inset: (left: page-pad * 0.75, right: page-pad, top: page-pad * 0.7))[
      #if "summary" in cv and cv.summary != "" {
        main-heading("✦", "About Me")
        text(size: pt(s.body), cv.summary)
      }

      #if present(cv.experience) {
        main-heading("📅", "Experience")
        for entry in cv.experience {
          timeline-row(entry.dates, {
            stack(spacing: 4pt,
              text(weight: "bold", size: pt(s.body), entry.title),
              if entry.organization != "" { text(size: pt(s.small), fill: rgb(muted), entry.organization) },
              if "highlights" in entry and entry.highlights.len() > 0 {
                block(above: 2pt)[
                  #for h in entry.highlights {
                    text(size: pt(s.small), [• #item-text(h)])
                    linebreak()
                  }
                ]
              },
            )
          })
        }
      }

      #if present(cv.education) {
        main-heading("🎓", "Education")
        for entry in cv.education {
          timeline-row(entry.dates, {
            let title = if entry.title != "" { entry.title } else { entry.organization }
            stack(spacing: 4pt,
              text(weight: "bold", size: pt(s.body), title),
              if entry.title != "" and entry.organization != "" {
                text(size: pt(s.small), fill: rgb(muted), entry.organization)
              },
            )
          })
        }
      }

      #if "quote" in cv and cv.quote != "" {
        v(16pt)
        align(center, text(style: "italic", size: pt(s.small), fill: rgb(muted), [“#cv.quote”]))
      }
    ]
  ],
)
