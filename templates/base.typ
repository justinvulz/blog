// templates/base.typ — YOUR shared layout and show rules.
// Unlike templates/tola.typ (auto-generated), this file is yours to edit.
// Both post.typ and page.typ build on top of it, so site-wide changes
// (header, footer, heading styles, <head> tags) live here in one place.

#import "@tola/site:0.0.0": info
#import "@tola/current:0.0.0": current-permalink, headings
#import "/utils/tola.typ": og-tags, to-string

/// Format a date that may be a datetime (from a template) or a plain
/// string (as it comes back from `pages()`), so both are safe to print.
#let fmt-date(d) = {
  if d == none { return "" }
  if type(d) == datetime { d.display("[year]-[month]-[day]") } else { str(d) }
}

/// Derive a post's category from its permalink: the folder segment right
/// after `/posts/`. A post at `/posts/rust/my-post/` is in category "rust";
/// a post directly under `/posts/my-post/` (no sub-folder) has no category.
/// Returns the category string, or `none`.
#let category-of(permalink) = {
  if permalink == none { return none }
  let segs = permalink.split("/").filter(s => s != "")
  if segs.len() >= 3 and segs.first() == "posts" { segs.at(1) } else { none }
}

/// Category of the page currently being rendered (or `none`).
#let current-category = category-of(current-permalink)

/// Insert a web image by its served URL (e.g. "/images/cat.jpg").
/// Always pass `alt` for accessibility. With `caption`, wraps in a <figure>.
/// Files live in `assets/images/` and are served at `/images/...`.
#let img(src, alt: "", caption: none) = {
  let el = html.elem("img", attrs: (src: src, alt: alt))
  if caption == none {
    el
  } else {
    html.figure[
      #el
      #html.elem("figcaption")[#caption]
    ]
  }
}

/// Lay out content in equal-width columns. Typst's `grid` is a layout
/// primitive that HTML export drops, so this emits a CSS-grid <div> instead.
/// `cols` sets the number of columns; `gap` is any CSS length.
#let columns(..items, cols: 2, gap: "1rem") = html.elem(
  "div",
  attrs: (
    class: "columns",
    style: "grid-template-columns: repeat(" + str(cols) + ", minmax(0, 1fr)); gap: " + gap + ";",
  ),
)[#for it in items.pos() { html.elem("div")[#it] }]

/// Warm placeholder-cover stripe pairs (from the design). A post with no cover
/// image gets a deterministic striped block instead, keyed off its permalink.
#let _cover-stripes = (
  ("#8c8264", "#b08a76"),
  ("#9c8a9c", "#8c8264"),
  ("#b08a76", "#9c8a9c"),
  ("#8c8264", "#9c8a9c"),
)
#let _stripe-for(key) = _cover-stripes.at(
  calc.rem(to-string(key).len(), _cover-stripes.len()),
)

/// A cover block: the `cover` image if set, otherwise a deterministic striped
/// placeholder (keyed off `key`) with `label` centered on it. Shared by post
/// cards and category cards so both look the same.
#let cover-block(cover: none, key: "", label: none, alt: "") = {
  if cover != none {
    html.elem("div", attrs: (class: "card-cover"))[
      #html.elem("img", attrs: (class: "card-cover-img", src: cover, alt: alt))
    ]
  } else {
    let stripes = _stripe-for(key)
    html.elem("div", attrs: (class: "card-cover", style: "background:" + stripes.at(0) + ";"))[
      #html.elem("div", attrs: (class: "card-cover-bar", style: "background:" + stripes.at(1) + ";"))[]
      #if label != none {
        html.elem("div", attrs: (class: "card-cover-label"))[#label]
      }
    ]
  }
}

/// The cover block for a post: its `cover` image if set, otherwise a
/// deterministic striped placeholder (keyed off the permalink).
/// `post` is a `pages()` entry or a metadata dict.
#let post-cover(post) = {
  let cat = category-of(post.at("permalink", default: none))
  cover-block(
    cover: post.at("cover", default: none),
    key: post.at("permalink", default: post.at("title", default: "")),
    label: if cat != none { cat } else { "post" },
    alt: to-string(post.at("title", default: "")),
  )
}

/// A single post card for listing grids. `post` is a `pages()` entry (needs
/// `permalink`, `title`, and ideally `summary`/`date`/`cover`). Emits the
/// design's card: cover (image or stripes), category label, title, excerpt, date.
#let post-card(post) = {
  let cat = category-of(post.permalink)
  html.elem("a", attrs: (class: "post-card", href: post.permalink))[
    #post-cover(post)
    #html.elem("div", attrs: (class: "card-body"))[
      #if cat != none { html.elem("div", attrs: (class: "card-cat"))[#cat] }
      #html.elem("div", attrs: (class: "card-title"))[#post.title]
      #if post.at("summary", default: none) != none {
        html.elem("div", attrs: (class: "card-excerpt"))[#post.summary]
      }
      #html.elem("div", attrs: (class: "card-date"))[
        #fmt-date(post.at("date", default: none))
      ]
    ]
  ]
}

/// Wrap a sequence of `pages()` entries in the responsive card grid.
#let card-grid(posts) = html.elem("div", attrs: (class: "card-grid"))[
  #for p in posts { post-card(p) }
]

