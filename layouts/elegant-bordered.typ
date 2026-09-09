// 14. Elegant Bordered — gold frame, centered header, two columns.
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let gold = colors.at("gold", default: colors.accent)
#let muted = colors.muted
#let accent = colors.accent
#let timeline-c = colors.at("timeline", default: gold)
#let all-skills = cv.essential_skills + cv.additional_skills
#let border-c = colors.at("border", default: gold)

#set page(
  paper: "a4",
  margin: mm(sp.page_margin_mm) + 3mm,
  fill: rgb(colors.at("page_bg", default: "#faf8f4")),
  foreground: {
    place(center + horizon, rect(
      width: 100% - 8mm,
      height: 100% - 8mm,
      stroke: 0.9pt + rgb(border-c),
      fill: none,
    ))
  },
)
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.52em, spacing: 0.58em)

#let section-title(title) = {
  block(above: pt(sp.section_gap_pt), below: 8pt)[
    #text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(colors.text), upper(title))
  ]
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 3pt)[
    #grid(
      columns: (24%, 1fr),
      column-gutter: 8pt,
      text(size: pt(s.small), fill: rgb(gold), weight: "bold", dates),
      block(inset: (left: 12pt, top: 1pt), stroke: (left: 1.2pt + rgb(timeline-c)), body),
    )
  ]
}

#let contact-chip(icon, body) = {
  if body != "" {
    box(inset: (x: 4pt, y: 2pt))[
      #text(size: pt(s.contact), fill: rgb(gold), icon)
      #h(3pt)
      #text(size: pt(s.contact), fill: rgb(colors.text), body)
    ]
  }
}

// Header
#align(center)[
  #if "role_label" in cv.basics and cv.basics.role_label != "" {
    text(size: pt(s.small), fill: rgb(gold), tracking: 1.5pt, upper(cv.basics.role_label))
    v(6pt)
  }
  #text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(colors.text), cv.basics.name)
  #if "headline" in cv.basics and cv.basics.headline != "" {
    v(8pt)
    text(font: t.fonts.heading, size: pt(s.headline), fill: rgb(gold), cv.basics.headline)
  }
  #if "summary" in cv and cv.summary != "" {
    v(10pt)
    block(width: 88%)[
      #set align(center)
      #text(size: pt(s.small), fill: rgb(muted), cv.summary)
    ]
  }
  #v(10pt)
  #{
    let chips = ()
    if "phones" in cv.basics {
      for phone in cv.basics.phones { chips.push(contact-chip("☎", phone.number)) }
    }
    if "location" in cv.basics and cv.basics.location != "" { chips.push(contact-chip("⌖", cv.basics.location)) }
    if "email" in cv.basics and cv.basics.email != "" { chips.push(contact-chip("✉", cv.basics.email)) }
    if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary { link.at("label", default: "") } else { str(link) }
        chips.push(contact-chip("🔗", label))
      }
    }
    chips.join(h(8pt))
  }
]

#v(8pt)
#line(length: 100%, stroke: 0.7pt + rgb(colors.rule))
#v(6pt)

#grid(
  columns: (sp.left_column_ratio * 1fr, (1 - sp.left_column_ratio) * 1fr),
  column-gutter: mm(sp.column_gutter_mm),
  {
    if present(all-skills) {
      section-title("Skills")
      for item in all-skills {
        block(spacing: 5pt)[#text(size: pt(s.small), item-text(item))]
      }
    }
  },
  {
    if present(cv.experience) {
      section-title("Experience")
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
  },
)

#line(length: 100%, stroke: 0.7pt + rgb(colors.rule))
#v(4pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: mm(sp.column_gutter_mm),
  {
    if present(cv.education) {
      section-title("Education")
      for entry in cv.education {
        block(below: 8pt)[
          #text(size: pt(s.small), fill: rgb(gold), weight: "bold", entry.dates)
          #linebreak()
          #let title = if entry.title != "" { entry.title } else { entry.organization }
          #text(weight: "bold", size: pt(s.body), title)
          #if entry.title != "" and entry.organization != "" {
            linebreak()
            text(size: pt(s.small), fill: rgb(muted), entry.organization)
          }
        ]
      }
    }
  },
  {
    if present(cv.languages) {
      section-title("Languages")
      for lang in cv.languages {
        block(spacing: 5pt)[#text(size: pt(s.small), item-text(lang).replace(" - ", " — "))]
      }
    }
  },
)

#if "slogan" in cv.basics and cv.basics.slogan != "" {
  v(1fr)
  align(center, text(size: pt(s.small), fill: rgb(gold), tracking: 1.8pt, upper(cv.basics.slogan)))
}
