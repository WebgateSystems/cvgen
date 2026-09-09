// Two-column CV. Optional sections + theme.scale from resume.json.
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

#set page(paper: "a4", margin: mm(sp.page_margin_mm))
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.5em, spacing: 0.55em)

#let section-title(title) = {
  block(spacing: pt(sp.section_gap_pt))[
    #text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(colors.accent), upper(title))
    #v(2pt, weak: true)
    #line(length: 100%, stroke: 0.6pt + rgb(colors.rule))
    #v(4pt, weak: true)
  ]
}

#let bullet-list(items) = {
  for item in items {
    block(spacing: pt(sp.item_gap_pt))[
      #text(size: pt(s.small), item-text(item))
    ]
  }
}

#let experience-entry(entry) = {
  block(spacing: pt(sp.item_gap_pt) + 2pt)[
    #text(size: pt(s.small), fill: rgb(colors.muted), entry.dates)
    #linebreak()
    #text(font: t.fonts.heading, weight: "bold", size: pt(s.body), entry.title)
    #linebreak()
    #text(size: pt(s.body), entry.organization)
    #if "url" in entry and entry.url != "" {
      linebreak()
      text(size: pt(s.small), fill: rgb(colors.muted), entry.url)
    }
    #if "highlights" in entry and entry.highlights.len() > 0 {
      v(2pt, weak: true)
      for h in entry.highlights {
        block(inset: (left: 0.6em), spacing: 1.5pt)[
          #text(size: pt(s.small), [• #item-text(h)])
        ]
      }
    }
  ]
}

#let education-entry(entry) = {
  block(spacing: pt(sp.item_gap_pt))[
    #text(size: pt(s.small), fill: rgb(colors.muted), entry.dates)
    #linebreak()
    #text(weight: "bold", size: pt(s.small), entry.organization)
    #if "title" in entry and entry.title != "" {
      linebreak()
      text(size: pt(s.small), entry.title)
    }
  ]
}

#align(center)[
  #stack(
    spacing: pt(s.name) * 0.28,
    text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(colors.accent), upper(cv.basics.name)),
    if "headline" in cv.basics and cv.basics.headline != "" {
      text(font: t.fonts.heading, size: pt(s.headline), fill: rgb(colors.muted), cv.basics.headline)
    },
    text(size: pt(s.contact), {
      let parts = ()
      if "phones" in cv.basics {
        for phone in cv.basics.phones {
          parts.push([(#phone.label): #phone.number])
        }
      }
      if "email" in cv.basics and cv.basics.email != "" {
        parts.push(cv.basics.email)
      }
      if "location" in cv.basics and cv.basics.location != "" {
        parts.push(cv.basics.location)
      }
      parts.join("  ·  ")
    }),
  )
]

#if has-summary {
  v(pt(sp.section_gap_pt))
  text(size: pt(s.body), cv.summary)
}

#v(pt(sp.section_gap_pt))
#line(length: 100%, stroke: 0.8pt + rgb(colors.rule))
#v(pt(sp.section_gap_pt))

#let left-ratio = sp.left_column_ratio
#let show-left = present(cv.essential_skills) or present(cv.additional_skills) or present(cv.languages)

#if show-left {
  grid(
    columns: (left-ratio * 1fr, (1 - left-ratio) * 1fr),
    column-gutter: mm(sp.column_gutter_mm),
    {
      if present(cv.essential_skills) {
        section-title("Essential Skills")
        bullet-list(cv.essential_skills)
      }
      if present(cv.additional_skills) {
        v(pt(sp.section_gap_pt))
        section-title("Additional Skills")
        bullet-list(cv.additional_skills)
      }
      if present(cv.languages) {
        v(pt(sp.section_gap_pt))
        section-title("Languages")
        bullet-list(cv.languages)
      }
    },
    {
      if present(cv.experience) {
        section-title("Professional Experience")
        for entry in cv.experience { experience-entry(entry) }
      }
      if present(cv.education) {
        v(pt(sp.section_gap_pt))
        section-title("Education")
        for entry in cv.education { education-entry(entry) }
      }
    },
  )
} else {
  if present(cv.experience) {
    section-title("Professional Experience")
    for entry in cv.experience { experience-entry(entry) }
  }
  if present(cv.education) {
    v(pt(sp.section_gap_pt))
    section-title("Education")
    for entry in cv.education { education-entry(entry) }
  }
}
