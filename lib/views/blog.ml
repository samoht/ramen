open Ui
open Html.At
open Tw

let footer ?filter ~number_of_pages page =
  if number_of_pages = 1 then Html.empty
  else
    let url i = Core.Page.url (Core.Page.create_blog_index ?filter i) in
    let pages =
      List.init number_of_pages (fun i ->
          let i = i + 1 in
          let active = i = page in
          if active then
            Html.span
              ~tw:[ px (int 2); font_bold ]
              [ Html.txt (string_of_int i) ]
          else
            Html.a
              ~at:[ href (url i) ]
              ~tw:
                [
                  px (int 2);
                  text black;
                  underline;
                  on_hover [ text ~shade:600 gray ];
                ]
              [ Html.txt (string_of_int i) ])
    in
    match pages with
    | [] -> Html.empty
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
        Html.div
          ~tw:
            [
              mt (int 16);
              text_center;
              flex;
              items_center;
              justify_center;
              gap (int 4);
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
  Html.a
    ~at:
      [ href (Core.Page.url (Core.Page.create_blog_index ~filter:(Tag tag) 1)) ]
    ~tw:
      [
        inline_block;
        px (int 4);
        py (int 2);
        bg ~shade:100 gray;
        text ~shade:700 gray;
        rounded full;
        text_sm;
        font_medium;
        on_hover [ bg ~shade:100 sky; text ~shade:700 sky ];
        transition_all;
      ]
    [ Html.txt ("#" ^ tag) ]

(* Render tag section for unfiltered blog page *)
let render_tag_section ~all_tags filter =
  match filter with
  | None ->
      Html.div
        ~tw:[ max_w xl_4; mx auto; px (int 6); text_center; mb (int 12) ]
        [
          Html.div
            ~tw:[ flex; flex_wrap; justify_center; gap (int 2) ]
            (List.map render_tag_pill all_tags);
        ]
  | _ -> Html.empty

(* Render post header with title and date *)
let render_post_header (post : Core.Blog.t) =
  Html.div
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
      Html.h3 ~tw:[ text_xl; font_semibold ]
        [
          Html.a
            ~at:[ href (Fmt.str "/blog/%s/" post.slug) ]
            ~tw:
              [
                text ~shade:900 gray;
                on_hover [ text ~shade:700 sky ];
                transition_colors;
              ]
            [ Html.txt post.title ];
        ];
      Html.time
        ~at:[ datetime (Core.Blog.date post) ]
        ~tw:[ text_sm; text ~shade:500 gray; whitespace_nowrap ]
        [ Html.txt (Core.Blog.pretty_date post) ];
    ]

(* Render post tags *)
let render_post_tags tags =
  Html.div
    ~tw:[ flex; gap (int 2) ]
    (List.map
       (fun tag ->
         Html.a
           ~at:
             [
               href
                 (Core.Page.url
                    (Core.Page.create_blog_index ~filter:(Tag tag) 1));
             ]
           ~tw:
             [ text_sm; text ~shade:700 sky; on_hover [ text ~shade:800 sky ] ]
           [ Html.txt ("#" ^ tag) ])
       tags)

(* Render a single blog post item *)
let render_blog_post_item (post : Core.Blog.t) =
  Card.render ~variant:Outlined
    [
      render_post_header post;
      Html.p
        ~tw:[ text ~shade:600 gray; leading_relaxed; mb (int 3) ]
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
      Html.section
        ~tw:[ bg white; pt (int 8) ]
        [
          Html.div
            ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
            [
              Html.div
                ~tw:[ flex; flex_col; gap (int 8) ]
                (List.map render_blog_post_item posts);
              footer ?filter ~number_of_pages page;
            ];
        ];
    ]

let file = __FILE__
