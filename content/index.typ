// content/index.typ — home page: hero headline + card grid of recent posts
#import "/templates/page.typ": page, card-grid
#import "@tola/pages:0.0.0": pages

#show: page.with(title: "Justin's Blog")

#let posts = (pages()
  .filter(p => "/posts/" in p.permalink)
  .filter(p => p.permalink != "/posts/") // exclude the /posts/ index page
  .filter(p => p.at("date", default: none) != none)
  .sorted(key: p => p.date)
  .rev())

#let recent = posts.slice(0, calc.min(posts.len(), 6))

#card-grid(recent)
