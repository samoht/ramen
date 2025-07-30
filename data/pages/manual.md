---
title: User Manual
description: Complete guide to using the Ramen static site generator
layout: full-width
in_nav: true
nav_order: 20
---

# Ramen Static Site Generator Manual

## Getting Started

Ramen is a type-safe static blog generator written in OCaml. It converts markdown files with YAML frontmatter into a static website.

## Directory Structure

```
data/
├── blog/
│   └── content/     # Blog posts (*.md files)
├── team/
│   └── team.yml     # Author information
├── pages/           # Static pages (*.md files)
├── images/          # Image assets
└── css/             # Stylesheets
```

## Creating Content

### Blog Posts

Create a new `.md` file in `data/blog/content/`:

```markdown
---
title: My First Post
authors:
  - Jane Doe
date: 2025-07-30
tags: [tutorial, ocaml]
synopsis: A brief introduction to our new blog
description: Learn how to get started with the Ramen static site generator
---

Your markdown content here...
```

### Static Pages

Create a new `.md` file in `data/pages/`:

```markdown
---
title: About
description: About our company
layout: default
in_nav: true
nav_order: 1
---

Page content in markdown...
```

## Building the Site

```bash
# Build the project
dune build

# Generate the static site
make

# Clean build artifacts
dune clean
```

## Customization

### Layouts

Pages can use one of three layouts:
- **default**: Standard layout with navigation and footer
- **minimal**: Clean layout with minimal chrome
- **full-width**: Maximum width for content-heavy pages

### Navigation

Pages with `in_nav: true` appear in the main navigation menu. Use `nav_order` to control the display order.

### Styling

The site uses Tailwind CSS through a type-safe OCaml wrapper. All styles are defined in the `lib/ui/tw.ml` module.

## Advanced Features

### Author Management

Authors can be team members (defined in `team.yml`) or external contributors. Team members get profile pages and avatars.

### Syntax Highlighting

Code blocks are automatically highlighted using the Hilite library.

### SEO Optimization

All pages include proper meta tags, Open Graph data, and structured data for search engines.