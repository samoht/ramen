---
author: John Smith
title: Getting Started with Ramen
date: 2025-07-30
tags: ramen, tutorial, getting-started
synopsis: A step-by-step guide to creating your first Ramen site.
image: getting-started.jpg
image-alt: A laptop showing code
---

This guide provides a step-by-step walkthrough for creating a new website using the `ramen` command-line tool. It is intended for **Content Creators and Bloggers** who do not need to write any OCaml code.

## Prerequisites

This guide assumes you have already installed the `ramen` executable and have it available in your `PATH`.

## 1. Initialize a New Project

To create a new site, use the `ramen init` command. This will create a new directory with a recommended project structure and example content.

```bash
ramen init my-blog
cd my-blog
```

This creates the following directory structure:
```
my-blog/
├── data/
│   ├── blog/
│   │   ├── content/     # Blog posts (Markdown)
│   │   └── images/      # Blog images
│   ├── team/            # Author information
│   │   └── team.yml
│   ├── pages/           # Static pages
│   │   └── index.yml
│   └── site.yml         # Site configuration
└── _site/               # Generated output is placed here
```

## 2. Configure Your Site

The main configuration file is `data/site.yml`. Edit this file to set your site's name, author, URL, and other global settings.

```yaml
# data/site.yml
name: My Blog
tagline: Thoughts on OCaml and Web Development
author: Your Name
url: https://myblog.example.com
# ...
```

## 3. Create Your First Post

Blog posts are Markdown files located in `data/blog/content/`. Create a new file to add a post.

The section at the top of the file, enclosed in `---`, is the YAML frontmatter. It contains structured metadata about the post.

```markdown
---
author: Your Name
title: Hello, World!
date: 2025-07-30
tags: first-post, ocaml
synopsis: My first post using Ramen.
image: /blog/images/hello-world.jpg
image-alt: A placeholder image
---

# Hello, World!

This is the body of the blog post, written in standard Markdown.

## Code Highlighting

Ramen supports syntax highlighting for code blocks.

```ocaml
let greeting name =
  Printf.printf "Hello, %s!" name
```
```

## 4. Add Author Information

Author details are managed in `data/team/team.yml`. Add an entry for each author referenced in your blog posts.

```yaml
# data/team/team.yml
- name: Your Name
  slug: your-name
  title: Software Developer
  homepage: https://example.com
  avatar: /team/images/your-name.jpg
```
Place the corresponding avatar image in `data/team/images/`.

## 5. Build Your Site

Once your content is ready, run the build command from the root of your project directory (`my-blog/`).

```bash
ramen build
```

This command reads all the content from the `data/` directory and generates the static site in the `_site/` directory.

For local development, you can use the `serve` command, which will start a local web server and automatically rebuild the site when you make changes to your content.

```bash
ramen serve
```

## 6. Styling Your Site

You can customize the look and feel of your site by editing the theme's configuration files. For the default theme, these are located in `themes/default/`:

*   **`theme.yml`**: This file is your main control panel for the theme. You can change things like the color scheme, fonts, and the links in your site's navigation header.
*   **`custom.css`**: For any style changes that aren't covered by `theme.yml`, you can add your own CSS rules to this file.

This approach allows you to significantly change your site's appearance without needing to edit any OCaml code.

## What's Next?

This guide covers the basic workflow for a new site. From here, you can explore:
- Adding more static pages in `data/pages/`.
- Customizing your theme by editing `themes/default/theme.yml`.
- Learning how to use Ramen as a library if you are an OCaml developer.
