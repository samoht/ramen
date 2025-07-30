# Theme Design Plan

**Status: Proposed**

## Summary

This document outlines a design for a theming system that serves both CLI users (without an OCaml toolchain) and OCaml developers.

## The Core Problem

Ramen's philosophy is type-safe HTML generation in OCaml. However, our primary CLI user cannot compile or run OCaml code. This requires two different approaches to "theming".

---

### 1. For Library Users (OCaml Developers)

**Method: Functor-based Theming**

This path is for developers using Ramen as a library in their own OCaml projects.

-   **API:** Ramen will provide a `Theme.S` module signature and an `Engine.Make(T: Theme.S)` functor.
-   **Experience:** The developer implements their own module matching `Theme.S` and applies the functor to it, giving them full, type-safe control over all HTML generation. This is the "power user" path for creating themes from scratch or deeply integrating Ramen into an existing site.

---

### 2. For CLI Users (Content Creators)

**Method: Configuration-Driven Theming**

This path is for non-developers who want to customize a pre-existing theme by editing configuration and CSS files. They do not get full structural control, but they get significant control over look-and-feel without needing a compiler.

-   **Directory Structure:** A theme is a directory that contains OCaml source, but also user-facing configuration files.
    ```
    my-project/
    ├── data/
    └── themes/
        └── default/
            ├── theme.ml        (* (Not edited by CLI user) *)
            ├── theme.yml       (* USER-EDITABLE *)
            └── custom.css      (* USER-EDITABLE *)
    ```

-   **`theme.yml` - The User's Control Panel:** This file allows users to customize aspects the theme developer has exposed.
    ```yaml
    # themes/default/theme.yml
    logo: /images/my-custom-logo.svg
    primary_color: "#4f46e5" # Used to generate CSS variables

    nav_links:
      - { name: "About", url: "/about" }
      - { name: "Contact", url: "/contact" }

    footer:
      copyright: "© 2025 My Awesome Site"
    ```

-   **How it Works:**
    1.  The theme's OCaml code (`theme.ml`) is responsible for reading `theme.yml`.
    2.  The rendering functions use the values from this file. For example, `Header.render` will iterate over the `nav_links` list to build the navigation.
    3.  The build process would also use `primary_color` to generate a small, theme-specific CSS file or CSS variables, allowing color customization.
    4.  The user can add any CSS overrides in `custom.css`.

-   **CLI Experience:**
    -   The user runs `ramen build`. The `--theme` option is still valid for selecting between different installed themes (e.g., `themes/default`, `themes/minimal`).
    -   The user customizes the *selected* theme by editing its `theme.yml` and `custom.css` files.

## Conclusion

This two-tiered approach allows Ramen to maintain its OCaml-centric vision while providing a practical and simple customization story for its non-developer audience. It clearly defines the boundary: **customization is done via configuration; deep structural changes require using Ramen as a library.**