/// Optional per-category presentation metadata. Keys are category names (the
/// post sub-folder under /posts/). Categories are derived from folders, so this
/// dict is the one place to give a category a nicer face. Each value may set:
///   cover:   image URL for the category card + header (else striped placeholder)
///   title:   display name (else the capitalized folder name)
///   summary: short description shown on the card and the category page
/// Categories missing here still work — they fall back to these defaults.
#let category-meta = (
  rust: (
    summary: [Ownership, lifetimes, and systems-programming notes.],
    // cover: "/images/rust.avif",
  ),
)

/// Presentation dict for a category (empty if none configured).
#let category-info(cat) = category-meta.at(cat, default: (:))

/// Display title for a category: its configured `title`, else the capitalized
/// folder name (e.g. "rust" -> "Rust").
#let category-title(cat) = category-info(cat).at(
  "title",
  default: upper(cat.first()) + cat.slice(1),
)

/// A post-like card for a single category. `cat` is the folder name and
/// `count` the number of posts filed under it. Links to /categories/<cat>/.
#let category-card(cat, count) = {
  let m = category-info(cat)
  html.elem("a", attrs: (class: "post-card", href: "/categories/" + cat + "/"))[
    #cover-block(
      cover: m.at("cover", default: none),
      key: cat,
      label: cat,
      alt: category-title(cat),
    )
    #html.elem("div", attrs: (class: "card-body"))[
      #html.elem("div", attrs: (class: "card-cat"))[category]
      #html.elem("div", attrs: (class: "card-title"))[#category-title(cat)]
      #if m.at("summary", default: none) != none {
        html.elem("div", attrs: (class: "card-excerpt"))[#m.summary]
      }
      #html.elem("div", attrs: (class: "card-date"))[
        #count #if count == 1 [post] else [posts]
      ]
    ]
  ]
}

/// Wrap a sequence of `(name, count)` category entries in the card grid.
#let category-grid(cats) = html.elem("div", attrs: (class: "card-grid"))[
  #for c in cats { category-card(c.name, c.count) }
]

/// Turn heading text into a URL-safe anchor id. ASCII letters/digits are kept,
/// whitespace/underscores become dashes, punctuation is dropped, and any other
/// character (e.g. CJK) is kept as-is so those headings still get a usable id.
#let slug(s) = {
  let keep = "abcdefghijklmnopqrstuvwxyz0123456789"
  let sep = " \t\n-_"
  let drop = ".,;:!?'`\"“”‘’()[]{}<>/\\|@#$%^&*=+~"
  let out = ""
  for c in lower(to-string(s)).clusters() {
    if c in keep { out += c } else if c in sep { out += "-" } else if c in drop {
      // dropped
    } else { out += c }
  }
  while "--" in out { out = out.replace("--", "-") }
  out.trim("-")
}

/// Show rules applied to every page's body.
/// Content headings are demoted one level (so the single page/post <h1> stays
/// unique) and given an `id` so the side overview can link to them.
#let base(body) = {
  show heading: it => html.elem(
    "h" + str(calc.min(it.level + 1, 6)),
    attrs: (id: slug(it.body)),
  )[#it.body]
  body
}

/// Side "On this page" overview built from the current page's headings.
/// Returns `none` when the page has no headings.
#let post-overview() = {
  if headings.len() == 0 { return none }
  let min-level = calc.min(..headings.map(h => h.level))
  html.elem("aside", attrs: (class: "post-toc"))[
    #html.elem("p", attrs: (class: "post-toc-title"))[On this page]
    #html.elem("ul", attrs: (class: "post-toc-list"))[
      #for h in headings {
        html.elem("li", attrs: (class: "toc-l" + str(h.level - min-level)))[
          #html.elem("a", attrs: (href: "#" + slug(h.text)))[#h.text]
        ]
      }
    ]
  ]
}

/// Per-page <head> content, derived from the page's metadata.
#let head(meta) = og-tags(
  title: meta.at("title", default: info.title),
  description: meta.at("summary", default: info.description),
  published: meta.at("date", default: none),
  author: meta.at("author", default: info.author),
  tags: meta.at("tags", default: ()),
  site-name: info.title,
)

/// Top navigation links. Edit this list to change the nav bar.
/// Each `url` must point to a page that exists (link validation is on).
#let nav-links = (
  (url: "/", label: "Home"),
  (url: "/posts/", label: "Posts"),
  (url: "/categories/", label: "Categories"),
  (url: "/about/", label: "About"),
)

/// True when `url` is the current page — exact match, or a prefix match for
/// sections (so "/posts/" stays highlighted while reading "/posts/my-post/").
#let is-active(url) = {
  if current-permalink == none { return false }
  if url == "/" { current-permalink == "/" } else {
    current-permalink == url or current-permalink.starts-with(url)
  }
}

/// Site chrome (header + nav + footer) wrapped around every page body.
/// `content-class` sets the width/layout of the main column:
///   "content"              default listing width,
///   "content narrow"       readable prose width (about, plain pages),
///   "content post-single"  a post with no side overview,
///   "content post-wide"    a post plus its sticky "On this page" overview.
#let shell(body, content-class: "content") = {
  html.header(class: "site-header")[
    #html.div(class: "wrap header-inner")[
      #link("/")[#html.span(class: "site-title")[#info.title#html.span(class: "logo-dot")[.]]]
      #html.nav(class: "nav-links")[
        #for item in nav-links {
          link(item.url)[#html.span(
            class: if is-active(item.url) { "nav-link active" } else { "nav-link" },
          )[#item.label]]
        }
      ]
    ]
  ]
  html.main(class: "wrap " + content-class)[#body]
  html.footer(class: "site-footer")[
    #html.div(class: "wrap")[
      © 2026 #info.title — built with Tola & Typst
    ]
  ]
}
