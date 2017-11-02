## Ramen -- A minimal tool to build static websites

## Usage

With [Docker](https://www.docker.com/):

```
$ docker run -v `pwd`:/data samoht/ramen
```

With [opam](https://opam.ocaml.org):

```
$ opam install ramen
$ ramen
```

Check `ramen --help` for more details.

## Manual

### Filesystem structure

The CLI help message for Ramen says:

```
Usage: ramen [--data=<path>] [--pages=<path>] [--site=<path>] [-v]
```

These three directories are:

- `site/`: the generated website, created by Ramen. Add images or stylesheet
  here but do not edit the contents of processed files there.
  Copy that directory to your live website to put your static website live.

- `pages/`: the base templates. All the templates in that directory
  are processed by Ramen and the expanded results are copied into
  `site/`.

- `data/`: the data read by Ramen used to feed the templates in `pages/`.

### Data Types

There are 2 kinds of data:

- **raw data**: Ramen uses these to complete template variables. Example of
  raw data could either be a raw file or a header value.

- **collections**: Ramen uses these to expand for loops. `foo.bar` denotes
  the entry `bar` in the collection `foo`. These are built from directories
  in `data/` or from structured files (with `.yml` or `.json` extensions).
  Collection are ordered:
  - when built from files, using lexicographic order.
  - when built from JSON or Yaml, using the order in which items are declared.

### Global Variables

Ramen predefines the `global` collection, with the following contents:

| global | description |
|--------|-------------|
| `site.date`  | the date of build. |
| `site.pages`| contents of the `pages/` directory. |
| `site.page` | the current page being built. |

### Syntax of Templates

Every template in pages has the following structure:

```
var_1: value_1
var_2: value_2
---
body
```

The body can contain templates of the form:

- **variables**: `{{ var }}`: Ramen replaces these with their raw
  values defined in the page header or in the data directory (see
  bellow). Variables are alpha-numeric characters with `-` and `_`.
  Full variables can contain dots, to explore collections. For instance,
  if `foo` has two keys `a` and `b` (as for instance their exists two files `
  data/foo/a` and  `data/foo/b`) the contents of these could be
  accessed in template bodies using `foo.a` and `foo.b`.

  When reading files in the `data/` directory, Ramen always removes
  the file extensions to build the variable names:
  the contents of `foo/a.html` is available as `foo.a`.
  In some cases (see
  [bellow](https://github.com/samoht/ramen#supported-file-extensions) for details),
  the contents is pre-processed.

  Raw data can also contains the `{{ .. }}` quotations. They are
  expanded recursively by Ramen.

- **loops**: `{{ for i in var }} <body> {{ endfor }}`: Ramen
  expands the body for each entry in the collection `var`.

  For instance, if `data/foo` contains two files `data/foo/a.md` and
  `data/foo/b.md` which contains `toto` and `titi` respectively, then:

  ```html
  {{ for i in foo }}
  Hello {{ i }}.
  {{ endfor }}
  ```
  is equivalent to:
  ```html
  Hello toto.
  Hello titi.
  ```

  When a collection is used as a parameter of a loop, two extra fields are
  added in the context: `first` and `last`. These are useful to test for
  start or end conditions, for instance:

  ```html
  {{ for i in foo }}
  {{ if i = foo.first }}
  Hello first {{ i }}.
  {{ else }}
  Hello {{ i }}
  {{ endif }}
  ```

- **conditions**: `{{ if cond_1 }} <body_1> ... {{ elif cond_n }} <body_n> {{
  endif }}`. Ramen picks the first `<body_i>` such that `cond_i` is
  satisfied (or it uses an empty string if none of the conditions
  are true). Conditions expressions are composed by:
    - single variables: `var`;
    - equalities: `var_1 = var_2` or `var_1 = 'string'`
    - inequalities: `var_1 != var_2` or `var_1 != 'string'`
    - parentheses: `( expr )`
    - negations: `! expr`
    - conjonctions: `expr_1 && expr_2`
    - disjonctions: `expr_1 || expr_2`

  For instance:

  ```html
  {{ if i.title && (i = site.page) }}
    <div class="nav active">{{i.title}}</div>
  {{ elif i.title }}
    <div class"nav">{{i.title}}<div>
  {{ endif }}
  ```

- **dictionaries**: `{{ xxx.[VAR].yyy }}` evaluates to `xxx.v.yyy`
  where `v` is the contents of `VAR`. This could be used in
  conjunction with for loops to "join" various collections.
  For example, if you have two collections `books` and `people`,
  you can cross-reference them using:
  ````html
  {{for i in books}}
    <div class="book">
      <div class="title">{{i.title}}</div>
      <div class="author">{{people.[i.author].name}}</div>
    </div>
  {{endfor}}
  ````
- **fonctions**: `{{ VAR(k_1: v_1, ..., k_n: v_n) }}` this is similar
  to evaluating `VAR` in the context where `k_1`,...,`k_n` are bound
  to `v_1`,...`v_n`. For instance, this could be used to parametrize
  a template to be re-used in various contexts.

  If `data/v.md` contains:
  ```html
  entry: .
  ----
  <b>{{entry.title}}</b>: {{entry.contents}}
  ```

  then, assuming that `foo` and `bar` are collections with a `title` and
  `contents` entries, `v` can be used as follows:
  ```html
  <ul>
    <li> {{ v(entry: foo) }} </li>
    <li> {{ v(entry: bar) }} </li>
  <ul>
  ```

### Supported File Extensions

The following file extensions are supported:

- `<file>.json`: the file is transformed into the collection `<file>`.

- `<file>.md`: the file's body is converted from HTML to markdown and is
  made available as `<file>`.
  If the file has some headers, they are available using `<file>.<var>`.

- `<file>.yml`: the file is transformed into the collection `<file>`. Note: only
   very limited support for yaml at the moment (no nesting, only key-value).

- every other files are considered as raw data: `<file>.<ext>` corresponds
  to binding where `<file>` is bound to the contents of that file.

### Examples

See the [examples/](https://github.com/samoht/ramen/tree/master/examples) folder.
