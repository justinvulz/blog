// content/index.typ — home page: intro + list of recent posts
#import "/templates/page.typ": page, fmt-date, img
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Justin's Blog")

Welcome! This is my blog built with #link("https://github.com/tola-rs/tola-ssg")[Tola] and Typst.
#img("/images/test.avif")

= Recent posts

#let posts = (pages()
  .filter(p => "/posts/" in p.permalink)
  .filter(p => p.at("date", default: none) != none)
  .sorted(key: p => p.date)
  .rev())


#let recent = posts.slice(0, calc.min(posts.len(), 10))

#for post in recent [
  - #link(post.permalink)[#post.title] — #fmt-date(post.date)
]
