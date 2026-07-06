// templates/page.typ — template for standalone pages (index, about, ...).
// Used from a content file with:  #show: page.with(title: "...")

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell, fmt-date, img, columns, card-grid, post-card

// Extra metadata this template understands, beyond the standard fields:
//   narrow: true  -> constrain to a readable prose width (e.g. the About page).
#let page = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => {
    let narrow = meta.at("narrow", default: false)
    shell(
      {
        if meta.at("title", default: none) != none {
          html.h1[#meta.title]
        }
        body
      },
      content-class: if narrow { "content narrow" } else { "content" },
    )
  },
)
