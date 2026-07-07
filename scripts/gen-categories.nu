#!/usr/bin/env nu
# Auto-generate one category index page per post sub-folder.
#
# A category's listing page lives at content/posts/<cat>/index.typ and serves
# /posts/<cat>/. Tola has no dynamic routes and link validation is error-level,
# so every category folder needs this file. For each folder content/posts/<cat>/
# that lacks an index.typ we scaffold one. Idempotent — safe to re-run.
#
# Because the page lives *inside* its category folder, it can never go stale:
# removing the folder removes the page with it, so there is nothing to prune.
#
# Local convenience only (not run on deploy). Run after adding a category
# folder:  nu scripts/gen-categories.nu
def main [] {
  let root = ($env.FILE_PWD | path dirname)
  let posts_dir = $"($root)/content/posts"

  # Only sub-folders of content/posts/ are categories.
  for folder in (ls $posts_dir | where type == dir) {
    let name = ($folder.name | path basename)
    let key = ($name | str downcase)   # Tola lowercases folders in permalinks,
                                       # so this is the category name in permalinks.
    let stub = ($folder.name | path join "index.typ")

    # Scaffold a stub only if missing. This file holds the category's display
    # metadata (title/summary/cover/layout) and is meant to be hand-edited —
    # so we never overwrite one that already exists.
    if ($stub | path exists) { continue }

    let title = ($name | str capitalize)   # starter display title (edit freely)
    let content = (
      r#'// Category index page for `{{key}}`  ->  /posts/{{key}}/
// Holds this category's display metadata; lists its posts. Safe to edit.
// Scaffolded by scripts/gen-categories.nu, which won't overwrite this file.
#import "/templates/category.typ": category
#show: category.with(
  title: "{{title}}",
  // summary: [Short description shown on the /categories/ card and the page.],
  // layout: "grid", // "grid" (cards) | "list" (ordered series index) | "both"
  // cover: "/images/{{key}}.avif",
)
'#
      | str replace --all "{{key}}" $key
      | str replace --all "{{title}}" $title
    )
    $content | save $stub
    print $"  posts/($key)/index.typ \(new)"
  }
}
