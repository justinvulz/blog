#import "/templates/post.typ": post, img, columns

#let args = (
  title: "Typst Basic Syntax",
  date: "2026-02-24",
  author: "Tola",
  summary: [Typst syntax guide and how it renders to HTML],
  tags: ("typst", "html", "tutorial"),
)

#show: post.with(..args)

Everything below `#show: post.with(...)` is the *body* of your post,
written in ordinary Typst markup. Tola renders it straight to HTML.

#columns(
  img("/images/test.avif"),
  img("/images/test.avif"),
)

= A section heading

Use `=` for headings. Inline styles: *bold*, _italic_, `inline code`,
and #link("https://typst.app/docs")[links].

== A subsection

- Bullet lists with `-`
- A second item
  - And nested items

+ Numbered lists with `+`
+ Second step

> Blockquotes start a line with `>`.

A fenced code block:

```rust
fn main() {
    println!("Hello from Tola!");
}
```

Math works too, inline $a^2 + b^2 = c^2$ and as a block:

$ sum_(i=1)^n i = (n (n+1)) / 2 $

= Second section
#lorem(30)
