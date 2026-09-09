// 7. Modern Gradient — purple/blue accents, pills, timeline with squares, projects.
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
#let secondary = colors.at("secondary", default: accent)
#let muted = colors.muted
#let timeline-c = colors.at("timeline", default: accent)
#let all-skills = cv.essential_skills + cv.additional_skills
#let pill-bg = colors.at("pill_bg", default: "#dbeafe")
#let pill-fg = colors.at("pill_text", default: accent)

#set page(
  paper: "a4",
  margin: mm(sp.page_margin_mm),
  fill: rgb(colors.at("page_bg", default: "#ffffff")),
  background: {
    place(right + top, dx: 15mm, dy: -30mm, ellipse(
      width: 95mm, height: 75mm,
      fill: rgb(colors.at("blob_1", default: "#c4b5fd")).transparentize(45%),
    ))
    place(right + top, dx: 40mm, dy: -10mm, ellipse(
      width: 60mm, height: 55mm,
      fill: rgb(colors.at("blob_2", default: "#93c5fd")).transparentize(40%),
    ))
    place(right + bottom, dx: 10mm, dy: 20mm, ellipse(
      width: 85mm, height: 65mm,
      fill: rgb(colors.at("blob_2", default: "#93c5fd")).transparentize(50%),
    ))
  },
)
      #set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.48em, spacing: 0.52em)

#let section-title(icon, title) = {
  block(above: pt(sp.section_gap_pt), below: 9pt)[
    #grid(
      columns: (16pt, 1fr),
      column-gutter: 6pt,
      align(horizon, text(size: pt(s.section), fill: rgb(accent), icon)),
      text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(accent), upper(title)),
    )
  ]
}

#let contact-line(icon, body) = {
  if body != "" {
    block(spacing: 4pt)[
      #grid(columns: (12pt, 1fr), column-gutter: 5pt,
        text(size: pt(s.contact), fill: rgb(accent), icon),
        text(size: pt(s.contact), body),
      )
    ]
  }
}

#let skill-pills(items) = {
  block[
    #set par(leading: 1.15em, spacing: 1.15em)
    #items.map(item => box(
      fill: rgb(pill-bg),
      inset: (x: 9pt, y: 5pt),
      radius: 4pt,
      text(size: pt(s.small), fill: rgb(pill-fg), item-text(item)),
    )).join(h(6pt))
  ]
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 3pt)[
    #grid(
      columns: (20%, 1fr),
      column-gutter: 10pt,
      text(size: pt(s.small), weight: "bold", fill: rgb(accent), dates),
      block(inset: (left: 14pt, top: 1pt), stroke: (left: 1.6pt + rgb(timeline-c)), body),
    )
  ]
}

// Header
#stack(
  spacing: 8pt,
  text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(colors.text), cv.basics.name),
  if "headline" in cv.basics and cv.basics.headline != "" {
    text(size: pt(s.headline), fill: rgb(secondary), weight: "bold", cv.basics.headline)
  },
)

#v(10pt)
#grid(
  columns: (1.45fr, 1fr),
  column-gutter: 14pt,
  {
    if "summary" in cv and cv.summary != "" {
      text(size: pt(s.body), cv.summary)
    }
  },
  {
    if "phones" in cv.basics {
      for phone in cv.basics.phones { contact-line("☎", [(#phone.label) #phone.number]) }
    }
    if "email" in cv.basics and cv.basics.email != "" { contact-line("✉", cv.basics.email) }
    if "location" in cv.basics and cv.basics.location != "" { contact-line("⌖", cv.basics.location) }
    if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary { link.at("label", default: "") } else { str(link) }
        contact-line("🔗", label)
      }
    }
  },
)

#if present(all-skills) {
  section-title("⚙", "Skills")
  skill-pills(all-skills)
}

#if present(cv.experience) {
  section-title("💼", "Experience")
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
  section-title("🎓", "Education")
  for entry in cv.education {
    block(below: 8pt)[
      #grid(columns: (20%, 1fr), column-gutter: 10pt,
        text(size: pt(s.small), weight: "bold", fill: rgb(accent), entry.dates),
        {
          let title = if entry.title != "" { entry.title } else { entry.organization }
          stack(spacing: 4pt,
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

#if present(cv.projects) {
  section-title("📁", "Projects")
  for entry in cv.projects {
    block(below: 9pt)[
      #stack(
        spacing: 3pt,
        text(weight: "bold", size: pt(s.body), entry.organization),
        if "url" in entry and entry.url != "" {
          text(size: pt(s.small), fill: rgb(accent), entry.url)
        },
        if entry.title != "" {
          text(size: pt(s.small), fill: rgb(muted), entry.title)
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
    ]
  }
}
