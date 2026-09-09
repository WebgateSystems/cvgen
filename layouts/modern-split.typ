// Hybrid: experience full width, then skills | education. Optional sections.
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
#let pill-bg = colors.at("pill_bg", default: "#e8f1fb")
#let pill-fg = colors.at("pill_text", default: colors.accent)

#set page(paper: "a4", margin: mm(sp.page_margin_mm))
#set text(font: t.fonts.body, size: pt(s.body), fill: rgb(colors.text), lang: "en")
#set par(leading: 0.4em, spacing: 0.5em)

#let section-title(title) = {
  v(pt(sp.section_gap_pt), weak: true)
  text(font: t.fonts.heading, size: pt(s.section), weight: "bold", fill: rgb(colors.accent), upper(title))
  v(3pt, weak: true)
  line(length: 100%, stroke: 0.7pt + rgb(colors.rule))
  v(6pt, weak: true)
}

#let skill-pills(items) = {
  let boxes = items.map(item => box(
    fill: rgb(pill-bg),
    inset: (x: 6pt, y: 3.5pt),
    radius: 3pt,
    text(size: pt(s.small), fill: rgb(pill-fg), item-text(item)),
  ))
  boxes.join(h(4pt))
}

#let timeline-entry(entry) = {
  grid(
    columns: (16%, 8pt, 1fr),
    column-gutter: 6pt,
    text(size: pt(s.small), fill: rgb(colors.muted), entry.dates),
    align(center)[#circle(radius: 2.4pt, fill: rgb(colors.accent))],
    {
      text(font: t.fonts.heading, weight: "bold", size: pt(s.body), entry.title)
      linebreak()
      text(size: pt(s.body), entry.organization)
      if "url" in entry and entry.url != "" {
        linebreak()
        text(size: pt(s.small), fill: rgb(colors.muted), entry.url)
      }
      if "highlights" in entry and entry.highlights.len() > 0 {
        v(2pt, weak: true)
        for h in entry.highlights {
          text(size: pt(s.small), [• #item-text(h)])
          linebreak()
        }
      }
      v(pt(sp.item_gap_pt))
    },
  )
}

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 12pt,
  {
    stack(
      spacing: pt(s.name) * 0.28,
      text(font: t.fonts.heading, size: pt(s.name), weight: "bold", fill: rgb(colors.accent), cv.basics.name),
      if "headline" in cv.basics and cv.basics.headline != "" {
        text(size: pt(s.headline), fill: rgb(colors.muted), cv.basics.headline)
      },
      if has-summary {
        v(4pt)
        text(size: pt(s.small), cv.summary)
      },
    )
  },
  align(right)[
    #text(size: pt(s.contact), {
      let parts = ()
      if "phones" in cv.basics {
        for phone in cv.basics.phones { parts.push([(#phone.label) #phone.number]) }
      }
      if "email" in cv.basics and cv.basics.email != "" { parts.push(cv.basics.email) }
      if "location" in cv.basics and cv.basics.location != "" { parts.push(cv.basics.location) }
      parts.join(linebreak())
    })
  ],
)

#if present(cv.experience) {
  section-title("Experience")
  for entry in cv.experience { timeline-entry(entry) }
}

#let skills = cv.essential_skills + cv.additional_skills
#let show-bottom = present(skills) or present(cv.education) or present(cv.languages)

#if show-bottom {
  let left-ratio = sp.left_column_ratio
  grid(
    columns: (left-ratio * 1fr, (1 - left-ratio) * 1fr),
    column-gutter: mm(sp.column_gutter_mm),
    {
      if present(skills) {
        section-title("Skills")
        skill-pills(skills)
      }
      if present(cv.languages) {
        section-title("Languages")
        skill-pills(cv.languages)
      }
    },
    {
      if present(cv.education) {
        section-title("Education")
        for entry in cv.education { timeline-entry(entry) }
      }
    },
  )
}
