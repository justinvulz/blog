#import "/templates/post.typ": post

#let args = (
  title: "Understanding Ownership",
  date: "2026-03-10",
  author: "Justin",
  summary: [A quick tour of Rust's ownership model],
  tags: ("rust", "memory"),
)

#show: post.with(..args)

This post lives under `content/posts/rust/`, so it is automatically filed
under the *rust* category.

= Moves and borrows

Ownership is Rust's headline feature.
