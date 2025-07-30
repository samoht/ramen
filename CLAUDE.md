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

# Check code style and quality
merlint lib/ bin/ test/

# Remove unused code (use with caution - always commit first!)
prune clean .
```

## Architecture

The project uses a modern, in-memory data loading architecture. For detailed information, see `ARCHITECTURE.md` in the root directory.

Key modules:
1.  **Data Loading (`lib/data.ml`):** Reads content from the `data/` directory (Markdown, YAML) into OCaml records.
2.  **Validation (`lib/validation.ml`):** Performs runtime checks on the loaded data to ensure its integrity.
3.  **Building (`lib/build.ml`):** Orchestrates the loading and validation, then delegates to the engine.
4.  **Engine (`lib/engine.ml`):** Generates the final static site files.
5.  **Views (`lib/views/`):** Contains the logic for rendering different types of pages.
6.  **UI Components (`lib/ui/`):** Contains reusable HTML components with type-safe styling.

## Code Style

This project follows OCaml best practices and uses automated tools for consistency:

- **Formatting**: Use `dune fmt` to format all code before committing
- **Linting**: Use `merlint` to check code quality and style issues
- **No manual style guide**: Code style is enforced by merlint rather than written guidelines

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
