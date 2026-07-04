// templates/category.typ — template for a single category's listing page.
// A category page lists every post whose folder matches `category`.
// Used from content/categories/<cat>.typ with:
//   #show: category.with(category: "rust", title: "Category: rust")

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell, fmt-date, category-of
#import "@tola/pages:0.0.0": pages

/// All posts filed under `cat`, newest first.
#let posts-in(cat) = (pages()
  .filter(p => category-of(p.permalink) == cat)
  .filter(p => p.at("date", default: none) != none)
  .sorted(key: p => p.date)
  .rev())

#let category = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => shell({
    let name = meta.at("category", default: "")
    html.h1[Category: #name]
    let posts = posts-in(name)
    if posts.len() == 0 {
      [_No posts in this category yet._]
    } else {
      for post in posts {
        [- #link(post.permalink)[#post.title] — #fmt-date(post.date)\ ]
      }
    }
    body
  }),
)
