# coder0xe.github.io

个人博客仓库，基于 [Hugo](https://gohugo.io/) + PaperMod 主题。

- 生产站点: `https://coder0xe.github.io/`
- 部署方式: GitHub Actions 自动构建并发布到 `gh-pages` 分支

## 目录结构

```text
.
├── content/
│   └── posts/              # 文章 Markdown
├── static/
│   └── img/                # 文章图片（推荐放这里）
├── themes/PaperMod/        # 主题
├── .github/workflows/
│   └── deploy-pages.yml    # Pages 部署工作流（多分支）
└── hugo.toml               # Hugo 配置
```

## 本地开发

1. 安装 Hugo Extended（版本建议 `0.155.3` 或以上）。
2. 在仓库根目录运行:

```bash
hugo server -D
```

3. 浏览器访问:

```text
http://localhost:1313/
```

仅本地构建:

```bash
hugo --cleanDestinationDir
```

## 写作规范（重要）

### 图片路径

文章图片请使用**站点绝对路径**，不要使用 `../img` 相对路径。

推荐:

```md
![demo](/img/example.png)
```

不推荐:

```md
![demo](../img/example.png)
![demo](./../img/example.png)
```

### Front Matter

- `date` 使用可解析格式，例如: `2026-02-17T21:00:00+08:00`
- `tags` / `categories` / `keywords` 使用数组

示例:

```yaml
---
title: "示例文章"
date: 2026-02-17T21:00:00+08:00
tags: ["Hugo", "Blog"]
categories: ["技术"]
keywords: ["hugo", "github pages"]
---
```

## GitHub Pages 部署（多分支策略）

工作流文件: `.github/workflows/deploy-pages.yml`

- `main` 分支: 发布到正式站点根目录
- `dev` / `develop` / `feature/**` / `release/**` / `hotfix/**`: 发布到预览目录
  - 预览地址形如: `https://coder0xe.github.io/previews/<branch>/`
- 删除预览分支时: 自动清理对应预览目录

### Pages 设置

在 GitHub 仓库设置里确认:

1. `Settings -> Pages`
2. `Source`: `Deploy from a branch`
3. `Branch`: `gh-pages`
4. `Folder`: `/ (root)`

## 常见问题

### 1) 首页 404（File not found）

通常是 Pages 源未绑定到 `gh-pages`，按上面的 Pages 设置检查。

### 2) 文章图片不显示

优先检查 Markdown 图片路径是否写成了 `../img/...`，应改为 `/img/...`。

### 3) Hugo 报 `range can't iterate over ...`

说明 `tags/categories/keywords` 被写成了字符串，而不是数组。
