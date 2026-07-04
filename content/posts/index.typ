// content/posts/index.typ  ->  /posts/   (the "Posts" nav target: full post list)
#import "/templates/page.typ": page, fmt-date
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Posts")

#let posts = (pages()
  .filter(p => "/posts/" in p.permalink)
  .filter(p => p.permalink != "/posts/") // exclude this index page itself
  .filter(p => p.at("date", default: none) != none)
  .sorted(key: p => p.date)
  .rev())

#for post in posts [
  - #link(post.permalink)[#post.title] — #fmt-date(post.date)
]
