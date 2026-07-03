// templates/base.typ — YOUR shared layout and show rules.
// Unlike templates/tola.typ (auto-generated), this file is yours to edit.
// Both post.typ and page.typ build on top of it, so site-wide changes
// (header, footer, heading styles, <head> tags) live here in one place.

#import "@tola/site:0.0.0": info
#import "/utils/tola.typ": og-tags

/// Format a date that may be a datetime (from a template) or a plain
/// string (as it comes back from `pages()`), so both are safe to print.
#let fmt-date(d) = {
  if d == none { return "" }
  if type(d) == datetime { d.display("[year]-[month]-[day]") } else { str(d) }
}

/// Show rules applied to every page's body.
/// Content-level `= Heading` becomes <h2> so the single page/post <h1>
/// (rendered by the layout below) stays unique for accessibility/SEO.
#let base(body) = {
  show heading.where(level: 1): it => html.h2[#it.body]
  body
}

/// Per-page <head> content, derived from the page's metadata.
#let head(meta) = og-tags(
  title: meta.at("title", default: info.title),
  description: meta.at("summary", default: info.description),
  published: meta.at("date", default: none),
  author: meta.at("author", default: info.author),
  tags: meta.at("tags", default: ()),
  site-name: info.title,
)

/// Site chrome (header + footer) wrapped around every page body.
#let shell(body) = {
  html.header(class: "site-header")[
    #html.div(class: "wrap")[
      #link("/")[#html.span(class: "site-title")[#info.title]]
    ]
  ]
  html.main(class: "wrap content")[#body]
  html.footer(class: "site-footer")[
    #html.div(class: "wrap")[
      © #info.author
    ]
  ]
}
