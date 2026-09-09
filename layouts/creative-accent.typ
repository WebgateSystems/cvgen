// 6. Creative Accent — cream page, organic blobs, serif name, terracotta accents.
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
#let timeline-c = colors.at("timeline", default: "#c4b8a8")
#let all-skills = cv.essential_skills + cv.additional_skills
#let pill-bg = colors.at("pill_bg", default: "#efeae3")
#let pill-fg = colors.at("pill_text", default: colors.text)
#let page-bg = colors.at("page_bg", default: "#f7f3ee")

#set page(
  paper: "a4",
  margin: mm(sp.page_margin_mm),
  fill: rgb(page-bg),
  background: {
    place(right + top, dx: 20mm, dy: -25mm, ellipse(
      width: 90mm,
      height: 70mm,
      fill: rgb(colors.at("blob_1", default: "#e8c4b8")).transparentize(35%),
    ))
    place(right + top, dx: 45mm, dy: -5mm, ellipse(
      width: 55mm,
      height: 55mm,
      fill: rgb(colors.at("blob_2", default: "#c5c9a8")).transparentize(40%),
    ))
    place(right + bottom, dx: 10mm, dy: 15mm, ellipse(
      width: 80mm,
      height: 60mm,
      fill: rgb(colors.at("blob_3", default: "#d4b896")).transparentize(40%),
    ))
    place(right + bottom, dx: 40mm, dy: 5mm, ellipse(
      width: 50mm,
      height: 45mm,
      fill: rgb(colors.at("blob_1", default: "#e8c4b8")).transparentize(45%),
    ))
  },
)

#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.48em, spacing: 0.55em)

#let section-title(icon, title) = {
  v(pt(sp.section_gap_pt))
  grid(
    columns: (14pt, 1fr),
    column-gutter: 6pt,
    align(horizon, text(size: pt(s.section), fill: rgb(accent), icon)),
    text(font: t.fonts.body, size: pt(s.section), weight: "bold", fill: rgb(colors.text), upper(title)),
  )
  v(8pt)
}

#let contact-line(icon, body) = {
  if body != "" {
    block(spacing: 4pt)[
      #grid(
        columns: (12pt, 1fr),
        column-gutter: 5pt,
        text(size: pt(s.contact), fill: rgb(accent), icon),
        text(size: pt(s.contact), fill: rgb(colors.text), body),
      )
    ]
  }
}

#let skill-pills(items) = {
  items.map(item => box(
    fill: rgb(pill-bg),
    inset: (x: 9pt, y: 5pt),
    radius: 4pt,
    text(size: pt(s.small), fill: rgb(pill-fg), item-text(item)),
  )).join(h(6pt))
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 2pt)[
    #grid(
      columns: (20%, 1fr),
      column-gutter: 10pt,
      text(size: pt(s.small), fill: rgb(colors.text), weight: "bold", dates),
      block(
        inset: (left: 14pt),
        stroke: (left: 1.4pt + rgb(timeline-c)),
      )[
        #place(left, dx: -17.5pt, dy: 2.5pt, circle(radius: 3pt, fill: rgb(accent)))
        #body
      ],
    )
  ]
}

// Header: name + headline
#stack(
  spacing: pt(s.name) * 0.2,
  text(
    font: t.fonts.heading,
    size: pt(s.name),
    weight: "bold",
    fill: rgb(colors.text),
    cv.basics.name,
  ),
  if "headline" in cv.basics and cv.basics.headline != "" {
    text(font: t.fonts.heading, size: pt(s.headline), fill: rgb(accent), cv.basics.headline)
  },
)

#v(12pt)

// Contact | Summary
#grid(
  columns: (sp.left_column_ratio * 1fr, (1 - sp.left_column_ratio) * 1fr),
  column-gutter: 14pt,
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
  {
    if has-summary {
      block(
        inset: (left: 12pt),
        stroke: (left: 0.8pt + rgb(colors.rule)),
      )[
        #text(size: pt(s.body), fill: rgb(colors.text), cv.summary)
      ]
    }
  },
)

#if present(all-skills) {
  section-title("🔧", "Skills")
  skill-pills(all-skills)
}

#if present(cv.experience) {
  section-title("💼", "Experience")
  for entry in cv.experience {
    timeline-row(entry.dates, {
      text(weight: "bold", size: pt(s.body), entry.title)
      if entry.organization != "" {
        linebreak()
        text(size: pt(s.small), fill: rgb(muted), entry.organization)
      }
      if "url" in entry and entry.url != "" {
        linebreak()
        text(size: pt(s.small), fill: rgb(muted), entry.url)
      }
      if "highlights" in entry and entry.highlights.len() > 0 {
        v(2pt)
        for h in entry.highlights {
          text(size: pt(s.small), [• #item-text(h)])
          linebreak()
        }
      }
    })
  }
}

#if present(cv.education) {
  section-title("🎓", "Education")
  for entry in cv.education {
    timeline-row(entry.dates, {
      let title = if entry.title != "" { entry.title } else { entry.organization }
      text(weight: "bold", size: pt(s.body), title)
      if entry.title != "" and entry.organization != "" {
        linebreak()
        text(size: pt(s.small), fill: rgb(muted), entry.organization)
      }
    })
  }
}
