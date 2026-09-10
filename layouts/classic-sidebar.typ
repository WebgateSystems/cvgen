// Classic lead CV: grey sidebar | main. No absolute place() for content (avoids overlap).
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let sidebar-bg = colors.at("sidebar_bg", default: "#e6e6e6")
#let sidebar-w = mm(sp.at("sidebar_width_mm", default: 62))
#let page-pad = mm(sp.page_margin_mm)

#set page(
  paper: "a4",
  margin: 0mm,
  background: place(
    left + top,
    rect(width: sidebar-w, height: 100%, fill: rgb(sidebar-bg)),
  ),
)

#set text(
  font: t.fonts.body,
  size: pt(s.body),
  fill: rgb(colors.text),
  lang: "en",
)
#set par(leading: 0.48em, spacing: 0.55em)

#let sidebar-heading(title) = {
  block(above: pt(sp.section_gap_pt) + 10pt, below: 7pt)[
    #text(
      font: t.fonts.heading,
      size: pt(s.section),
      weight: "bold",
      fill: rgb(colors.accent),
      upper(title),
    )
  ]
}

#let plain-list(items) = {
  for item in items {
    block(spacing: 3.5pt)[
      #set par(leading: 0.4em)
      #text(size: pt(s.small), fill: rgb(colors.text), item-text(item))
    ]
  }
}

#let main-heading(title) = {
  block(above: pt(sp.section_gap_pt) + 4pt, below: 7pt)[
    #grid(
      columns: (7pt, 1fr),
      column-gutter: 5pt,
      align(horizon, square(size: 5pt, fill: rgb(colors.accent))),
      text(
        font: t.fonts.heading,
        size: pt(s.section) + 0.5pt,
        weight: "bold",
        fill: rgb(colors.accent),
        upper(title),
      ),
    )
  ]
}

#let exp-entry(entry) = {
  block(below: pt(sp.item_gap_pt) + 2pt)[
    #grid(
      columns: (23%, 1fr),
      column-gutter: 7pt,
      text(
        font: t.fonts.heading,
        size: pt(s.small),
        weight: "bold",
        fill: rgb(colors.text),
        entry.dates,
      ),
      {
        let head = if entry.title != "" and entry.organization != "" {
          entry.title + " " + entry.organization
        } else if entry.title != "" { entry.title } else { entry.organization }
        text(font: t.fonts.heading, size: pt(s.body), weight: "bold", head)
        if "url" in entry and entry.url != "" {
          linebreak()
          text(size: pt(s.small), fill: rgb(colors.muted), entry.url)
        }
        if "highlights" in entry and entry.highlights.len() > 0 {
          for h in entry.highlights {
            linebreak()
            text(size: pt(s.small), fill: rgb(colors.muted), item-text(h))
          }
        }
      },
    )
  ]
}

#let edu-entry(entry) = {
  block(below: pt(sp.item_gap_pt) + 1pt)[
    #grid(
      columns: (23%, 1fr),
      column-gutter: 7pt,
      text(
        font: t.fonts.heading,
        size: pt(s.small),
        weight: "bold",
        entry.dates,
      ),
      {
        text(size: pt(s.small), weight: "bold", entry.organization)
        if "title" in entry and entry.title != "" {
          text(size: pt(s.small), [, ] + entry.title)
        }
      },
    )
  ]
}

#grid(
  columns: (sidebar-w, 1fr),
  column-gutter: 0pt,
  // LEFT: sidebar content (stays inside grey band)
  block(
    width: 100%,
    inset: (left: page-pad * 0.65, right: page-pad * 0.55, top: page-pad, bottom: page-pad),
  )[
    #set text(size: pt(s.contact))
    #if "phones" in cv.basics {
      for phone in cv.basics.phones {
        block(spacing: 3pt)[
          #text()[☎ (#phone.label) #phone.number]
        ]
      }
    }
    #if "email" in cv.basics and cv.basics.email != "" {
      block(spacing: 3pt)[
        #text()[✉ #cv.basics.email]
      ]
    }
    #if "location" in cv.basics and cv.basics.location != "" {
      block(spacing: 3pt)[
        #text(cv.basics.location)
      ]
    }
    #if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary {
          link.at("label", default: link.at("url", default: ""))
        } else { str(link) }
        if label != "" {
          block(spacing: 3pt)[#text(size: pt(s.small), label)]
        }
      }
    }

    #if present(cv.essential_skills) {
      sidebar-heading("Essential Skills")
      plain-list(cv.essential_skills)
    }
    #if present(cv.additional_skills) {
      sidebar-heading("Additional Skills")
      plain-list(cv.additional_skills)
    }
    #if present(cv.languages) {
      sidebar-heading("Languages")
      plain-list(cv.languages)
    }
  ],
  // RIGHT: main column
  block(
    width: 100%,
    inset: (left: page-pad * 0.7, right: page-pad, top: page-pad, bottom: page-pad),
  )[
    #stack(
      spacing: pt(s.name) * 0.25,
      text(
        font: t.fonts.heading,
        size: pt(s.name),
        weight: "bold",
        fill: rgb(colors.accent),
        upper(cv.basics.name),
      ),
      if "headline" in cv.basics and cv.basics.headline != "" {
        text(
          font: t.fonts.heading,
          size: pt(s.headline),
          fill: rgb(colors.text),
          cv.basics.headline,
        )
      },
    )

    // Summary only under header in main column (never in sidebar)
    #if "summary" in cv and cv.summary != "" {
      v(8pt)
      text(size: pt(s.small), fill: rgb(colors.muted), cv.summary)
    }

    #if present(cv.experience) {
      main-heading("Professional Experience")
      for entry in cv.experience {
        exp-entry(entry)
      }
    }

    #if present(cv.education) {
      main-heading("Education")
      for entry in cv.education {
        edu-entry(entry)
      }
    }
  ],
)
