// templates/post.typ — template for blog posts.
// Used from a post file with:  #show: post.with(title: "...", date: "...", ...)

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell, fmt-date

#let post = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => shell(html.article(class: "post")[
    #if meta.at("title", default: none) != none {
      html.h1[#meta.title]
    }
    #if meta.at("date", default: none) != none {
      html.p(class: "post-meta")[
        #fmt-date(meta.date)
        #if meta.at("author", default: none) != none [ · #meta.author]
      ]
    }
    #body
  ]),
)
