module F = Fmt
open Ui
open Html
open Tw
module Fmt = F

(* Return the source file path for a blog post *)
let file (blog : Core.Blog.t) = blog.path

let author (b : Core.Blog.author) =
  let author_name = Core.Blog.author_name b in
  let link_to_author = Core.Page.create_blog_index ~author:b 1 in
  a
    ~at:[ At.href (Core.Page.url link_to_author) ]
    ~tw:[ text ~shade:700 gray; on_hover [ text ~shade:900 gray ]; font_medium ]
    [ txt author_name ]

let back =
  nav
    ~tw:[ mb (int 6) ]
    [
      a
        ~at:[ At.href "/blog/" ]
        ~tw:
          [
            text ~shade:700 gray; on_hover [ text ~shade:900 gray ]; font_medium;
          ]
        [ txt "← Back to Blog" ];
    ]

let authors l =
  let author_links = List.map author l in
  match author_links with
  | [] -> void
  | [ single ] ->
      span ~tw:[ text_sm; text ~shade:600 gray ] [ txt "By "; single ]
  | multiple ->
      div
        ~tw:[ text_sm; text ~shade:600 gray ]
        (txt "By " :: List.concat_map (fun a -> [ a; txt ", " ]) multiple)

let tag str =
  let index = Core.Page.create_blog_index ~tag:str 1 in
  a
    ~at:[ At.href (Core.Page.url index) ]
    ~tw:[ text ~shade:600 gray; on_hover [ text ~shade:800 gray ]; text_sm ]
    [ txt "#"; txt str ]

let tags (item : Core.Blog.t) =
  match item.tags with
  | [] -> void
  | tags -> div ~tw:[ flex; gap (int 2) ] (List.map tag tags)

let source_links (item : Core.Blog.t) =
  match item.links with
  | [] -> void
  | links ->
      div
        ~tw:[ mt (int 2); text_sm; text ~shade:600 gray ]
        [
          txt "Originally posted on: ";
          span
            ~tw:[ inline_flex; gap (int 2) ]
            (List.mapi
               (fun i link ->
                 let platform =
                   let link_lower = String.lowercase_ascii link in
                   if Astring.String.is_infix ~affix:"linkedin" link_lower then
                     "LinkedIn"
                   else if
                     Astring.String.is_infix ~affix:"bluesky" link_lower
                     || Astring.String.is_infix ~affix:"bsky" link_lower
                   then "Bluesky"
                   else if
                     Astring.String.is_infix ~affix:"discuss.ocaml" link_lower
                   then "OCaml Discuss"
                   else if Astring.String.is_infix ~affix:"twitter" link_lower
                   then "Twitter"
                   else if Astring.String.is_infix ~affix:"github" link_lower
                   then "GitHub"
                   else "Source"
                 in
                 span
                   [
                     (if i > 0 then txt " • " else txt "");
                     a
                       ~at:[ At.href link; At.target "_blank" ]
                       ~tw:
                         [
                           text ~shade:700 gray;
                           on_hover [ text ~shade:900 gray ];
                           underline;
                         ]
                       [ txt platform ];
                   ])
               links);
        ]

let html_of_title title = String.trim title

(* Render the header section of a blog post *)
let render_header_section (blog : Core.Blog.t) =
  section
    ~tw:[ bg white; border_b; border_color ~shade:200 gray; py (int 24) ]
    [
      div
        ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
        [
          back;
          (* Title and metadata *)
          h1
            ~tw:[ text_3xl; font_bold; text ~shade:900 gray; mb (int 4) ]
            [ txt (html_of_title blog.title) ];
          div
            ~tw:
              [
                flex;
                flex_col;
                on_sm [ flex_row ];
                on_sm [ items_baseline ];
                on_sm [ justify_between ];
                gap (int 2);
                mb (int 2);
              ]
            [
              authors blog.authors;
              time
                ~at:[ At.datetime (Core.Blog.date blog) ]
                ~tw:[ text_sm; text ~shade:500 gray; whitespace_nowrap ]
                [ txt (Core.Blog.pretty_date blog) ];
            ];
          tags blog;
          source_links blog;
        ];
    ]

(* Render the content section of a blog post *)
let render_content_section (blog : Core.Blog.t) =
  section
    ~tw:[ py (int 8); bg white ]
    [
      div
        ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
        [
          div
            ~tw:[ prose; prose_gray; max_w none; mt (int 8) ]
            [ raw blog.body_html ];
        ];
    ]

let render ~site (blog : Core.Blog.t) =
  let title = blog.title in
  let description = blog.description in
  let image = Fmt.str "%s%s" site.Core.Site.url blog.image in
  let url = Fmt.str "%s/blog/%s/" site.Core.Site.url blog.slug in
  let og =
    Ui.Layout.
      { title; description = Some description; typ = `Article; image; url }
  in
  let links = Ui.Layout.{ prev = None; next = None; canonical = url } in

  Ui.Layout.render ~title ~description ~og ~links ~site
    (Core.Page.Blog_post blog)
    [ render_header_section blog; render_content_section blog ]
