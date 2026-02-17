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
└── hugo.toml               # Hugo config
```

## Local Development

1. Install Hugo Extended (recommended `0.155.3` or newer).
2. Run at repository root:

```bash
hugo server -D
```

3. Open:

```text
http://localhost:1313/
```

Build only:

```bash
hugo --cleanDestinationDir
```

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

Example:

```yaml
---
title: "Sample Post"
date: 2026-02-17T21:00:00+08:00
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

