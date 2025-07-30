module F = Fmt
open Ui
open Html
module Fmt = F

let footer ?filter ~number_of_pages page =
  if number_of_pages = 1 then void
  else
    let url i = Core.Page.url (Core.Page.create_blog_index ?filter i) in
    let pages =
      List.init number_of_pages (fun i ->
          let i = i + 1 in
          let active = i = page in
          if active then
            span
              ~tw:[ Tw.px (Tw.Int 2); Tw.font_bold ]
              [ txt (string_of_int i) ]
          else
            a
              ~at:[ At.href (url i) ]
              ~tw:
                [
                  Tw.px (Tw.Int 2);
                  Tw.text_black;
                  Tw.underline;
                  Tw.hover (Tw.text ~shade:600 Tw.Gray);
                ]
              [ txt (string_of_int i) ])
    in
    match pages with
    | [] -> void
    | _ ->
        let prev =
          if page = 1 then []
          else
            [
              Button.render ~variant:Outline ~href:(url (page - 1)) "← Previous";
            ]
        in
        let next =
          if page = number_of_pages then []
          else
            [ Button.render ~variant:Outline ~href:(url (page + 1)) "Next →" ]
        in
        div
          ~tw:
            [
              Tw.mt (Tw.Int 16);
              Tw.text_center;
              Tw.flex;
              Tw.items_center;
              Tw.justify_center;
              Tw.gap (Tw.Int 4);
            ]
          (prev @ pages @ next)

let url ?filter page =
  Core.Page.url ~domain:true (Core.Page.create_blog_index ?filter page)

let description ~site = site.Core.Site.description

let title ?filter ~site page =
  let title =
    match filter with
    | None -> "Blog"
    | Some (Core.Blog.Tag t) -> "#" ^ t
    | Some (Author s) -> Core.Blog.author_name s ^ "'s posts"
  in
  let all =
    match page with
    | 1 -> [ site.Core.Site.name; " - "; title ]
    | i ->
        [ site.Core.Site.name; " - "; title; " (page "; string_of_int i; ")" ]
  in
  String.concat "" all

