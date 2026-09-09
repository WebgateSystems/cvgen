// 4. Sidebar Card — dark sidebar (avatar, contact, quote, languages) + main timeline.
#let cv = json("../build/resume.json")
#let t = cv.theme
#let s = t.sizes_pt
#let sp = t.spacing
#let colors = t.colors

#let pt(n) = n * 1pt
#let mm(n) = n * 1mm
#let present(arr) = type(arr) == array and arr.len() > 0
#let has-summary = "summary" in cv and cv.summary != ""
#let has-quote = "quote" in cv and cv.quote != ""
#let item-text(item) = if type(item) == dictionary { item.at("text", default: "") } else { str(item) }
#let accent = colors.accent
#let muted = colors.muted
#let timeline-c = colors.at("timeline", default: "#93c5fd")
#let sidebar-bg = colors.at("sidebar_bg", default: "#2c3e50")
#let sidebar-fg = colors.at("sidebar_text", default: "#ffffff")
#let sidebar-w = mm(sp.at("sidebar_width_mm", default: 68))
#let page-pad = mm(sp.page_margin_mm)
#let all-skills = cv.essential_skills + cv.additional_skills
#let pill-bg = colors.at("pill_bg", default: "#e8eef6")
#let pill-fg = colors.at("pill_text", default: accent)

#let initials(name) = {
  let parts = name.split(" ").filter(w => w != "")
  if parts.len() == 0 { return "?" }
  upper(parts.map(w => w.slice(0, 1)).join(""))
}

#set page(
  paper: "a4",
  margin: 0mm,
  fill: rgb(colors.at("page_bg", default: "#ffffff")),
  background: place(left + top, rect(width: sidebar-w, height: 100%, fill: rgb(sidebar-bg))),
)

#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.45em, spacing: 0.55em)

#let main-heading(icon, title) = {
  block(above: pt(sp.section_gap_pt), below: 6pt)[
    #line(length: 100%, stroke: 0.6pt + rgb(colors.rule))
    #v(6pt)
    #grid(
      columns: (14pt, 1fr),
      column-gutter: 6pt,
      align(horizon, text(size: pt(s.section), fill: rgb(accent), icon)),
      text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(accent), upper(title)),
    )
  ]
}

#let skill-pills(items) = {
  items.map(item => box(
    fill: rgb(pill-bg),
    inset: (x: 8pt, y: 4pt),
    radius: 4pt,
    text(size: pt(s.small), fill: rgb(pill-fg), item-text(item)),
  )).join(h(5pt))
}

#let timeline-row(dates, body) = {
  block(below: pt(sp.item_gap_pt) + 2pt)[
    #grid(
      columns: (22%, 1fr),
      column-gutter: 8pt,
      text(size: pt(s.small), fill: rgb(accent), weight: "bold", dates),
      block(
        inset: (left: 12pt),
        stroke: (left: 1.5pt + rgb(timeline-c)),
      )[
        #place(left, dx: -15.5pt, dy: 2pt, circle(radius: 2.8pt, fill: rgb(accent)))
        #body
      ],
    )
  ]
}

#grid(
  columns: (sidebar-w, 1fr),
  column-gutter: 0pt,
  // Sidebar
  block(
    width: 100%,
    inset: (x: page-pad * 0.7, y: page-pad),
  )[
    #set text(fill: rgb(sidebar-fg))
    #align(center)[
      #box(
        width: 56pt,
        height: 56pt,
        radius: 28pt,
        fill: rgb(colors.at("avatar_bg", default: "#f1f5f9")),
        align(center + horizon, text(
          size: 16pt,
          weight: "bold",
          fill: rgb(sidebar-bg),
          initials(cv.basics.name),
        )),
      )
      #v(10pt)
      #text(font: t.fonts.heading, size: pt(s.name), weight: "bold", cv.basics.name)
      #if "headline" in cv.basics and cv.basics.headline != "" {
        v(4pt)
        text(size: pt(s.headline), cv.basics.headline)
      }
    ]

    #v(14pt)
    #set text(size: pt(s.contact))
    #if "location" in cv.basics and cv.basics.location != "" {
      block(spacing: 4pt)[⌖ #cv.basics.location]
    }
    #if "phones" in cv.basics {
      for phone in cv.basics.phones {
        block(spacing: 4pt)[☎ (#phone.label) #phone.number]
      }
    }
    #if "email" in cv.basics and cv.basics.email != "" {
      block(spacing: 4pt)[✉ #cv.basics.email]
    }
    #if "links" in cv.basics {
      for link in cv.basics.links {
        let label = if type(link) == dictionary {
          link.at("label", default: link.at("url", default: ""))
        } else { str(link) }
        if label != "" {
          block(spacing: 4pt)[🔗 #label]
        }
      }
    }

    #if has-quote {
      v(16pt)
      line(length: 100%, stroke: 0.6pt + rgb(sidebar-fg).transparentize(50%))
      v(10pt)
      align(center, text(style: "italic", size: pt(s.small), [“#cv.quote”]))
      v(10pt)
      line(length: 100%, stroke: 0.6pt + rgb(sidebar-fg).transparentize(50%))
    }

    #if present(cv.languages) {
      v(16pt)
      text(size: pt(s.section), weight: "bold", upper("Languages"))
      v(8pt)
      for lang in cv.languages {
        block(spacing: 4pt)[
          #text(size: pt(s.small), item-text(lang))
        ]
      }
    }
  ],
  // Main
  block(
    width: 100%,
    inset: (left: page-pad * 0.75, right: page-pad, top: page-pad, bottom: page-pad),
  )[
    #if has-summary {
      main-heading("👤", "Summary")
      text(size: pt(s.body), cv.summary)
    }

    #if present(all-skills) {
      main-heading("⚙", "Skills")
      skill-pills(all-skills)
    }

    #if present(cv.experience) {
      main-heading("💼", "Experience")
      for entry in cv.experience {
        timeline-row(entry.dates, {
          text(weight: "bold", size: pt(s.body), fill: rgb(accent), entry.title)
          if entry.organization != "" {
            linebreak()
            text(size: pt(s.small), fill: rgb(muted), entry.organization)
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
      main-heading("🎓", "Education")
      for entry in cv.education {
        timeline-row(entry.dates, {
          let title = if entry.title != "" { entry.title } else { entry.organization }
          text(weight: "bold", size: pt(s.body), fill: rgb(accent), title)
          if entry.title != "" and entry.organization != "" {
            linebreak()
            text(size: pt(s.small), fill: rgb(muted), entry.organization)
          }
        })
      }
    }
  ],
)
