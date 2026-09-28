// templates/base.typ — YOUR shared layout and show rules.
// Unlike templates/tola.typ (auto-generated), this file is yours to edit.
// Both post.typ and page.typ build on top of it, so site-wide changes
// (header, footer, heading styles, <head> tags) live here in one place.

#import "@tola/site:0.0.0": info
#import "@tola/current:0.0.0": current-permalink, headings
#import "@tola/pages:0.0.0": pages
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

/// Placeholder-cover stripe pairs, as CSS variables (themed in main.css). A post with no cover
/// image gets a deterministic striped block instead, keyed off its permalink.
#let _cover-stripes = (
  ("var(--stripe-1)", "var(--stripe-2)"),
  ("var(--stripe-3)", "var(--stripe-1)"),
  ("var(--stripe-2)", "var(--stripe-3)"),
  ("var(--stripe-1)", "var(--stripe-3)"),
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

/// Default display title for a category key — capitalize the first letter
/// (e.g. "rust" -> "Rust"). Real titles are set per-category in
/// content/posts/<cat>/index.typ via the `title:` field.
#let cap(name) = if name == "" { name } else { upper(name.first()) + name.slice(1) }

/// Presentation metadata for a category, read from its /posts/<cat>/ index page
/// (a normal page in `pages()`), NOT from any dict here. That page sets
/// `title`/`summary`/`cover`; this looks it up by its permalink `/posts/<cat>/`.
/// Returns a dict with `title`, `summary`, `cover` (defaults if the page or a
/// field is missing). During `pages()`'s scan phase everything falls back.
#let category-info(cat) = {
  let p = pages().find(p => p.at("permalink", default: none) == "/posts/" + cat + "/")
  (
    title: if p != none { p.at("title", default: cap(cat)) } else { cap(cat) },
    summary: if p != none { p.at("summary", default: none) } else { none },
    cover: if p != none { p.at("cover", default: none) } else { none },
  )
}

/// The cover block for a post: its `cover` image if set; otherwise, if the post
/// is under a category, that category's cover; otherwise a deterministic striped
/// placeholder (keyed off the permalink).
/// `post` is a `pages()` entry or a metadata dict.
#let post-cover(post) = {
  let cat = category-of(post.at("permalink", default: none))
  let cover = post.at("cover", default: none)
  if cover == none and cat != none {
    cover = category-info(cat).cover
  }
  cover-block(
    cover: cover,
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
      #if post.at("order", default: none) != none {
        html.elem("div", attrs: (class: "card-part"))[Part #post.order]
      }
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

/// A compact ordered "series index" of `posts` (already in reading order).
/// Each row is a numbered link — the post's `order` if set, else its position,
/// zero-padded — with the title and date. Good for a tutorial series.
#let post-list(posts) = html.elem("ol", attrs: (class: "series-index"))[
  #for (i, p) in posts.enumerate() {
    let n = p.at("order", default: i + 1)
    let num = if n < 10 { "0" + str(n) } else { str(n) }
    html.elem("li")[
      #html.elem("a", attrs: (class: "series-row", href: p.permalink))[
        #html.elem("span", attrs: (class: "series-num"))[#num]
        #html.elem("span", attrs: (class: "series-item-title"))[#p.title]
        #html.elem("span", attrs: (class: "series-item-date"))[#fmt-date(p.at("date", default: none))]
      ]
    ]
  }
]

/// Every distinct category (post sub-folder under /posts/) with its post count
/// and display metadata, alphabetical. `pages()` gives both the posts (for the
/// count) and the /categories/<cat>/ pages (for title/summary/cover).
#let category-entries() = {
  let cats = (pages()
    .filter(p => p.at("date", default: none) != none)
    .map(p => category-of(p.permalink))
    .filter(c => c != none))
  cats.dedup().sorted().map(name => {
    let info = category-info(name)
    (name: name, count: cats.filter(c => c == name).len(), ..info)
  })
}

