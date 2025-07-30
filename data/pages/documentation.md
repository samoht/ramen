---
title: Documentation
description: Documentation for the Ramen static site generator
layout: default
in_nav: true
nav_order: 10
---

# Ramen Documentation

## Page Header Fields

When creating a static page, you can use the following fields in the YAML frontmatter:

- **title** (required): The page title
- **description** (optional): A brief description of the page content
- **layout** (required): The layout template to use. Options are:
  - `default`: Standard page layout with sidebar
  - `minimal`: Clean layout without sidebar
  - `full-width`: Full-width layout for content that needs more space
- **in_nav** (optional, default: false): Whether to show this page in the main navigation
- **nav_order** (optional): Sort order for navigation items (lower numbers appear first)

### Example

```yaml
---
title: About Us
description: Learn more about our team and mission
layout: default
in_nav: true
nav_order: 5
---
```

## Blog Post Header Fields

Blog posts support these frontmatter fields:

- **title** (required): The post title
- **authors** (required): List of authors (can reference team members or use names)
- **date** (required): Publication date in YYYY-MM-DD format
- **tags** (optional): List of tags for categorization
- **image** (optional): Featured image path
- **image_alt** (optional): Alt text for the featured image
- **synopsis** (required): Brief summary for listing pages
- **description** (required): SEO meta description

## Team/Author Fields

Team members (authors) are defined in `data/team/team.yml` with:

- **name** (required): Full name
- **slug** (required): URL-friendly identifier
- **title** (optional): Job title or role
- **avatar** (optional): Profile picture path
- **homepage** (optional): Personal website URL
- **aliases** (optional): Alternative names to match in blog posts
- **hidden** (optional): Hide from public team listings