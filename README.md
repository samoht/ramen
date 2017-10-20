## Ramen -- A minimal tool to build static websites

```
Usage: ramen [--data=<path>] [--pages=<path>] [--site=<path>] [-v]
```

With [Docker](www.docker.com):

```
$ docker run -v `pwd`:/data samoht/ramen
```

### Filesystem structure

A Ramen website consists of 3 directories:

- `site/`: the generated website, created by Ramen. Do not edit the files
  there. Just copy that directory to your live website.

- `pages/`: the base templates. All the templates in that directory
  will be processed by Ramen and the results will be copied into `site/`.

- `data/`: the data read by Ramen used to feed the templates in `pages/`.

### Data Types

There are 2 kinds of data:

- **raw data**: Ramen will use these to complete template variables. Example of
  raw data could either be a raw file or a header value.

- **collections**: Ramen will use these to expanse for loops. `foo.bar` denotes
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

- **variables**: `{{ var }}`: Ramen will replace these with their raw
  values defined in the page header or in the data directory (see
  bellow). Variables are alpha-numeric characters with `-` and `_`.
  Full variables can contain dots, to explore collections. For instance,
  if `foo` has two keys `a` and `b` (as for instance their exists two files `
  data/foo/a` and  `data/foo/b`) the contents of these could be
  accessed in template bodies using `foo.a` and `foo.b`.

  _Note:_ when reading files in the `data/` directory, Ramen will
  remove the extensions it understands (see
  [bellow](https://github.com/samoht/ramen#supported-file-extensions)),
  so the contents of `foo/a.md` will be available using `foo.a.body`.

- **loops**: `{{ for i in var }} <body> {{ endfor }}`: Ramen will
  expanse the body for each entry in the collection `var`.

- **conditions**: `{{ if cond_1 }} <body_1> ... {{ elif cond_n }} <body_n> {{
  endif }}`. Ramen will pick the first `<body_i>` such that `cond_i` is
  satisfied (or it will use an empty string if none of the conditions
  are true). Conditions are a `&&`-separated list of conjonctions of
  either a single variable `var` (to check if this variablie is
  defined in the current context) or variable equality `(var_1 = var_2)`
  (to check if both variables points to the same contents -- they
  could be collections). Simple negations are also supported,
  using `!var` and `(var_1 != var_2)`.

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

_Note_: raw data can also contains the `{{ .. }}` quotations. They will be
expanded recursively by Ramen.

### Supported File Extensions

The following file extensions are supported:

- `<file>.json`: will be transformed into the collection `<file>`.

- `<file>.md`: will convert `<file>`'s body from HTML to markdown and will
  make it available as `<file>.body`.
  If the file has some headers, they will be available
  using `<file>.<var>`.

- `<file>.yml`: will be transformed into the collection `<file>`. Note: only
   very limited support for yaml at the moment (no nesting, only key-value).

- every other files will be considered as raw data.

### Examples

See the [examples/](https://github.com/samoht/ramen/tree/master/examples) folder.
