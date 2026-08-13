# coder0xe.github.io

Personal blog repository powered by [Hugo](https://gohugo.io/) + PaperMod.

- Production site: `https://coder0xe.github.io/`
- Deployment: GitHub Actions builds and publishes to the `gh-pages` branch

## Project Structure

```text
.
├── content/
│   └── posts/              # Markdown posts
├── static/
│   └── img/                # Post images (recommended location)
├── themes/PaperMod/        # Theme
├── .github/workflows/
│   └── deploy-pages.yml    # Pages deployment workflow (multi-branch)
├── tests/
│   └── writing-tools.sh    # Local writing command tests
├── Makefile                # Create, preview, and build commands
└── hugo.toml               # Hugo config
```

## Local Writing

### 1. Prepare the toolchain

Install Hugo Extended `0.155.3` or newer. Then check the environment at the repository root:

```bash
brew install hugo
```

If Hugo is already installed, continue with:

```bash
make doctor
```

List all writing commands provided by the repository:

```bash
make help
```

### 2. Create a draft

`POST` is the post filename. A short English or pinyin slug is recommended:

```bash
make new POST=my-first-post
```

This creates `content/posts/my-first-post.md` with `draft = true`, so it is excluded from production builds. Fill in the title, description, tags, categories, and content.

Put post images in `static/img/` and use a site-absolute path in Markdown:

```md
![Alt text](/img/example.png)
```

### 3. Preview as you write

```bash
make serve
```

Open `http://localhost:1313/`. Hugo rebuilds after each save; this command includes drafts and navigates to the page most recently changed.

### 4. Check before publishing

When the post is ready, change this Front Matter field:

```toml
draft = true
```

to:

```toml
draft = false
```

Then run a production build check:

```bash
make check
```

The generated site is stored in the Git-ignored `public/` directory. GitHub Actions publishes it after the commit is pushed.

Without Make, run `hugo server --buildDrafts --navigateToChanged --cacheDir "$PWD/.hugo_cache"` for preview or `hugo --gc --minify --cleanDestinationDir --cacheDir "$PWD/.hugo_cache"` for a production build.

## Writing Rules (Important)

### Image Paths

Use **site-absolute paths** for images. Do not use `../img` relative paths.

Recommended:

```md
![demo](/img/example.png)
```

Not recommended:

```md
![demo](../img/example.png)
![demo](./../img/example.png)
```

### Front Matter

- `date` must be parseable, e.g. `2026-02-17T21:00:00+08:00`
- `tags` / `categories` / `keywords` should be arrays
- Keep `draft = true` while writing and change it to `draft = false` when publishing

Example:

```yaml
---
title: "Sample Post"
date: 2026-02-17T21:00:00+08:00
description: "Post summary"
draft: false
tags: ["Hugo", "Blog"]
categories: ["Tech"]
keywords: ["hugo", "github pages"]
---
```

## GitHub Pages Deployment (Multi-Branch Strategy)

Workflow file: `.github/workflows/deploy-pages.yml`

- `main`: deploys to production site root
- `dev` / `develop` / `feature/**` / `release/**` / `hotfix/**`: deploys preview builds
  - Preview URL format: `https://coder0xe.github.io/previews/<branch>/`
- When a preview branch is deleted: matching preview directory is cleaned up automatically

### Required Pages Settings

In your GitHub repository:

1. `Settings -> Pages`
2. `Source`: `Deploy from a branch`
3. `Branch`: `gh-pages`
4. `Folder`: `/ (root)`

## Troubleshooting

### 1) Root URL shows 404 (File not found)

Usually Pages source is not correctly bound to `gh-pages`. Recheck the settings above.

### 2) Images in posts are not displayed

Check Markdown image paths first. Replace `../img/...` with `/img/...`.

### 3) Hugo error: `range can't iterate over ...`

`tags/categories/keywords` were written as strings instead of arrays.
