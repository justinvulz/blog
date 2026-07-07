// content/categories.typ  ->  /categories/   (list of all categories)
#import "/templates/page.typ": page
#import "/templates/base.typ": category-entries, category-grid

#show: page.with(title: "Categories")

// Every distinct category (post sub-folder under /posts/) with its post count
// and display metadata (title/summary/cover come from each posts/<cat>/index.typ).
#let cats = category-entries()

#if cats.len() == 0 [
  _No categories yet._
] else [
  #category-grid(cats)
]
