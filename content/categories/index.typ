// content/categories/index.typ  ->  /categories/   (list of all categories)
#import "/templates/page.typ": page
#import "/templates/base.typ": category-of, category-grid
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Categories")

// Every distinct category (post sub-folder under /posts/) with its post count,
// alphabetical. Each becomes a post-like card via `category-grid`.
#let cats = {
  let names = (pages()
    .filter(p => p.at("date", default: none) != none)
    .map(p => category-of(p.permalink))
    .filter(c => c != none))
  names
    .dedup()
    .sorted()
    .map(c => (name: c, count: names.filter(n => n == c).len()))
}

#if cats.len() == 0 [
  _No categories yet._
] else [
  #category-grid(cats)
]
