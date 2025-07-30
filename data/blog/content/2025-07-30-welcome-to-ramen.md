---
author: Jane Doe
title: Welcome to Ramen
date: 2025-07-30
tags: ramen, introduction
synopsis: An introduction to Ramen, a static site generator built with OCaml.
image: ramen-bowl.jpg
image-alt: A delicious bowl of ramen
---

This post provides a high-level overview of **Ramen**, a static site generator built with OCaml.

## What is Ramen?

Ramen is a command-line tool that transforms a directory of Markdown files and YAML data into a self-contained, static website. It is designed to build content-heavy sites where a consistent data structure is important.

It includes standard features like support for RSS feeds, sitemaps, and responsive images. HTML is generated using OCaml functions, which promotes reuse and composability, and it uses Tailwind CSS for styling.

## How It Works

Ramen's key architectural feature is its build process. It uses the OCaml compiler as a data validation tool by converting your content into OCaml code before the final build.

The build process is as follows:

1.  **Content Processing**: Ramen reads your Markdown files and YAML frontmatter.
2.  **Code Generation**: Your content is converted into strongly-typed OCaml modules.
3.  **Compilation**: The OCaml compiler validates the structure of all content. If there are errors, such as a missing field in a post's frontmatter, the build will fail.
4.  **HTML Generation**: If compilation succeeds, the tool generates static HTML files with optimized assets.

For example, this YAML frontmatter:
```yaml
---
author: Jane Doe
title: My Post
date: 2025-07-30
tags: ocaml, web
---
```
Is transformed into a typed OCaml record. If you have a typo in a field name or an incorrect data format, the compiler will raise an error, preventing a broken page from being deployed.

## Who is Ramen For?

Ramen is designed for two main types of users:

1.  **Content Creators and Bloggers**: If you want to create a blog or a simple static site, you can use the `ramen` command-line tool. Your focus will be on writing content in Markdown files. You benefit from Ramen's content validation without needing to know any OCaml.

2.  **OCaml Developers**: If you are building a larger website in OCaml, you can use Ramen as a library. This allows you to use its content processing and validation engine within your existing application, giving you full control over the final HTML and styling.

The posts in this series will specify which audience they are for.

## Getting Started

To build the example site included in this repository, you will need OCaml and the `dune` build system installed.

```bash
# From the root of the repository, build the project
dune build

# Build the example site
make build-example

# Serve the output locally
make serve
```
This will start a local web server. The generated site can be found in the `_site/` directory.

## Next Steps

The following posts in this series will cover:
- How to structure your content for a new Ramen project.
- How to customize the HTML components.
- How to deploy a Ramen site.
