// content/index.typ — home page: "field log" intro, dated post log grouped by
// year, and a sidebar with the featured category and the category list.
#import "/templates/page.typ": page
#import "/templates/base.typ": home-intro, post-log, featured-category, category-list, category-entries, category-of
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Justin's Blog", show-title: false)

#let posts = (pages()
  .filter(p => "/posts/" in p.permalink)
  .filter(p => p.permalink != "/posts/") // exclude the /posts/ index page
  .filter(p => p.at("date", default: none) != none)
  .sorted(key: p => p.date)
  .rev())

#let recent = posts.slice(0, calc.min(posts.len(), 10))

// Feature the category of the newest post that has one.
#let featured = posts.map(p => category-of(p.permalink)).find(c => c != none)

#home-intro[這裡是 Justin 的部落格。#linebreak()主要分享我平常研究的酷東西。]

#html.elem("div", attrs: (class: "home-grid"))[
  #post-log(recent, more: "/posts/")
  #html.elem("aside", attrs: (class: "home-side"))[
    #if featured != none { featured-category(featured) }
    #category-list(category-entries())
  ]
]
