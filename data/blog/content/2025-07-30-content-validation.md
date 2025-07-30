---
author: Alice Johnson
title: Content Validation
date: 2025-07-30
tags: ramen, ocaml, validation
synopsis: An explanation of how Ramen uses its build process to validate content structure.
image: type-safety.jpg
image-alt: OCaml code showing type definitions
---

This document explains how Ramen validates your site's content during its build process.

## The Build Process and Validation

A key feature of Ramen is its build process, which uses the OCaml compiler to enforce the structure of your content. This helps prevent common errors, such as typos in field names or missing metadata.

The process works as follows:
1.  **Parsing**: The `ramen` tool first parses your Markdown files and the YAML frontmatter within them.
2.  **Code Generation**: It then translates this content into OCaml source code. Each piece of content becomes a value with a specific, predefined type.
3.  **Compilation**: This generated code is then compiled. If your content does not match the expected types (e.g., a required field is missing or has the wrong format), the OCaml compiler will raise an error and the build will fail.

This approach means that many common content errors are caught at build time, before the site is deployed.

## Example: Blog Post Validation

The default project in Ramen expects a blog post's frontmatter to have a specific structure. This structure is defined by an OCaml type:

```ocaml
(* A simplified representation of the internal type *)
type post_metadata = {
  title : string;
  author : string;
  date : string; (* In YYYY-MM-DD format *)
  tags : string list;
  synopsis : string;
  image : string;
  image_alt : string;
}
```

### Valid Frontmatter

If you provide frontmatter that matches this structure, the build will succeed:

```yaml
---
author: Jane Doe
title: A Correctly Formatted Post
date: 2025-07-30
tags: ocaml, web-dev
synopsis: This post follows the expected structure.
image: /blog/images/correct.jpg
image-alt: A placeholder image
---
```

### Invalid Frontmatter

If you have a typo in a field name or provide data in the wrong format, the build will fail with an error message.

**Example 1: Typo in a field name**

```yaml
---
autor: Jane Doe  # Typo: should be "author"
title: A Post with a Typo
date: 2025-07-30
# ...
---
```
The build will fail because the `autor` field is not defined in the expected type.

**Example 2: Missing required field**

```yaml
---
title: A Post with a Missing Field
date: 2025-07-30
# The "author" field is missing.
---
```
The build will fail because the generated OCaml record will be missing a required field, which is a compile-time error.

## Who Benefits From This?

This validation process is useful for both of Ramen's target audiences:

*   **For Content Creators (CLI Users)**: This process is your safety net. It helps enforce consistency across all content and reduces the chance of deploying a page with broken or missing metadata. If you forget a field, you get a clear error message telling you what's wrong, without needing to understand the underlying code.

*   **For OCaml Developers (Library Users)**: This is where you can leverage the full power of OCaml's type system. You can define your own complex content types and be confident that all data loaded by Ramen will conform to those structures, preventing a whole class of bugs in your application. For example, if you decide to make the `synopsis` field mandatory for all blog posts, you can update its type definition. The compiler will then produce errors for all existing posts that are missing this field, providing a clear to-do list of which files need to be updated.

## Customizing Content Types

The content types themselves are defined within Ramen's source code (or within a plugin). To add, remove, or change the fields for a content type like a blog post, you would need to modify the corresponding OCaml type definition and update the generator logic.

This feature is aimed at developers building sites with specific, structured content needs. For a standard blog, the default settings are often sufficient.
