// Category index page for `nixos`  ->  /posts/nixos/
// Holds this category's display metadata; lists its posts. Safe to edit.
// Scaffolded by scripts/gen-categories.sh, which won't overwrite this file.
#import "/templates/category.typ": category
#show: category.with(
  title: "NixOS",
  summary: [A hands-on NixOS tutorial series — practical, beginner-friendly notes.],
  layout: "list", // "grid" (cards) | "list" (ordered series index) | "both"
  // cover: "/images/nixos.avif",
)
