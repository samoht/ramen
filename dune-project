(lang dune 3.16)
(name ramen)
(generate_opam_files true)

(using directory-targets 0.1)

(source
 (github samoht/ramen))

(authors "Thomas Gazagnaire")

(maintainers "Thomas Gazagnaire")

(license MIT)

(package
 (name ramen)
 (synopsis "A type-safe static site generator")
 (description "Ramen is a static site generator that leverages OCaml's type system to catch content errors at compile time")
 (depends
  (ocaml (>= 4.08))
  ppx_import
  ppx_deriving
  ppx_deriving_yaml
  dune
  cmdliner
  uucp
  uunf
  uri
  hilite
  markup
  lambdasoup
  bos
  base64
  fpath
  ptime
  pure-html
  htmlit
  tailwindcss
  cmarkit
  yojson
  yaml
  js_of_ocaml
  brr
  (alcotest :with-test)
  (tailwindcss :with-test)))