/// A post-like card for a single category `entry` (from `category-entries`).
/// Links to /posts/<name>/ (that category's index page).
#let category-card(entry) = {
  html.elem("a", attrs: (class: "post-card", href: "/posts/" + entry.name + "/"))[
    #cover-block(
      cover: entry.at("cover", default: none),
      key: entry.name,
      label: entry.name,
      alt: entry.title,
    )
    #html.elem("div", attrs: (class: "card-body"))[
      #html.elem("div", attrs: (class: "card-cat"))[category]
      #html.elem("div", attrs: (class: "card-title"))[#entry.title]
      #if entry.at("summary", default: none) != none {
        html.elem("div", attrs: (class: "card-excerpt"))[#entry.summary]
      }
      #html.elem("div", attrs: (class: "card-date"))[
        #entry.count #if entry.count == 1 [post] else [posts]
      ]
    ]
  ]
}

/// Wrap the `category-entries()` list in the card grid.
#let category-grid(cats) = html.elem("div", attrs: (class: "card-grid"))[
  #for c in cats { category-card(c) }
]

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

/// Split a post date (datetime, or a "YYYY-MM-DD" string from `pages()`) into
/// its year and its "MM-DD" part, both strings.
#let date-parts(d) = {
  if type(d) == datetime {
    (year: str(d.year()), md: d.display("[month]-[day]"))
  } else {
    let s = to-string(d)
    (
      year: s.slice(0, calc.min(4, s.len())),
      md: if s.len() >= 10 { s.slice(5, 10) } else { s },
    )
  }
}

/// Home-page intro: a mono shell-prompt line over a large lede (the page's
/// <h1>) ending in a block cursor.
#let home-intro(body, prompt: "~/blog $ cat README") = html.elem("section", attrs: (class: "home-intro"))[
  #html.elem("div", attrs: (class: "home-prompt"))[#prompt]
  #html.elem("h1", attrs: (class: "home-lede"))[#body#html.elem("span", attrs: (class: "cursor", aria-hidden: "true"))[]]
]

/// A dated "log" of `posts` (already newest first), grouped under a big year
/// heading. Each row: MM-DD · category · title (+ summary) · Part N.
/// `more` is an optional URL shown as "All posts →" beside the first year.
#let post-log(posts, more: none) = {
  let years = posts.map(p => date-parts(p.date).year).dedup()
  html.elem("div", attrs: (class: "post-log"))[
    #for (i, y) in years.enumerate() {
      html.elem("div", attrs: (class: "log-year"))[
        #html.elem("h2", attrs: (class: "log-year-num"))[#y]
        // Lone links sit in a <div>: next to block siblings Typst would
        // otherwise wrap them in a <p> (and its prose styles).
        #if i == 0 and more != none {
          html.div(class: "log-more")[#html.elem("a", attrs: (href: more))[All posts →]]
        }
      ]
      html.elem("ol", attrs: (class: "log-list"))[
        #for p in posts.filter(p => date-parts(p.date).year == y) {
          let cat = category-of(p.permalink)
          html.elem("li")[
            #html.elem("a", attrs: (class: "log-row", href: p.permalink))[
              #html.span(class: "log-date")[#date-parts(p.date).md]
              #html.span(class: "log-cat")[#if cat != none { cat }]
              #html.span(class: "log-main")[
                #html.span(class: "log-title")[#p.title]
                #if p.at("summary", default: none) != none {
                  html.span(class: "log-excerpt")[#p.summary]
                }
              ]
              #html.span(class: "log-part")[#if p.at("order", default: none) != none [Part #p.order]]
            ]
          ]
        }
      ]
    }
  ]
}

