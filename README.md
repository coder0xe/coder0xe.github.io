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
├── tests/
│   └── writing-tools.sh    # 本地写作命令测试
├── Makefile                # 新建、预览和构建命令
└── hugo.toml               # Hugo 配置
```

## 本地写作

### 1. 准备工具

需要 Hugo Extended `0.155.3` 或更新版本。安装后在仓库根目录检查环境：

```bash
brew install hugo
```

如果已经安装 Hugo，可直接运行：

```bash
make doctor
```

查看仓库提供的全部写作命令：

```bash
make help
```

### 2. 新建草稿

`POST` 是文章文件名，建议使用简短的英文或拼音 slug：

```bash
make new POST=my-first-post
```

命令会创建 `content/posts/my-first-post.md`，其中 `draft = true`，不会进入生产构建。随后填写标题、描述、标签、分类和正文即可。

文章图片放入 `static/img/`，并在 Markdown 中使用站点绝对路径：

```md
![图片说明](/img/example.png)
```

### 3. 实时预览

```bash
make serve
```

浏览器访问 `http://localhost:1313/`。保存 Markdown 后，Hugo 会自动重建页面；此命令会显示草稿，并自动跳转到刚修改的页面。

文章支持 LaTeX 公式。行内公式用 `$E=mc^2$` 或 `\(E=mc^2\)`；独立公式用 `$$` 或 `\[`、`\]` 包围。网页通过 MathJax 渲染公式，首次加载需要能访问 jsDelivr。

### 4. 发布前检查

完成文章后，将 Front Matter 中的：

```toml
draft = true
```

改为：

```toml
draft = false
```

然后运行生产构建检查：

```bash
make check
```

构建产物位于 `public/`，已被 Git 忽略。提交并推送后，GitHub Actions 会自动发布。

如果不使用 Make，也可以直接运行 `hugo server --buildDrafts --navigateToChanged --cacheDir "$PWD/.hugo_cache"` 预览，或运行 `hugo --gc --minify --cleanDestinationDir --cacheDir "$PWD/.hugo_cache"` 构建。

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
- 写作过程中保留 `draft = true`；准备发布时改为 `draft = false`

示例:

```yaml
---
title: "示例文章"
date: 2026-02-17T21:00:00+08:00
description: "文章摘要"
draft: false
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
