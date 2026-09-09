// 5. Timeline — single column, navy accent, vertical timeline, skill badges.
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let has-summary = "summary" in cv and cv.summary != ""
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let accent = colors.accent
#let muted = colors.muted
#let timeline-c = colors.at("timeline", default: accent)
#let all-skills = cv.essential_skills + cv.additional_skills

#set page(paper: "a4", margin: mm(sp.page_margin_mm), fill: rgb(colors.at("page_bg", default: "#ffffff")))
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.45em, spacing: 0.55em)

#let section-title(icon, title) = {
  v(pt(sp.section_gap_pt))
  grid(
    columns: (14pt, 1fr),
    column-gutter: 6pt,
    align(horizon, text(size: pt(s.section), fill: rgb(accent), icon)),
    text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(accent), upper(title)),
  )
  v(3pt)
  line(length: 100%, stroke: 0.7pt + rgb(colors.rule))
  v(8pt)
}

#let contact-line(icon, body) = {
  if body != "" {
    block(spacing: 3pt)[
      #grid(
        columns: (12pt, 1fr),
        column-gutter: 4pt,
        text(size: pt(s.contact), fill: rgb(accent), icon),
        text(size: pt(s.contact), fill: rgb(colors.text), body),
      )
    ]
  }
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 2pt)[
    #grid(
      columns: (20%, 1fr),
      column-gutter: 10pt,
      text(size: pt(s.small), fill: rgb(accent), weight: "bold", dates),
      block(
        inset: (left: 14pt, top: 1pt, bottom: 2pt),
        stroke: (left: 1.6pt + rgb(timeline-c)),
        body,
      ),
    )
  ]
}

#let skill-badge(item) = {
  box(
    fill: rgb(colors.at("pill_bg", default: "#e8eef6")),
    stroke: 0.7pt + rgb(accent),
    inset: (x: 8pt, y: 5pt),
    radius: 2pt,
    text(size: pt(s.small), fill: rgb(colors.text), item-text(item)),
  )
}

// Header
#grid(
  columns: (1.35fr, 1fr),
  column-gutter: 14pt,
  {
    stack(
      spacing: 10pt,
      text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(accent), cv.basics.name),
      if "headline" in cv.basics and cv.basics.headline != "" {
        text(size: pt(s.headline), fill: rgb(muted), cv.basics.headline)
      },
    )
  },
  {
    if "phones" in cv.basics {
      for phone in cv.basics.phones {
        contact-line("☎", [(#phone.label) #phone.number])
      }
    }
    if "email" in cv.basics and cv.basics.email != "" {
      contact-line("✉", cv.basics.email)
    }
    if "location" in cv.basics and cv.basics.location != "" {
      contact-line("⌖", cv.basics.location)
    }
    if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary {
          link.at("label", default: link.at("url", default: ""))
        } else { str(link) }
        contact-line("🔗", label)
      }
    }
  },
)

#if has-summary {
  section-title("👤", "Summary")
  text(size: pt(s.body), cv.summary)
}

#if present(cv.experience) {
  section-title("💼", "Experience")
  for entry in cv.experience {
    timeline-row(entry.dates, {
      stack(
        spacing: 4pt,
        text(font: t.fonts.heading, weight: "bold", size: pt(s.body), fill: rgb(accent), entry.title),
        if entry.organization != "" {
          text(size: pt(s.small), fill: rgb(muted), entry.organization)
        },
        if "url" in entry and entry.url != "" {
          text(size: pt(s.small), fill: rgb(muted), entry.url)
        },
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
  section-title("🎓", "Education")
  for entry in cv.education {
    timeline-row(entry.dates, {
      let title = if entry.title != "" { entry.title } else { entry.organization }
      stack(
        spacing: 4pt,
        text(font: t.fonts.heading, weight: "bold", size: pt(s.body), fill: rgb(accent), title),
        if entry.title != "" and entry.organization != "" {
          text(size: pt(s.small), fill: rgb(muted), entry.organization)
        },
      )
    })
  }
}

#if present(all-skills) {
  section-title("🧰", "Key Skills")
  block[
    #set par(leading: 1.1em, spacing: 1.1em)
    #all-skills.map(skill-badge).join(h(6pt))
  ]
}
