// templates/page.typ — template for standalone pages (index, about, ...).
// Used from a content file with:  #show: page.with(title: "...")

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell

#let page = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => shell({
    if meta.at("title", default: none) != none {
      html.h1[#meta.title]
    }
    body
  }),
)
