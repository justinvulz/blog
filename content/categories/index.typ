// content/categories/index.typ  ->  /categories/   (list of all categories)
#import "/templates/page.typ": page
#import "/templates/base.typ": category-of
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Categories")

// Every distinct category (post sub-folder under /posts/), alphabetical.
#let cats = (pages()
  .filter(p => p.at("date", default: none) != none)
  .map(p => category-of(p.permalink))
  .filter(c => c != none)
  .dedup()
  .sorted())

#if cats.len() == 0 [
  _No categories yet._
] else [
  #for cat in cats [
    - #link("/categories/" + cat + "/")[#(upper(cat.first()) + cat.slice(1))]
  ]
]