/// Sidebar block spotlighting category `cat`: cover, title, summary, its first
/// `limit` posts (series order, like the category page) and a link to it.
#let featured-category(cat, limit: 5) = {
  let info = category-info(cat)
  let posts = posts-in(cat)
  let url = "/posts/" + cat + "/"
  html.elem("section", attrs: (class: "side-block"))[
    #html.elem("h2", attrs: (class: "side-label"))[Featured category]
    #html.div(class: "side-cover")[#html.elem("a", attrs: (href: url))[
      #cover-block(cover: info.cover, key: cat, label: cat, alt: info.title)
    ]]
    #html.elem("div", attrs: (class: "side-title"))[#info.title]
    #if info.summary != none {
      html.elem("div", attrs: (class: "side-summary"))[#info.summary]
    }
    #if posts.len() > 0 {
      html.elem("ol", attrs: (class: "side-list"))[
        #for (i, p) in posts.slice(0, calc.min(posts.len(), limit)).enumerate() {
          let n = p.at("order", default: i + 1)
          let num = if n < 10 { "0" + str(n) } else { str(n) }
          html.elem("li")[
            #html.elem("a", attrs: (class: "side-row", href: p.permalink))[
              #html.span(class: "side-num")[#num]
              #html.span(class: "side-row-title")[#p.title]
            ]
          ]
        }
      ]
    }
    #html.div(class: "side-link")[#html.elem("a", attrs: (href: url))[View the category →]]
  ]
}

/// Sidebar list of every category (from `category-entries()`) with its count.
#let category-list(cats) = if cats.len() > 0 {
  html.elem("section", attrs: (class: "side-block"))[
    #html.elem("h2", attrs: (class: "side-label"))[Categories]
    #html.elem("ul", attrs: (class: "side-cats"))[
      #for c in cats {
        html.elem("li")[
          #html.elem("a", attrs: (class: "side-cat", href: "/posts/" + c.name + "/"))[
            #html.span[#c.name]
            #html.span(class: "side-count")[#c.count]
          ]
        ]
      }
    ]
  ]
}

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

/// Posts in category `cat` that carry an `order`, sorted ascending — i.e. the
/// posts of a tutorial series in reading sequence. During `pages()`'s scan
/// phase this is `()`; it fills in during compile (the two-phase gotcha).
#let series-in(cat) = (pages()
  .filter(p => category-of(p.permalink) == cat)
  .filter(p => p.at("order", default: none) != none)
  .sorted(key: p => p.order))

/// Prev/next navigation within the current post's series (ordered by `order`).
/// Returns `none` when the post isn't part of an ordered series, so the caller
/// can skip it for standalone posts.
#let series-nav() = {
  if current-category == none { return none }
  let series = series-in(current-category)
  let idx = series.position(p => p.permalink == current-permalink)
  if idx == none { return none }
  let prev = if idx > 0 { series.at(idx - 1) } else { none }
  let next = if idx < series.len() - 1 { series.at(idx + 1) } else { none }
  if prev == none and next == none { return none }
  html.elem("nav", attrs: (class: "series-nav"))[
    #if prev != none {
      html.elem("a", attrs: (class: "series-link series-prev", href: prev.permalink))[
        #html.elem("span", attrs: (class: "series-nav-label"))[← Previous]
        #html.elem("span", attrs: (class: "series-nav-title"))[#prev.title]
      ]
    } else { html.elem("span") }
    #if next != none {
      html.elem("a", attrs: (class: "series-link series-next", href: next.permalink))[
        #html.elem("span", attrs: (class: "series-nav-label"))[Next →]
        #html.elem("span", attrs: (class: "series-nav-title"))[#next.title]
      ]
    }
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
      // The toggle sits beside <nav>, not in it: Typst treats <button> as a
      // block, which would wrap the inline nav links in a <p>.
      #html.div(class: "header-end")[
        #html.nav(class: "nav-links")[
          #for item in nav-links {
            link(item.url)[#html.span(
              class: if is-active(item.url) { "nav-link active" } else { "nav-link" },
            )[#item.label]]
          }
        ]
        // Light/dark toggle; wired up by assets/scripts/theme.js.
        #html.elem(
          "button",
          attrs: (class: "theme-toggle", type: "button", aria-label: "Toggle light/dark theme"),
        )[#html.span(class: "theme-icon")[]]
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