let og ?filter ~site page =
  let title = title ?filter ~site page in
  let image = Fmt.str "%s/images/favicon.ico" site.Core.Site.url in
  {
    Ui.Layout.title;
    description = Some (description ~site);
    typ = `Website;
    url = url ?filter page;
    image;
  }

(* Render hero section based on filter *)
let render_hero_section ~site filter =
  match filter with
  | None ->
      Ui.Hero.render
        {
          style = Some Simple;
          title = "Blog";
          description = description ~site;
          subtitle = None;
          palette = Ui.Colors.default_palette;
        }
  | Some (Core.Blog.Tag tag) ->
      Ui.Hero.render
        {
          style = Some Simple;
          title = "#" ^ tag;
          description = "Posts tagged with " ^ tag;
          subtitle = None;
          palette = Ui.Colors.default_palette;
        }
  | Some (Author a) ->
      let name = Core.Blog.author_name a in
      Ui.Hero.render
        {
          style = Some Simple;
          title = name;
          description = "Articles by " ^ name;
          subtitle = None;
          palette = Ui.Colors.default_palette;
        }

(* Render a single tag pill *)
let render_tag_pill tag =
  a
    ~at:
      [
        At.href
          (Core.Page.url (Core.Page.create_blog_index ~filter:(Tag tag) 1));
      ]
    ~tw:
      [
        Tw.inline_block;
        Tw.px (Tw.Int 4);
        Tw.py (Tw.Int 2);
        Tw.bg ~shade:100 Tw.Gray;
        Tw.text ~shade:700 Tw.Gray;
        Tw.rounded_full;
        Tw.text_sm;
        Tw.font_medium;
        Tw.hover (Tw.bg ~shade:100 Tw.Sky);
        Tw.hover (Tw.text ~shade:700 Tw.Sky);
        Tw.transition_all;
      ]
    [ txt ("#" ^ tag) ]

(* Render tag section for unfiltered blog page *)
let render_tag_section ~all_tags filter =
  match filter with
  | None ->
      div
        ~tw:
          [
            Tw.max_w_4xl;
            Tw.mx_auto;
            Tw.px (Int 6);
            Tw.text_center;
            Tw.mb (Int 12);
          ]
        [
          div
            ~tw:[ Tw.flex; Tw.flex_wrap; Tw.justify_center; Tw.gap (Int 2) ]
            (List.map render_tag_pill all_tags);
        ]
  | _ -> void

(* Render post header with title and date *)
let render_post_header (post : Core.Blog.t) =
  Html.div
    ~tw:
      [
        Tw.flex;
        Tw.flex_col;
        Tw.sm Tw.flex_row;
        Tw.sm Tw.items_baseline;
        Tw.sm Tw.justify_between;
        Tw.gap (Int 2);
        Tw.mb (Int 2);
      ]
    [
      Html.h3
        ~tw:[ Tw.text_xl; Tw.font_semibold ]
        [
          Html.a
            ~at:[ At.href (Fmt.str "/blog/%s/" post.slug) ]
            ~tw:
              [
                Tw.text ~shade:900 Tw.Gray;
                Tw.hover (Tw.text ~shade:700 Tw.Sky);
                Tw.transition_colors;
              ]
            [ Html.txt post.title ];
        ];
      Html.time
        ~at:[ At.datetime (Core.Blog.date post) ]
        ~tw:[ Tw.text_sm; Tw.text ~shade:500 Tw.Gray; Tw.whitespace_nowrap ]
        [ Html.txt (Core.Blog.pretty_date post) ];
    ]

(* Render post tags *)
let render_post_tags tags =
  Html.div
    ~tw:[ Tw.flex; Tw.gap (Int 2) ]
    (List.map
       (fun tag ->
         Html.a
           ~at:
             [
               At.href
                 (Core.Page.url
                    (Core.Page.create_blog_index ~filter:(Tag tag) 1));
             ]
           ~tw:
             [
               Tw.text_sm;
               Tw.text ~shade:700 Tw.Sky;
               Tw.hover (Tw.text ~shade:800 Tw.Sky);
             ]
           [ Html.txt ("#" ^ tag) ])
       tags)

(* Render a single blog post item *)
let render_blog_post_item (post : Core.Blog.t) =
  Card.render ~variant:Outlined
    [
      render_post_header post;
      Html.p
        ~tw:[ Tw.text ~shade:600 Tw.Gray; Tw.leading_relaxed; Tw.mb (Int 3) ]
        [ Html.txt post.description ];
      render_post_tags post.tags;
    ]

(* Main render function *)
let render ~site ~blog_posts:_ ~all_tags
    { Core.Blog.filter; page; posts; all_posts } =
  let posts_per_page = Option.value ~default:10 site.Core.Site.posts_per_page in
  let number_of_pages =
    let n = (List.length all_posts + posts_per_page - 1) / posts_per_page in
    if n = 0 then 1 else n
  in
  assert (page <= number_of_pages);

  let links =
    let canonical = url ?filter page in
    let prev = if page = 1 then None else Some (url ?filter (page - 1)) in
    let next =
      if page = number_of_pages then None else Some (url ?filter (page + 1))
    in
    Ui.Layout.{ canonical; next; prev }
  in

  let og = og ?filter ~site page in
  assert (og.url = links.canonical);
  let page_title = title ?filter ~site page in

  Ui.Layout.render ~title:page_title ~description:(description ~site) ~links ~og
    ~site
    (Core.Page.create_blog_index ?filter page)
    [
      render_hero_section ~site filter;
      render_tag_section ~all_tags filter;
      section
        ~tw:[ Tw.bg_white; Tw.pt (Int 8) ]
        [
          div
            ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px (Int 6) ]
            [
              div
                ~tw:[ Tw.space_y (Int 8) ]
                (List.map render_blog_post_item posts);
              footer ?filter ~number_of_pages page;
            ];
        ];
    ]

let file = __FILE__
