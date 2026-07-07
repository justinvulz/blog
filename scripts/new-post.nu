#!/usr/bin/env nu
# Scaffold a new blog post.
#
# Creates content/posts/<slug>.typ (or content/posts/<category>/<slug>.typ)
# pre-filled with the post template: title, today's date, author, summary,
# tags, and an optional cover. The slug is derived from the title.
#
# Examples:
#   nu scripts/new-post.nu "My First Post"
#   nu scripts/new-post.nu "Understanding Ownership" --category rust --tags "rust, memory"
#   nu scripts/new-post.nu "Nix Flakes" -c nixos -s "Reproducible dev shells" --cover /images/flake.avif
#
# When --category names a NEW folder, its /posts/<cat>/ index page is
# scaffolded automatically (via scripts/gen-categories.nu).
def main [
  title: string                 # Post title (required)
  --category (-c): string = ""  # Category = sub-folder under content/posts/
  --author (-a): string = "Justin"
  --summary (-s): string = ""   # Card excerpt / meta description
  --tags (-t): string = ""      # Comma-separated, e.g. "rust, memory"
  --cover: string = ""          # Optional cover image URL, e.g. /images/foo.avif
  --force (-f)                  # Overwrite an existing file
] {
  let root = ($env.FILE_PWD | path dirname)

  # title -> url-safe slug
  let slug = (
    $title
    | str downcase
    | str replace --all --regex '[^a-z0-9]+' '-'
    | str trim --char '-'
  )
  if ($slug | is-empty) {
    error make { msg: $"Could not derive a slug from title: '($title)'" }
  }

  let dir = if ($category | is-empty) {
    $"($root)/content/posts"
  } else {
    $"($root)/content/posts/($category)"
  }
  let file = $"($dir)/($slug).typ"

  if ($file | path exists) and (not $force) {
    error make { msg: $"Post already exists: ($file) — pass --force to overwrite." }
  }

  # Build the Typst tags tuple: () / ("a",) / ("a", "b")
  let tag_list = (
    $tags | split row ',' | each { |t| $t | str trim } | where { |t| $t != "" }
  )
  let tags_typ = if ($tag_list | is-empty) {
    "()"
  } else {
    let inner = ($tag_list | each { |t| '"' + $t + '"' } | str join ', ')
    let tail = if ($tag_list | length) == 1 { "," } else { "" }
    "(" + $inner + $tail + ")"
  }

  let today = (date now | format date "%Y-%m-%d")
  let is_new_category = (not ($category | is-empty)) and (not ($dir | path exists))

  mut lines = [
    '#import "/templates/post.typ": post, img, columns'
    ''
    '#let args = ('
    ('  title: "' + $title + '",')
    ('  date: "' + $today + '",')
    ('  author: "' + $author + '",')
  ]
  # Omit empty summary/cover: an empty Typst content block (`[]`) breaks the
  # OG-description meta tag, so only emit these fields when they have a value.
  if not ($summary | is-empty) {
    $lines = ($lines | append ('  summary: [' + $summary + '],'))
  }
  $lines = ($lines | append ('  tags: ' + $tags_typ + ','))
  if not ($cover | is-empty) {
    $lines = ($lines | append ('  cover: "' + $cover + '",'))
  }
  $lines = ($lines | append [
    ')'
    ''
    '#show: post.with(..args)'
    ''
    'Write your post here.'
    ''
    '= First section'
    ''
    'Body text in ordinary Typst markup.'
  ])

  mkdir $dir
  ($lines | str join "\n") + "\n" | save --force $file

  # A brand-new category folder needs its /posts/<cat>/ index page.
  if $is_new_category {
    print $"New category '($category)' — regenerating category pages..."
    nu $"($root)/scripts/gen-categories.nu"
  }

  let url = if ($category | is-empty) {
    $"/posts/($slug)/"
  } else {
    $"/posts/($category)/($slug)/"
  }
  print $"Created ($file)"
  print $"        will publish at ($url)"
}
