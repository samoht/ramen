open Html

type external_link = { href : string; label : string }

let ocaml_org = { href = "https://ocaml.org"; label = "OCaml" }
let github_org = { href = "https://github.com/ocaml"; label = "GitHub" }
let x = { href = "https://x.com/ocamllang"; label = "X" }
let discord = { href = "https://discord.gg/cCYQbqN"; label = "Discord" }

let external' ?class_ ~palette content url =
  let base_classes = match class_ with None -> [] | Some c -> c in
  let hover = [ Colors.hover_text_primary palette ] in
  a
    ~at:[ At.href url; At.target "_blank"; At.rel "noopener noreferrer" ]
    ~tw:(base_classes @ hover) content

let internal' ?class_ ~palette content url =
  let base_classes = match class_ with None -> [] | Some c -> c in
  let hover = [ Colors.hover_text_primary palette ] in
  a ~at:[ At.href url ] ~tw:(base_classes @ hover) content

let external_nav ~palette link =
  external' ~palette [ Icon.external_link; txt link.label ] link.href
