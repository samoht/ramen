(* HTML component module implementation using Htmlit with integrated Tailwind *)

open Htmlit

(* Type that combines HTML element with its Tailwind classes *)
type t = { el : El.html; tw : Tw.t list }

(* Attribute type - abstract to prevent direct usage of class' *)
type attr = At.t

(* Re-export At module without class' *)
module At = struct
  let id = At.id
  let title = At.title
  let lang = At.lang
  let dir = At.dir
  let tabindex = At.tabindex
  let contenteditable = At.contenteditable
  let spellcheck b = At.spellcheck (string_of_bool b)
  let onclick = At.v "onclick"
  let onchange = At.v "onchange"
  let oninput = At.v "oninput"
  let onsubmit = At.v "onsubmit"
  let type' = At.type'
  let value = At.value
  let name = At.name
  let placeholder = At.placeholder
  let required = At.required
  let disabled = At.disabled
  let checked = At.checked
  let readonly = At.v "readonly" ""
  let href = At.href
  let target = At.v "target"
  let rel = At.rel
  let download = At.v "download"
  let src = At.src
  let alt = At.alt
  let width = At.width
  let height = At.height
  let loading = At.v "loading"
  let charset = At.charset
  let content = At.content
  let style = At.style
  let property = At.v "property"
  let datetime = At.v "datetime"
  let srcset = At.v "srcset"
  let sizes = At.v "sizes"
  let title' = At.v "title"
  let loading_lazy = At.v "loading" "lazy"
  let int = At.int
  let v = At.v
  let true' name = At.v name ""
  let false' name = At.v name "false"

  (* SVG attributes *)
  let fill_rule `evenodd = At.v "fill-rule" "evenodd"
  let clip_rule `evenodd = At.v "clip-rule" "evenodd"
  let cx i = At.v "cx" (string_of_int i)
  let cy i = At.v "cy" (string_of_int i)
  let r i = At.v "r" (string_of_int i)
  let view_box s = At.v "viewBox" s
  let fill s = At.v "fill" s
  let stroke s = At.v "stroke" s
  let stroke_width s = At.v "stroke-width" s
  let stroke_linecap s = At.v "stroke-linecap" s
  let stroke_linejoin s = At.v "stroke-linejoin" s
  let x s = At.v "x" s
  let y s = At.v "y" s
  let rx s = At.v "rx" s
  let d s = At.v "d" s
  let x1 s = At.v "x1" s
  let y1 s = At.v "y1" s
  let x2 s = At.v "x2" s
  let y2 s = At.v "y2" s
end

(* Aria module *)
module Aria = struct
  module At = Htmlit.At

  let label s = At.v "aria-label" s
  let labelledby s = At.v "aria-labelledby" s
  let describedby s = At.v "aria-describedby" s
  let hidden = At.v "aria-hidden" "true"
  let expanded b = At.v "aria-expanded" (string_of_bool b)
  let current s = At.v "aria-current" s
  let role s = At.v "role" s
end

let of_htmlit el = { el; tw = [] }
let to_htmlit t = t.el
let to_tw t = t.tw

(* Text helpers *)
let txt s = { el = El.txt s; tw = [] }
let txtf segments = txt (Core.Pp.str segments)
let raw s = { el = El.unsafe_raw s; tw = [] }
let rawf segments = raw (Core.Pp.str segments)

(* Empty element *)
let empty = { el = El.void; tw = [] }

(* Helper to create elements - applies tw classes immediately *)
let el_with_tw name ?at ?(tw = []) children =
  let atts = Option.value ~default:[] at in
  (* Add tw classes to attributes *)
  let atts_with_tw =
    match tw with
    | [] -> atts
    | tw_styles -> Htmlit.At.class' (Tw.to_classes tw_styles) :: atts
  in
  (* Convert children to Htmlit elements *)
  let child_els = List.map to_htmlit children in
  (* Collect all tw styles from this element and its children *)
  let all_tw = tw @ List.concat_map to_tw children in
  { el = El.v ~at:atts_with_tw name child_els; tw = all_tw }

(* Convert to string *)
let to_string ?(doctype = false) t = El.to_string ~doctype (to_htmlit t)

(* Livereload module *)
module Livereload = struct
  let enabled =
    try Sys.getenv "SITE_LIVERELOAD" = "true" with Not_found -> false

  let endpoint =
    try Sys.getenv "SITE_LIVERELOAD_ENDPOINT"
    with Not_found -> "ws://localhost:8080"

  let script =
    if enabled then
      raw
        (Core.Pp.str
           [
             "<script>\n";
             "(function() {\n";
             "  const ws = new WebSocket('";
             endpoint;
             "');\n";
             "  ws.onmessage = (event) => {\n";
             "    if (event.data === 'reload') {\n";
             "      location.reload();\n";
             "    }\n";
             "  };\n";
             "})();\n";
             "</script>";
           ])
    else empty
end

(* HTML Elements with optional Tailwind classes *)
let div ?at ?tw children = el_with_tw "div" ?at ?tw children
let span ?at ?tw children = el_with_tw "span" ?at ?tw children
let p ?at ?tw children = el_with_tw "p" ?at ?tw children
let a ?at ?tw children = el_with_tw "a" ?at ?tw children
let ul ?at ?tw children = el_with_tw "ul" ?at ?tw children
let li ?at ?tw children = el_with_tw "li" ?at ?tw children
let nav ?at ?tw children = el_with_tw "nav" ?at ?tw children
let section ?at ?tw children = el_with_tw "section" ?at ?tw children
let article ?at ?tw children = el_with_tw "article" ?at ?tw children
let header ?at ?tw children = el_with_tw "header" ?at ?tw children
let footer ?at ?tw children = el_with_tw "footer" ?at ?tw children
let h1 ?at ?tw children = el_with_tw "h1" ?at ?tw children
let h2 ?at ?tw children = el_with_tw "h2" ?at ?tw children
let h3 ?at ?tw children = el_with_tw "h3" ?at ?tw children
let h4 ?at ?tw children = el_with_tw "h4" ?at ?tw children
let h5 ?at ?tw children = el_with_tw "h5" ?at ?tw children
let h6 ?at ?tw children = el_with_tw "h6" ?at ?tw children
let script ?at ?tw children = el_with_tw "script" ?at ?tw children
let title ?at ?tw children = el_with_tw "title" ?at ?tw children
let head ?at ?tw children = el_with_tw "head" ?at ?tw children
let body ?at ?tw children = el_with_tw "body" ?at ?tw children
let root ?at ?tw children = el_with_tw "html" ?at ?tw children
let option ?at ?tw children = el_with_tw "option" ?at ?tw children
let select ?at ?tw children = el_with_tw "select" ?at ?tw children
let main ?at ?tw children = el_with_tw "main" ?at ?tw children
let aside ?at ?tw children = el_with_tw "aside" ?at ?tw children
let time ?at ?tw children = el_with_tw "time" ?at ?tw children
let dialog ?at ?tw children = el_with_tw "dialog" ?at ?tw children
let data ?at ?tw children = el_with_tw "data" ?at ?tw children
let picture ?at ?tw children = el_with_tw "picture" ?at ?tw children
let slot ?at ?tw children = el_with_tw "slot" ?at ?tw children
let template ?at ?tw children = el_with_tw "template" ?at ?tw children

(* Void elements *)
let img ?at ?(tw = []) () =
  let atts = Option.value ~default:[] at in
  let atts_with_tw =
    match tw with
    | [] -> atts
    | tw_styles -> Htmlit.At.class' (Tw.to_classes tw_styles) :: atts
  in
  { el = El.v ~at:atts_with_tw "img" []; tw }

let meta ?at ?(tw = []) () =
  let atts = Option.value ~default:[] at in
  let atts_with_tw =
    match tw with
    | [] -> atts
    | tw_styles -> Htmlit.At.class' (Tw.to_classes tw_styles) :: atts
  in
  { el = El.v ~at:atts_with_tw "meta" []; tw }

let link ?at ?(tw = []) () =
  let atts = Option.value ~default:[] at in
  let atts_with_tw =
    match tw with
    | [] -> atts
    | tw_styles -> Htmlit.At.class' (Tw.to_classes tw_styles) :: atts
  in
  { el = El.v ~at:atts_with_tw "link" []; tw }

(* Void is now an alias for empty *)
let void = empty

(* SVG element creation *)
let svg ~at children = El.v ~at "svg" children
let g ~at children = El.v ~at "g" children
let circle ~at children = El.v ~at "circle" children
let rect ~at children = El.v ~at "rect" children
let path ~at children = El.v ~at "path" children
let line ~at children = El.v ~at "line" children

(* Pretty printing *)
let pp t =
  let tw_classes = Tw.to_classes t.tw in
  let el_str = El.to_string ~doctype:false t.el in
  if tw_classes = "" then el_str
  else
    Core.Pp.str
      [ "<element with classes=\""; tw_classes; "\">"; el_str; "</element>" ]
