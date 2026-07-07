// templates/category.typ — template for a single category's index page.
// A category page lists every post in its folder. It lives at
// content/posts/<cat>/index.typ (URL /posts/<cat>/) and the category name is
// derived from that folder, so you only set display metadata:
//   #show: category.with(title: "Rust", summary: [...], layout: "list")

#import "/templates/tola.typ": wrap-page
#import "/templates/base.typ": base, head, shell, category-of, card-grid, post-list, cap
#import "@tola/current:0.0.0": current-permalink
#import "@tola/pages:0.0.0": pages

/// The category owned by an index page at `/posts/<cat>/` — the last path
/// segment. Returns "" if the permalink isn't a category index page.
#let category-of-index(permalink) = {
  if permalink == none { return "" }
  let segs = permalink.split("/").filter(s => s != "")
  if segs.len() == 2 and segs.first() == "posts" { segs.at(1) } else { "" }
}

/// Posts filed under `cat`. Series posts (those with an `order`) come first in
/// reading sequence, so a tutorial series lists in order; any remaining posts
/// follow, newest first.
#let posts-in(cat) = {
  let all = pages().filter(p => category-of(p.permalink) == cat)
  let series = all
    .filter(p => p.at("order", default: none) != none)
    .sorted(key: p => p.order)
  let rest = all
    .filter(p => p.at("order", default: none) == none)
    .filter(p => p.at("date", default: none) != none)
    .sorted(key: p => p.date)
    .rev()
  series + rest
}

#let category = wrap-page(
  base: base,
  head: head,
  view: (body, meta) => shell({
    // Category name comes from the folder (permalink), but allow an explicit
    // `category:` override for a page placed outside the usual /posts/<cat>/.
    let name = meta.at("category", default: category-of-index(current-permalink))
    html.h1[#meta.at("title", default: cap(name))]
    let summary = meta.at("summary", default: none)
    if summary != none {
      html.elem("p", attrs: (class: "category-lede"))[#summary]
    }
    let posts = posts-in(name)
    if posts.len() == 0 {
      [_No posts in this category yet._]
    } else {
      // `layout` is set per category in content/posts/<cat>/index.typ:
      //   "grid" (default) — cover cards; "list" — compact ordered series index;
      //   "both"/"mix" — the list followed by the cards.
      let layout = meta.at("layout", default: "grid")
      if layout == "list" {
        post-list(posts)
      } else if layout == "both" or layout == "mix" {
        post-list(posts)
        card-grid(posts)
      } else {
        card-grid(posts)
      }
    }
    body
  }),
)
