# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal blog built with [Tola SSG](https://github.com/tola-rs/tola-ssg) (v0.7.1), a static site generator that renders **Typst** (`.typ`) source to HTML. Content, templates, and page logic are all Typst — there is no JavaScript build step.

## Commands

- `tola serve` — live-reload dev server at http://127.0.0.1:5277 (config in `[serve]` of `tola.toml`).
- `tola build` — production build into `public/`.
- `tola build --clean` — wipe `public/` first. Use this after moving/renaming assets, since the asset manifest can go stale and cause misleading `not in any configured asset entry` errors.
- There is no test suite or linter. "Correctness" = the build succeeds; link/asset validation runs at build time (see below).

`tola` is installed via the Nix profile locally. The shell is `nu` (Nushell), not bash.

## Architecture

### Template layering (most important thing to understand)

```
templates/tola.typ   AUTO-GENERATED — do NOT edit. Provides wrap-page, tola-page, base show rules.
utils/tola.typ       AUTO-GENERATED — do NOT edit. Provides og-tags, cls, to-string, parse-date, etc.
        │  everything below builds on wrap-page
templates/base.typ   THE site-wide file. Header/nav/footer (shell), <head> tags (head),
                     heading show rules (base), nav-links list, fmt-date helper.
templates/post.typ   Post template  — title + date/author meta + body.
templates/page.typ   Plain-page template — title + body (index, about, posts list).
content/**/*.typ     Actual pages. Each applies a template via `#show: <template>.with(...)`.
```

`templates/tola.typ` and `utils/tola.typ` carry an "AUTO-GENERATED, avoid modifying" banner because they are regenerated on Tola upgrades — put all customization in `base.typ`/`post.typ`/`page.typ` instead. `wrap-page(base:, head:, view:, transform-meta:)` is the extension point: `base` sets show rules, `head(meta)` builds `<head>` content, `view(body, meta)` wraps the body with layout (this is where `shell(...)` is called).

### Writing a page

A content file is metadata + body:
```typ
#import "/templates/post.typ": post
#show: post.with(title: "...", date: "YYYY-MM-DD", author: "...", summary: [...], tags: (...))

Body in plain Typst markup...
```
Standard metadata fields recognized by Tola: `title, summary, date, update, author, draft, tags, permalink, aliases`. `draft: true` hides a page from `pages()`.

### Filename → URL mapping

`content/index.typ` → `/`, `content/about.typ` → `/about/`, `content/posts/first.typ` → `/posts/first/`, `content/posts/index.typ` → `/posts/`. Folder-style permalinks with trailing slash.

### pages() and the two-phase gotcha

`#import "@tola/pages:0.0.0": pages` lists pages for index/listing pages. It compiles in two phases: during the **scan/filter** phase `pages()` returns `[]` (dynamic content is skipped, then filled in during the compile phase) — this is normal, not a bug. Note dates from `pages()` may come back as **strings**, whereas inside a template `meta.date` is a **datetime**. Use `fmt-date` (in `base.typ`) to print either safely; only call `.display()` on values you know are datetime.

### Link and asset validation is ERROR-level

`tola.toml` sets `[validate.pages] level = "error"` and `[validate.assets] level = "error"`. Any internal `#link("/foo/")` to a page that doesn't exist **fails the whole build**. So when adding a nav entry (`nav-links` in `base.typ`) or any internal link, the target page must exist first. External URLs (`https://…`) skip validation.

### Styling / assets gotcha

`[site.header].styles` takes the **source-relative path** (`assets/styles/main.css`), NOT the output URL, and the directory must be listed under `[build.assets].nested`. Tola then mounts `assets/styles` → `/styles/` and injects the `<link>` with a cache-busting hash. Giving `styles` a URL like `/styles/main.css` fails validation. `nested = ["assets/styles"]` mounts by basename (`assets/styles` → `/styles/`, not `/assets/styles/`).

## Deployment

Auto-deploys via **Cloudflare Workers Builds** (native Git integration, not GitHub Actions) on every push to `main`:
- `wrangler.jsonc` — assets-only Worker serving `./public` (no server code).
- `build.sh` — the Cloudflare build command: downloads the pinned `tola` release binary and runs `tola build`. Bump `TOLA_VERSION` here (keep in sync with the local `tola --version`).
- Deploy command is the default `npx wrangler deploy`; Cloudflare runs the build on Ubuntu 24.04 and handles auth.

`public/`, `.tola/` (cache), and a stray `./tola` binary are gitignored — never commit build output.
