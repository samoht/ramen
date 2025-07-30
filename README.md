# Ramen 🍜

<div align="center">
  <img src="data/images/ramen.jpg" alt="Ramen" width="150">
</div>

A type-safe static site generator built with OCaml, designed for both
content creators and OCaml developers.

Ramen provides a command-line tool for building content-heavy static sites
with a focus on data validation and consistency. It also exposes its core
logic as an OCaml library for developers who need more control.

## Demo

🌐 [**View Example Site**](_site/index.html) – Generated from the content
in this repository

## Target Audience

Ramen is for two groups of people:

1.  **CLI Users (Content Creators):** If you want to build a blog or static
    site without writing any OCaml, you can use the `ramen` command-line
    tool. You write content in Markdown and configure your site with simple
    YAML files.
2.  **Library Users (OCaml Developers):** If you're an OCaml developer, you
    can use Ramen as a library to add content-driven pages to a larger web
    project (e.g., a Dream application). You get full, type-safe control
    over the data and HTML generation.

---

## For CLI Users

### Features

- **Simple, file-based content:** Write posts in Markdown, manage data
  in YAML.
- **Content validation:** The build process checks your content for
  missing fields or incorrect formats, preventing broken pages.
- **Modern tooling:** A simple CLI with `init`, `build`, and `serve`
  commands.
- **Built-in styling:** Clean, professional design with no configuration
  required.

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/samoht/ramen.git
cd ramen

# Install dependencies
dune pkg lock                           # for dune package management
# OR
opam install . --deps-only . -t        # for opam users

# Build and install
dune build
dune install    # installs the `ramen` binary into your current opam switch
```

### Requirements

- OCaml ≥ 5.0
- Dune ≥ 3.0
- Standard OCaml web libraries (dependencies handled by opam/dune)

## Quick Start

1.  **Create a new site:**
    ```bash
    ramen init my-blog
    cd my-blog
    ```

3.  **Start the development server:**
    ```bash
    ramen serve
    ```
    Your site is now available at `http://localhost:8080`. The server will
    automatically rebuild the site when you change any content.

---

## For Library Users

### Features

- **Data-driven core:** A powerful `Ramen.Core` library for loading and
  validating structured content from files.
- **Functor-based theming:** An `Engine.Make(T: Theme.S)` functor that
  allows you to provide your own OCaml modules to render HTML, giving you
  full, type-safe control over the output.
- **Seamless integration:** Designed to be used within other OCaml applications.

### How It Works

Ramen's architecture is data-driven:

1.  **Load:** `Ramen.Core.Loader` reads Markdown and YAML files from your
    `data/` directory.
2.  **Validate:** `Ramen.Core.Validation` checks the loaded data against
    your defined OCaml types. Errors are reported with clear, file-specific
    messages.
3.  **Build:** `Ramen.Builder` orchestrates the process and generates the
    final static assets.

This in-memory model provides the type-safety of the original design
without the complex code-generation build step.

### Example Usage (in a Dream app)

```ocaml
(* my_dream_app.ml *)

let () =
  (* 1. Use Ramen to build the static part of your site on startup *)
  let _ = Ramen.Builder.build ~data_dir:"docs" ~output_dir:"_site/docs" () in

  (* 2. Serve the generated files alongside your dynamic routes *)
  Dream.run @@ Dream.router [
    Dream.get "/docs/**" (Dream.static "_site/docs");
    Dream.get "/" (fun _ -> Dream.html "My dynamic homepage!");
    (* ... other dynamic routes ... *)
  ]
```

## Contributing

Contributions are welcome! Please see the `TODO/` directory for the
project's roadmap and open issues.

## AI Transparency

**This project was developed with significant AI assistance** ([Claude
Code](https://claude.ai/code) by Anthropic). The core architecture
originated from the Tarides.com blog generator, but extensive refactoring,
feature additions, and modernization were performed using AI-assisted
development.

While the tool has been tested and works well in practice, users should
be aware that:

1. **Technical implications**: AI-generated code may have unique patterns
   or subtle issues. We've tested Ramen on real projects, but thorough
   testing is always recommended.

2. **Legal uncertainty**: The copyright status and liability for
   AI-generated code remain legally untested. The original codebase
   provides a foundation, but AI contributions cannot be easily traced to
   specific training data.

3. **Practical use**: Despite these unknowns, Ramen provides useful
   functionality for static site generation and is actively maintained.

**By using this tool, you acknowledge these uncertainties.** As with any
development tool: use version control, review generated sites, and test
thoroughly.

## License

ISC
