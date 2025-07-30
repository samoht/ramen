# Ramen 🍜

<div align="center">
  <a href="_site/index.html">
    <img src="data/images/ramen.jpg" alt="Ramen" width="100">
  </a>
  <br>
  <sub>Click the logo to view the example site (build it first with `dune exec bin/main.exe -- build`)</sub>
</div>

A type-safe static site generator built with OCaml, designed for both content creators and OCaml developers.

Ramen provides a command-line tool for building content-heavy static sites with a focus on data validation and consistency. It also exposes its core logic as an OCaml library for developers who need more control.

## Target Audience

Ramen is for two groups of people:

1.  **CLI Users (Content Creators):** If you want to build a blog or static site without writing any OCaml, you can use the `ramen` command-line tool. You write content in Markdown and configure your site with simple YAML files.
2.  **Library Users (OCaml Developers):** If you're an OCaml developer, you can use Ramen as a library to add content-driven pages to a larger web project (e.g., a Dream application). You get full, type-safe control over the data and HTML generation.

---

## For CLI Users

### Features

- **Simple, file-based content:** Write posts in Markdown, manage data in YAML.
- **Content validation:** The build process checks your content for missing fields or incorrect formats, preventing broken pages.
- **Modern tooling:** A simple CLI with `init`, `build`, and `serve` commands.
- **Configurable themes:** Customize the look and feel of your site by editing YAML and CSS files.

### Quick Start

1.  **Installation:**
    Download the pre-compiled binary for your OS from the latest [GitHub Release](https://github.com/your-org/ramen/releases).

2.  **Create a new site:**
    ```bash
    ramen init my-blog
    cd my-blog
    ```

3.  **Start the development server:**
    ```bash
    ramen serve
    ```
    Your site is now available at `http://localhost:8080`. The server will automatically rebuild the site when you change any content.

### Customization

You can customize the default theme by editing files in the `themes/default/` directory of your project:

-   **`theme.yml`**: Change colors, fonts, navigation links, and other settings.
-   **`custom.css`**: Add your own CSS rules to override the default styles.

This allows you to change the appearance of your site without writing any OCaml.

---

## For Library Users

### Features

- **Data-driven core:** A powerful `Ramen.Core` library for loading and validating structured content from files.
- **Functor-based theming:** An `Engine.Make(T: Theme.S)` functor that allows you to provide your own OCaml modules to render HTML, giving you full, type-safe control over the output.
- **Seamless integration:** Designed to be used within other OCaml applications.

### How It Works

Ramen's architecture is data-driven:

1.  **Load:** `Ramen.Core.Loader` reads Markdown and YAML files from your `data/` directory.
2.  **Validate:** `Ramen.Core.Validation` checks the loaded data against your defined OCaml types. Errors are reported with clear, file-specific messages.
3.  **Build:** `Ramen.Builder` orchestrates the process and generates the final static assets.

This in-memory model provides the type-safety of the original design without the complex code-generation build step.

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

Contributions are welcome! Please see the `TODO/` directory for the project's roadmap and open issues.

## License

MIT
