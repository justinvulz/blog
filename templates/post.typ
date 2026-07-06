// templates/post.typ — template for blog posts.
// Used from a post file with:  #show: post.with(title: "...", date: "...", ...)

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell, fmt-date, post-overview, img, columns, current-category

#let post = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => {
    let article = html.article(class: "post")[
      #if meta.at("title", default: none) != none {
        html.h1[#meta.title]
      }
      #if meta.at("date", default: none) != none {
        html.p(class: "post-meta")[
          #fmt-date(meta.date)
          #if meta.at("author", default: none) != none [ · #meta.author]
          #if current-category != none [ · #html.span(class: "post-category")[#current-category]]
        ]
      }
      #body
    ]
    let overview = post-overview()
    if overview == none {
      shell(article, content-class: "content post-single")
    } else {
      // Two columns on wide screens: article + sticky side overview.
      shell(html.elem("div", attrs: (class: "post-layout"))[
        #article
        #overview
      ], content-class: "content post-wide")
    }
  },
)
