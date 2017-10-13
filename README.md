## Ramen -- A minimal tool to build static websites

```
Usage: ramen [--data=<path>] [--pages=<path>] [--site=<path>] [-v]
```

### Filesystem structure

A Ramen website consists of 3 directories:

- `site/`: the generated website, created by Ramen.
- `pages/`: the base templates. All the templates in that directory
  will be processed by Ramen and the results will be copied into `site/`.
- `data/`: the data read by Ramen used to feed the templates in `pages/`.

### Data Types

There are 2 kinds of data:

- raw data: Ramen will use these to complete template variables. Example of raw
  data could either be a raw file or a header value.
- collections: Ramen will use these to expanse for loops. `foo.bar` denotes
  the entry `bar` in the collection `foo`. These are built from directories
  in `data/` or from structured files (with `.yml` or `.json` extensions).

### Syntax of Templates

Every template in pages has the following structure:

```
var1: value1
var2: value2
---
body
```

The body can contain templates of the form:

- variables `{{ VAR }}`: Ramen will replace these with their raw values defined
  in the page header or in the data directory (see bellow).
- loops `{{ for i in VAR }} <body> {{ enfor }}`: Ramen will expanse the body
  for each entry in the collection `var`.
- conditions `{{ if VAR }} <body> {{ endif }}`. Ramen will remove `<body>` if
  `VAR` is not defined.
- arrays `{{ xxx.[VAR].yyy }}` evaluates to `xx.yy.zz` where `yy` is the
  contents of `VAR`. This could be used in conjunction with for loops to
  "join" various collections.

__Note__: raw data can also contains the `{{ .. }}` quotations. They will be
expanded recursively by Ramen.

### Support File Extensions

The following file extensions are supported:

- `<file>.json`: will be transformed into the collection `<file>`.
- `<file>.md`: will be transformed into the raw data `<file>` when markdown has
  been translated to HTML.
- `<file>.yml`: will be transformed into the collection `<file>`. Note: only
   very limited support for yaml at the moment (no nesting, only key-value).
- every other files will be considered as raw data.

### Examples

See a simple example in [./examples/bootstrap].
