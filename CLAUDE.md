# AI Assistant Guide (CLAUDE.md)

This file provides guidance for an AI assistant working on the Ramen codebase.

## Project Overview

Ramen is a static site generator built with OCaml. It has two primary user groups:

1.  **CLI Users:** Content creators who use the `ramen` binary to build static sites. They interact with Markdown and YAML files and should not need to use OCaml.
2.  **Library Users:** OCaml developers who use Ramen as a library to build content-driven websites with full, type-safe control over HTML generation.

## Development Workflow

The primary way to interact with the project during development is through the `ramen` CLI.

```bash
# Build the ramen executable
dune build

# Create a test project to work with
./_build/default/bin/main.exe init my-test-site
cd my-test-site

# Build the static site from the test project's data
../_build/default/bin/main.exe build

# Serve the site locally for preview
../_build/default/bin/main.exe serve
```

### Other Important Commands

```bash
# Run the test suite
dune test

# Format all OCaml code before committing (ALWAYS run this)
dune fmt
```

## Architecture

The project uses a modern, in-memory data loading architecture. The old code-generation system is gone.

1.  **Loading (`lib/core/loader.ml`):** Reads content from the `data/` directory (Markdown, YAML) into OCaml records.
2.  **Validation (`lib/core/validation.ml`):** Performs runtime checks on the loaded data to ensure its integrity (e.g., all posts have an author).
3.  **Building (`lib/builder/builder.ml`):** Orchestrates the loading and validation, then uses the page generators to create the site.
4.  **Page Generation (`lib/pages/`):** Contains the logic for rendering different types of pages (e.g., `blog.ml`, `index.ml`).
5.  **Components (`lib/component/`):** Contains reusable, hardcoded HTML components (e.g., `header.ml`, `footer.ml`).

## Theming System (Future Work)

The current theming is hardcoded. A key development goal is to implement a new, flexible theming system as described in `TODO/theme.md`.

-   **For CLI Users:** The new system will be **Configuration-Driven**. Users will edit a `theme.yml` file to change colors, fonts, navigation links, etc., without touching OCaml code.
-   **For Library Users:** The new system will be **Functor-Based**. Developers will implement a `Theme.S` module signature to create entirely new themes in OCaml.

When making changes to UI components, be mindful of this future direction. Aim to make components that could be easily configured by a `theme.yml` file.

## Tailwind CSS Usage

This project uses a centralized `Tw` module for all Tailwind CSS classes to ensure they can be statically analyzed.

1.  **Never use raw Tailwind strings** in components (e.g., `class_ "bg-white p-4"`).
2.  **Always use the `Tw` module** (e.g., `Tw.class' [ Tw.bg_white; Tw.p_4 ]`).
3.  If a class is missing, add it to `lib/tw/tw.ml` and `lib/tw/tw.mli`.
