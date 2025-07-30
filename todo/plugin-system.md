# RFC-001: Pluggable Extension System

**Status: Proposed**

## Summary

This RFC proposes the design of a pluggable extension system to allow users to define their own content types (e.g., "Projects", "Events") as self-contained plugins. This is a long-term goal to make Ramen a truly generic engine.

## Target Audience & User Stories

1.  **For CLI Users (Plugin Consumers):**
    *   **User Story:** "As a content creator, I want to add a 'Projects' section to my site. I can do this by adding `projects` to a `plugins` list in my `site.yml` and creating content in a new `data/projects/` directory."

2.  **For OCaml Developers (Plugin Creators):**
    *   **User Story:** "As a developer, I want to create a 'Portfolio' plugin. I can do this by defining the `Portfolio.t` data type and implementing a `Plugin.S` signature that tells Ramen how to load, validate, and render my new content type."

## Design Proposal: Functor-Based Plugins

Similar to the theme system, we will use OCaml's Functor system to create a type-safe plugin architecture.

### 1. The `Plugin.S` Signature (The Contract for Developers)

A new module signature will define the contract for a content plugin:

```ocaml
(* lib/plugin.mli *)
module type S = sig
  (** The unique name for this plugin (e.g., "blog", "projects"). *)
  val name : string

  (** The OCaml type of the content this plugin manages. *)
  type t

  (** A Yojson decoder to parse and validate the content from YAML/JSON. *)
  val decoder : Yojson.Safe.t -> (t, string) result

  (** A function that generates pages for this content type.
      It receives the theme module and the list of loaded content items. *)
  val generators : (module Theme.S) -> t list -> unit
end
```

### 2. Plugin Configuration (for CLI Users)

Users will enable plugins in their `site.yml` configuration file:

```yaml
# site.yml
plugins:
  - blog
  - papers
  - projects  # A custom plugin
```

The `ramen` executable will read this list to determine which plugin modules to load and which directories under `data/` to parse.

### 3. Engine Refactoring

The core engine (`lib/builder/builder.ml`) will be modified to manage a list of registered plugins. During the build process, it will:
1.  Iterate through the enabled plugins.
2.  Use each plugin's `decoder` to load the corresponding content from `data/<plugin_name>/`.
3.  Pass the loaded content to the plugin's `generators` function to create the final HTML pages.

### 4. Theme and Plugin Interaction

The `Theme.S` signature will need to be extensible to handle rendering data from arbitrary plugins. This is a complex challenge. A possible approach is to have themes provide a generic rendering function:

```ocaml
(* In Theme.S *)
val render_plugin_page : plugin_name:string -> data:Univ.t -> Htmlit.t
```
Here, `Univ.t` could be a universal type that allows for type-safe casting at runtime, ensuring the theme can safely handle data from different plugins. This requires further research.