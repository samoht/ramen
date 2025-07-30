module F = Fmt
open Ui
open Html
module Fmt = F

(* Return the source file path for a blog post *)
let file (blog : Core.Blog.t) = blog.path

let author (b : Core.Blog.author) =
  let author_name = Core.Blog.author_name b in
  let link_to_author = Core.Page.create_blog_index ~author:b 1 in
  a
    ~at:[ At.href (Core.Page.url link_to_author) ]
    ~tw:[ Tw.text_gray_700; Tw.hover_text_gray_900; Tw.font_medium ]
    [ txt author_name ]

let back =
  nav
    ~tw:[ Tw.mb (Int 6) ]
    [
      a
        ~at:[ At.href "/blog/" ]
        ~tw:
          [
            Tw.text ~shade:700 Gray;
            Tw.hover (Tw.text ~shade:900 Gray);
            Tw.font_medium;
          ]
        [ txt "← Back to Blog" ];
    ]

let authors l =
  let author_links = List.map author l in
  match author_links with
  | [] -> void
  | [ single ] ->
      span ~tw:[ Tw.text_sm; Tw.text ~shade:600 Gray ] [ txt "By "; single ]
  | multiple ->
      div
        ~tw:[ Tw.text_sm; Tw.text ~shade:600 Gray ]
        (txt "By " :: List.concat_map (fun a -> [ a; txt ", " ]) multiple)

let tag str =
  let index = Core.Page.create_blog_index ~tag:str 1 in
  a
    ~at:[ At.href (Core.Page.url index) ]
    ~tw:[ Tw.text_gray_600; Tw.hover (Tw.text ~shade:800 Gray); Tw.text_sm ]
    [ txt "#"; txt str ]

let tags (item : Core.Blog.t) =
  match item.tags with
  | [] -> void
  | tags -> div ~tw:[ Tw.flex; Tw.gap (Int 2) ] (List.map tag tags)

let source_links (item : Core.Blog.t) =
  match item.links with
  | [] -> void
  | links ->
      div
        ~tw:[ Tw.mt (Int 2); Tw.text_sm; Tw.text ~shade:600 Gray ]
        [
          txt "Originally posted on: ";
          span
            ~tw:[ Tw.inline_flex; Tw.gap (Int 2) ]
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
                           Tw.text_gray_700;
                           Tw.hover_text_gray_900;
                           Tw.underline;
                         ]
                       [ txt platform ];
                   ])
               links);
        ]

let html_of_title title = String.trim title

(* Render the header section of a blog post *)
let render_header_section (blog : Core.Blog.t) =
  section
    ~tw:
      [
        Tw.bg_white;
        Tw.border_b;
        Tw.border_color ~shade:200 Gray;
        Tw.py (Int 24);
      ]
    [
      div
        ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px (Int 6) ]
        [
          back;
          (* Title and metadata *)
          h1
            ~tw:[ Tw.text_3xl; Tw.font_bold; Tw.text_gray_900; Tw.mb (Int 4) ]
            [ txt (html_of_title blog.title) ];
          div
            ~tw:
              [
                Tw.flex;
                Tw.flex_col;
                Tw.sm_flex_row;
                Tw.sm Tw.items_baseline;
                Tw.sm Tw.justify_between;
                Tw.gap (Int 2);
                Tw.mb (Int 2);
              ]
            [
              authors blog.authors;
              time
                ~at:[ At.datetime (Core.Blog.date blog) ]
                ~tw:[ Tw.text_sm; Tw.text_gray_500; Tw.whitespace_nowrap ]
                [ txt (Core.Blog.pretty_date blog) ];
            ];
          tags blog;
          source_links blog;
        ];
    ]

(* Render the content section of a blog post *)
let render_content_section (blog : Core.Blog.t) =
  section
    ~tw:[ Tw.py (Int 8); Tw.bg_white ]
    [
      div
        ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px (Int 6) ]
        [
          div
            ~tw:[ Tw.prose; Tw.prose_gray; Tw.max_w_none; Tw.mt (Int 8) ]
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
