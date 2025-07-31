open Html
open Tw

type config = { main_css : string; js : string list }

type og = {
  title : string;
  description : string option;
  url : string;
  typ : [ `Website | `Article ];
  image : string;
}

type links = { prev : string option; next : string option; canonical : string }

let meta_of_og { title; description; url; typ; image } =
  let typ = match typ with `Website -> "website" | `Article -> "article" in
  let og name content_value =
    meta
      ~at:
        [ At.property (Core.Pp.str [ "og:"; name ]); At.content content_value ]
      ()
  in
  [ og "title" title; og "type" typ; og "url" url; og "image" image ]
  @ match description with None -> [] | Some d -> [ og "description" d ]

let default_og ?description ~title ~site page =
  let typ =
    match page with Core.Page.Blog_post _ -> `Article | _ -> `Website
  in
  let url = Core.Page.url ~domain:true page in
  let image = Core.Pp.str [ site.Core.Site.url; "/images/logo-1280.png" ] in
  { title; description; url; typ; image }

let href_of_file filename = filename

type t =
  | Html of { head : config -> Html.t; body : string; tw : Tw.t list }
  | Raw of string

(* Helper function to build link elements *)
let build_links ?links canonical =
  match links with
  | None -> [ link ~at:[ At.rel "canonical"; At.href canonical ] () ]
  | Some l ->
      let prev =
        match l.prev with
        | None -> []
        | Some s -> [ link ~at:[ At.rel "prev"; At.href s ] () ]
      in
      let next =
        match l.next with
        | None -> []
        | Some s -> [ link ~at:[ At.rel "next"; At.href s ] () ]
      in
      let canonical =
        [ link ~at:[ At.rel "canonical"; At.href l.canonical ] () ]
      in
      canonical @ prev @ next

(* Helper function to build meta tags *)
let build_meta_tags ?description ?og ~title ~site page =
  let twitter =
    [ meta ~at:[ At.name "twitter:card"; At.content "summary" ] () ]
  in
  let og_meta =
    match og with
    | None -> meta_of_og (default_og ?description ~title ~site page)
    | Some og -> meta_of_og og
  in
  let description_meta =
    match description with
    | None -> []
    | Some d -> [ meta ~at:[ At.name "description"; At.content d ] () ]
  in
  description_meta @ twitter @ og_meta

(* Helper function to build scripts *)
let build_scripts js =
  match js with
  | [] -> []
  | _js ->
      List.map
        (fun js_file -> script ~at:[ At.src js_file; At.v "defer" "" ] [])
        js

(* Helper function to build head elements *)
let build_head_elements ~site ~page_title { main_css; js } =
  [
    Livereload.script;
    meta ~at:[ At.charset "utf-8" ] ();
    meta
      ~at:
        [
          At.name "viewport";
          At.content "width=device-width, initial-scale=1, shrink-to-fit=no";
        ]
      ();
    meta
      ~at:
        [
          At.name "ahrefs-site-verification";
          At.content
            "5e32d11fd27a224068d9a09705a0fe2f156d88114b2d386535b721c79d921343";
        ]
      ();
    link
      ~at:
        [
          At.rel "icon";
          At.type' "image/x-icon";
          At.href (href_of_file "/images/favicon.ico");
        ]
      ();
    link ~at:[ At.rel "stylesheet"; At.href main_css ] ();
    link
      ~at:[ At.rel "stylesheet"; At.href (href_of_file "/css/syntax.css") ]
      ();
    link
      ~at:
        [
          At.rel "alternate";
          At.type' "application/rss+xml";
          At.title' (Core.Pp.str [ site.Core.Site.name; " RSS Feed" ]);
          At.href "/feed.xml";
        ]
      ();
    title [ txt (Core.Pp.str [ site.Core.Site.title; " | "; page_title ]) ];
  ]
  @ build_scripts js

let render ~title ?description ?og ?links ~site page inner =
  let canonical =
    match links with
    | Some l -> l.canonical
    | None -> Core.Page.url ~domain:true page
  in
  let link_elems = build_links ?links canonical in
  let meta_elems = build_meta_tags ?description ?og ~title ~site page in

  let headers config =
    build_head_elements ~site ~page_title:title config @ meta_elems @ link_elems
  in

  let head config = head (headers config) in
  let body_html =
    body
      ~tw:[ antialiased; min_h screen ]
      [
        Header.render
          {
            menu = None;
            active_page = Some page;
            site;
            palette = Colors.default_palette;
          };
        div
          ~tw:[ min_h screen; flex; flex_col ]
          [
            main ~tw:[ isolate; flex ] inner;
            Footer.render { site; palette = Colors.default_palette };
          ];
      ]
  in
  let tw = Html.to_tw body_html in
  let body = Html.to_string body_html in
  Html { head; body; tw }

let raw s = Raw s

let to_string config = function
  | Raw s -> s
  | Html { head; body = body_content; _ } ->
      let head_el = head config in
      Html.to_string ~doctype:true
        (Html.root
           ~at:[ At.lang "en" ]
           [ head_el; Html.body ~at:[] [ Html.raw body_content ] ])

let to_tw = function Raw _ -> [] | Html { tw; _ } -> tw

let pp_config config =
  Core.Pp.record
    [
      ("main_css", Core.Pp.quote config.main_css);
      ("js", Core.Pp.list Core.Pp.quote config.js);
    ]

let pp_og og =
  Core.Pp.record
    [
      ("title", Core.Pp.quote og.title);
      ("description", Core.Pp.option Core.Pp.quote og.description);
      ("url", Core.Pp.quote og.url);
      ( "typ",
        match og.typ with
        | `Website -> "\"Website\""
        | `Article -> "\"Article\"" );
      ("image", Core.Pp.quote og.image);
    ]

let pp_links links =
  Core.Pp.record
    [
      ("prev", Core.Pp.option Core.Pp.quote links.prev);
      ("next", Core.Pp.option Core.Pp.quote links.next);
      ("canonical", Core.Pp.quote links.canonical);
    ]

let pp = function
  | Raw s -> Core.Pp.str [ "Raw "; Core.Pp.quote s ]
  | Html { body; tw; _ } ->
      Core.Pp.record
        [
          ("body", Core.Pp.str [ "length="; Core.Pp.int (String.length body) ]);
          ("tw", Core.Pp.str [ "classes="; Core.Pp.int (List.length tw) ]);
        ]
